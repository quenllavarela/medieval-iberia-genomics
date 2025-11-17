from Bio import Entrez, SeqIO
import os

# Load the modules in your bash before running this python script like this
# module load PDC/23.12 biopython/1.84-cpeGNU-23.12

# Replace with your email
Entrez.email = "zoe.pochon@gmail.com"

# List of accession numbers
accessions = [
    "AJ781038", "KM393165", "KM393168", "KM393166", "AB126267", "AB126266", "KM065415",
    "KC013340", "KT310174", "DQ225150", "DQ225149", "KR005641", "KR005640", "AY386330", "KM393163",
    "M13178", "FN598218", "Z70560", "Z68146", "DQ408301", "AB030673", "KM393164", "KC013329",
    "KC013325", "KT268312", "KC013305", "AF113323", "Z70599", "AY504945", "AB126271", "AB126262",
    "AB126269", "AF162273", "FJ591158", "KC013343", "KC013324", "KC013308", "KM393169", "AB030694",
    "DQ293995", "KC013316", "DQ225151", "KC013321", "KC013312", "KC013333", "KC013346", "KC013313",
    "KC013327", "AB126265", "AB126270", "DQ357065", "DQ357064", "KF724387", "AY903437", "AY044266",
    "DQ333426", "AB550331", "EF216869", "AJ717293", "KF724386", "DQ333428", "AY064476", "AY064475",
    "AY647977", "AY083234", "AY582124", "DQ234779", "DQ234778", "DQ408305", "DQ408302",
    "DQ408304", "DQ408303", "FJ265736", "DQ234775", "DQ234771", "DQ234769", "AJ249437"
]

# Create output directory called 'fastas'
output_dir = "fastas"
os.makedirs(output_dir, exist_ok=True)

# Download each genome in FASTA format
for acc in accessions:
    try:
        print(f"Downloading {acc}...")
        handle = Entrez.efetch(db="nucleotide", id=acc, rettype="fasta", retmode="text")
        record = handle.read()
        with open(os.path.join(output_dir, f"{acc}.fasta"), "w") as out_file:
            out_file.write(record)
    except Exception as e:
        print(f"Failed to download {acc}: {e}")
