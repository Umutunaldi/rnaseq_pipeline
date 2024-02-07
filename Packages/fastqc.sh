#!/bin/bash

# Download FastQC archive
wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.12.1.zip

# Unzip the archive
unzip fastqc_v0.12.1.zip

# Remove the zip file
rm fastqc_v0.12.1.zip

# Move into the FastQC directory
cd FastQC

# Make the fastqc script executable
chmod +x fastqc

