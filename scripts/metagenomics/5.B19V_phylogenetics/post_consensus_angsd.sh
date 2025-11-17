#!/bin/bash
#SBATCH -A naiss2025-22-972
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -e logs/consensus_angsd_%A_%a.err
#SBATCH -o logs/consensus_angsd_%A_%a.out
#SBATCH --job-name consensus_angsd

# WARNING: CAMILO THINKS SAMTOOLS CONSENSUS MIGHT BE BETTER THAN ANGSD, ESPECIALLY ON HAPLOID ORGANISMS
# If higher coverage, try out samtools consensus. However don't forget that you have to perform a real realignment of the multiple sequence alignment because samtools consensus keeps indels

# Variable that the script obtains by iterating the sample_list. 
BAM=$(sed "${SLURM_ARRAY_TASK_ID}q;d" list_for_angsd.txt | cut -f 1)
BAM_NAME=$(basename ${BAM} .bam)
threads=2

OUTPUT=consensus_angsd
REFERENCE=reference_for_mapping/B19V_gen2_ON023027.fasta

# Load necessary modules
module load angsd/0.940

# Create output folder
mkdir -p ${OUTPUT}

# Command suggested by Benjamin and ChatGPT as well
# This command sometimes fails and I don't know why. Anyway I settled for the soft-clipping so I don't think I need to remove transitions on top of that
# angsd -i ${BAM} -doFasta 2 -doCounts 1 -minMapQ 30 -out ${OUTPUT}/${BAM_NAME}_rmTrans -nThreads ${threads} -setMinDepth 1 -rmTrans 1 -ref ${REFERENCE} 
angsd -i ${BAM} -doFasta 2 -doCounts 1 -minMapQ 20 -out ${OUTPUT}/${BAM_NAME} -nThreads ${threads} -setMinDepth 1 -rmTrans 1 -ref ${REFERENCE}

# Explanations of the command
# input.bam is the input file, which is a BAM file containing aligned reads to a reference genome.
# -doFasta 2 tells ANGSD to output a fasta file with the consensus sequence.
# -doCounts 1 enables the counting of bases at each position, which is necessary for determining the consensus
# -minMapQ 30 means that we only use the reads that have a mapping quality of 30 or more
# -setMinDepth 5 means that we need to have a depth of 5 to call the snp. This option should be taken away in case you work with very low coverage data!
# -out allows you to provide the file name
# -nThreads to provide the number of threads.
# NOTA BENE, it seems that for a parameter to be activated in ANGSD, you have to specify 1 otherwise 0 means unactive or you just don't write the parameter. 
