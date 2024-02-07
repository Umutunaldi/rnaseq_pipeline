#!/bin/bash

# Download CMake archive
wget https://github.com/Kitware/CMake/releases/download/v3.28.2/cmake-3.28.2.tar.gz

# Extract the archive
tar xzf cmake-3.28.2.tar.gz

# Remove the tar file
rm -r cmake-3.28.2.tar.gz

# Move into the extracted directory
cd cmake-3.28.2/

# Bootstrap CMake
./bootstrap

# Build CMake
make

# Install CMake
sudo make install

