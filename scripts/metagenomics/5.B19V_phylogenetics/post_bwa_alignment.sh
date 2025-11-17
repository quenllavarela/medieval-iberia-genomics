#!/bin/bash
#SBATCH -A naiss2025-22-972
#SBATCH -p shared
#SBATCH -t 1:00:00
#SBATCH -n 20
#SBATCH -e logs/bwa_alignment_%A_%a.err
#SBATCH -o logs/bwa_alignment_%A_%a.out
#SBATCH --job-name bwaAlignment

# Variable that the script obtains by iterating the sample_list.
FASTQ=$(sed "${SLURM_ARRAY_TASK_ID}q;d" fastq_list_for_mapping.txt | cut -f 1)
FASTQ_NAME=$(basename ${FASTQ} .fastq.gz)
OUTPUT=bwa_alignment

# Other necessary paths
REFERENCE="reference_for_mapping/B19V_gen2_ON023027.fasta"

# Set number of threads
threads=20

# The job will stop if an error arises
set -euo pipefail

# Load necessary modules
module load samtools/1.20 bwa/0.7.18

# Create output folder if non-existent
mkdir -p ${OUTPUT}

# Map with bwa aln
bwa aln -t ${threads} $REFERENCE ${FASTQ} -n 0.01 -l 16500 -o 2 -f ${OUTPUT}/${FASTQ_NAME}.sai
echo "Alignment successful for ${REFERENCE}"

# Perform samse, filtering, sorting, and indexing
bwa samse ${REFERENCE} ${OUTPUT}/${FASTQ_NAME}.sai ${FASTQ} > ${OUTPUT}/${FASTQ_NAME}.sam
samtools view -@ ${threads} -F 4 -Sb ${OUTPUT}/${FASTQ_NAME}.sam > ${OUTPUT}/${FASTQ_NAME}.unsorted.bam
samtools sort -@ ${threads} ${OUTPUT}/${FASTQ_NAME}.unsorted.bam -o ${OUTPUT}/${FASTQ_NAME}.bam
samtools index -@ ${threads} ${OUTPUT}/${FASTQ_NAME}.bam

# Only keep reads that are longer or equalt to 20bp
samtools view -@ ${threads} -b -F 4 -e 'length(seq)>19' ${OUTPUT}/${FASTQ_NAME}.bam > ${OUTPUT}/${FASTQ_NAME}.rl20.bam
samtools index -@ ${threads} ${OUTPUT}/${FASTQ_NAME}.rl20.bam

# Remove duplicates
samtools markdup -@ ${threads} -r ${OUTPUT}/${FASTQ_NAME}.rl20.bam ${OUTPUT}/${FASTQ_NAME}.rl20.dedup.bam
samtools index -@ ${threads} ${OUTPUT}/${FASTQ_NAME}.rl20.dedup.bam

# Cleanup intermediate files
rm -f ${OUTPUT}/${FASTQ_NAME}.sai
rm -f ${OUTPUT}/${FASTQ_NAME}.sam
rm -f ${OUTPUT}/${FASTQ_NAME}.unsorted.bam
rm -f ${OUTPUT}/${FASTQ_NAME}.rl20.bam
rm -f ${OUTPUT}/${FASTQ_NAME}.rl20.bam.bai
