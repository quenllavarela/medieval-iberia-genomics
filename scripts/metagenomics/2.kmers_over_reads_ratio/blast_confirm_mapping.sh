#!/bin/bash

startnum=1 # Beware that the file needs to have no header
echo "Startnum is $startnum"
endnum=$(wc -l fasta_files_for_blastn.tsv | cut -d ' ' -f 1)
echo "Endnum is $endnum"

chmod +x "post_blast_confirm_mapping.sh" 
sbatch --array=$startnum-$endnum:1 post_blast_confirm_mapping.sh
