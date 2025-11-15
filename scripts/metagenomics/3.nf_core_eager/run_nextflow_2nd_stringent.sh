module load PDC/24.11 apptainer/1.4.0-cpeGNU-24.11
module load bioinfo-tools java/OpenJDK_11.0.2

NXF_VER=22.10.6 nextflow run nf-core/eager \
    -r 2.5.0 \
    -c nextflow.config \
    -profile pdc_kth \
    --project naiss2025-5-172 \
    --outdir eager_2nd \
    -work-dir eager_2nd/work \
    --input fastq_list_trimmed.tsv \
    --fasta ../fastas/TN_ncbi-genomes-2023-02-28_ASM19585v1/GCF_000195855.1_ASM19585v1_genomic.fna \
    --bwa_index ../fastas/TN_ncbi-genomes-2023-02-28_ASM19585v1/ \
    --fasta_index ../fastas/TN_ncbi-genomes-2023-02-28_ASM19585v1/GCF_000195855.1_ASM19585v1_genomic.fna.fai \
    --seq_dict ../fastas/TN_ncbi-genomes-2023-02-28_ASM19585v1/GCF_000195855.1_ASM19585v1_genomic.fna.dict \
    --skip_fastqc 'true' \
    --skip_adapterremoval 'true' \
    --mapper 'circularmapper' \
    --bwaalnn '0.2' \
    --run_bam_filtering \
    --bam_mapping_quality_threshold 20 \
    --bam_filter_minreadlength 30 \
    --dedupper 'markduplicates' \
    --run_genotyping \
    --genotyping_tool 'ug' \
    --gatk_ug_jar '~/bin/GenomeAnalysisTK.jar' \
    --gatk_ug_out_mode 'EMIT_ALL_SITES' \
    -with-trace \
    -with-report \
    -with-timeline \
    -resume

# Note that the GenomeAnalysisTK.jar file alias GATK needs to be an old version, ideally v.3.5. Later versions are not compatible with MultiVCFAnalyzer.
