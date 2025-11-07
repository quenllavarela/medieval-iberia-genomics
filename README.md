# Scripts for Medieval Ibiza Genomics Paper

This folder contains the scripts used for filtering, merging, and preparing genomic datasets for population genetic and local ancestry analyses described in:

**"Genetic Diversity and Health in Medieval Islamic Ibiza: Unveiling North African, European, and Sub-Saharan Ancestries"**

---

## **1. Overview of Scripts**

| Script | Purpose | Inputs | Outputs |
|--------|---------|--------|---------|
| `01_filter_and_merge.sh` | Filters ancient (Ibiza) and modern (Koenig/1K-HGDP) datasets, harmonizes SNPs, removes duplicates, and merges datasets. Prepares final PLINK files and VCF. | - Ibiza VCF (ancient samples)<br>- Koenig/1K-HGDP VCF (modern reference panel) | - Merged PLINK files (`.bed`, `.bim`, `.fam`)<br>- Filtered VCFs ready for RFMix |
| `02_prepare_rfmix_inputs.sh` | Generates input files for RFMix v1.5.4: phased alleles, SNP positions, class files, and per-chromosome splits. | - Merged VCF from `01_filter_and_merge.sh`<br>- Sample list for RFMix (`samplelist_simple.txt`) | - Allele files<br>- SNP position files<br>- Class file<br>- Chromosome-specific allele and SNP files |
| `convert_to_cM.py` | Converts SNP positions (bp) to genetic positions (cM) using a recombination map. Generates per-chromosome cM files for RFMix input. | - Per-chromosome SNP positions (`chr1.txt`, ..., `chr22.txt`)<br>- Per-chromosome recombination maps (`chr1.b38.txt`, ..., `chr22.b38.txt`) | - Per-chromosome cM files (`chr1_snps_only_cM.txt`, ..., `chr22_snps_only_cM.txt`) | 
| `cov_decay_Eivissa_published.R` | Compute generations sicne admixture from the decay of local ancestry covariance | fb from RFMix output: `s.all_1.0.ForwardBackward.txt`, ..., `s.all_22.0.ForwardBackward.txt`; genetic map (1 column, cM position in the chromosome of each SNP): `chr1_snps_only_cM.txt`, ... , `chr22_snps_only_cM.txt`; targets_date_include.txt: three tab separated columns (ind label \t date \t include or not(1/0) | `generations_cov.txt` generations since admixture, individual-based and population-based ; `plot_cov_decay.pdf`: plot with individual-based and population-based covariance decay |







