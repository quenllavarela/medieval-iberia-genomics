#!/bin/bash

# -----------------------------------------------------------------------------
# 02_prepare_rfmix_inputs.sh
#
# Updated, cleaned and corrected version of the workflow used to prepare input
# files for RFMix v1.5.4 from merged PLINK/VCF datasets.
#
# Generated outputs:
#   1. Allele file (phased, no missing)
#   2. SNP positions file
#   3. Class file
#   4. Chromosome-specific allele and SNP files
#
# Required software:
#   bcftools
#   plink
#   python
# -----------------------------------------------------------------------------

set -euo pipefail

# === Modules (optional; comment out if not on HPC) ===
ml bcftools
ml plink
ml python

# === User-defined paths ===
MERGED_VCF="merged.GP99_dataset.maf0.05.vcf.gz"   # Input VCF from Script 1
KEEP_SAMPLES="samplelist_simple.txt"              # One sample ID per line
PREFIX="rfmix_sources"
OUTPUT_DIR="rfmix_input"

# === Optional metadata file for class assignment ===
# Expected format: sample_id <tab> population_label
# Example:
# NA12878    CEU_bas
# sampleX    bed_moz
# ibiza_01   QUERY
#
# Edit the class-mapping awk block below to match your populations and codes.
SAMPLE_GROUPS="sampleorder_simple.txt"

# Create output directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/alleles_chromosomes"
mkdir -p "$OUTPUT_DIR/chromosomes"

# -----------------------------------------------------------------------------
# Input checks
# -----------------------------------------------------------------------------
if [ ! -f "$MERGED_VCF" ]; then
    echo "ERROR: MERGED_VCF not found: $MERGED_VCF" >&2
    exit 1
fi

if [ ! -f "$KEEP_SAMPLES" ]; then
    echo "ERROR: KEEP_SAMPLES not found: $KEEP_SAMPLES" >&2
    exit 1
fi

if [ ! -f "$SAMPLE_GROUPS" ]; then
    echo "ERROR: SAMPLE_GROUPS not found: $SAMPLE_GROUPS" >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Step 1: Subset samples and retain only variants with no missing genotypes
# -----------------------------------------------------------------------------
echo "Subsetting samples..."

bcftools view -S "$KEEP_SAMPLES" \
    -Oz -o "${OUTPUT_DIR}/${PREFIX}.subset.vcf.gz" \
    "$MERGED_VCF"
bcftools index -f "${OUTPUT_DIR}/${PREFIX}.subset.vcf.gz"

echo "Retaining variants with no missing genotypes..."

bcftools view -i 'F_MISSING=0' \
    -Oz -o "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz" \
    "${OUTPUT_DIR}/${PREFIX}.subset.vcf.gz"
bcftools index -f "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz"

# Extract the actual sample order from the final VCF used for RFMix
bcftools query -l "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz" \
    > "${OUTPUT_DIR}/${PREFIX}_sample_order.txt"

# -----------------------------------------------------------------------------
# Step 2: Check that all genotypes are phased
# -----------------------------------------------------------------------------
echo "Checking that all genotypes are phased..."

if bcftools query -f '[%GT\t]\n' "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz" | grep -q '/'; then
    echo "ERROR: Unphased genotypes detected (found '/' in GT field)." >&2
    echo "RFMix v1.5.4 allele generation in this script expects phased genotypes using '|'." >&2
    exit 1
fi

# -----------------------------------------------------------------------------
# Step 3: Generate allele file (phased, no missing)
# -----------------------------------------------------------------------------
echo "Generating allele file..."

bcftools query -f '[%GT\t]\n' "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz" | \
awk '{
    for (i = 1; i <= NF; i++) {
        split($i, a, "|");
        if (length(a) != 2) {
            print "ERROR: malformed phased genotype: " $i > "/dev/stderr";
            exit 1;
        }
        printf "%s%s", a[1], a[2];
    }
    printf "\n";
}' > "${OUTPUT_DIR}/${PREFIX}_alleles.txt"

# -----------------------------------------------------------------------------
# Step 4: Generate SNP positions file
# -----------------------------------------------------------------------------
echo "Generating SNP positions file..."

bcftools query -f '%CHROM:%POS\n' "${OUTPUT_DIR}/${PREFIX}.phased.nomissing.vcf.gz" \
    > "${OUTPUT_DIR}/${PREFIX}_snp_locations.txt"

# -----------------------------------------------------------------------------
# Step 5: Generate class file using the real VCF sample order
# -----------------------------------------------------------------------------
echo "Generating class file..."

# Join actual VCF sample order with user-provided sample group metadata
# SAMPLE_GROUPS must contain:
#   column 1 = sample ID
#   column 2 = population label
#
# Edit the mapping below to match your ancestry/reference codes.
awk 'NR==FNR {group[$1]=$2; next}
{
    sample=$1;
    pop=group[sample];

    if (pop == "") {
        print "ERROR: sample missing from SAMPLE_GROUPS file: " sample > "/dev/stderr";
        exit 1;
    }

    if (pop == "CEU_bas") val = 1;
    else if (pop == "bed_moz") val = 2;
    else val = 0;

    printf "%d %d ", val, val;
}
END {
    printf "\n";
}' "$SAMPLE_GROUPS" "${OUTPUT_DIR}/${PREFIX}_sample_order.txt" \
    > "${OUTPUT_DIR}/${PREFIX}_classes.txt"

# -----------------------------------------------------------------------------
# Step 6: Split SNP position file by chromosome
# -----------------------------------------------------------------------------
echo "Splitting SNP positions by chromosome..."

for chr in {1..22}; do
    awk -F: -v chr="$chr" '$1 == chr { print }' \
        "${OUTPUT_DIR}/${PREFIX}_snp_locations.txt" \
        > "${OUTPUT_DIR}/chromosomes/chr${chr}.txt"
done

# -----------------------------------------------------------------------------
# Step 7: Split allele file by chromosome
# -----------------------------------------------------------------------------
echo "Splitting allele file by chromosome..."

LOC_FILE="${OUTPUT_DIR}/${PREFIX}_snp_locations.txt"
ALLELE_FILE="${OUTPUT_DIR}/${PREFIX}_alleles.txt"
CURRENT_LINE=0

for chr in {1..22}; do
    SNP_COUNT=$(awk -F: -v chr="$chr" '$1 == chr {count++} END {print count+0}' "$LOC_FILE")
    START_LINE=$((CURRENT_LINE + 1))
    END_LINE=$((CURRENT_LINE + SNP_COUNT))

    if [ "$SNP_COUNT" -gt 0 ]; then
        sed -n "${START_LINE},${END_LINE}p" "$ALLELE_FILE" \
            > "${OUTPUT_DIR}/alleles_chromosomes/chr${chr}_alleles.txt"
    else
        : > "${OUTPUT_DIR}/alleles_chromosomes/chr${chr}_alleles.txt"
    fi

    CURRENT_LINE=$END_LINE
done

# -----------------------------------------------------------------------------
# Step 8: Convert positions to cM using your Python script
# -----------------------------------------------------------------------------
# python3 /path/to/convert_to_cM.py --input "${OUTPUT_DIR}/chromosomes" --output "${OUTPUT_DIR}/chromosomes_cM"

echo "RFMix input preparation complete."
