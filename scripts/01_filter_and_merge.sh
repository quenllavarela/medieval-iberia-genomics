#!/bin/bash

# -----------------------------------------------------------------------------
# 01_filter_and_merge.sh
#
# Updated, cleaned, and corrected version of the filtering and merging workflow
# used in the study to combine imputed ancient Ibiza genomes with a modern
# reference panel.
#
# This script preserves the main analytical logic of the executed pipeline
# while simplifying file-specific intermediate steps and improving robustness
# and readability.
#
# Main outputs:
#   1. merged PLINK dataset
#   2. merged datasets filtered at MAF 0.01 and 0.05
#   3. SNP-matched VCFs for downstream analyses such as RFMix
#
# Required software:
#   bcftools
#   tabix
#   plink
# -----------------------------------------------------------------------------

set -euo pipefail

# === Modules (optional; comment out if not on HPC) ===
ml bioinfo-tools
ml bcftools
ml tabix
ml plink

# === User-defined input files ===
# Ibiza dataset should already be filtered to retain genotypes with GP >= 0.99.
# KOENIG_VCF can be a .vcf.gz or .bcf file readable by bcftools.
IBIZA_VCF="/path/to/ibiza.vcf.gz"
KOENIG_VCF="/path/to/koenig.bcf"

# === Prefixes ===
IBIZA_PREFIX="ibiza"
KOENIG_PREFIX="koenig"
MERGED_PREFIX="merged.GP99_dataset"

# === Thresholds ===
INITIAL_MAF_IBIZA=0.01
INITIAL_MAF_KOENIG=0.05

IBIZA_MIND=0.15
IBIZA_GENO=0.20
IBIZA_MAF=0.01

KOENIG_MIND=0.15
KOENIG_GENO=0.20
KOENIG_MAF=0.05

# -----------------------------------------------------------------------------
# Step 1: Filter Ibiza dataset
# -----------------------------------------------------------------------------
echo "Filtering Ibiza dataset..."

bcftools view -m2 -M2 -v snps "$IBIZA_VCF" -Oz -o "${IBIZA_PREFIX}.biallelic.vcf.gz"
bcftools index -f "${IBIZA_PREFIX}.biallelic.vcf.gz"

bcftools view -i "MAF[0] >= ${INITIAL_MAF_IBIZA}" \
    "${IBIZA_PREFIX}.biallelic.vcf.gz" \
    -Oz -o "${IBIZA_PREFIX}.biallelic.maf01.vcf.gz"
tabix -f -p vcf "${IBIZA_PREFIX}.biallelic.maf01.vcf.gz"

plink --vcf "${IBIZA_PREFIX}.biallelic.maf01.vcf.gz" \
      --make-bed \
      --out "${IBIZA_PREFIX}.biallelic"

plink --bfile "${IBIZA_PREFIX}.biallelic" \
      --mind ${IBIZA_MIND} \
      --make-bed \
      --out "${IBIZA_PREFIX}.mind"

plink --bfile "${IBIZA_PREFIX}.mind" \
      --geno ${IBIZA_GENO} \
      --make-bed \
      --out "${IBIZA_PREFIX}.geno"

plink --bfile "${IBIZA_PREFIX}.geno" \
      --maf ${IBIZA_MAF} \
      --make-bed \
      --out "${IBIZA_PREFIX}.final"

# -----------------------------------------------------------------------------
# Step 2: Filter Koenig dataset
# -----------------------------------------------------------------------------
echo "Filtering Koenig dataset..."

bcftools view -m2 -M2 -v snps "$KOENIG_VCF" -Oz -o "${KOENIG_PREFIX}.biallelic.vcf.gz"
bcftools index -f "${KOENIG_PREFIX}.biallelic.vcf.gz"

bcftools view -i "MAF[0] >= ${INITIAL_MAF_KOENIG}" \
    "${KOENIG_PREFIX}.biallelic.vcf.gz" \
    -Oz -o "${KOENIG_PREFIX}.biallelic.maf05.vcf.gz"
tabix -f -p vcf "${KOENIG_PREFIX}.biallelic.maf05.vcf.gz"

plink --vcf "${KOENIG_PREFIX}.biallelic.maf05.vcf.gz" \
      --make-bed \
      --out "${KOENIG_PREFIX}.biallelic"

plink --bfile "${KOENIG_PREFIX}.biallelic" \
      --mind ${KOENIG_MIND} \
      --make-bed \
      --out "${KOENIG_PREFIX}.mind"

plink --bfile "${KOENIG_PREFIX}.mind" \
      --geno ${KOENIG_GENO} \
      --make-bed \
      --out "${KOENIG_PREFIX}.geno"

plink --bfile "${KOENIG_PREFIX}.geno" \
      --maf ${KOENIG_MAF} \
      --make-bed \
      --out "${KOENIG_PREFIX}.final"

# -----------------------------------------------------------------------------
# Step 3: Rename SNP IDs to CHR:POS
# -----------------------------------------------------------------------------
echo "Renaming SNP IDs to CHR:POS..."

awk 'BEGIN{OFS="\t"} {$2=$1":"$4; print}' \
    "${IBIZA_PREFIX}.final.bim" > "${IBIZA_PREFIX}.chrpos.bim"
cp "${IBIZA_PREFIX}.final.bed" "${IBIZA_PREFIX}.chrpos.bed"
cp "${IBIZA_PREFIX}.final.fam" "${IBIZA_PREFIX}.chrpos.fam"

awk 'BEGIN{OFS="\t"} {$2=$1":"$4; print}' \
    "${KOENIG_PREFIX}.final.bim" > "${KOENIG_PREFIX}.chrpos.bim"
cp "${KOENIG_PREFIX}.final.bed" "${KOENIG_PREFIX}.chrpos.bed"
cp "${KOENIG_PREFIX}.final.fam" "${KOENIG_PREFIX}.chrpos.fam"

# -----------------------------------------------------------------------------
# Step 4: Identify shared SNPs
# -----------------------------------------------------------------------------
echo "Identifying shared SNPs..."

cut -f2 "${IBIZA_PREFIX}.chrpos.bim" | sort -u > "${IBIZA_PREFIX}.snps.txt"
cut -f2 "${KOENIG_PREFIX}.chrpos.bim" | sort -u > "${KOENIG_PREFIX}.snps.txt"

comm -12 "${IBIZA_PREFIX}.snps.txt" "${KOENIG_PREFIX}.snps.txt" > common_snps.txt

plink --bfile "${IBIZA_PREFIX}.chrpos" \
      --extract common_snps.txt \
      --make-bed \
      --out "${IBIZA_PREFIX}.common"

plink --bfile "${KOENIG_PREFIX}.chrpos" \
      --extract common_snps.txt \
      --make-bed \
      --out "${KOENIG_PREFIX}.common"

# -----------------------------------------------------------------------------
# Step 5: Remove duplicated SNP IDs if present
# -----------------------------------------------------------------------------
echo "Removing duplicated SNP IDs if needed..."

awk '{print $2}' "${IBIZA_PREFIX}.common.bim" | sort | uniq -d > "${IBIZA_PREFIX}.dup.txt"
awk '{print $2}' "${KOENIG_PREFIX}.common.bim" | sort | uniq -d > "${KOENIG_PREFIX}.dup.txt"

if [ -s "${IBIZA_PREFIX}.dup.txt" ]; then
    plink --bfile "${IBIZA_PREFIX}.common" \
          --exclude "${IBIZA_PREFIX}.dup.txt" \
          --make-bed \
          --out "${IBIZA_PREFIX}.nodup"
else
    cp "${IBIZA_PREFIX}.common.bed" "${IBIZA_PREFIX}.nodup.bed"
    cp "${IBIZA_PREFIX}.common.bim" "${IBIZA_PREFIX}.nodup.bim"
    cp "${IBIZA_PREFIX}.common.fam" "${IBIZA_PREFIX}.nodup.fam"
fi

if [ -s "${KOENIG_PREFIX}.dup.txt" ]; then
    plink --bfile "${KOENIG_PREFIX}.common" \
          --exclude "${KOENIG_PREFIX}.dup.txt" \
          --make-bed \
          --out "${KOENIG_PREFIX}.nodup"
else
    cp "${KOENIG_PREFIX}.common.bed" "${KOENIG_PREFIX}.nodup.bed"
    cp "${KOENIG_PREFIX}.common.bim" "${KOENIG_PREFIX}.nodup.bim"
    cp "${KOENIG_PREFIX}.common.fam" "${KOENIG_PREFIX}.nodup.fam"
fi

# -----------------------------------------------------------------------------
# Step 6: Merge datasets
# -----------------------------------------------------------------------------
echo "Merging datasets..."

plink --bfile "${KOENIG_PREFIX}.nodup" \
      --bmerge "${IBIZA_PREFIX}.nodup.bed" "${IBIZA_PREFIX}.nodup.bim" "${IBIZA_PREFIX}.nodup.fam" \
      --make-bed \
      --out "${MERGED_PREFIX}" || true

if [ -f "${MERGED_PREFIX}-merge.missnp" ]; then
    echo "Merge conflicts detected. Excluding problematic SNPs and retrying..."

    plink --bfile "${IBIZA_PREFIX}.nodup" \
          --exclude "${MERGED_PREFIX}-merge.missnp" \
          --make-bed \
          --out "${IBIZA_PREFIX}.mergefix"

    plink --bfile "${KOENIG_PREFIX}.nodup" \
          --exclude "${MERGED_PREFIX}-merge.missnp" \
          --make-bed \
          --out "${KOENIG_PREFIX}.mergefix"

    plink --bfile "${KOENIG_PREFIX}.mergefix" \
          --bmerge "${IBIZA_PREFIX}.mergefix.bed" "${IBIZA_PREFIX}.mergefix.bim" "${IBIZA_PREFIX}.mergefix.fam" \
          --make-bed \
          --out "${MERGED_PREFIX}"
fi

if [ ! -f "${MERGED_PREFIX}.bim" ]; then
    echo "ERROR: merge failed and ${MERGED_PREFIX}.bim was not created." >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Step 7: Generate merged datasets with different MAF thresholds
# -----------------------------------------------------------------------------
echo "Generating merged datasets with MAF thresholds..."

plink --bfile "${MERGED_PREFIX}" \
      --maf 0.01 \
      --make-bed \
      --out "${MERGED_PREFIX}.maf0.01"

plink --bfile "${MERGED_PREFIX}" \
      --maf 0.05 \
      --make-bed \
      --out "${MERGED_PREFIX}.maf0.05"

# -----------------------------------------------------------------------------
# Step 8: Prepare final VCFs for downstream analyses
# -----------------------------------------------------------------------------
echo "Preparing final SNP-matched VCFs..."

cut -f2 "${MERGED_PREFIX}.bim" > snpstoextractvcf.txt

zcat "${IBIZA_PREFIX}.biallelic.vcf.gz" | \
awk 'BEGIN {OFS="\t"} /^#/ {print; next} {$3=$1":"$2; print}' | \
bgzip > "${IBIZA_PREFIX}.biallelic.chrpos.vcf.gz"
tabix -f -p vcf "${IBIZA_PREFIX}.biallelic.chrpos.vcf.gz"

zcat "${KOENIG_PREFIX}.biallelic.vcf.gz" | \
awk 'BEGIN {OFS="\t"} /^#/ {print; next} {$3=$1":"$2; print}' | \
bgzip > "${KOENIG_PREFIX}.biallelic.chrpos.vcf.gz"
tabix -f -p vcf "${KOENIG_PREFIX}.biallelic.chrpos.vcf.gz"

bcftools view -i 'ID=@snpstoextractvcf.txt' \
    "${IBIZA_PREFIX}.biallelic.chrpos.vcf.gz" \
    -Oz -o "${IBIZA_PREFIX}.final.vcf.gz"
tabix -f -p vcf "${IBIZA_PREFIX}.final.vcf.gz"

bcftools view -i 'ID=@snpstoextractvcf.txt' \
    "${KOENIG_PREFIX}.biallelic.chrpos.vcf.gz" \
    -Oz -o "${KOENIG_PREFIX}.final.vcf.gz"
tabix -f -p vcf "${KOENIG_PREFIX}.final.vcf.gz"

echo "Done."
echo "Main merged dataset: ${MERGED_PREFIX}"
echo "Merged datasets with MAF filters: ${MERGED_PREFIX}.maf0.01 and ${MERGED_PREFIX}.maf0.05"

echo "Final VCFs: ${IBIZA_PREFIX}.final.vcf.gz and ${KOENIG_PREFIX}.final.vcf.gz"
