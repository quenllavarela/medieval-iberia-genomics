#!/bin/bash
#SBATCH -A naiss2025-5-172
#SBATCH -p shared
#SBATCH -c 8
#SBATCH --mem 32000
#SBATCH -t 1-00:00:00
#SBATCH -e logs/blastn/blast_confirm_mapping_%A_%a.err
#SBATCH -o logs/blastn/blast_confirm_mapping_%A_%a.out
#SBATCH --job-name blastnconf

module load bioinfo-tools blast/2.15.0+

# Get FASTA path for this array index (1-based)
FASTA=$(sed -n "${SLURMi_ARRAY_TASK_ID}p" fasta_files_for_blastn.tsv | cut -f1)

# Extract sample information from path
FASTA=$(sed -n "${SLURM_ARRAY_TASK_ID}p" fasta_files_for_blastn.tsv | cut -f1)
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" fasta_files_for_blastn.tsv | cut -f1 | cut -d "/" -f 3)
TAXID=$(sed -n "${SLURM_ARRAY_TASK_ID}p" fasta_files_for_blastn.tsv | cut -f1 | cut -d "/" -f 2)
OUTPUT=blast_confirm_results

mkdir -p ${OUTPUT}


blastn \
  -task blastn \
  -query "${FASTA}" \
  -db nt \
  -perc_identity 90 \
  -qcov_hsp_perc 80 \
  -evalue 1e-5 \
  -word_size 11 \
  -soft_masking false \
  -max_target_seqs 50 \
  -max_hsps 1 \
  -num_threads 8 \
  -outfmt "6 qseqid qlen qstart qend sseqid sacc staxids sscinames pident length mismatch gapopen evalue bitscore qcovs qcovhsp sstart send" \
  -out "${OUTPUT}/${TAXID}_${SAMPLE}_blast.tsv"

blastdbcmd -db nt -info | head -n 20 > ${OUTPUT}/nt_db_info_${SLURM_ARRAY_TASK_ID}.txt


# -task blastn            # Nucleotide–nucleotide search tuned for ~70–150 bp reads (word size 11 by default).
# -query "${FASTA}"       # Input FASTA of reads to test (one file per SLURM array index).
# -db nt                  # Subject database: NCBI nt (nucleotide collection) installed on the cluster.
# -perc_identity 90       # Minimum % identity for an HSP; keeps deamination-noisy but real matches, prunes weak ones.
# -qcov_hsp_perc 80       # Require ≥80% of the query to be covered by the HSP; avoids tiny/local matches.
# -evalue 1e-5            # Significance threshold; smaller is stricter. 1e-5 is conservative for short aDNA reads.
# -word_size 11           # Seed size; 11 is appropriate for ~100 bp reads (more specific than blastn-short’s 7).
# -soft_masking false     # Treat soft-masked **subject** letters as hard-masked during seeding (more stringent).
# -max_target_seqs 50     # Report up to 50 top subject sequences per query after filtering; enough for tie checks.
# -max_hsps 1             # At most one HSP per subject per query; simplifies per-read top-hit logic.
# -num_threads 8          # Use 8 CPU threads per task.
# -outfmt "6 ..."         # Tabular output with explicit fields listed below for robust downstream parsing.
# -out "blast_results/${SAMPLE}_blast.tsv"  # Per-sample results file.

# Capture database metadata (date/version/volumes) for reproducibility in Methods:
# blastdbcmd -db nt -info | head -n 20 > blast_results/nt_db_info_${SLURM_ARRAY_TASK_ID}.txt
