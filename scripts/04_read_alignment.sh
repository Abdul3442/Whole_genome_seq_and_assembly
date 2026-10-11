#!/usr/bin/env bash
# ==============================================================================
# Script: 04_read_alignment.sh
# Purpose: Align Illumina (BWA) and Nanopore (Minimap2) reads to assembly
# ==============================================================================

set -euo pipefail

ENV_BIN="/home/abdul/miniconda3/envs/grabseqs_env/bin"
LOCAL_BIN="${HOME}/.local/bin"
export PATH="${ENV_BIN}:${LOCAL_BIN}:${PATH}"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

THREADS=4
ASM_FASTA="outputs/03_assembly/flye_assembly/assembly.fasta"
ALN_DIR="outputs/06_alignment"

CLEAN_SHORT_1="outputs/02_trimmed/ERR15819122_1_clean.fastq.gz"
CLEAN_SHORT_2="outputs/02_trimmed/ERR15819122_2_clean.fastq.gz"
CLEAN_LONG="outputs/02_trimmed/ERR15819127_clean.fastq.gz"

echo "=========================================================="
echo ">>> STEP 4: Read Alignment & BAM Indexing (Linux Shell)"
echo "=========================================================="

mkdir -p "${ALN_DIR}"

# 1. Nanopore Mapping
if [ ! -f "${ALN_DIR}/nanopore_mapped.bam" ]; then
    echo "[INFO] Aligning Oxford Nanopore reads with Minimap2..."
    minimap2 -ax map-ont -t "${THREADS}" "${ASM_FASTA}" "${CLEAN_LONG}" | \
        samtools sort -@ "${THREADS}" -o "${ALN_DIR}/nanopore_mapped.bam"
    samtools index "${ALN_DIR}/nanopore_mapped.bam"
    samtools flagstat "${ALN_DIR}/nanopore_mapped.bam" > "${ALN_DIR}/nanopore_flagstat.txt"
    echo "[SUCCESS] Nanopore mapping completed."
else
    echo "[INFO] Nanopore BAM already exists: ${ALN_DIR}/nanopore_mapped.bam"
fi

# 2. Illumina Mapping
if [ ! -f "${ALN_DIR}/illumina_mapped.bam" ]; then
    echo "[INFO] Indexing and aligning Illumina reads with BWA-MEM..."
    bwa index "${ASM_FASTA}"
    bwa mem -t "${THREADS}" "${ASM_FASTA}" "${CLEAN_SHORT_1}" "${CLEAN_SHORT_2}" | \
        samtools sort -@ "${THREADS}" -o "${ALN_DIR}/illumina_mapped.bam"
    samtools index "${ALN_DIR}/illumina_mapped.bam"
    samtools flagstat "${ALN_DIR}/illumina_mapped.bam" > "${ALN_DIR}/illumina_flagstat.txt"
    echo "[SUCCESS] Illumina mapping completed."
else
    echo "[INFO] Illumina BAM already exists: ${ALN_DIR}/illumina_mapped.bam"
fi

echo "[SUCCESS] Stage 4 (Alignment) completed successfully."
