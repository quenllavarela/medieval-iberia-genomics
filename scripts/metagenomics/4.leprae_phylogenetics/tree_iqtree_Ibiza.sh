#!/bin/bash
#SBATCH -A naiss2025-22-972
#SBATCH -p shared
#SBATCH -c 20
#SBATCH -t 1-00:00:00
#SBATCH -e logs/tree_iqtree_Ibiza_%A.err
#SBATCH -o logs/tree_iqtree_Ibiza_%A.out
#SBATCH --job-name tree_iqtree


# Variable that the script obtains by iterating the sample_list. 

MSA80=tree_iqtree_Ibiza/snpAlignment_cov80.fas
MSA85=tree_iqtree_Ibiza/snpAlignment_cov85.fas
MSA90=tree_iqtree_Ibiza/snpAlignment_cov90.fas

#THREADS
threads=20

# Load necessary modules
module load PDC/24.11 iqtree/2.4.0-cpeGNU-24.11

# Command 
# iqtree2 -s ${MSA80} -m MFP -bb 10000 -nt ${threads}
# iqtree2 -s ${MSA85} -m MFP -bb 10000 -nt ${threads}
# iqtree2 -s ${MSA90} -m MFP -bb 10000 -nt ${threads}

# Best tree model for full tree
# iqtree2 -s ${MSA80} -m GTR+F -b 100 -nt ${threads} -redo
# iqtree2 -s ${MSA85} -m GTR+F -b 100 -nt ${threads} -redo
# iqtree2 -s ${MSA90} -m GTR+F -b 100 -nt ${threads} -redo

# -s is the name of the multiple sequence alignment file
# -m MFP for model finder or other model once you know which model is best. 
# Model MFP means that it actually needs to look for the best model. It takes much more time and afterwards you can take that information of best model to change that command
# -bb amount of ultrafast bootstraps
# -b amount of bootstraps
# -nt number of threads
# -redo overrides a previous run
