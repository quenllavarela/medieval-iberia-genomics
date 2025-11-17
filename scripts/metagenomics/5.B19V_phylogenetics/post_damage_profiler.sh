#!/bin/bash
#SBATCH -A naiss2025-22-972
#SBATCH -p shared
#SBATCH -n 4
#SBATCH -t 1:00:00
#SBATCH -e logs/damage_profiler_%A_%a.err
#SBATCH -o logs/damage_profiler_%A_%a.out
#SBATCH --job-name damageprofiler

# Variable that the script obtains by iterating the sample_list.
BAM=$(sed "${SLURM_ARRAY_TASK_ID}q;d" list_for_damage_profiler.txt | cut -f 1)
BAM_NAME=$(basename ${BAM} .bam)

OUTPUT="damage_profiler_B19_relaxed_mapping"

# Create output folder
mkdir -p ${OUTPUT}

# Command
java -jar ~/bin/DamageProfiler-1.1-java11.jar -i $BAM -o ${OUTPUT}/${BAM_NAME}
