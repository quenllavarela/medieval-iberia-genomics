#!/bin/bash
#SBATCH -A naiss2024-22-1614
#SBATCH -p shared
#SBATCH -c 10
#SBATCH --mem 8800
#SBATCH -t 1:00:00
#SBATCH -e logs/extract_MaltExtract/post_extract_MaltExtract_reads_fastqs_%A_%a.err
#SBATCH -o logs/extract_MaltExtract/post_extract_MaltExtract_reads_fastqs_%A_%a.out
#SBATCH --job-name extract

# Reminder! Activate your aMeta conda environment before submitting this script!

# Load required modules
module load seqtk/1.4

# Read TAXID, TAXON NAME, and SAMPLE from task list
TAXID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" extract_list.tsv | cut -f1)
TAXON=$(sed -n "${SLURM_ARRAY_TASK_ID}p" extract_list.tsv | cut -f2)
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" extract_list.tsv | cut -f3)

echo "Processing SAMPLE: ${SAMPLE} | TAXID: ${TAXID} | TAXON: ${TAXON}"

# Paths
RMA6="results/MALT/${SAMPLE}.trimmed.rma6"
NCBI_DB="resources/ncbi"
SUPP_FOLDER="supplementary_maltextract/${TAXID}/${SAMPLE}"
FASTQ_INPUT="../data/${SAMPLE}.fastq.gz"
OUTPUT_FASTQ="extract_MaltExtract_reads_fastqs/${SAMPLE}_${TAXID}_MaltExtracted.fastq.gz"
LOG_FILE="extract_MaltExtract_reads_fastqs/${SAMPLE}_${TAXID}_num_reads.log"

# Create output directories
mkdir -p "${SUPP_FOLDER}" "extract_MaltExtract_reads_fastqs"

# Step 1: Run MaltExtract
echo "Running MaltExtract..."
time MaltExtract -Xmx8G \
    -i "${RMA6}" \
    -f default \
    -o "${SUPP_FOLDER}" \
    -r "${NCBI_DB}" \
    --taxa "${TAXON}" \
    --reads --threads 10 \
    --matches --minPI 85.0 --maxReadLength 0 --minComp 0.0 --meganSummary \
    -v \
    --destackingOff --dupRemOff --downSampOff

# Step 2: Merge FASTA files
FASTA_DIR="${SUPP_FOLDER}/default/reads/${SAMPLE}.trimmed.rma6"
MERGED_FASTA="${FASTA_DIR}/merged.fasta"

FASTA_FILES=$(find "${FASTA_DIR}" -type f -name "*.fasta" -size +0c)

echo "Merging FASTA files into: ${MERGED_FASTA}"
cat ${FASTA_FILES} > "${MERGED_FASTA}"

# Step 3: Extract read IDs and subset FASTQ
echo "Extracting reads using merged FASTA..."
READ_ID_LIST=$(mktemp)
grep '^>' "${MERGED_FASTA}" | sed 's/^>//' | sed 's/ .*$//' | sort | uniq > "${READ_ID_LIST}"

NUM_READS=$(wc -l < "${READ_ID_LIST}")
echo "Extracting ${NUM_READS} unique reads..." | tee "${LOG_FILE}"

seqtk subseq "${FASTQ_INPUT}" "${READ_ID_LIST}" | gzip > "${OUTPUT_FASTQ}"

# Cleanup
rm -f "${READ_ID_LIST}"

echo "Output FASTQ created: ${OUTPUT_FASTQ}"
echo "Number of reads logged in: ${LOG_FILE}"
