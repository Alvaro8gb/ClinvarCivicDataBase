#!/bin/bash

DATA_PATH="data"

DATA_PATH_CLINVAR="$DATA_PATH/clinvar"
DATA_PATH_CIVIC="$DATA_PATH/civic"


CLINVAR_URL="https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/archive"
CIVIC_URL="https://civicdb.org/downloads"


echo "DEBUG: Creando directorio ClinVar en: $DATA_PATH_CLINVAR"
mkdir -p "$DATA_PATH_CLINVAR"

echo "DEBUG: Descargando archivos de ClinVar desde: $CLINVAR_URL"

files_clinvar=(
    "variant_summary_2025-01.txt.gz"
    "gene_specific_summary_2025-01.txt.gz"
    "submission_summary_2025-01.txt.gz"
)

for file in "${files_clinvar[@]}"; do
    echo "DEBUG: Intentando descargar: $CLINVAR_URL/$file"
    wget -nc -P "$DATA_PATH_CLINVAR" "$CLINVAR_URL/$file"
done

echo "---"

echo "DEBUG: Creando directorio CIViC en: $DATA_PATH_CIVIC"
mkdir -p "$DATA_PATH_CIVIC"

CIVIC_FILE="01-Jan-2026-VariantSummaries.tsv"
CIVIC_FULL_URL="$CIVIC_URL/01-Jan-2026/$CIVIC_FILE"

echo "DEBUG: Descargando CIViC desde: $CIVIC_FULL_URL"
wget -nc -P "$DATA_PATH_CIVIC" "$CIVIC_FULL_URL"
