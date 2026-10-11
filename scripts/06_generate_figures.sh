#!/usr/bin/env bash
# ==============================================================================
# Script: 06_generate_figures.sh
# Purpose: Generate 300-DPI figures in outputs/07_figures/
# ==============================================================================

set -euo pipefail

ENV_PYTHON="/home/abdul/miniconda3/envs/grabseqs_env/bin/python"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

mkdir -p outputs/07_figures

echo "=========================================================="
echo ">>> STEP 6: Generating Figures (Linux Shell)"
echo "=========================================================="

echo "[INFO] Generating Figure 1: Circular Genome Map..."
"${ENV_PYTHON}" scripts/generate_circular_map.py

echo "[INFO] Generating Figure 2: Sequencing QC Diagnostics..."
"${ENV_PYTHON}" scripts/generate_qc_figures.py

echo "[INFO] Generating Figure 3: Assembly Contiguity & Plasmids..."
"${ENV_PYTHON}" scripts/generate_assembly_figures.py

echo "[INFO] Generating Figure 4: Sequencing Coverage Depth..."
"${ENV_PYTHON}" scripts/generate_coverage_figures.py

echo "[INFO] Generating Figure 5: Functional Genome Annotation..."
"${ENV_PYTHON}" scripts/generate_functional_figures.py

echo "[SUCCESS] All figures verified:"
ls -lh outputs/07_figures/*.png outputs/07_figures/*.pdf
