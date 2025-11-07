library(data.table)
library(dplyr)
library(tidyr)
library(furrr)
library(purrr)
library(ggplot2)
library(nls2)
options(mc.cores = parallel::detectCores())
nodes <- parallel::detectCores()
setwd("~/")
nanc<-2
snps_within_chr<-0.005
width_i_r<-0.001
minr<-0.005
n_groups<-100
targets_C14<-fread("targets_date_include.txt") %>% rename("ind"=V1,"C14_date"=V2,"yesno"=V3)
mean_date<-floor(targets_C14 %>% filter(yesno==1) %>% summarise(date=mean(C14_date))) %>% unlist()

cor_parallel <- function(mat1,mat2,n_blocks) {
  larger_matrix<-list(mat1,mat2)[[which.max(c(ncol(mat1),ncol(mat2)))]]
  n_blocks=min(n_blocks,floor(ncol(larger_matrix)/2))
  n_blocks=ifelse(n_blocks==0,1,n_blocks)
  larger_matrix_blocks <- split.default(data.table(larger_matrix),rep(1:n_blocks, each = floor(ncol(larger_matrix)/n_blocks), length.out = ncol(larger_matrix)))
  smaller_matrix <- list(mat1,mat2)[[which(!(c(1,2) %in% which.max(c(ncol(mat1),ncol(mat2)))))]]
  smaller_matrix_multiple <- lapply(c(1:n_blocks),function(i)smaller_matrix)
  first_matrix<-if(which.max(c(ncol(mat1),ncol(mat2)))==1){larger_matrix_blocks}else{smaller_matrix_multiple}
  second_matrix<-if(which.max(c(ncol(mat1),ncol(mat2)))==2){larger_matrix_blocks}else{smaller_matrix_multiple}
  cor_blocks <- future_map2(first_matrix, second_matrix, ~ cor(.x, .y,use = "pairwise.complete.obs"))
  cor_matrices <- lapply(cor_blocks,function(x)as.matrix(x))
  if (which.max(c(ncol(mat1),ncol(mat2)))==1) {
    cor_matrix <- do.call(rbind, cor_matrices)
  } else {
    cor_matrix <- do.call(cbind, cor_matrices)
  }
  return(cor_matrix)
}

cov_parallel <- function(mat1,mat2,n_blocks) {
  larger_matrix<-list(mat1,mat2)[[which.max(c(ncol(mat1),ncol(mat2)))]]
  n_blocks=min(n_blocks,floor(ncol(larger_matrix)/2))
  n_blocks=ifelse(n_blocks==0,1,n_blocks)
  larger_matrix_blocks <- split.default(data.table(larger_matrix),rep(1:n_blocks, each = floor(ncol(larger_matrix)/n_blocks), length.out = ncol(larger_matrix)))
  smaller_matrix <- list(mat1,mat2)[[which(!(c(1,2) %in% which.max(c(ncol(mat1),ncol(mat2)))))]]
  smaller_matrix_multiple <- lapply(c(1:n_blocks),function(i)smaller_matrix)
  first_matrix<-if(which.max(c(ncol(mat1),ncol(mat2)))==1){larger_matrix_blocks}else{smaller_matrix_multiple}
  second_matrix<-if(which.max(c(ncol(mat1),ncol(mat2)))==2){larger_matrix_blocks}else{smaller_matrix_multiple}
  cov_blocks <- future_map2(first_matrix, second_matrix, ~ cov(.x, .y,use = "pairwise.complete.obs"))
  cov_matrices <- lapply(cov_blocks,function(x)as.matrix(x))
  if (which.max(c(ncol(mat1),ncol(mat2)))==1) {
    cov_matrix <- do.call(rbind, cov_matrices)
  } else {
    cov_matrix <- do.call(cbind, cov_matrices)
  }
  return(cov_matrix)
}



n_groups<-100
cov_r_prop <- c()
chromosomes <- c(1:22)
cov_r_prop <- lapply(1:n_groups, function(i){
  all_covariances<-c()
  all_total<-c()
  all_anc<-c()
  for (chromosome in chromosomes) { 
    fb<-fread(paste0("s.all_",chromosome,".0.ForwardBackward.txt"),header = FALSE,quote = FALSE)
    gm<-fread(paste0("chr",chromosome,"_snps_only_cM.txt"), header = FALSE,quote = FALSE)
    total_snps<-nrow(fb)
    sampled_snps<-sort(sample(c(1:total_snps),round(snps_within_chr*total_snps),replace = FALSE))
    fb_sample<-fb[sampled_snps,]
    gm_sample<-gm[sampled_snps,]
    nsnps<-nrow(fb_sample)
    nind<-ncol(fb_sample)/(2*nanc)
    snps_cM<-data.frame(SNP=paste0("SNP.",c(1:(nsnps))),cM=as.vector(gm_sample))
    names(snps_cM)<-c("SNP","cM")
    ind_hap_anc<-as.data.frame(rbind(rep(rep(c(1:nind),each=4)),
        rep(rep(c(1,2),each=nanc),nind),
        rep(rep(c(0:(nanc-1)),2),nind))) 
    
    fb_indhapanc<-rbind(ind_hap_anc,fb_sample) %>%  mutate(var=c("ind","hap","anc",paste0("SNP.",c(1:(nsnps)))))
    maxanc_df <- fb_indhapanc %>% 
      pivot_longer(-var) %>% 
      pivot_wider(names_from=var,values_from=value) %>%
      select(-name) %>%
      pivot_longer(cols=paste0("SNP.",c(1:(nsnps))),names_to="SNP",values_to="prob") %>% 
      group_by(ind,hap,SNP) %>% filter(prob==max(prob)) %>% 
      mutate(maxanc_filt=ifelse(prob>0.9,anc,NA),SNP=as.numeric(gsub("SNP.","",SNP))) %>%
      filter(ind %in% which(targets_C14$yesno==1))
    genotypes<-maxanc_df %>% select(ind,hap,SNP,maxanc_filt) %>% 
      arrange(ind,hap,SNP) %>% 
      mutate(ind_hap=paste(ind,hap,sep="_"))   %>%
      group_by() %>% select(-c(ind,hap)) %>% 
      pivot_wider(names_from=SNP,values_from=maxanc_filt,names_prefix = "SNP.") %>%
      select(-ind_hap) 
    anc<-rowSums(genotypes,na.rm=TRUE)
    total<-rowSums(!is.na(genotypes))
    inds_genotyped=colSums(!is.na(as.matrix(genotypes)))
    af=colSums(as.matrix((genotypes)),na.rm=TRUE)/(colSums(!is.na(as.matrix(genotypes))))
    maf=ifelse(af<0.5,af,1-af)
    print(chromosome)
    covariance_within = cov_parallel(genotypes,genotypes,nodes/2)
    covariance_within_inds<-lapply(c(1:nind),function(ind)cov_parallel(genotypes[c((ind*2-1):(ind*2)),],genotypes[c((ind*2-1):(ind*2)),],nodes/2))
    covariance_within_long = expand.grid(rownames(covariance_within),colnames(covariance_within))
    colnames(covariance_within_long) = c("SNPA","SNPB")
    covariance_within_long = covariance_within_long
    covariance_within_long$global<-as.vector(covariance_within)
    covariance_within_long <- covariance_within_long %>%
      bind_cols(as_tibble(sapply(c(1:nind),function(ind)as.vector(covariance_within_inds[[ind]])), .name_repair = ~paste0("ind", seq_along(.))))
    covariance_within_long_df = covariance_within_long  %>% 
      left_join(snps_cM  %>%
                  rename(SNPA = SNP,cMA=cM),
                by=c("SNPA")) %>%
      left_join(snps_cM  %>%
                  rename(SNPB = SNP,cMB=cM),
                by=c("SNPB"))  %>%
      filter(cMA>cMB) %>%
      mutate(chr=chromosome,
             cM_distance=abs(cMA-cMB),
             r=(1-exp(-2*cM_distance/100))/2)%>%
      filter(SNPA!=SNPB,
             r>minr,
             !(is.na(global))) %>%
      group_by()
    all_covariances<-rbind(all_covariances,covariance_within_long_df)
    all_anc<-rbind(all_anc,anc)
    all_total<-rbind(all_total,total)
    print(paste0("cov parallel chr ",chromosome, ", sample ",i," done"))
  }
  cov_r_i<-all_covariances %>%
    group_by(interval_r = cut(r, breaks= seq(0,  0.5, by = width_i_r),labels=FALSE)) %>%
    mutate(interval_r=ifelse(r==0.5,0.5,(interval_r-0.5)* width_i_r)) %>%
    filter(interval_r<0.4) %>%
    filter(interval_r>0.005) %>%
    group_by(interval_r) %>%
    summarise(across(c("global",paste0("ind",c(1:nind))), ~ mean(.x, na.rm = TRUE))) %>%
    pivot_longer(cols=c("global",paste0("ind",c(1:nind))),values_to="cov",names_to="ind") %>%
    group_by(interval_r,ind)%>%
    filter(!is.na(cov)) %>% 
    mutate(i=i)
  adm_prop<-c(colSums(all_anc)/colSums(all_total),i)
  return(list(cov_r_i,adm_prop))
  })

cov_r<-do.call(rbind, lapply(cov_r_prop, `[[`, 1))
adm_prop <- as.data.frame(do.call(rbind, lapply(cov_r_prop, `[[`, 2)))
colnames(adm_prop)<-c(paste(paste0("ind",rep(1:((ncol(adm_prop)-1)/2),each=2)),rep(c(1:2),(ncol(adm_prop)-1)/2),sep="."),"i")
alpha <- adm_prop %>% filter(i==1) %>% select(-i) %>% as.numeric() %>% mean()
nind<-length(unlist(unique(cov_r %>% filter (ind!="global") %>% group_by() %>% select(ind))))

model_cov<- lapply(c(1:n_groups),function(sampling){
  lapply(c("global",paste0("ind",c(1:nind))),function(individual){
  model_fit<-NULL
  attempts<-0
  while(is.null(model_fit)&(attempts<50)){
    attempts=attempts+1
    model_fit <- 
      tryCatch({cov_r %>%
          filter(i==sampling) %>%
          filter(ind==individual) %>%
          mutate(y=cov,
                 x=1-interval_r) %>% nls2(formula=y~A*x^g+C,start=list(g=sample(size=1,c(1:50)),A=0.01,C=0.01),lower=list(-1,0,-1),upper=list(1000,1,1),trace=TRUE,algorithm = "port")
                 #x=1-interval_r) %>% nls2(formula=y~alpha*(1-alpha)*x^g+C,start=list(g=20,C=0.01),lower=list(-1,-1),upper=list(1000,1),trace=TRUE,algorithm = "port")
        
        },
      error = function(e) {
        NULL
      })
    attempts=attempts+1
  }
  return(c(coef(model_fit),individual,sampling))})}
)
coefs_cov<-as.data.frame(do.call(rbind,lapply(c(1:(nind+1)), function(ind) as.data.frame(do.call(rbind, lapply(model_cov, `[[`, ind))) %>% filter(!grepl("ind", .[[1]])))) )
colnames(coefs_cov)<-c("g","A","C","ind","i")
all_coefs_cov<-coefs_cov %>%  group_by(ind) %>% 
  mutate(g=as.numeric(g)) %>% 
  summarise(mean=mean(g,na.rm=TRUE),
            min=min(g,na.rm=TRUE),
            Q025=quantile(g, probs = 0.025,na.rm=TRUE),
            median=median(g,na.rm=TRUE),
            Q975=quantile(g, probs = 0.975,na.rm=TRUE),
            max=max(g,na.rm=TRUE)) %>%
    mutate(date=as.character(mean_date),
           sample_code=c("global",targets_C14 %>% filter(yesno==1) %>% select(ind) %>% unlist()))

fwrite(all_coefs_cov,file="generations_cov.txt",sep="\t",quote=FALSE,col.names=TRUE)


###plots


fitted_cov_r <-coefs_cov %>% group_by(ind) %>% 
                                      mutate(g=as.numeric(g),A=as.numeric(A),C=as.numeric(C)) %>% 
                                      summarise_at(c("g","A","C"),mean,na.rm=TRUE)%>% 
                                      mutate(date=ifelse(ind=="global","global",as.character(mean_date)),
                                             sample_code=c("global",targets_C14 %>% filter(yesno==1) %>% select(ind) %>% unlist())) %>%
  mutate(dateplot=ifelse(ind=="global",ind,sample_code))

cov_r_global_2groups_plot <- as.data.frame(rbind(
                                   cov_r %>% filter(i==1) %>% 
                                     filter(ind=="global")%>%
                                     group_by(ind,interval_r) %>% summarise(cov=mean(cov)) %>%
                                     mutate(date="global") %>% left_join(all_coefs_cov %>% select(ind,date,sample_code),by=c("ind","date")),  
                                   cov_r %>% filter(i==1) %>%
                                     filter(ind!="global")%>% 
                                     group_by(ind,interval_r) %>% summarise(cov=mean(cov)) %>% 
                                     mutate(date=as.character(mean_date)) %>% left_join(all_coefs_cov %>% select(ind,date,sample_code),by=c("ind","date")))) %>%                         
  mutate(dateplot=ifelse(ind=="global",ind,sample_code),
         date=as.factor(date))
r_plot<-seq(0,0.4,0.01)
fitted_cov_r_global_2groups_plot<-fitted_cov_r %>%
  slice(rep(1:n(), each = length(r_plot))) %>%
  mutate(r = rep(r_plot, times = nrow(fitted_cov_r)),
         cov=A*(1-r)^g+C,
         dateplot=ifelse(ind=="global",ind,sample_code),
         date=as.factor(date),
         line=ifelse(ind=="global",2,1))

label_df <- fitted_cov_r_global_2groups_plot %>%
  group_by(sample_code,date,dateplot) %>%
  summarise(y = max(cov)) %>% mutate(x=1) %>% 
  left_join(all_coefs_cov %>% select(-date,-ind) ,by="sample_code") %>%
  mutate(text=paste0("g = ",round(mean,2)," (",round(Q025,2),", ",round(Q975,2),")"))

plot_cov_decay<-ggplot() +
  geom_point(data=cov_r_global_2groups_plot ,aes(x=(1-interval_r),y=cov,group=sample_code,color=date),alpha=0.3,size=0.5)+
  geom_line(data=fitted_cov_r_global_2groups_plot ,aes(x=(1-r),y=cov,group=sample_code,color=date,linewidth =line,linetype = as.factor(line)))+
  scale_linewidth_continuous(range=c(0.4,1.2))+
  scale_linetype_manual(values=c("dashed","solid"))+
  scale_color_manual(values=c("#FF6F59","#254441"))+
  geom_text(data = label_df , aes(label = text ,x=x,y=y,color=date), hjust = 1,nudge_x=0.01)+
  ylim(-0.1,0.4)+
  xlim(0.6,1.01)+
  guides(
    color = "none",    
    linetype = "none",
    linewidth = "none",  
    size = "none",
    fill = "none"
  )+
  facet_wrap(~dateplot,ncol=3)+
  theme(aspect.ratio=1) +
  theme_minimal()

ggsave(plot=plot_cov_decay,file=paste0("plot_cov_decay.pdf"))








