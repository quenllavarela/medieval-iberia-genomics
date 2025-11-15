# Using the KrakenUniq k-mers/reads ratio for pathogen candidate screening

This document describes how we used the KrakenUniq k-mers/reads ratio as a proxy for evenness of coverage to prioritise pathogen candidates, in addition to the aMeta authentication scores.

## Extract candidate pathogens from KrakenUniq output

Starting from the aMeta KrakenUniq output, we first extract lines that match a curated list of pathogen taxon names. This list was built iteratively over several projects.

```bash
grep -f pathogen_list.txt aMeta/results/KRAKENUNIQ/*/krakenuniq.output   | grep -w species   | grep -v "species group"   > all_krakenuniq_potential_pathogens
```

- `pathogen_list.txt` contains one taxon string per line.
- We restrict to entries reported at `species` level.
- We exclude lines that contain "species group".

The resulting file `all_krakenuniq_potential_pathogens` contains all candidate pathogen hits across samples.

## Compute the k-mers/reads ratio

We then compute a k-mers/reads ratio, which we use as a proxy for evenness of coverage. In the standard KrakenUniq output, column 3 holds the number of reads assigned to the taxon and column 5 holds the number of unique k-mers.

The command below

1. Cleans the sample name by replacing `/krakenuniq.output:` with a tab  
2. Squeezes multiple spaces into a single space to clean species names  
3. Computes the ratio `unique_kmers / reads` and appends it as a new column  
4. Sorts rows by this ratio in descending order  
5. Writes the result to a new file

```bash
sed 's|/krakenuniq.output:|	|g' all_krakenuniq_potential_pathogens   | tr -s ' '   | awk -F'	' 'BEGIN { OFS = "	" } {
      if ($3 == 0) {
        ratio = 0
      } else {
        ratio = $5 / $3
      }
      print $0, ratio
    }'   | sort -t $'	' -k11,11nr   > all_krakenuniq_potential_pathogens_ratio.tsv
```

The last column in `all_krakenuniq_potential_pathogens_ratio.tsv` is the k-mers/reads ratio. A higher value generally indicates more evenly distributed coverage and less duplicated signal for a given read count.

## Filter by read count

For this study we restricted our investigation to candidates with enough reads to generate interpretable damage plots. We used a threshold of 200 reads at this step. One could choose a lower threshold, for example 100 reads, depending on how deep and low coverage one wants to explore and the available resources.

```bash
awk '$3 > 200' all_krakenuniq_potential_pathogens_ratio.tsv   > all_krakenuniq_potential_pathogens_ratio_200_reads.tsv
```

Here `$3` is the read count column.

When inspecting `all_krakenuniq_potential_pathogens_ratio_200_reads.tsv`, the top entries are usually the main pathogens already identified by aMeta. In this dataset we saw

- *Mycobacterium leprae* in sample s.313  
- Index hopping of *M. leprae* into s.197_A  
- *Streptococcus pneumoniae* in s.155

## Manual review along the ratio gradient

We then worked down the file ordered by decreasing k-mers/reads ratio, and visually inspected candidates down to a ratio of about 1.5. Below this threshold the list becomes increasingly noisy and less informative.

For each candidate pathogen species encountered, we checked the aMeta authentication plots, even when the aMeta score was low. In most cases the edit distance distribution indicated that the assignment was not reliable.

If the same species repeatedly showed non convincing authentication plots across several samples, and later appeared again with fewer than 100 taxReads (so that aMeta did not generate authentication plots for it), we inferred that it likely represented the same type of contamination pattern at this site and did not investigate those further.

Only two candidates produced convincing authentication patterns given their genomic properties (full or partial single strandedness and relatively higher mutation rate compared to bacteria):

- Hepatitis B virus (HBV) in s.167  
- Primate erythroparvovirus 1 (B19V) in s.315  

Most other viral hits were not human pathogens. This is expected because the pathogen list used in this step only required the word "virus" in the name, in order not to miss obscure viral taxa. Including all virus names explicitly would have made the list unwieldy.

## Re-screening HBV and B19V with a relaxed ratio threshold

Once HBV and B19V had been confirmed at the site, we revisited the KrakenUniq results and extracted all occurrences of these viruses with a k-mers/reads ratio greater than 1 and no read count filter. This provided a broader set of potential detections to consider.

In hindsight, this ratio threshold is probably strict for B19V. Its small genome can reach high coverage with strong duplication, which can push the k-mers/reads ratio below 1 even for real infections. In this dataset we checked explicitly that this did not affect our conclusions, but in other studies one might want to relax the ratio threshold for B19V.

To populate the supplementary tables with KrakenUniq information for these potential detections we used simple `grep` queries on the ratio file:

```bash
# HBV candidates
grep "Hepatitis" all_krakenuniq_potential_pathogens_ratio.tsv
# returned 7 potential detections

# B19V candidates
grep "Primate erythroparvovirus 1" all_krakenuniq_potential_pathogens_ratio.tsv
# returned 11 potential detections in this dataset
```

By request of the microbial expert reviewer, we also extended the supplementary tables to include the same KrakenUniq summaries for all potential detections and all aMeta score based detections of *M. leprae*, *S. pneumoniae* and *P. micra*.

## Read extraction and BLAST confirmation

For promising candidates we extracted the corresponding reads from the MALT FASTA output, mapped them and confirmed species assignment with BLAST. The relevant wrapper and post-processing scripts are:

- MALT read extraction  
  - `extract_MaltExtract_reads.sh`  
  - `post_extract_MaltExtract_reads.sh`  

- BLAST confirmation of mapping  
  - `blast_confirm_mapping.sh`  
  - `post_blast_confirm_mapping.sh`  

These wrapper scripts are followed by species specific BLAST summarisation scripts:

- `summarise_blast_bit_delta_*.py`

These compute a bit score difference (delta) between the target species and alternative hits:

- For viral targets (B19V and HBV) we required a delta of at least 6  
- For bacterial targets (*M. leprae*, *S. pneumoniae* and *P. micra*) we required a delta of at least 5  

These thresholds ensured that the best hit was consistently favoured over alternative species.

## Practical recommendations

Based on this and other datasets, I would recommend systematic screening for B19V in any ancient DNA dataset, since it appears to be very common and remains a persistent infection in a large fraction of the present day population. HBV is also a strong candidate for routine screening, at least for medieval contexts studied so far.

Both viruses have genomic characteristics that make them easy to miss for many detection tools. Combining aMeta authentication scores, KrakenUniq k-mers/reads ratios and targeted BLAST confirmation provides a practical strategy to detect such pathogens in complex metagenomic data.
