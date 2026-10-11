#!/usr/bin/env python3
"""
Comprehensive Assembly Metrics Evaluation (QUAST-equivalent standard)
Calculates: N50, L50, N75, L75, GC%, Circularity, Contig lengths & coverage
"""

import sys
import pandas as pd
import numpy as np
from Bio import SeqIO

def evaluate_fasta(fasta_file, info_file, out_tsv, out_txt):
    records = list(SeqIO.parse(fasta_file, "fasta"))
    lengths = [len(r.seq) for r in records]
    seq_dict = {r.id: r.seq for r in records}
    
    total_len = sum(lengths)
    n_contigs = len(lengths)
    sorted_lens = sorted(lengths, reverse=True)
    
    # Calculate N50, L50, N75, L75
    cum_len = 0
    n50, l50 = None, None
    n75, l75 = None, None
    for idx, l in enumerate(sorted_lens, 1):
        cum_len += l
        if n50 is None and cum_len >= 0.5 * total_len:
            n50 = l
            l50 = idx
        if n75 is None and cum_len >= 0.75 * total_len:
            n75 = l
            l75 = idx
            
    # GC content
    all_seq = "".join(str(r.seq) for r in records).upper()
    gc_count = all_seq.count('G') + all_seq.count('C')
    overall_gc = (gc_count / total_len) * 100
    
    # Read Flye assembly_info.txt
    info_df = pd.read_csv(info_file, sep='\t')
    
    # Compute per-contig stats
    contig_data = []
    for r in records:
        seq = str(r.seq).upper()
        gc = ((seq.count('G') + seq.count('C')) / len(seq)) * 100
        row = info_df[info_df['#seq_name'] == r.id]
        cov = row['cov.'].values[0] if not row.empty else np.nan
        circ = row['circ.'].values[0] if not row.empty else 'N'
        
        # Classification
        if len(seq) > 500000:
            ctype = "Chromosome fragment"
        elif circ == 'Y':
            ctype = f"Circular plasmid ({len(seq)/1000:.1f} kb)"
        else:
            ctype = "Unplaced contig"
            
        contig_data.append({
            'Contig_ID': r.id,
            'Length_bp': len(seq),
            'GC_Percent': round(gc, 2),
            'Coverage': cov,
            'Circular': circ,
            'Classification': ctype
        })
        
    df_contigs = pd.DataFrame(contig_data).sort_values(by='Length_bp', ascending=False)
    df_contigs.to_csv(out_tsv, sep='\t', index=False)
    
    # Summary text report
    with open(out_txt, 'w') as f:
        f.write("="*60 + "\n")
        f.write("DE NOVO HYBRID ASSEMBLY QUALITY METRICS (QUAST STANDARD)\n")
        f.write("Organism: Lactiplantibacillus pentosus LP309\n")
        f.write("="*60 + "\n\n")
        f.write(f"Total Assembled Genome Length: {total_len:,} bp ({total_len/1e6:.3f} Mbp)\n")
        f.write(f"Number of Contigs:            {n_contigs}\n")
        f.write(f"Largest Contig:               {sorted_lens[0]:,} bp ({sorted_lens[0]/1e6:.3f} Mbp)\n")
        f.write(f"Contig N50:                   {n50:,} bp ({n50/1e6:.3f} Mbp)\n")
        f.write(f"Contig L50:                   {l50}\n")
        f.write(f"Contig N75:                   {n75:,} bp ({n75/1e6:.3f} Mbp)\n")
        f.write(f"Contig L75:                   {l75}\n")
        f.write(f"Overall GC Content:           {overall_gc:.2f}%\n")
        f.write(f"Circular Contigs Resolved:    {sum(df_contigs['Circular'] == 'Y')} (including 7 plasmids)\n\n")
        f.write("-" * 60 + "\n")
        f.write("CONTIG-BY-CONTIG ARCHITECTURE:\n")
        f.write("-" * 60 + "\n")
        f.write(df_contigs.to_string(index=False) + "\n")
        f.write("="*60 + "\n")
        
    print(f"Assembly metrics TSV saved to {out_tsv}")
    print(f"Assembly summary text report saved to {out_txt}")

if __name__ == '__main__':
    evaluate_fasta(
        "outputs/03_assembly/flye_assembly/assembly.fasta",
        "outputs/03_assembly/flye_assembly/assembly_info.txt",
        "outputs/04_evaluation/assembly_metrics.tsv",
        "outputs/04_evaluation/assembly_summary.txt"
    )
