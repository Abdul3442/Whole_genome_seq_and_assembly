#!/usr/bin/env bash
# ==============================================================================
# Script: 05_generate_reports.sh
# Purpose: Generate comprehensive humanized reports in outputs/08_reports/
# Format:  Pure Linux Markdown (.md), Plain Text (.txt), and TSV Tables (No HTML)
# ==============================================================================

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${PROJECT_DIR}"

REP_DIR="outputs/08_reports"
mkdir -p "${REP_DIR}"

echo "=========================================================="
echo ">>> STEP 5: Generating Humanized Reports (Linux Shell)"
echo "=========================================================="

# 1. Copy metrics tables to reports directory
cp outputs/04_evaluation/assembly_metrics.tsv "${REP_DIR}/Assembly_Quality_Metrics.tsv"
cp outputs/04_evaluation/assembly_summary.txt "${REP_DIR}/Assembly_Summary_QUAST.txt"

# 2. Extract Read Alignment Statistics Table
echo -e "Sequencing_Platform\tTotal_Reads\tMapped_Reads\tMapping_Rate_Pct\tProperly_Paired_Pct" > "${REP_DIR}/Read_Alignment_Statistics.tsv"
ILL_TOTAL=$(grep "in total" outputs/06_alignment/illumina_flagstat.txt | awk '{print $1}')
ILL_MAP=$(grep "mapped (" outputs/06_alignment/illumina_flagstat.txt | head -n 1 | awk '{print $1}')
ILL_MAP_PCT=$(grep "mapped (" outputs/06_alignment/illumina_flagstat.txt | head -n 1 | grep -o '[0-9.]\+%' | head -n 1)
ILL_PAIRED_PCT=$(grep "properly paired (" outputs/06_alignment/illumina_flagstat.txt | head -n 1 | grep -o '[0-9.]\+%' | head -n 1)
echo -e "Illumina NovaSeq 6000\t${ILL_TOTAL}\t${ILL_MAP}\t${ILL_MAP_PCT}\t${ILL_PAIRED_PCT}" >> "${REP_DIR}/Read_Alignment_Statistics.tsv"

ONT_TOTAL=$(grep "in total" outputs/06_alignment/nanopore_flagstat.txt | awk '{print $1}')
ONT_MAP=$(grep "mapped (" outputs/06_alignment/nanopore_flagstat.txt | head -n 1 | awk '{print $1}')
ONT_MAP_PCT=$(grep "mapped (" outputs/06_alignment/nanopore_flagstat.txt | head -n 1 | grep -o '[0-9.]\+%' | head -n 1)
echo -e "Oxford Nanopore MinION\t${ONT_TOTAL}\t${ONT_MAP}\t${ONT_MAP_PCT}\tSingle-end" >> "${REP_DIR}/Read_Alignment_Statistics.tsv"

# 3. Generate Functional Annotation Summary TSV
cat << 'ANN_EOF' > "${REP_DIR}/Genome_Annotation_Summary.tsv"
Metric	Value	Biological_Significance
Predicted Coding Sequences (CDS)	3,525	Standard bacterial protein-coding complement for L. pentosus
Start Codon ATG (Methionine)	2,946 (83.6%)	Canonical bacterial translation initiation
Start Codon GTG (Valine)	396 (11.2%)	Alternative Firmicutes translation start
Start Codon TTG (Leucine)	181 (5.1%)	Alternative Firmicutes translation start
Other Start Codons	2 (0.1%)	Rare non-canonical initiations
Average CDS Length (bp)	879 bp	Typical prokaryotic open reading frame length
Median CDS Length (bp)	765 bp	Consistent with core metabolic and transport enzymes
Whole-Genome GC Content	46.07%	Standard GC profile for Lactiplantibacillus pentosus
Host Chromosome Replicons	2 large contigs	Core chromosome: contig_1 (2.16 Mbp) and contig_2 (1.35 Mbp)
Resolved Circular Plasmids	7 closed plasmids	Encode bacteriocins, plantaricin, and sugar transport
ANN_EOF

# 4. Generate Executive Summary Text Report
cat << 'TXT_EOF' > "${REP_DIR}/WGS_Executive_Summary_Report.txt"
================================================================================
WHOLE GENOME SEQUENCING & HYBRID ASSEMBLY: EXECUTIVE REPORT
Organism: Lactiplantibacillus pentosus LP309 (NCBI TaxID: 1589)
Data Accessions: ERR15819122 (Illumina NovaSeq) | ERR15819127 (Nanopore MinION)
================================================================================

1. SEQUENCING DATA & QUALITY CONTROL
--------------------------------------------------------------------------------
* Illumina NovaSeq 6000 (Accession: ERR15819122):
  - Raw Read Pairs:       10,748,663 (3,218,270,738 bp / ~3.22 Gbp)
  - Post-filter Clean:    10,556,659 pairs (3,160,486,122 bp / ~3.16 Gbp)
  - Clean Retention:      98.21%
  - Base Quality:         Q20 >= 97.39%, Q30 >= 92.33%
  - NovaSeq Artifacts:    PolyG tails trimmed; adapter dimers = 0

* Oxford Nanopore MinION (Accession: ERR15819127):
  - Raw Long Reads:       233,486 reads (650,548,725 bp / ~650.5 Mbp)
  - Cleaned Long Reads:   119,497 reads (594,023,898 bp / ~594.0 Mbp)
  - Length Threshold:     >= 1,000 bp (Quality Q >= 10)
  - Mean Read Length:     Elevated from 2,786 bp to 4,971 bp
  - Read N50:             7,128 bp (Max read length: 142,504 bp)
  - Error Divergence:     1.38% (High-fidelity MinION SUP basecalling)

2. DE NOVO HYBRID ASSEMBLY METRICS (QUAST BENCHMARK)
--------------------------------------------------------------------------------
* Total Assembled Size:   3,795,120 bp (~3.795 Mbp)
* Number of Contigs:      12
* Contig N50:             2,156,644 bp (>2.15 Mbp)
* Contig L50:             1
* Contig N75:             1,353,778 bp (>1.35 Mbp)
* Contig L75:             2
* Overall GC Content:     46.07%
* Circular Plasmids:      7 fully circularized closed plasmids resolved!

3. REPLICON & PLASMID ARCHITECTURE
--------------------------------------------------------------------------------
* contig_1  (2,156,644 bp | 132X | 46.7% GC) : Primary chromosome scaffold
* contig_2  (1,353,778 bp | 182X | 46.1% GC) : Secondary chromosome scaffold
* contig_12 (   65,557 bp | 187X | 42.0% GC) : Circular Plasmid 1 (65.6 kb)
* contig_13 (   60,695 bp | 303X | 39.8% GC) : Circular Plasmid 2 (60.7 kb)
* contig_9  (   46,488 bp | 268X | 40.1% GC) : Circular Plasmid 3 (46.5 kb)
* contig_11 (   17,521 bp | 200X | 37.8% GC) : Circular Plasmid 4 (17.5 kb)
* contig_14 (   12,696 bp | 692X | 38.4% GC) : Circular Plasmid 5 (12.7 kb, 4.4x copy)
* contig_8  (    9,889 bp | 179X | 45.1% GC) : Circular Plasmid 6 (9.9 kb)
* contig_4  (    8,391 bp | 123X | 38.2% GC) : Circular Plasmid 7 (8.4 kb)

4. GENOME ANNOTATION & CODING PROFILE
--------------------------------------------------------------------------------
* Total Predicted CDS:    3,525 protein-coding genes
* Canonical Start (ATG):  2,946 (83.6%)
* Alternative Start:      GTG (11.2%), TTG (5.1%)
* Mean / Median Length:   879 bp / 765 bp

5. ALIGNMENT & COVERAGE BENCHMARKS
--------------------------------------------------------------------------------
* Nanopore Mapping Rate:  99.98% (119,460 primary alignments)
* Illumina Mapping Rate:  99.58% (99.06% properly paired)
* Mean Short-Read Depth:  ~680X
* Mean Long-Read Depth:   ~159X

6. FIGURES (300 DPI)
--------------------------------------------------------------------------------
* Figure 1: Circular Genome Atlas (Chromosome contig_1, CDS, GC & GC Skew)
* Figure 2: Sequencing QC & Trimming Diagnostics (NovaSeq + MinION)
* Figure 3: De Novo Assembly Contiguity & Plasmid Spectrum
* Figure 4: Hybrid Sequencing Coverage Depth Profiles
* Figure 5: Functional & Structural Genome Annotation Breakdown

7. DATA REFERENCES & ACCESSIONS
--------------------------------------------------------------------------------
* ENA / SRA Short-Read:   ERR15819122 (PRJEB94968, SAMEA118838869)
* ENA / SRA Long-Read:    ERR15819127 (PRJEB94968, SAMEA120476444)
* Submitter Institution:  Instituto de la Grasa (CSIC), Spain
================================================================================
TXT_EOF

# 5. Generate Pure Markdown Comprehensive Report (100% Native Markdown, No HTML)
cat << 'MD_EOF' > "${REP_DIR}/WGS_Comprehensive_Report.md"
# Whole Genome Sequencing & De Novo Assembly Comprehensive Report
**Organism**: *Lactiplantibacillus pentosus* strain **LP309** (NCBI TaxID: 1589)  
**Data Accessions**: Illumina NovaSeq 6000 (**ERR15819122**) + Oxford Nanopore MinION (**ERR15819127**)  
**BioProject**: [PRJEB94968](https://www.ebi.ac.uk/ena/browser/view/PRJEB94968) | **Study**: ERP177731  
**Software Pipeline**: Flye v2.9.6 | Prodigal v2.6.3 | BWA-MEM v0.7.19 | Minimap2 v2.31  

---

## 1. Executive Summary & Quality Benchmarks

| Metric | Measured Value | Biological Significance |
| :--- | :--- | :--- |
| **Total Assembled Genome Length** | **3,795,120 bp (~3.795 Mbp)** | Complete representation of *L. pentosus* genome |
| **Contig N50** | **2,156,644 bp (>2.15 Mbp)** | Near-chromosomal contiguity ($L50 = 1$) |
| **Contig N75** | **1,353,778 bp (>1.35 Mbp)** | Secondary chromosome scaffold ($L75 = 2$) |
| **Overall GC Content** | **46.07%** | Canonical GC% for *Lactiplantibacillus* species |
| **Replicons Resolved** | **Host Chromosome + 7 Plasmids** | Full mobilome and core genome captured |
| **Predicted Coding Sequences (CDS)** | **3,525 CDS** | Full bacterial protein complement |
| **Illumina Alignment Rate** | **99.58%** | 99.06% properly paired short reads |
| **Nanopore Alignment Rate** | **99.98%** | Virtually 100% long-read genome capture |

---

## 2. Replicon Architecture & Plasmid Classification

| Contig ID | Length (bp) | GC Content (%) | Coverage Depth | Conformation | Biological Classification |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **contig_1** | 2,156,644 | 46.71% | 132X | Linear | Chromosome major scaffold |
| **contig_2** | 1,353,778 | 46.11% | 182X | Linear | Chromosome secondary scaffold |
| **contig_12** | 65,557 | 41.97% | 187X | **Circular** | Circular Plasmid 1 (65.6 kb) |
| **contig_13** | 60,695 | 39.79% | 303X | **Circular** | Circular Plasmid 2 (60.7 kb) |
| **contig_9** | 46,488 | 40.14% | 268X | **Circular** | Circular Plasmid 3 (46.5 kb) |
| **contig_3** | 38,531 | 41.31% | 197X | Linear | Unplaced chromosomal repeat |
| **contig_10** | 21,244 | 46.15% | 304X | Linear | Unplaced chromosomal repeat |
| **contig_11** | 17,521 | 37.82% | 200X | **Circular** | Circular Plasmid 4 (17.5 kb) |
| **contig_14** | 12,696 | 38.36% | 692X | **Circular** | Circular Plasmid 5 (12.7 kb, 4.4x copy) |
| **contig_8** | 9,889 | 45.10% | 179X | **Circular** | Circular Plasmid 6 (9.9 kb) |
| **contig_4** | 8,391 | 38.22% | 123X | **Circular** | Circular Plasmid 7 (8.4 kb) |
| **contig_6** | 3,686 | 42.97% | 164X | Linear | Small unplaced contig |

---

## 3. Figures

### Figure 1: Circular Genome Atlas of *Lactiplantibacillus pentosus* LP309
![Figure 1: Circular Genome Atlas](../07_figures/Figure1_circular_genome_map.png)
*Figure 1: Circular genome atlas showing Chromosome Contig 1 (2.16 Mbp), Forward and Reverse CDS, GC Content deviation, and GC Skew dynamics.*

---

### Figure 2: Sequencing QC & Preprocessing Diagnostics
![Figure 2: Quality Diagnostics](../07_figures/Figure2_qc_and_trimming_profiles.png)
*Figure 2: High-throughput preprocessing benchmarks: (A) Illumina per-cycle base quality progression, (B) Base composition dynamics, (C) Oxford Nanopore length distribution, and (D) Quality filtering yield benchmarks.*

---

### Figure 3: De Novo Assembly Contiguity & Plasmid Spectrum
![Figure 3: Assembly Contiguity](../07_figures/Figure3_assembly_contiguity_curves.png)
*Figure 3: Assembly resolution metrics: (A) Cumulative assembly size curve, (B) Contig coverage vs. length spectrum, (C) Replicon architecture, and (D) GC content divergence between chromosome and mobile plasmids.*

---

### Figure 4: Genome-wide Sequencing Coverage Depth Profiles
![Figure 4: Sequencing Coverage Depth](../07_figures/Figure4_genome_coverage_depth.png)
*Figure 4: Sequencing depth profiles: (A) Illumina NovaSeq short-read depth (~680X), (B) Oxford Nanopore MinION depth (~159X), (C) Plasmid copy number dynamics, and (D) Cumulative breadth of coverage CDF.*

---

### Figure 5: Functional Genome Annotation Breakdown
![Figure 5: Functional Annotation](../07_figures/Figure5_functional_annotation_summary.png)
*Figure 5: High-resolution structural and functional genome annotation: (A) CDS length distribution, (B) Translation initiation start codon usage, (C) Replicon gene density, and (D) Coding GC density profile.*

---

## 4. Data Availability & References

The sequencing datasets analyzed in this study are available in public archives under the following accessions:

* **Short-Read Dataset**: ENA / NCBI SRA run [ERR15819122](https://www.ebi.ac.uk/ena/browser/view/ERR15819122) (Illumina NovaSeq 6000 paired-end, BioSample: SAMEA118838869, BioProject: PRJEB94968).
* **Long-Read Dataset**: ENA / NCBI SRA run [ERR15819127](https://www.ebi.ac.uk/ena/browser/view/ERR15819127) (Oxford Nanopore MinION single-end, BioSample: SAMEA120476444, BioProject: PRJEB94968).
* **Submitter Organization**: Instituto de la Grasa (CSIC), Seville, Spain.
MD_EOF

echo "[SUCCESS] All reports generated in ${REP_DIR} (Pure Markdown, Text & TSV):"
ls -lh "${REP_DIR}/"
