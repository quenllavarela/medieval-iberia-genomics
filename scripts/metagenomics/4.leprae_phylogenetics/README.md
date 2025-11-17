# Phylogenetic analysis of Mycobacterium leprae

This folder contains the files and scripts used to generate the phylogenetic datasets and trees for the M. leprae analysis.

## 1. Selection of genomes used for phylogenetics

After running nf-core/eager, we retained only:

- VCF files from non-hypermutated strains (`hypermutated_strains_to_remove.txt`)
- Genomes with a mean coverage above 3x (`samples_with_at_least_3x.txt`)

This filtering ensured that downstream phylogenetic inference relied on higher confidence SNP calls and avoided noise from low-coverage or hypermutated genomes.

## 2. Selection of informative SNPs and creation of exclusion file

We used the list of informative SNPs published in Schuenemann et al. 2018 (`informative_SNPs_for_phylogeny_Schuenemann_2018.txt`) to define the positions to exclude in MultiVCFAnalyzer. 

## 3. MultiVCFAnalyzer run

The full MultiVCFAnalyzer command is provided in:

- `MultiVCFAnalyzer_Ibiza.sh`

Note that the directory containing the outgroup VCF must begin with `outgroup_` for the tool to recognise it.

MultiVCFAnalyzer produced:

- `snpTable.tsv`
- the initial SNP alignment used for downstream filtering

`snpTable.tsv` is included here for reference.

## 4. Filtering of SNP alignments

The SNP alignment was inspected and edited in MEGA to retain only SNPs covered in at least:

- 80% of genomes → `snpAlignment_cov80.fas`
- 85% of genomes → `snpAlignment_cov85.fas`
- 90% of genomes → `snpAlignment_cov90.fas`

These coverage thresholds were used to evaluate the robustness of the phylogeny under different levels of missing-data filtering.

## 5. Phylogenetic tree inference

Maximum parsimony trees were generated directly in MEGA.  
Maximum likelihood trees were generated with IQ-TREE 2 using:

- `tree_iqtree_Ibiza.sh`

All trees were inferred from the filtered SNP alignments described above.
