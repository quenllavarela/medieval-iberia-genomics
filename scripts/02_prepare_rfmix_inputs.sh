#!/bin/bash
# -----------------------------------------------------------------------------
# 02_prepare_rfmix_inputs.sh
# Prepares input files for RFMix v1.5.4 from merged PLINK/VCF datasets
# Generates:
#   - Allele file (phased, no missing)
#   - SNP positions file
#   - Class file
#   - Chromosome-specific allele and SNP files
# -----------------------------------------------------------------------------

# === Modules (optional; comment if not on HPC) ===
ml bcftools
ml plink
ml python

# === User-defined paths ===
MERGED_VCF="merged.GP99_dataset.maf0.05.vcf.gz"   # Input VCF from Script 1
KEEP_SAMPLES="samplelist_simple.txt"             # List of samples to include (one per line)
PREFIX="rfmix_sources"
OUTPUT_DIR="rfmix_input"

# Create output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/alleles_chromosomes"
mkdir -p "$OUTPUT_DIR/chromosomes"

# -----------------------------------------------------------------------------
# Step 1: Subset samples and remove missing data
# -----------------------------------------------------------------------------
bcftools view -S "$KEEP_SAMPLES" -Oz -o "${OUTPUT_DIR}/${PREFIX}.subset.vcf.gz" "$MERGED_VCF"
bcftools index "${OUTPUT_DIR}/${PREFIX}.subset.vcf.gz"

bcftools view -i 'F_MISSING=0' -Oz -o "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz" "${OUTPUT_DIR}/${PREFIX}.subset.vcf.gz"
bcftools index "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz"

# -----------------------------------------------------------------------------
# Step 2: Generate Allele File (phased, no missing)
# -----------------------------------------------------------------------------
bcftools query -f '[%GT\t]\n' "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz" | \
awk '{
    for (i=1; i<=NF; i++) {
        split($i, a, "|");
        printf "%s %s ", a[1], a[2];
    }
    print "";
}' > "${OUTPUT_DIR}/${PREFIX}_alleles.txt"

# Remove all spaces for compatibility
sed 's/[[:space:]]//g' "${OUTPUT_DIR}/${PREFIX}_alleles.txt" > "${OUTPUT_DIR}/${PREFIX}_alleles_combined_no_spaces_per_line.txt"

# -----------------------------------------------------------------------------
# Step 3: Generate SNP Positions File
# -----------------------------------------------------------------------------
bcftools query -f '%CHROM:%POS\n' "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz" > "${OUTPUT_DIR}/${PREFIX}_snp_locations.txt"

# -----------------------------------------------------------------------------
# Step 4: Generate Class File
# Adjust ancestry codes based on your reference populations
# -----------------------------------------------------------------------------
awk '{
    if ($1 == "CEU_bas") val = 1;
    else if ($1 == "bed_moz") val = 2;
    else val = 0;
    printf "%d %d ", val, val;
}' sampleorder_simple.txt > "${OUTPUT_DIR}/${PREFIX}_classes.txt"

# -----------------------------------------------------------------------------
# Step 5: Split Allele and SNP files by chromosome
# -----------------------------------------------------------------------------
for chr in {1..22}; do
    awk -v chr="$chr" '$1 ~ "^"chr":" { print }' "${OUTPUT_DIR}/${PREFIX}_snp_locations.txt" > "${OUTPUT_DIR}/chromosomes/chr${chr}.txt"
done

# Split alleles by chromosome
LOC_FILE="${OUTPUT_DIR}/${PREFIX}_snp_locations.txt"
ALLELE_FILE="${OUTPUT_DIR}/${PREFIX}_alleles_combined_no_spaces_per_line.txt"
CURRENT_LINE=0

for chr in {1..22}; do
    SNP_COUNT=$(grep -c "^${chr}:" "$LOC_FILE")
    START_LINE=$((CURRENT_LINE + 1))
    END_LINE=$((CURRENT_LINE + SNP_COUNT))
    sed -n "${START_LINE},${END_LINE}p" "$ALLELE_FILE" > "${OUTPUT_DIR}/alleles_chromosomes/chr${chr}_alleles.txt"
    CURRENT_LINE=$END_LINE
done

# -----------------------------------------------------------------------------
# Step 6: Convert positions to cM using your Python script
# -----------------------------------------------------------------------------
# python3 /path/to/convert_to_cM.py --input "${OUTPUT_DIR}/chromosomes" --output "${OUTPUT_DIR}/chromosomes_cM"

echo "RFMix input preparation complete."
