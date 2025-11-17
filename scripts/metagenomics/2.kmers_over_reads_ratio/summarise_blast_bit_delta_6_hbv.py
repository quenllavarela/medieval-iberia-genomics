#!/usr/bin/env python3
import os
import glob
import csv
import re
from collections import defaultdict

# Margin rule: top HBV hit must beat best non-target by >= 6 bits
BIT_DELTA = 6.0

# ---- HBV taxon matching ----
# Accept:
#   - anything containing "HBV" (HBV genotype A2, HBV1.1, HBV recombinant B/C, ...)
#   - names starting with "Hepatitis B virus" (human HBV and labelled variants)
_HBV_PATTERNS = [
    re.compile(r'HBV', re.IGNORECASE),
    re.compile(r'^hepatitis\s+b\s+virus\b', re.IGNORECASE),
]

def is_target_hbv(name: str) -> bool:
    n = name.strip()
    return any(p.search(n) for p in _HBV_PATTERNS)

# ---- artifact patterns (to ignore completely) ----
# synthetic constructs and vectors, which we neither want as target nor as nonTarget competitors
_ARTIFACT_PATTERNS = [
    re.compile(r'^synthetic construct$', re.I),
    re.compile(r'^vector\b', re.I),
    re.compile(r'^cloning vector\b', re.I),
]

def is_artifact(name: str) -> bool:
    n = name.strip()
    return any(p.search(n) for p in _ARTIFACT_PATTERNS)

# ---- sample name extraction ----
def sample_root(path: str) -> str:
    # Filenames like 10407_s.155_blast.tsv -> sample "10407_s.155"
    base = os.path.basename(path)
    if base.endswith("_blast.tsv"):
        base = base[:-len("_blast.tsv")]
    return base.lower()

# ---- parse BLAST outfmt 6 ----
# outfmt 6 columns:
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

            # ignore synthetic constructs and vectors completely
            if is_artifact(name):
                continue

            hits[qid].append((bits, is_target_hbv(name)))
    return hits

# ---- classification ----
def classify_read(items):
    """items = list of (bitscore, is_target). Return 'validated', 'ambiguous', or 'nonTarget'."""
    if not items:
        return None

    max_bits = max(b for b, _ in items)
    # hits that share the top bitscore (within float tolerance)
    top = [(b, isT) for b, isT in items if abs(b - max_bits) < 1e-6]

    any_target_top    = any(isT for _, isT in top)
    any_nontarget_top = any((not isT) for _, isT in top)

    if any_target_top and any_nontarget_top:
        return "ambiguous"
    if any_nontarget_top and not any_target_top:
        return "nonTarget"

    # Only HBV at the very top; check margin to best non-target
    best_non = max((b for b, isT in items if not isT), default=None)
    if best_non is None:
        return "validated"
    return "validated" if (max_bits - best_non) >= BIT_DELTA else "ambiguous"

# ---- main ----
def main():
    # Files are always in blast_confirm_results and named 10407*_blast.tsv
    tsvs = sorted(glob.glob("blast_confirm_results/10407*_blast.tsv"))

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

    outname = "blast_confirm_margin_summary_hbv_bitdelta6.tsv"
    with open(outname, "w", newline="") as out:
        w = csv.writer(out, delimiter="\t")
        w.writerow([
            "sample",
            "HBV_validated_reads",
            "HBV_ambiguous_reads",
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

