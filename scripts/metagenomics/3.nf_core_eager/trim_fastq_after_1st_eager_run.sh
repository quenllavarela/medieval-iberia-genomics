#!/bin/bash

startnum=1 # Beware that the file needs to have no header
echo "Startnum is $startnum"
endnum=$(wc -l trimming_plan.tsv | cut -d ' ' -f 1)  

echo "Endnum is $endnum"

chmod +x "post_trim_fastq_after_1st_eager_run.sh" 
sbatch --array=$startnum-$endnum:1 post_trim_fastq_after_1st_eager_run.sh
