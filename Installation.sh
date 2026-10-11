


#!/bin/bash

# 1. Create a fresh environment with Python 3.9
conda create -n grabseqs_env python=3.9 -y

# Activate the env
conda activate grabseqs_env

# 2. Set strict channel priority inside the environment
conda run -n grabseqs_env conda config --env --set channel_priority strict

# 3. Install grabseqs directly into the target environment
conda run -n grabseqs_env conda install -c conda-forge -c bioconda -c louiejtaylor grabseqs -y

echo "Grabseqs successfully installed in grabseqs_env!"

# Heres the command below using which you can download the SRA data from NCBI using your Terminal

grabseqs sra 

#short read:  Illumina NovaSeq 6000 paired end sequencing (ERR15819122)
# Long read: MinION sequencing (ERR15819127)

