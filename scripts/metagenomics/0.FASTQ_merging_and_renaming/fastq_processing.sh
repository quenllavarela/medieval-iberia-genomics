# Here are the exact commands that were used to keep separated or split the three fastq files that were too heavy for MALT on our server
# Renaming to archaeological IDs happened afterwards

# ldo128
cat ldo128-b1e1l1p1_AAGCTAA-ATGGCGG_L002_CutAdapt-eq_set-FLASH_corrected.200525_A00621_0231_BHMC7VDRXX.all.fastq.gz ldo128-b1e1l1p1_AAGCTAA-ATGGCGG_L004_CutAdapt-eq_set-FLASH_corrected.210602_A00621_0414_AH5LKFDSX2.all.fastq.gz > ldo128-b1e1l1p1_B.fastq.gz

mv ldo128-b1e1l1p1_AAGCTAA-ATGGCGG_L004_CutAdapt-eq_set-FLASH_corrected.201215_A00187_0399_AHGNGCDSXY.all.fastq.gz ldo128-b1e1l1p1_A.fastq.gz

# ldo136
mv ldo136-b1e1l1p1_TTCAACC-ACTCATT_L002_CutAdapt-eq_set-FLASH_corrected.220701_A00621_0713_BHNWWKDSX3.all.fastq.gz ldo136-b1e1l1p1_A.fastq.gz

mv ldo136-b1e1l1p1_TTCAACC-ACTCATT_L004_CutAdapt-eq_set-FLASH_corrected.220816_A01901_0021_AHK3JYDSX3.all.fastq.gz ldo136-b1e1l1p1_B.fastq.gz

cat ldo136-b1e1l1p1_TTCAACC-AATGAGT_L002_CutAdapt-eq_set-FLASH_corrected.200525_A00621_0231_BHMC7VDRXX.all.fastq.gz ldo136-b1e1l1p1_TTCAACC-AATGAGT_L004_CutAdapt-eq_set-FLASH_corrected.210602_A00621_0414_AH5LKFDSX2.all.fastq.gz > ldo136-b1e1l1p1_C.fastq.gz

cat ldo136-b1e1l1p1_TTCAACC-AATGAGT_L001_CutAdapt-eq_set-FLASH_corrected.200624_A00187_0321_BHFC3HDSXY.all.fastq.gz ldo136-b1e1l1p1_TTCAACC-AATGAGT_L004_CutAdapt-eq_set-FLASH_corrected.201215_A00187_0399_AHGNGCDSXY.all.fastq.gz > ldo136-b1e1l1p1_D.fastq.gz

# ldo124 (both entry fastqs were a screening run and a deep sequencing run, so we split the large one into two files of similar size and merged one with the screening file)
zcat ldo124-b1e1l1p1_AATAGTA-TTATGAT_L001_CutAdapt-eq_set-FLASH_corrected.200624_A00187_0321_BHFC3HDSXY.all.fastq.gz | \
split -d -l 755507512 - ldo124-b1e1l1p1_
mv ldo124-b1e1l1p1_00 ldo124-b1e1l1p1_A.fastq
mv ldo124-b1e1l1p1_01 ldo124-b1e1l1p1_B.fastq
gzip ldo124-b1e1l1p1_A.fastq
gzip ldo124-b1e1l1p1_B.fastq
cat ldo124-b1e1l1p1_B.fastq.gz ldo124-b1e1l1p1_AATAGTA-TTATGAT_L002_CutAdapt-eq_set-FLASH_corrected.200525_A00621_0231_BHMC7VDRXX.all.fastq.gz > ldo124-b1e1l1p1_B_merged.fastq.gz
mv ldo124-b1e1l1p1_B_merged.fastq.gz ldo124-b1e1l1p1_B.fastq.gz
