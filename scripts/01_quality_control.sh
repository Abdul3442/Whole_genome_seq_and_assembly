#!/usr/bin/env bash
# ==============================================================================
# Script: 01_quality_control.sh
# Purpose: Preprocessing and quality control for Illumina NovaSeq and ONT reads
# ==============================================================================

set -euo pipefail

ENV_BIN="/home/abdul/miniconda3/envs/grabseqs_env/bin"
LOCAL_BIN="${HOME}/.local/bin"
export PATH="${ENV_BIN}:${LOCAL_BIN}:${PATH}"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

THREADS=4

echo "=========================================================="
echo ">>> STEP 1: Quality Control & Trimming (Linux Shell)"
echo "=========================================================="

mkdir -p outputs/01_qc outputs/02_trimmed

RAW_SHORT_1="01_raw_data/short_read/ERR15819122_1.fastq.gz"
RAW_SHORT_2="01_raw_data/short_read/ERR15819122_2.fastq.gz"
RAW_LONG="01_raw_data/long_read/ERR15819127.fastq.gz"

CLEAN_SHORT_1="outputs/02_trimmed/ERR15819122_1_clean.fastq.gz"
CLEAN_SHORT_2="outputs/02_trimmed/ERR15819122_2_clean.fastq.gz"
CLEAN_LONG="outputs/02_trimmed/ERR15819127_clean.fastq.gz"

# 1. Illumina Trimming
if [ ! -f "${CLEAN_SHORT_1}" ]; then
    echo "[INFO] Running fastp quality filtering on Illumina reads..."
    fastp \
        -i "${RAW_SHORT_1}" -I "${RAW_SHORT_2}" \
        -o "${CLEAN_SHORT_1}" -O "${CLEAN_SHORT_2}" \
        --detect_adapter_for_pe \
        --trim_poly_g \
        -q 20 -u 30 -l 50 \
        -w "${THREADS}" \
        --html outputs/01_qc/fastp.html \
        --json outputs/01_qc/fastp.json
    echo "[SUCCESS] Illumina fastp filtering completed."
else
    echo "[INFO] Clean Illumina reads already present: ${CLEAN_SHORT_1}"
fi

# 2. Nanopore Filtering
if [ ! -f "${CLEAN_LONG}" ]; then
    echo "[INFO] Running seqkit quality & length filtering on Nanopore reads..."
    seqkit seq -m 1000 -Q 10 "${RAW_LONG}" -o "${CLEAN_LONG}"
    seqkit stats -a "${CLEAN_LONG}" > outputs/01_qc/nanopore_clean_stats.txt
    echo "[SUCCESS] Nanopore filtering completed."
else
    echo "[INFO] Clean Nanopore reads already present: ${CLEAN_LONG}"
fi

echo "[SUCCESS] Stage 1 (QC & Trimming) completed successfully."
