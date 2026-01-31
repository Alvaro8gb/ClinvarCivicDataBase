#!/bin/bash

DATA_PATH="data"

DATA_PATH_CLINVAR="$DATA_PATH/clinvar"
DATA_PATH_CIVIC="$DATA_PATH/civic"


CLINVAR_URL="https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/archive"
CIVIC_URL="https://civicdb.org/downloads"


mkdir -p "$DATA_PATH_CLINVAR"
mkdir -p "$DATA_PATH_CIVIC"


wget -nc -P "$DATA_PATH_CLINVAR" "$CLINVAR_URL/variant_summary_2025-01.txt.gz"
wget -nc -P "$DATA_PATH_CLINVAR" "$CLINVAR_URL/gene_specific_summary_2025-01.txt.gz"
wget -nc -P "$DATA_PATH_CLINVAR" "$CLINVAR_URL/submission_summary_2025-01.txt.gz"


wget -nc -P "$DATA_PATH_CIVIC" "$CIVIC_URL/01-Jan-2026/01-Jan-2026-VariantSummaries.tsv"

