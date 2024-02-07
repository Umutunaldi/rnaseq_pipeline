#!/bin/bash

# Download Trimmomatic archive
wget https://github.com/usadellab/Trimmomatic/files/5854859/Trimmomatic-0.39.zip

# Unzip the archive
unzip Trimmomatic-0.39.zip

# Remove the extracted directory
rm -r Trimmomatic-0.39.zip

