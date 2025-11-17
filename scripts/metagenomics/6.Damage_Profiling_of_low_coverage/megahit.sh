#!/bin/bash
#SBATCH -A naiss2024-22-1614
#SBATCH -p shared
#SBATCH -t 3:00:00
#SBATCH -c 5
#SBATCH --mem 4400
#SBATCH -e logs/megahit_%A.err
#SBATCH -o logs/megahit_%A.out
#SBATCH --job-name megahit

# Provide the fastq to assemble as argument $1

OUTPUT_FOLDER=$(basename "$1" .fastq.gz)

module load megahit/1.2.9

megahit -r $1 -o $OUTPUT_FOLDER -t 5
