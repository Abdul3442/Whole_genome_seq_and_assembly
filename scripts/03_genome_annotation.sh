#!/usr/bin/env bash
# ==============================================================================
# Script: 03_genome_annotation.sh
# Purpose: Prokaryotic structural and functional genome annotation with Prodigal
# ==============================================================================

set -euo pipefail

ENV_BIN="/home/abdul/miniconda3/envs/grabseqs_env/bin"
LOCAL_BIN="${HOME}/.local/bin"
export PATH="${ENV_BIN}:${LOCAL_BIN}:${PATH}"

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

ASM_FASTA="outputs/03_assembly/flye_assembly/assembly.fasta"
ANNOT_DIR="outputs/05_annotation"

echo "=========================================================="
echo ">>> STEP 3: Prokaryotic Genome Annotation (Linux Shell)"
echo "=========================================================="

mkdir -p "${ANNOT_DIR}"

if [ ! -f "${ANNOT_DIR}/proteins.faa" ]; then
    echo "[INFO] Running Prodigal prokaryotic gene finding..."
    prodigal \
        -i "${ASM_FASTA}" \
        -o "${ANNOT_DIR}/annotation.gff" \
        -f gff \
        -a "${ANNOT_DIR}/proteins.faa" \
        -d "${ANNOT_DIR}/genes.fna"
    echo "[SUCCESS] Prodigal gene prediction completed."
else
    echo "[INFO] Annotation files already exist in ${ANNOT_DIR}"
fi

CDS_COUNT=$(grep -c -v '^#' "${ANNOT_DIR}/annotation.gff" || true)
echo "[INFO] Total predicted coding sequences (CDS): ${CDS_COUNT}"
echo "[SUCCESS] Stage 3 (Annotation) completed successfully."
