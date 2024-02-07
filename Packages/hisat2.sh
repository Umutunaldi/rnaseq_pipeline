#!/bin/bash

# Download HISAT2 archive
wget https://github.com/DaehwanKimLab/hisat2/archive/refs/tags/v2.2.1.tar.gz

# Extract the tarball
tar -xzvf v2.2.1.tar.gz

# Remove the downloaded tarball
rm -r v2.2.1.tar.gz

# Change directory to HISAT2 source directory
cd hisat2-2.2.1

# Build HISAT2
make

