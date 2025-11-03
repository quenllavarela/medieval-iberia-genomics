#!/usr/bin/env python3
"""
convert_to_cM.py

Converts SNP positions (bp) to genetic positions (cM) using a recombination map.
Generates per-chromosome cM files for RFMix input.

Usage:
    python3 convert_to_cM.py --input /path/to/snp_files/ --recomb_map /path/to/recombination_maps/ --output /path/to/output/

Dependencies:
    pandas, numpy
"""

import pandas as pd
import numpy as np
import os
import argparse

# --------------------------
# Argument parsing
# --------------------------
parser = argparse.ArgumentParser(description="Convert SNP positions to centimorgans (cM) per chromosome.")
parser.add_argument('--input', required=True, help="Folder with chromosome SNP files (e.g., chr1.txt, chr2.txt, ...)")
parser.add_argument('--recomb_map', required=True, help="Folder with chromosome recombination maps (e.g., chr1.b38.txt)")
parser.add_argument('--output', required=True, help="Output folder for cM files")
args = parser.parse_args()

input_dir = args.input
recomb_dir = args.recomb_map
output_dir = args.output

# Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# --------------------------
# Process chromosomes 1-22
# --------------------------
for chrom in range(1, 23):
    print(f"Processing chromosome {chrom}...")

    # Load SNP positions for this chromosome
    snps_file = os.path.join(input_dir, f"chr{chrom}.txt")
    snps_positions = pd.read_csv(snps_file, sep=":", header=None, names=["chrom", "pos"])
    snps_positions["pos"] = snps_positions["pos"].astype(int)

    # Load recombination map for this chromosome
    recomb_file = os.path.join(recomb_dir, f"chr{chrom}.b38.txt")
    recomb_map = pd.read_csv(recomb_file, sep="\t")

    # Interpolate SNP positions in bp to cM
    snps_positions['cM'] = np.interp(
        snps_positions['pos'],
        recomb_map['pos'],
        recomb_map['cM']
    )

    # Save only the cM values
    output_file = os.path.join(output_dir, f"chr{chrom}_snps_only_cM.txt")
    snps_positions['cM'].to_csv(output_file, index=False, header=False, float_format="%.10f")

print("All chromosomes processed successfully!")
