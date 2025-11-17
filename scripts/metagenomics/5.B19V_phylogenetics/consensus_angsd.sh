#!/bin/bash

startnum=1 # Beware that the file needs to have no header
echo "Startnum is $startnum"
endnum=$(wc -l list_for_angsd.txt | cut -d ' ' -f 1)
echo "Endnum is $endnum"

chmod +x "post_consensus_angsd.sh" 
sbatch --array=$startnum-$endnum:1 post_consensus_angsd.sh
