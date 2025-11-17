# Phylogenetic analysis of Human Parvovirus B19

This folder contains the scripts and file lists used to generate the Human Parvovirus B19 (B19V) consensus sequences and phylogenetic trees for this study.

## 1. Read mapping

The Bonczarowska 2023 ancient B19V genome was downloaded and mapped together with the MaltExtracted reads from the individuals with the highest number of B19V reads in this study. These individuals are listed in `fastq_list_for_mapping.txt` (s.131, s.133, s.157 and s.315).

Reads were mapped with BWA aln using:

- `bwa_alignment.sh` (wrapper)
- `post_bwa_alignment.sh` (post-processing)

## 2. Consensus calling

Consensus sequences were called per individual from the merged BAM files listed in `list_for_angsd.txt`. Transitions were removed to minimise the effect of deamination.

Scripts:

- `consensus_angsd.sh` (wrapper for ANGSD)
- `post_consensus_angsd.sh` (post-processing)

## 3. Reference dataset

The modern B19V reference panel from Mühlemann et al. (Dataset 4) was downloaded using:

- `download_muehlemann_b19_dataset_4.py`

Ancient consensus FASTA files from that study were also downloaded for inclusion in the phylogeny.

## 4. Multiple sequence alignment

All consensus FASTA sequences (from this study and from published datasets) were concatenated and aligned with MAFFT using:

- `mafft.sh`

The resulting multiple sequence alignment was used as the input for phylogenetic inference.

## 5. Phylogenetic tree inference

Maximum likelihood phylogenies were generated with IQ-TREE 2 using:

- `tree_iqtree.sh`

## 6. Authentication of ancient B19V sequences

Deamination profiles were generated for the newly recovered ancient B19V isolates. Samples to analyse are listed in `list_for_damage_profiler.txt`.

Scripts:

- `damage_profiler.sh` (wrapper)
- `post_damage_profiler.sh` (post-processing)

These profiles were used to evaluate the authenticity of the ancient B19V reads.

## Summary

This pipeline covers read mapping, consensus generation, dataset assembly, multiple sequence alignment, phylogenetic inference and authentication for the B19V genomes analysed in this study.

