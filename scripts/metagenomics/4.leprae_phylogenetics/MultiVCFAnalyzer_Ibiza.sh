#!/bin/bash
#SBATCH -A naiss2025-22-972
#SBATCH -p shared
#SBATCH -c 20
#SBATCH --mem 18G
#SBATCH -t 3:00:00
#SBATCH -o logs/MultiVCFAnalyzer_Ibiza_%A.out
#SBATCH -e logs/MultiVCFAnalyzer_Ibiza_%A.err
#SBATCH --job-name Multi


# Script to run MultiVCFAnalyzer
# I added my VCF files at the top for more comfort
# Only use vcfs with a coverage of 3x at this step
# Line 1: command
# Line 2: NA
# Line 3: Reference fasta path
# Line 4: NA
# Line 5: Output folder name
# Line 6: F for False
# Line 7: 30 for the minimum genotyping quality
# Line 8: A minimum fold coverage threshold of 3
# Line 9: A homozygous SNP, meaning a SNP that is same as in the reference is called if the base frequency is >= 90%
# Line 10: A heterozygous SNP, meaning a SNP different from the reference is called if the base frequency is >= 90%
# Line 11: gff file path containing the regions to exclude
# First following lines: my vcf files
# Last following lines: all the reference vcf files


multivcfanalyzer \
NA \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/circularmapper_reference/GCF_000195855.1_ASM19585v1_genomic_500.fna \
NA \
vcf_analysis_Ibiza \
F \
30 \
3 \
0.9 \
0.9 \
positions2exclude.gff \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/outgroup_M.lepromatosis/M.lepromatosis.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/1262-16/1262-16.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/2936/2936.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/2DDS/2DDS.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/3077_Sweden/3077_Sweden.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/511/511.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/515/515.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/516/516.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/517/517.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/518/518.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/519/519.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/520/520.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/97016/97016.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Abusir1630_Egypt/Abusir1630_Egypt.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Airaku-3/Airaku-3.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_07/ARLP_07.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_08/ARLP_08.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_10/ARLP_10.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_11/ARLP_11.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_12/ARLP_12.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_13/ARLP_13.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_14/ARLP_14.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_20/ARLP_20.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_23/ARLP_23.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_25/ARLP_25.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_27/ARLP_27.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_29/ARLP_29.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_30/ARLP_30.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_32/ARLP_32.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_37/ARLP_37.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_40/ARLP_40.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_46/ARLP_46.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_48/ARLP_48.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_49/ARLP_49.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_52/ARLP_52.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_57/ARLP_57.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_62/ARLP_62.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_68/ARLP_68.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_73/ARLP_73.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ARLP_74/ARLP_74.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/BEL024_Belarus/BEL024_Belarus.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Bergen_Norway/Bergen_Norway.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Bn7-39/Bn7-39.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Bn7-41/Bn7-41.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Bn8-46/Bn8-46.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Bn8-51/Bn8-51.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Bn8-52/Bn8-52.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Body188_Czechia/Body188_Czechia.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/BP/BP.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br14-1/Br14-1.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br14-2/Br14-2.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br14-4/Br14-4.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br14-5/Br14-5.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br1/Br1.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-14/Br2016-14.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-16/Br2016-16.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-17/Br2016-17.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-18/Br2016-18.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-19/Br2016-19.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-20/Br2016-20.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-21/Br2016-21.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-24/Br2016-24.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-26/Br2016-26.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-27/Br2016-27.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-45/Br2016-45.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-46/Br2016-46.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Br2016-47/Br2016-47.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/BrMM1/BrMM1.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/BrMM2/BrMM2.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/BrMM4/BrMM4.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/BrMM5/BrMM5.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Brw15-10M/Brw15-10M.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Brw15-12M/Brw15-12M.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Brw15-13L/Brw15-13L.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Brw15-1E/Brw15-1E.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Brw15-20M/Brw15-20M.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Brw15-25E/Brw15-25E.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Brw15-25M/Brw15-25M.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Brw15-5E/Brw15-5E.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Brw15-6M2/Brw15-6M2.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ch4/Ch4.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/CHRY023_UK/CHRY023_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/CHRY044_UK/CHRY044_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/CM1/CM1.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/EDI006_UK/EDI006_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/EGG/EGG.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Fio3/Fio3.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/G1083_Denmark/G1083_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/G1149_Denmark/G1149_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/G154_Denmark/G154_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/G34_Denmark/G34_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/GC96CU_UK/GC96CU_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Gu4-17/Gu4-17.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Gu4-19L/Gu4-19L.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Gu5-23/Gu5-23.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Indonesia-1/Indonesia-1.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Izumi/Izumi.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/JDS097_UK/JDS097_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Jorgen404_Denmark/Jorgen404_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Jorgen427_Denmark/Jorgen427_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Jorgen507_Denmark/Jorgen507_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Jorgen533_Denmark/Jorgen533_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Jorgen722_Denmark/Jorgen722_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Jorgen749_Denmark/Jorgen749_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Kanazawa/Kanazawa.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/KirkHill_Scotland/KirkHill_Scotland.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Kitasato/Kitasato.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Korea-3-2/Korea-3-2.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Kusatsu-6/Kusatsu-6.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Kyoto-1/Kyoto-1.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/LRC-1A/LRC-1A.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml10-91/Ml10-91.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml10-93/Ml10-93.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml10-94/Ml10-94.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml10-95/Ml10-95.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml10-96/Ml10-96.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml10-97/Ml10-97.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml10-98/Ml10-98.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml10-99/Ml10-99.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml2-10/Ml2-10.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/ML2-5/ML2-5.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml6-50/Ml6-50.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml6-55/Ml6-55.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml9-79/Ml9-79.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml9-80/Ml9-80.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml9-81/Ml9-81.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml9-82/Ml9-82.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml9-83/Ml9-83.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml9-84/Ml9-84.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml9-86/Ml9-86.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ml9-87/Ml9-87.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/MMW_H50_1_UK/MMW_H50_1_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/MMW_H80_1_UK/MMW_H80_1_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/MMW_H94_1_UK/MMW_H94_1_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ng12-33/Ng12-33.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ng13-32/Ng13-32.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ng13-33/Ng13-33.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ng14-35/Ng14-35.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ng15-36/Ng15-36.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ng15-37/Ng15-37.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ng16-38/Ng16-38.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ng17-39/Ng17-39.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/NHDP-55/NHDP-55.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/NHDP-63/NHDP-63.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/NHDP-98/NHDP-98.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Oku-4/Oku-4.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Pak/Pak.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/PAVd09_I/PAVd09_I.5_Portugal.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/R7546-671_Russia/R7546-671_Russia.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Refshale_16_Denmark/Refshale_16_Denmark.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ryukyu-2/Ryukyu-2.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/SK11_Hungary/SK11_Hungary.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/SK14_UK/SK14_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/SK2_UK/SK2_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/SK8_UK/SK8_UK.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/SK92_Norway/SK92_Norway.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/SM1/SM1.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/T18_Italy/T18_Italy.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Thai-237/Thai-237.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Thai-311/Thai-311.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Thai-53/Thai-53.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Tsukuba-1/Tsukuba-1.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/UF101_Spain/UF101_Spain.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/UF25_Spain/UF25_Spain.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/UF700_Spain/UF700_Spain.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/UF703_Spain/UF703_Spain.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/US57/US57.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/W-09/W-09.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ye2-3/Ye2-3.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ye3s2/Ye3s2.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ye4-10/Ye4-10.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ye4-11/Ye4-11.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ye4-12/Ye4-12.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Ye4-8/Ye4-8.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Zensho-2/Zensho-2.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/s.313/s.313.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/523A1/523A1.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/536/536.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/Bn8-47/Bn8-47.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/UF21_Spain/UF21_Spain.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/UF803_Spain/UF803_Spain.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/UF11_Spain/UF11_Spain.unifiedgenotyper.vcf \
/cfs/klemming/projects/supr/archaeogenetics/pochonz/Phylogenetics/leprae/after_eager_dedup_processing/vcfs/UF800_Spain/UF800_Spain.unifiedgenotyper.vcf
