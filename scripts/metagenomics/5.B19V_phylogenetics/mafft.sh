#!/bin/bash
#SBATCH -A naiss2025-22-972
#SBATCH -p shared
#SBATCH -t 1:00:00
#SBATCH -n 20
#SBATCH -e logs/mafft_%A.err
#SBATCH -o logs/mafft_%A.out
#SBATCH --job-name mafft

module load mafft/7.526

mafft --auto --reorder --adjustdirectionaccurately tree/all_consensus.fasta > tree/all_aligned.fasta
