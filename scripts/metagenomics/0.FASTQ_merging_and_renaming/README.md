# FASTQ preprocessing for metagenomic screening

This directory documents how the raw sequencing data were prepared for metagenomic screening and pathogen detection.

## 1. FASTQ splitting for MALT memory limits

For three samples (s.133, s.157 and s.197) the total FASTQ size exceeded the 2 TB memory limit for a MALT job on our cluster. To keep within this limit, we processed these individuals as multiple input files of more even size in aMeta.

This was done at the level of the laboratory identifiers:

- ldo128 → later renamed to s.157
- ldo136 → later renamed to s.197
- ldo124 → later renamed to s.133

For ldo128 and ldo136 we retained separate subsets of sequencing runs as independent MALT inputs. For ldo124 we first split a very large file into two parts of similar size, then merged one part with a smaller sequencing run.

The exact commands used on the cluster are given in:

- `fastq_processing.sh`

## 2. Renaming laboratory IDs to archaeological sample IDs

After splitting and merging to satisfy the MALT memory constraints, we renamed the files from laboratory identifiers (ldoXXX) to archaeological sample identifiers (s.XXX) and merged runs per individual for pathogen detection.

The complete mapping from lab IDs to archaeological IDs, and from original lane files to the final per-sample FASTQs, is provided in:

- `renaming_list.txt`
