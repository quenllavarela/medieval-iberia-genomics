#!/usr/bin/env python3
import os
import glob
import csv
import re
from collections import defaultdict

# Margin rule: top Parvimonas micra hit must beat best non-target by >= 5 bits
BIT_DELTA = 5.0

# ---- Parvimonas micra taxon matching ----
# Accept as target:
#   - Parvimonas micra (any strain name)
# Other Parvimonas spp. (parva, sp. G1604, sp. G1425) are treated as nonTarget.
_PMICRA_PATTERNS = [
    re.compile(r'\bParvimonas\s+micra\b', re.I),
]

def is_target_pmicra(name: str) -> bool:
    name_stripped = name.strip()
    return any(pattern.search(name_stripped) for pattern in _PMICRA_PATTERNS)

# ---- artifact patterns (to ignore completely) ----
# cloning / synthetic constructs and generic vectors
_ARTIFACT_PATTERNS = [
    re.compile(r'^synthetic construct$', re.I),
    re.compile(r'^vector\b', re.I),
    re.compile(r'^cloning vector\b', re.I),
]

def is_artifact(name: str) -> bool:
    name_stripped = name.strip()
    return any(pattern.search(name_stripped) for pattern in _ARTIFACT_PATTERNS)

# ---- sample name extraction ----
def sample_root(path: str) -> str:
    # Filenames like 33033_s.001_blast.tsv -> sample "33033_s.001"
    base_name = os.path.basename(path)
    if base_name.endswith("_blast.tsv"):
        base_name = base_name[:-len("_blast.tsv")]
    return base_name.lower()

# ---- parse BLAST outfmt 6 ----
# 1 qseqid | 2 qlen | 3 qstart | 4 qend | 5 sseqid | 6 sacc | 7 staxids | 8 sscinames |
# 9 pident | 10 length | 11 mismatch | 12 gapopen | 13 evalue | 14 bitscore |
# 15 qcovs | 16 qcovhsp | 17 sstart | 18 send
def per_read_hits(tsv_path):
    hits = defaultdict(list)  # qid -> [(bitscore, is_target)]
    with open(tsv_path, encoding="utf-8", errors="ignore") as handle:
        for line in handle:
            if not line.strip() or line.startswith("#"):
                continue
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 14:
                continue
            try:
                query_id = parts[0]
                taxon_name = parts[7]          # ssciname
                bit_score = float(parts[13])   # bitscore
            except Exception:
                continue

            # ignore vectors / synthetic constructs completely
            if is_artifact(taxon_name):
                continue

            hits[query_id].append((bit_score, is_target_pmicra(taxon_name)))
    return hits

# ---- classification ----
def classify_read(items):
    """items = list of (bitscore, is_target). Return 'validated', 'ambiguous', or 'nonTarget'."""
    if not items:
        return None

    max_bitscore = max(bits for bits, _ in items)
    top_hits = [(bits, is_target) for bits, is_target in items if abs(bits - max_bitscore) < 1e-6]

    any_target_top = any(is_target for _, is_target in top_hits)
    any_nontarget_top = any((not is_target) for _, is_target in top_hits)

    if any_target_top and any_nontarget_top:
        return "ambiguous"
    if any_nontarget_top and not any_target_top:
        return "nonTarget"

    # Only Parvimonas micra at the top; check margin to best non-target
    best_non = max((bits for bits, is_target in items if not is_target), default=None)
    if best_non is None:
        return "validated"
    return "validated" if (max_bitscore - best_non) >= BIT_DELTA else "ambiguous"

# ---- main ----
def main():
    # Parvimonas BLAST files start with 33033 and end with _blast.tsv
    tsv_paths = sorted(glob.glob("blast_confirm_results/33033*_blast.tsv"))

    per_individual = {
        "validated": defaultdict(set),
        "ambiguous": defaultdict(set),
        "nonTarget": defaultdict(set),
    }

    for tsv_path in tsv_paths:
        sample = sample_root(tsv_path)
        hits = per_read_hits(tsv_path)
        for query_id, items in hits.items():
            classification = classify_read(items)
            if classification:
                per_individual[classification][sample].add(query_id)

    samples = sorted(set().union(*[set(mapping.keys()) for mapping in per_individual.values()]))

    output_name = "blast_confirm_margin_summary_pmicra_bitdelta5.tsv"
    with open(output_name, "w", newline="") as output_handle:
        writer = csv.writer(output_handle, delimiter="\t")
        writer.writerow([
            "sample",
            "Pmicra_validated_reads",
            "Pmicra_ambiguous_reads",
            "nonTarget_top_reads"
        ])
        for sample in samples:
            validated_count = len(per_individual["validated"][sample])
            ambiguous_count = len(per_individual["ambiguous"][sample])
            nontarget_count = len(per_individual["nonTarget"][sample])
            writer.writerow([sample, validated_count, ambiguous_count, nontarget_count])

    print(f"Written summary to: {output_name}")

if __name__ == "__main__":
    main()

