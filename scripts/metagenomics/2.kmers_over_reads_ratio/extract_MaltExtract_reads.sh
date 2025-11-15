#!/bin/bash

startnum=1 # Beware that the file needs to have no header
echo "Startnum is $startnum"
endnum=$(wc -l extract_list.tsv | cut -d ' ' -f 1)
echo "Endnum is $endnum"

chmod +x "post_extract_MaltExtract_reads.sh" 
sbatch --array=$startnum-$endnum:1 post_extract_MaltExtract_reads.sh
