#!/bin/bash
#SBATCH -A naiss2025-22-972
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 2:00:00
#SBATCH -e logs/trim_fastq_after_1st_eager_run_%A_%a.err
#SBATCH -o logs/trim_fastq_after_1st_eager_run_%A_%a.out
#SBATCH --job-name trimFQ

set -euo pipefail

# Load fastp
module load fastp/0.24.0

# Get input values from the trimming plan
LINE=$(sed "${SLURM_ARRAY_TASK_ID}q;d" trimming_plan.tsv)
INPUT=$(echo "$LINE" | cut -f1)
TRIM=$(echo "$LINE" | cut -f2)
TYPE=$(echo "$LINE" | cut -f3)

# Output folder
OUTPUT="fastqs_for_2nd_eager_run"
mkdir -p "$OUTPUT"

# Derive base name for consistent naming
BASENAME=$(basename "$INPUT" | sed 's/\.[fp]q\.gz$//')  # Strip .fq.gz or .fastq.gz

# Construct output path with .fastq.gz suffix
OUTFILE="$OUTPUT/${BASENAME}_tr${TRIM}.fastq.gz"

# Apply trimming or symlink
if [ "$TRIM" -eq 0 ]; then
    ln -s "$(realpath "$INPUT")" "$OUTFILE"
else
    fastp --in1 "$INPUT" \
          --out1 "$OUTFILE" \
          --trim_front1 "$TRIM" \
          --trim_tail1 "$TRIM" \
          --thread 4 \
          --trim_poly_g
fi
