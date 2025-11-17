#!/usr/bin/env python3
import os
import glob
import csv
import re
from collections import defaultdict

# Margin rule: top M. leprae hit must beat best non-target by >= 5 bits
BIT_DELTA = 5.0

# ---- leprosy taxon matching ----
# Accept as target:
#   - Mycobacterium leprae (any strain name)
# Mycobacterium lepromatosis is treated as a separate species (nonTarget).
_LEPRAE_PATTERNS = [
    re.compile(r'\bMycobacterium\s+leprae\b', re.I),
]

def is_target_leprae(name: str) -> bool:
    n = name.strip()
    return any(p.search(n) for p in _LEPRAE_PATTERNS)

# ---- artifact patterns (to ignore completely) ----
# cloning / synthetic constructs and generic vectors
_ARTIFACT_PATTERNS = [
    re.compile(r'^synthetic construct$', re.I),
    re.compile(r'^synthetic\b.*\bMycobacterium\b.*\bleprae\b', re.I),
    re.compile(r'^vector\b', re.I),
    re.compile(r'^cloning vector\b', re.I),
]

def is_artifact(name: str) -> bool:
    n = name.strip()
    return any(p.search(n) for p in _ARTIFACT_PATTERNS)

# ---- sample name extraction ----
def sample_root(path: str) -> str:
    # Filenames like 1769_s.001_blast.tsv -> sample "1769_s.001"
    base = os.path.basename(path)
    if base.endswith("_blast.tsv"):
        base = base[:-len("_blast.tsv")]
    return base.lower()

# ---- parse BLAST outfmt 6 ----
# 1 qseqid | 2 qlen | 3 qstart | 4 qend | 5 sseqid | 6 sacc | 7 staxids | 8 sscinames |
# 9 pident | 10 length | 11 mismatch | 12 gapopen | 13 evalue | 14 bitscore |
# 15 qcovs | 16 qcovhsp | 17 sstart | 18 send
def per_read_hits(tsv_path):
    hits = defaultdict(list)  # qid -> [(bitscore, is_target)]
    with open(tsv_path, encoding="utf-8", errors="ignore") as f:
        for line in f:
            if not line.strip() or line.startswith("#"):
                continue
            p = line.rstrip("\n").split("\t")
            if len(p) < 14:
                continue
            try:
                qid  = p[0]
                name = p[7]          # ssciname
                bits = float(p[13])  # bitscore
            except Exception:
                continue

            # ignore vectors / synthetic constructs completely
            if is_artifact(name):
                continue

            hits[qid].append((bits, is_target_leprae(name)))
    return hits

# ---- classification ----
def classify_read(items):
    """items = list of (bitscore, is_target). Return 'validated', 'ambiguous', or 'nonTarget'."""
    if not items:
        return None

    max_bits = max(b for b, _ in items)
    top = [(b, isT) for b, isT in items if abs(b - max_bits) < 1e-6]

    any_target_top    = any(isT for _, isT in top)
    any_nontarget_top = any((not isT) for _, isT in top)

    if any_target_top and any_nontarget_top:
        return "ambiguous"
    if any_nontarget_top and not any_target_top:
        return "nonTarget"

    # Only M. leprae at the top; check margin to best non-target
    best_non = max((b for b, isT in items if not isT), default=None)
    if best_non is None:
        return "validated"
    return "validated" if (max_bits - best_non) >= BIT_DELTA else "ambiguous"

# ---- main ----
def main():
    # Leprosy BLAST files start with 1769 and end with _blast.tsv
    tsvs = sorted(glob.glob("blast_confirm_results/1769*_blast.tsv"))

    per_ind = {
        "validated": defaultdict(set),
        "ambiguous": defaultdict(set),
        "nonTarget": defaultdict(set),
    }

    for tsv in tsvs:
        indiv = sample_root(tsv)
        hits = per_read_hits(tsv)
        for qid, items in hits.items():
            cls = classify_read(items)
            if cls:
                per_ind[cls][indiv].add(qid)

    samples = sorted(set().union(*[set(d.keys()) for d in per_ind.values()]))

    outname = "blast_confirm_margin_summary_leprae_bitdelta5.tsv"
    with open(outname, "w", newline="") as out:
        w = csv.writer(out, delimiter="\t")
        w.writerow([
            "sample",
            "Mleprae_validated_reads",
            "Mleprae_ambiguous_reads",
            "nonTarget_top_reads"
        ])
        for s in samples:
            v = len(per_ind["validated"][s])
            a = len(per_ind["ambiguous"][s])
            n = len(per_ind["nonTarget"][s])
            w.writerow([s, v, a, n])

    print(f"Written summary to: {outname}")

if __name__ == "__main__":
    main()

