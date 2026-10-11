# Whole Genome Sequencing & Hybrid De Novo Assembly
### *Lactiplantibacillus pentosus* strain LP309

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-green.svg)]()
[![Assembly: Complete](https://img.shields.io/badge/Genome-3.795_Mbp-brightgreen.svg)]()
[![Plasmids: 7](https://img.shields.io/badge/Circular_Plasmids-7_Resolved-orange.svg)]()

This repository contains an end-to-end, reproducible Whole Genome Sequencing (WGS) and de novo hybrid assembly workflow for **_Lactiplantibacillus pentosus_ LP309** (NCBI TaxID: 1589). The pipeline integrates high-accuracy Illumina NovaSeq 6000 short reads with Oxford Nanopore MinION long reads to resolve the host chromosome and 7 circular closed plasmids.

---

## 🔬 Genomic Summary & Key Metrics

* **Organism**: *Lactiplantibacillus pentosus* (Strain LP309)
* **Total Assembled Size**: **3,795,120 bp (~3.795 Mbp)**
* **Assembly N50**: **2,156,644 bp (>2.15 Mbp)** ($L50 = 1$)
* **Assembly N75**: **1,353,778 bp (>1.35 Mbp)** ($L75 = 2$)
* **Overall GC Content**: **46.07%**
* **Replicons Resolved**: Core chromosome (~3.55 Mbp) + **7 circular closed plasmids** (8.4 kb to 65.6 kb)
* **Predicted CDS (Genes)**: **3,525 protein-coding genes** (Prodigal v2.6.3)
* **Read Alignment Rate**: **99.98%** (Nanopore) | **99.58%** (Illumina)

---

## 📊 Publication Figures

### Figure 1: Circular Genome Atlas
Chromosome Contig 1 (2.16 Mbp), Forward/Reverse Coding Sequences, GC Content & GC Skew dynamics:
![Figure 1](outputs/07_figures/Figure1_circular_genome_map.png)

### Figure 2: Sequencing QC & Trimming Diagnostics
Illumina per-cycle quality progression, GC dynamics, and Nanopore length distribution:
![Figure 2](outputs/07_figures/Figure2_qc_and_trimming_profiles.png)

### Figure 3: De Novo Assembly Contiguity & Structural Resolution
Cumulative assembly length progression, contig coverage spectrum, and plasmid architecture:
![Figure 3](outputs/07_figures/Figure3_assembly_contiguity_curves.png)

### Figure 4: Hybrid Read Depth of Coverage Profiles
Chromosome-wide Illumina NovaSeq (~680X) and Oxford Nanopore (~159X) coverage uniformity:
![Figure 4](outputs/07_figures/Figure4_genome_coverage_depth.png)

### Figure 5: Functional Genome Annotation Breakdown
CDS length spectrum, canonical (ATG 83.6%) & alternative start codon usage, and replicon gene density:
![Figure 5](outputs/07_figures/Figure5_functional_annotation_summary.png)

---

## 🧬 Replicon Architecture Table

| Replicon | Length (bp) | GC (%) | Depth | Conformation | Biological Classification |
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

## 🚀 Pipeline Execution

Clone the repository and run the automated Linux shell script:

```bash
# Clone the repository
git clone git@github.com:Abdul3442/Whole_genome_seq_and_assembly.git
cd Whole_genome_seq_and_assembly

# Execute the complete analysis pipeline
./Analysis.sh
```

### Modular Scripts
Individual workflow stages can also be executed independently:
```bash
./scripts/01_quality_control.sh     # Illumina (fastp) & ONT (seqkit) trimming
./scripts/02_hybrid_assembly.sh      # Flye de novo assembly & QUAST metrics
./scripts/03_genome_annotation.sh    # Prodigal prokaryotic CDS prediction
./scripts/04_read_alignment.sh       # BWA-MEM and Minimap2 read mapping
./scripts/06_generate_figures.sh     # High-resolution 300 DPI figures
./scripts/05_generate_reports.sh     # HTML and text reports compilation
```

---

## 📁 Repository Structure

```text
Whole_genome_seq_and_assembly/
├── Analysis.sh                     # Master pipeline execution script
├── Installation.sh                 # Environment setup and dependencies
├── readme.md                       # Comprehensive project documentation
├── scripts/                        # Modular Linux bash & plotting scripts
│   ├── 01_quality_control.sh
│   ├── 02_hybrid_assembly.sh
│   ├── 03_genome_annotation.sh
│   ├── 04_read_alignment.sh
│   ├── 05_generate_reports.sh
│   ├── 06_generate_figures.sh
│   ├── evaluate_assembly.py
│   ├── generate_assembly_figures.py
│   ├── generate_circular_map.py
│   ├── generate_coverage_figures.py
│   ├── generate_functional_figures.py
│   └── generate_qc_figures.py
└── outputs/
    ├── 03_assembly/flye_assembly/  # assembly.fasta, assembly_info.txt, graph.gfa
    ├── 04_evaluation/              # Assembly metrics TSV and summary
    ├── 05_annotation/              # annotation.gff, proteins.faa, genes.fna
    ├── 06_alignment/               # Alignment flagstat metrics
    ├── 07_figures/                 # 300 DPI PNG and vector PDF publication figures
    └── 08_reports/                 # HTML report, executive summaries, and TSV tables
```

---

## 📄 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
