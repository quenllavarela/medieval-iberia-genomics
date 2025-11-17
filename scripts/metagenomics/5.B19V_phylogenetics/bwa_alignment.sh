#!/bin/bash

startnum=1 # Beware that the file needs to have no header
echo "Startnum is $startnum"
endnum=$(wc -l fastq_list_for_mapping.txt | cut -d ' ' -f 1)
echo "Endnum is $endnum"

chmod +x "post_bwa_alignment.sh" 
sbatch --array=$startnum-$endnum:1 post_bwa_alignment.sh
