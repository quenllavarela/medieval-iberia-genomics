#!/bin/bash
# -----------------------------------------------------------------------------
# 01_filter_and_merge.sh
# Filters and merges Ibiza ancient samples with modern reference panel
# Produces PLINK files and a final VCF for downstream analysis
# -----------------------------------------------------------------------------

# === Modules (optional; comment if not on HPC) ===
ml bioinfo-tools
ml bcftools
ml tabix
ml plink

# === User-defined paths ===
IBIZA_VCF="/path/to/ibiza.vcf.gz"
KOENIG_VCF="/path/to/koenig.vcf.gz"
OUT_PREFIX="merged.GP99_dataset"
MAF_THRESHOLD=0.05
MIND_THRESHOLD=0.15
GENO_THRESHOLD=0.2

# -----------------------------------------------------------------------------
# Step 1: Filter VCFs for biallelic SNPs and MAF
# -----------------------------------------------------------------------------
for VCF in "$IBIZA_VCF" "$KOENIG_VCF"; do
    BASE=$(basename "$VCF" .vcf.gz)
    echo "Processing $BASE ..."

    # Keep only biallelic SNPs
    bcftools view -m2 -M2 -v snps "$VCF" -Oz -o "${BASE}.biallelic.vcf.gz"
    tabix -p vcf "${BASE}.biallelic.vcf.gz"

    # Filter for MAF >= 0.01 (optional; can be adjusted)
    bcftools view -i 'MAF[0]>=0.01' "${BASE}.biallelic.vcf.gz" -Oz -o "${BASE}.biallelic.maf01.vcf.gz"
    tabix -p vcf "${BASE}.biallelic.maf01.vcf.gz"

    # Convert to PLINK format
    plink --vcf "${BASE}.biallelic.maf01.vcf.gz" --make-bed --out "${BASE}.biallelic"
    plink --bfile "${BASE}.biallelic" --mind $MIND_THRESHOLD --make-bed --out "${BASE}.biallelic.min${MIND_THRESHOLD}"
    plink --bfile "${BASE}.biallelic.min${MIND_THRESHOLD}" --geno $GENO_THRESHOLD --make-bed --out "${BASE}.biallelic.min${MIND_THRESHOLD}.geno${GENO_THRESHOLD}"
    plink --bfile "${BASE}.biallelic.min${MIND_THRESHOLD}.geno${GENO_THRESHOLD}" --maf $MAF_THRESHOLD --make-bed --out "${BASE}.biallelic.min${MIND_THRESHOLD}.geno${GENO_THRESHOLD}.maf${MAF_THRESHOLD}"
done

# -----------------------------------------------------------------------------
# Step 2: Harmonize SNP IDs (CHR:POS) and remove duplicates
# -----------------------------------------------------------------------------
echo "Harmonizing SNP IDs..."
awk '{print $1 ":" $4}' "${IBIZA_VCF%.vcf.gz}.biallelic.min${MIND_THRESHOLD}.geno${GENO_THRESHOLD}.maf${MAF_THRESHOLD}.bim" > ibiza_snps.txt
awk '{print $1 ":" $4}' "${KOENIG_VCF%.vcf.gz}.biallelic.min${MIND_THRESHOLD}.geno${GENO_THRESHOLD}.maf${MAF_THRESHOLD}.bim" > koenig_snps.txt

sort ibiza_snps.txt > sorted_ibiza_snps.txt
sort koenig_snps.txt > sorted_koenig_snps.txt

# Subset PLINK datasets to common SNPs
plink --bfile "${IBIZA_VCF%.vcf.gz}.biallelic.min${MIND_THRESHOLD}.geno${GENO_THRESHOLD}.maf${MAF_THRESHOLD}" \
      --extract sorted_koenig_snps.txt --make-bed --out ibiza_common
plink --bfile "${KOENIG_VCF%.vcf.gz}.biallelic.min${MIND_THRESHOLD}.geno${GENO_THRESHOLD}.maf${MAF_THRESHOLD}" \
      --extract sorted_ibiza_snps.txt --make-bed --out koenig_common

# Remove duplicate SNPs
awk '{print $2}' ibiza_common.bim | sort | uniq -d > ibiza_dup.txt
awk '{print $2}' koenig_common.bim | sort | uniq -d > koenig_dup.txt
plink --bfile ibiza_common --exclude ibiza_dup.txt --make-bed --out ibiza_nodup
plink --bfile koenig_common --exclude koenig_dup.txt --make-bed --out koenig_nodup

# -----------------------------------------------------------------------------
# Step 3: Merge datasets
# -----------------------------------------------------------------------------
echo "Merging datasets..."
plink --bfile koenig_nodup --bmerge ibiza_nodup.bed ibiza_nodup.bim ibiza_nodup.fam --make-bed --out "$OUT_PREFIX"

# Resolve merge conflicts by excluding problematic SNPs
plink --bfile ibiza_nodup --exclude ${OUT_PREFIX}-merge.missnp --make-bed --out ibiza_flipped
plink --bfile koenig_nodup --exclude ${OUT_PREFIX}-merge.missnp --make-bed --out koenig_flipped

plink --bfile koenig_flipped --bmerge ibiza_flipped.bed ibiza_flipped.bim ibiza_flipped.fam --make-bed --out "$OUT_PREFIX"

# -----------------------------------------------------------------------------
# Step 4: Prepare VCF 
# -----------------------------------------------------------------------------
cut -f2 "$OUT_PREFIX".bim > snpstoextractvcf.txt

for BASE in "${IBIZA_VCF%.vcf.gz}" "${KOENIG_VCF%.vcf.gz}"; do
    zcat "${BASE}.biallelic.maf01.vcf.gz" | \
        awk 'BEGIN {OFS="\t"} !/^#/ {$3 = $1":"$2}1' | \
        bgzip > "${BASE}.biallelic.final.vcf.gz"
    tabix -p vcf "${BASE}.biallelic.final.vcf.gz"
done

bcftools view -i 'ID=@snpstoextractvcf.txt' "${IBIZA_VCF%.vcf.gz}.biallelic.final.vcf.gz" -Oz -o ibiza.final.vcf.gz
bcftools view -i 'ID=@snpstoextractvcf.txt' "${KOENIG_VCF%.vcf.gz}.biallelic.final.vcf.gz" -Oz -o koenig.final.vcf.gz
tabix -p vcf ibiza.final.vcf.gz
tabix -p vcf koenig.final.vcf.gz

echo "Filtering and merging complete. Final PLINK and VCF files ready."
