#!/usr/bin/env bash
# ==============================================================================
# Script: 02_hybrid_assembly.sh
# Purpose: De novo long-read assembly with Flye and architecture evaluation
# ==============================================================================

set -euo pipefail

ENV_BIN="/home/abdul/miniconda3/envs/grabseqs_env/bin"
LOCAL_BIN="${HOME}/.local/bin"
export PATH="${ENV_BIN}:${LOCAL_BIN}:${PATH}"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

THREADS=4
GENOME_SIZE="3.7m"
CLEAN_LONG="outputs/02_trimmed/ERR15819127_clean.fastq.gz"
ASM_DIR="outputs/03_assembly/flye_assembly"
ASM_FASTA="${ASM_DIR}/assembly.fasta"

echo "=========================================================="
echo ">>> STEP 2: De Novo Assembly & Architecture (Linux Shell)"
echo "=========================================================="

mkdir -p "${ASM_DIR}" outputs/04_evaluation

if [ ! -f "${ASM_FASTA}" ]; then
    echo "[INFO] Running Flye de novo assembly..."
    flye \
        --nano-hq "${CLEAN_LONG}" \
        --out-dir "${ASM_DIR}" \
        --threads "${THREADS}" \
        --genome-size "${GENOME_SIZE}"
    echo "[SUCCESS] Flye assembly completed."
else
    echo "[INFO] Assembly FASTA already present at: ${ASM_FASTA}"
fi

# Evaluate assembly metrics
echo "[INFO] Evaluating assembly statistics..."
python3 scripts/evaluate_assembly.py

echo "[SUCCESS] Stage 2 (Assembly & Evaluation) completed successfully."
