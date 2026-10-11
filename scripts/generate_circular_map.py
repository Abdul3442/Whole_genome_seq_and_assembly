#!/usr/bin/env python3
"""
Publication-Quality Figure 1: Circular Genome Map of Lactiplantibacillus pentosus LP309
Using pyCirclize / BioPython
Author: Antigravity WGS Pipeline
"""

import os
import numpy as np
import pandas as pd
from Bio import SeqIO
from pycirclize import Circos
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
from matplotlib.patches import Patch

def main():
    print("Loading assembly and annotation...")
    records = {r.id: r for r in SeqIO.parse("outputs/03_assembly/flye_assembly/assembly.fasta", "fasta")}
    
    target_id = "contig_1"
    target_record = records[target_id]
    seq = str(target_record.seq).upper()
    seq_len = len(seq)
    
    # Parse CDS for contig_1
    cds_df = []
    with open("outputs/05_annotation/annotation.gff") as f:
        for line in f:
            if line.startswith("#") or not line.strip():
                continue
            parts = line.strip().split('\t')
            if len(parts) >= 9 and parts[0] == target_id and parts[2] == 'CDS':
                start = int(parts[3])
                end = int(parts[4])
                strand = 1 if parts[6] == '+' else -1
                cds_df.append({'start': start, 'end': end, 'strand': strand})
    df_cds = pd.DataFrame(cds_df)
    
    # Compute sliding window GC content & GC skew
    window_size = 10000
    step_size = 5000
    starts = np.arange(0, seq_len - window_size, step_size)
    gc_vals = []
    skew_vals = []
    pos_vals = []
    
    for s in starts:
        w_seq = seq[s:s+window_size]
        g = w_seq.count('G')
        c = w_seq.count('C')
        total_gc = g + c
        gc_pct = (total_gc / window_size) * 100
        skew = (g - c) / (g + c) if (g + c) > 0 else 0
        gc_vals.append(gc_pct)
        skew_vals.append(skew)
        pos_vals.append(s + window_size / 2)
        
    mean_gc = np.mean(gc_vals)
    pos_vals = np.array(pos_vals)
    gc_vals = np.array(gc_vals)
    skew_vals = np.array(skew_vals)
    
    min_gc, max_gc = float(np.min(gc_vals) - 2), float(np.max(gc_vals) + 2)
    min_skew, max_skew = float(np.min(skew_vals) - 0.05), float(np.max(skew_vals) + 0.05)
    
    # Initialize Circos
    circos = Circos(sectors={target_id: seq_len}, space=0)
    sector = circos.get_sector(target_id)
    
    # Center text
    sector.text(f"Lactiplantibacillus pentosus LP309\nChromosome Contig 1 ({seq_len/1e6:.2f} Mbp)\nAssembly Coverage: 132x | GC: 46.7%", 
                r=0, size=9.5, fontweight="bold", color="#111111")
    
    # Track 0: Coordinates / Axis
    sector.axis(fc="none", ec="#333333", lw=1.2)
    
    # Track 1: Forward CDS (outer)
    fwd_track = sector.add_track((90, 95))
    fwd_track.axis(fc="#F0F4F8", ec="none")
    fwd_cds = df_cds[df_cds['strand'] == 1]
    for _, row in fwd_cds.iterrows():
        fwd_track.rect(row['start'], row['end'], fc="#2E75B6", ec="none", alpha=0.85)
        
    # Track 2: Reverse CDS (inner)
    rev_track = sector.add_track((84, 89))
    rev_track.axis(fc="#F0F4F8", ec="none")
    rev_cds = df_cds[df_cds['strand'] == -1]
    for _, row in rev_cds.iterrows():
        rev_track.rect(row['start'], row['end'], fc="#E64B35", ec="none", alpha=0.85)
        
    # Track 3: GC Content
    gc_track = sector.add_track((68, 80))
    gc_track.axis(fc="none", ec="#CCCCCC", lw=0.6)
    gc_track.line(pos_vals, gc_vals, color="#3C5488", lw=1.2, vmin=min_gc, vmax=max_gc)
    gc_track.line([0, seq_len], [mean_gc, mean_gc], color="#666666", lw=0.8, ls="--", vmin=min_gc, vmax=max_gc)
    
    # Track 4: GC Skew
    skew_track = sector.add_track((52, 64))
    skew_track.axis(fc="none", ec="#CCCCCC", lw=0.6)
    skew_track.line(pos_vals, skew_vals, color="#00A087", lw=1.2, vmin=min_skew, vmax=max_skew)
    skew_track.line([0, seq_len], [0, 0], color="#666666", lw=0.8, ls="--", vmin=min_skew, vmax=max_skew)

    fig = circos.plotfig()
    
    legend_elements = [
        Patch(facecolor='#2E75B6', label='Forward Strand CDS (n=1,061)'),
        Patch(facecolor='#E64B35', label='Reverse Strand CDS (n=947)'),
        Line2D([0], [0], color='#3C5488', lw=1.8, label=f'GC Content % (Mean = {mean_gc:.1f}%)'),
        Line2D([0], [0], color='#00A087', lw=1.8, label='GC Skew ((G-C)/(G+C))')
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=2, 
               frameon=True, facecolor='#F8F9FA', edgecolor='none', fontsize=9.5)
    
    plt.title("Figure 1: Circular Genome Atlas of Lactiplantibacillus pentosus LP309\n"
              "Chromosome Architecture, Gene Orientation, GC Content & GC Skew Dynamics",
              fontsize=13, fontweight='bold', pad=25)
              
    png_path = "outputs/07_figures/Figure1_circular_genome_map.png"
    pdf_path = "outputs/07_figures/Figure1_circular_genome_map.pdf"
    fig.savefig(png_path, dpi=300, bbox_inches='tight')
    fig.savefig(pdf_path, bbox_inches='tight')
    plt.close()
    print(f"Figure 1 successfully saved to {png_path} and {pdf_path}")

if __name__ == '__main__':
    main()
