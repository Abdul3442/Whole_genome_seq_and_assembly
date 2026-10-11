#!/usr/bin/env python3
"""
Publication-Quality Figure 3: Assembly Contiguity & Size Spectrum
Author: Antigravity WGS Pipeline
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

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
    df = pd.read_csv("outputs/04_evaluation/assembly_metrics.tsv", sep='\t')
    
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))
    fig.patch.set_facecolor('white')

    # Color palette
    c_chrom = '#2E75B6'
    c_plasmid = '#E64B35'
    c_unplaced = '#7F7F7F'

    colors = []
    for ctype in df['Classification']:
        if 'Chromosome' in ctype:
            colors.append(c_chrom)
        elif 'Circular plasmid' in ctype:
            colors.append(c_plasmid)
        else:
            colors.append(c_unplaced)
    df['Color'] = colors

    # ---------------------------------------------------------
    # Panel A: Cumulative Assembly Length Curve
    # ---------------------------------------------------------
    ax = axes[0, 0]
    sorted_lens = np.sort(df['Length_bp'].values)[::-1]
    cum_lens = np.cumsum(sorted_lens) / 1e6
    contig_indices = np.arange(1, len(sorted_lens) + 1)

    ax.step(contig_indices, cum_lens, where='mid', color='#0072B5', lw=2.5, label='Cumulative Assembly Size')
    ax.scatter(contig_indices, cum_lens, color='#0072B5', s=45, zorder=5)

    total_mbp = cum_lens[-1]
    ax.axhline(total_mbp * 0.5, color='#E64B35', linestyle='--', lw=1.2, label=f'N50 threshold (50% = {total_mbp*0.5:.2f} Mbp)')
    ax.axhline(total_mbp, color='#2E75B6', linestyle=':', lw=1.2, label=f'Total Genome ({total_mbp:.2f} Mbp)')

    ax.set_xlabel('Contig Index (Ranked by Length)')
    ax.set_ylabel('Cumulative Length (Mbp)')
    ax.set_title('A. Cumulative Contig Assembly Progression', fontweight='bold', loc='left')
    ax.set_xticks(contig_indices)
    ax.legend(frameon=True, facecolor='#F8F9FA', edgecolor='none')
    ax.grid(True)

    # ---------------------------------------------------------
    # Panel B: Contig Length vs Coverage Spectrum
    # ---------------------------------------------------------
    ax = axes[0, 1]
    for ctype, col in [('Chromosome', c_chrom), ('Circular plasmid', c_plasmid), ('Unplaced contig', c_unplaced)]:
        sub = df[df['Classification'].str.contains(ctype)]
        if not sub.empty:
            ax.scatter(sub['Length_bp'] / 1e3, sub['Coverage'], color=col, s=sub['Coverage']/3 + 40,
                       label=ctype, alpha=0.85, edgecolors='black', lw=0.6)

    # Annotate plasmids
    for _, row in df.iterrows():
        if row['Circular'] == 'Y':
            ax.annotate(f"{row['Contig_ID']} ({row['Length_bp']/1000:.1f}k)",
                        xy=(row['Length_bp']/1000, row['Coverage']),
                        xytext=(8, -2), textcoords='offset points',
                        fontsize=7.5, color='#333333')

    ax.set_xscale('log')
    ax.set_xlabel('Contig Length (kb, Log Scale)')
    ax.set_ylabel('Sequencing Depth Coverage (X)')
    ax.set_title('B. Contig Depth vs. Length (Chromosome & 7 Plasmids)', fontweight='bold', loc='left')
    ax.legend(frameon=True, facecolor='#F8F9FA', edgecolor='none')
    ax.grid(True, which='both')

    # ---------------------------------------------------------
    # Panel C: Contig Size Spectrum & Circularity Architecture
    # ---------------------------------------------------------
    ax = axes[1, 0]
    y_pos = np.arange(len(df))
    bars = ax.barh(y_pos, df['Length_bp'] / 1e3, color=df['Color'], alpha=0.9, edgecolor='none')
    ax.set_yticks(y_pos)
    ax.set_yticklabels([f"{row['Contig_ID']} ({'Circ' if row['Circular']=='Y' else 'Lin'})" for _, row in df.iterrows()])
    ax.invert_yaxis()
    ax.set_xlabel('Length (kb)')
    ax.set_title('C. Resolved Genomic Elements Architecture', fontweight='bold', loc='left')
    ax.grid(axis='x')

    # Add length labels
    for bar in bars:
        width = bar.get_width()
        if width > 500:
            label_text = f"{width/1000:.2f} Mbp"
        else:
            label_text = f"{width:.1f} kb"
        ax.annotate(label_text,
                    xy=(width, bar.get_y() + bar.get_height() / 2),
                    xytext=(5, 0), textcoords="offset points",
                    ha='left', va='center', fontsize=8, color='#333333')

    # ---------------------------------------------------------
    # Panel D: GC Content vs. Contig Length
    # ---------------------------------------------------------
    ax = axes[1, 1]
    ax.scatter(df['Length_bp'] / 1e3, df['GC_Percent'], c=df['Color'], s=90, edgecolors='black', lw=0.6)
    ax.axhline(46.07, color='#2E75B6', linestyle='--', lw=1.3, label='Genome Average GC (46.07%)')

    for _, row in df.iterrows():
        ax.annotate(f"{row['Contig_ID']}",
                    xy=(row['Length_bp']/1000, row['GC_Percent']),
                    xytext=(6, 3), textcoords='offset points',
                    fontsize=7.5, color='#444444')

    ax.set_xscale('log')
    ax.set_ylim(35, 50)
    ax.set_xlabel('Contig Length (kb, Log Scale)')
    ax.set_ylabel('GC Content (%)')
    ax.set_title('D. GC Content Deviation (Plasmid Divergence from Host Chromosome)', fontweight='bold', loc='left')
    ax.legend(frameon=True, facecolor='#F8F9FA', edgecolor='none')
    ax.grid(True, which='both')

    plt.suptitle("Figure 3: De Novo Hybrid Assembly Contiguity & Structural Resolution\n"
                 "Lactiplantibacillus pentosus LP309 (Total: 3.795 Mbp | N50: 2.157 Mbp | 7 Circular Plasmids)",
                 fontsize=13, fontweight='bold', y=0.995)
    plt.tight_layout(rect=[0, 0, 1, 0.96])

    png_path = "outputs/07_figures/Figure3_assembly_contiguity_curves.png"
    pdf_path = "outputs/07_figures/Figure3_assembly_contiguity_curves.pdf"
    plt.savefig(png_path, dpi=300)
    plt.savefig(pdf_path)
    plt.close()
    print(f"Figure 3 successfully saved to {png_path} and {pdf_path}")

if __name__ == '__main__':
    main()
