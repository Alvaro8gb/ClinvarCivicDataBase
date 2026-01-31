#!/bin/bash

DATA_PATH="data"
DUMP_PATH="dumps"

DATA_PATH_CLINVAR="$DATA_PATH/clinvar"
DATA_PATH_CIVIC="$DATA_PATH/civic"


mkdir -p "$DUMP_PATH"

python clinvar_variant_parser.py \
    $DUMP_PATH/clinvar_variant.db \
    $DATA_PATH_CLINVAR/variant_summary_2025-01.txt.gz

python clinvar_gene_parser.py \
    $DUMP_PATH/clinvar_gene.db \
    $DATA_PATH_CLINVAR/gene_specific_summary_2025-01.txt.gz

python civic_variant_parser.py \
    $DUMP_PATH/civiv_variant.db \
    $DATA_PATH_CIVIC/01-Jan-2026-VariantSummaries.tsv
