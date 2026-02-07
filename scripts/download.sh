#!/bin/bash

DATA_PATH="data"

DATA_PATH_CLINVAR="$DATA_PATH/clinvar"
DATA_PATH_CIVIC="$DATA_PATH/civic"


CLINVAR_URL="https://ftp.ncbi.nlm.nih.gov/pub/clinvar/tab_delimited/archive"
CIVIC_URL="https://civicdb.org/downloads"

DATE_CLINVAR="2025-12"
DATE_CIVIC="01-Dec-2025"

echo "DEBUG: Creando directorio ClinVar en: $DATA_PATH_CLINVAR"
mkdir -p "$DATA_PATH_CLINVAR"

echo "DEBUG: Descargando archivos de ClinVar desde: $CLINVAR_URL"

files_clinvar=(
    "variant_summary_$DATE_CLINVAR.txt.gz"
    "gene_specific_summary_$DATE_CLINVAR.txt.gz"
    "submission_summary_$DATE_CLINVAR.txt.gz"
)

for file in "${files_clinvar[@]}"; do
    echo "DEBUG: Intentando descargar: $CLINVAR_URL/$file"
    wget -nc -P "$DATA_PATH_CLINVAR" "$CLINVAR_URL/$file"
    hash=$(md5sum $DATA_PATH_CLINVAR/$file | awk '{ print $1 }')
    echo "MD5:  $hash"
done

echo "---"

echo "DEBUG: Creando directorio CIViC en: $DATA_PATH_CIVIC"
mkdir -p "$DATA_PATH_CIVIC"


CIVIC_FILE="$DATE_CIVIC-VariantSummaries.tsv"
CIVIC_FULL_URL="$CIVIC_URL/$DATE_CIVIC/$CIVIC_FILE"

echo "DEBUG: Descargando CIViC desde: $CIVIC_FULL_URL"
wget -nc -P "$DATA_PATH_CIVIC" "$CIVIC_FULL_URL"

hash=$(md5sum $DATA_PATH_CIVIC/$CIVIC_FILE | awk '{ print $1 }')
echo "MD5:  $hash"
