#!/usr/bin/env bash
# ==============================================================================
# Pipeline: Whole Genome Sequencing Analysis & De Novo Hybrid Assembly
# Organism: Lactiplantibacillus pentosus LP309
# Data:     Illumina NovaSeq 6000 (ERR15819122) + Oxford Nanopore MinION (ERR15819127)
# Standard: Fully Modular Linux Shell-Based Pipeline
# ==============================================================================

set -euo pipefail

# ANSI color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

log_header() {
    echo -e "\n${BOLD}${CYAN}====================================================================${NC}"
    echo -e "${BOLD}${CYAN}>>> $1${NC}"
    echo -e "${BOLD}${CYAN}====================================================================${NC}"
}

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${PROJECT_DIR}"

log_header "WHOLE GENOME SEQUENCING ANALYSIS PIPELINE: LACTIPLANTIBACILLUS PENTOSUS"

# Ensure executable permissions on all shell scripts
chmod +x scripts/*.sh

# Execute modular pipeline stages
log_header "STAGE 1: Quality Control & Trimming"
bash scripts/01_quality_control.sh

log_header "STAGE 2: De Novo Assembly & Evaluation"
bash scripts/02_hybrid_assembly.sh

log_header "STAGE 3: Prokaryotic Genome Annotation"
bash scripts/03_genome_annotation.sh

log_header "STAGE 4: Read Alignment & Coverage Profiling"
bash scripts/04_read_alignment.sh

log_header "STAGE 5: Figures Generation (300 DPI)"
bash scripts/06_generate_figures.sh

log_header "STAGE 6: Humanized Reports Compilation"
bash scripts/05_generate_reports.sh

echo -e "\n${BOLD}${GREEN}====================================================================${NC}"
echo -e "${BOLD}${GREEN}[SUCCESS] Complete WGS Analysis Finished With Zero Errors!${NC}"
echo -e "${BOLD}${GREEN}All reports saved to: outputs/08_reports/${NC}"
echo -e "${BOLD}${GREEN}All figures saved to: outputs/07_figures/${NC}"
echo -e "${BOLD}${GREEN}====================================================================${NC}\n"
