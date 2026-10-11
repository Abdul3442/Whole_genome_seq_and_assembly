#!/usr/bin/env python3
"""
Publication-Quality Figure 5: Functional Genomic Annotation & CDS Profile
Author: Antigravity WGS Pipeline
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from Bio import SeqIO

plt.rcParams.update({
    'font.family': 'sans-serif',
    'font.sans-serif': ['DejaVu Sans', 'Arial', 'Helvetica'],
    'font.size': 10,
    'axes.labelsize': 11,
    'axes.titlesize': 12,
    'xtick.labelsize': 9,
    'ytick.labelsize': 9,
    'legend.fontsize': 9,
    'figure.titlesize': 14,
    'figure.dpi': 300,
    'axes.spines.top': False,
    'axes.spines.right': False,
    'axes.linewidth': 1.1,
    'grid.alpha': 0.3,
    'grid.linestyle': '--'
})

def main():
    # Parse Prodigal proteins and genes
    prot_records = list(SeqIO.parse("outputs/05_annotation/proteins.faa", "fasta"))
    gene_records = list(SeqIO.parse("outputs/05_annotation/genes.fna", "fasta"))
    
    gene_lens = [len(r.seq) for r in gene_records]
    prot_lens = [len(r.seq) for r in prot_records]
    
    # Parse Prodigal headers for start codons & coding scores
    # Prodigal header format: >ID # start # stop # strand # ID=...;partial=00;start_type=ATG;rbs_motif=...
    start_codons = {'ATG': 0, 'GTG': 0, 'TTG': 0, 'Other': 0}
    coding_densities = {}
    
    for r in prot_records:
        header = r.description
        st = 'Other'
        for part in header.split(';'):
            if part.startswith('start_type='):
                st = part.split('=')[1]
                break
        if st in start_codons:
            start_codons[st] += 1
        else:
            start_codons['Other'] += 1
            
        contig_name = r.id.rsplit('_', 1)[0]
        coding_densities[contig_name] = coding_densities.get(contig_name, 0) + 1

    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    fig.patch.set_facecolor('white')

    # ---------------------------------------------------------
    # Panel A: CDS Length Spectrum
    # ---------------------------------------------------------
    ax = axes[0, 0]
    sns.histplot(gene_lens, bins=60, kde=True, color='#0072B5', ax=ax, edgecolor='none', alpha=0.7)
    med_len = np.median(gene_lens)
    mean_len = np.mean(gene_lens)
    ax.axvline(med_len, color='#E64B35', lw=1.8, linestyle='--', label=f'Median CDS: {med_len:.0f} bp')
    ax.axvline(mean_len, color='#3C5488', lw=1.5, linestyle=':', label=f'Mean CDS: {mean_len:.0f} bp')

    ax.set_xlim(0, 4000)
    ax.set_xlabel('Predicted Coding Sequence Length (bp)')
    ax.set_ylabel('Number of Genes (CDS)')
    ax.set_title('A. Predicted CDS Length Spectrum (Total: 3,525 CDS)', fontweight='bold', loc='left')
    ax.legend(frameon=True, facecolor='#F8F9FA', edgecolor='none')
    ax.grid(True)

    # ---------------------------------------------------------
    # Panel B: Translation Initiation & Start Codon Usage
    # ---------------------------------------------------------
    ax = axes[0, 1]
    labels = list(start_codons.keys())
    counts = list(start_codons.values())
    total_genes = sum(counts)
    pcts = [(c / total_genes) * 100 for c in counts]
    colors = ['#00A087', '#4DBBD5', '#E64B35', '#7F7F7F']

    bars = ax.bar(labels, pcts, color=colors, alpha=0.9, width=0.5, edgecolor='none')
    ax.set_ylabel('Proportion of Total CDS (%)')
    ax.set_title('B. Canonical & Alternative Start Codon Frequencies', fontweight='bold', loc='left')
    ax.grid(axis='y')

    for bar, count in zip(bars, counts):
        height = bar.get_height()
        ax.annotate(f'{height:.1f}%\n(n={count:,})',
                    xy=(bar.get_x() + bar.get_width() / 2, height),
                    xytext=(0, 4), textcoords="offset points",
                    ha='center', va='bottom', fontsize=8.5, fontweight='bold', color='#333333')
    ax.set_ylim(0, max(pcts) * 1.2)

    # ---------------------------------------------------------
    # Panel C: Gene Density Across Genomic Replicons
    # ---------------------------------------------------------
    ax = axes[1, 0]
    df_asm = pd.read_csv("outputs/04_evaluation/assembly_metrics.tsv", sep='\t')
    df_asm['CDS_Count'] = [coding_densities.get(cid, 0) for cid in df_asm['Contig_ID']]
    df_asm['Gene_Density_per_kb'] = (df_asm['CDS_Count'] / df_asm['Length_bp']) * 1000

    y_pos = np.arange(len(df_asm))
    bar_cols = ['#2E75B6' if 'Chromosome' in c else '#E64B35' if 'plasmid' in c else '#7F7F7F' for c in df_asm['Classification']]
    bars = ax.barh(y_pos, df_asm['CDS_Count'], color=bar_cols, alpha=0.85, edgecolor='none')
    ax.set_yticks(y_pos)
    ax.set_yticklabels([f"{r['Contig_ID']} ({'Plasmid' if r['Circular']=='Y' else 'Chrom/Ctg'})" for _, r in df_asm.iterrows()])
    ax.invert_yaxis()
    ax.set_xlabel('Annotated Coding Sequences (CDS)')
    ax.set_title('C. Gene Distribution Across Host Chromosome & 7 Plasmids', fontweight='bold', loc='left')
    ax.grid(axis='x')

    for bar, (_, r) in zip(bars, df_asm.iterrows()):
        width = bar.get_width()
        dens = r['Gene_Density_per_kb']
        ax.annotate(f"{int(width):,} CDS ({dens:.2f} genes/kb)",
                    xy=(width, bar.get_y() + bar.get_height() / 2),
                    xytext=(5, 0), textcoords="offset points",
                    ha='left', va='center', fontsize=8, color='#333333')

    # ---------------------------------------------------------
    # Panel D: GC Content of Coding vs. Global Genome
    # ---------------------------------------------------------
    ax = axes[1, 1]
    cds_gc = []
    for g in gene_records:
        seq = str(g.seq).upper()
        gc = ((seq.count('G') + seq.count('C')) / len(seq)) * 100
        cds_gc.append(gc)

    sns.kdeplot(cds_gc, color='#00A087', lw=2.4, ax=ax, label=f'CDS Coding GC (Mean = {np.mean(cds_gc):.2f}%)', fill=True, alpha=0.2)
    ax.axvline(46.07, color='#3C5488', lw=1.8, linestyle='--', label='Whole Genome GC (46.07%)')
    ax.axvline(np.mean(cds_gc), color='#00A087', lw=1.8, linestyle=':', label=f'Mean CDS GC ({np.mean(cds_gc):.2f}%)')

    ax.set_xlabel('GC Content (%)')
    ax.set_ylabel('Density')
    ax.set_title('D. Coding Sequence GC Content Profile', fontweight='bold', loc='left')
    ax.legend(frameon=True, facecolor='#F8F9FA', edgecolor='none')
    ax.grid(True)

    plt.suptitle("Figure 5: High-Resolution Structural & Functional Genome Annotation\n"
                 "Lactiplantibacillus pentosus LP309 (Prodigal Prokaryotic Annotation: 3,525 CDS)",
                 fontsize=13, fontweight='bold', y=0.995)
    plt.tight_layout(rect=[0, 0, 1, 0.96])

    png_path = "outputs/07_figures/Figure5_functional_annotation_summary.png"
    pdf_path = "outputs/07_figures/Figure5_functional_annotation_summary.pdf"
    plt.savefig(png_path, dpi=300)
    plt.savefig(pdf_path)
    plt.close()
    print(f"Figure 5 successfully saved to {png_path} and {pdf_path}")

if __name__ == '__main__':
    main()
