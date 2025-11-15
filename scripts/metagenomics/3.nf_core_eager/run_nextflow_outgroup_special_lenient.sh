module load PDC/24.11 apptainer/1.4.0-cpeGNU-24.11
module load bioinfo-tools java/OpenJDK_11.0.2

NXF_VER=22.10.6 nextflow run nf-core/eager \
    -r 2.5.0 \
    -c nextflow.config \
    -profile pdc_kth \
    --project naiss2025-5-172 \
    --outdir eager_outgroup \
    -work-dir eager_outgroup/work \
    --input fastq_list_outgroup.tsv \
    --fasta ../fastas/TN_ncbi-genomes-2023-02-28_ASM19585v1/GCF_000195855.1_ASM19585v1_genomic.fna \
    --bwa_index ../fastas/TN_ncbi-genomes-2023-02-28_ASM19585v1/ \
    --fasta_index ../fastas/TN_ncbi-genomes-2023-02-28_ASM19585v1/GCF_000195855.1_ASM19585v1_genomic.fna.fai \
    --seq_dict ../fastas/TN_ncbi-genomes-2023-02-28_ASM19585v1/GCF_000195855.1_ASM19585v1_genomic.fna.dict \
    --mapper 'circularmapper' \
    --bwaalnn '0.01' \
    --bwaalnl '16' \
    --run_bam_filtering \
    --dedupper 'markduplicates' \
    --run_genotyping \
    --genotyping_tool 'ug' \
    --gatk_ug_jar '~/bin/GenomeAnalysisTK.jar' \
    --gatk_ug_out_mode 'EMIT_ALL_SITES' \
    -with-trace \
    -with-report \
    -with-timeline \
    -resume

# Note that this more lenient mapping for the Mycobacterium lepromatosis outgroup is based on Fotakis et al. 2020. However, I didn't cut the reference genome in chunks and rather used the FASTQ SRR1576832 Bonczarowska et al. 2022 used instead.  
