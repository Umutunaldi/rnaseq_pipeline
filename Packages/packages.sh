#!/bin/bash

# Define packages to install
packages=(
    "zip" 
    "unzip" 
    "zenity" 
    "default-jre" 
    "default-jdk" 
    "openjdk-11-jdk" 
    "python3-pip" 
    "libboost-dev" 
    "libstdc++-12-dev" 
    "build-essential" 
    "libcurl4-gnutls-dev" 
    "libxml2-dev" 
    "libssl-dev" 
    "libreadline-dev" 
    "libffi-dev" 
    "make" 
    "mesa-common-dev" 
    "libbz2-dev" 
    "liblzma-dev" 
    "git" 
    "libboost-all-dev" 
    "libopenblas0-pthread" 
    "linux-tools-generic" 
    "python-is-python3" 
    "parallel"
    "samtools"
)

# Function to check if a package is installed
is_package_installed() {
    dpkg -l "$1" &>/dev/null
}

# Install packages
for package in "${packages[@]}"; do
    if ! is_package_installed "$package"; then
        sudo apt install -y "$package"
    else
        echo "$package is already installed. Skipping..."
    fi
done

# Additional installations
sudo apt-get install -y libncurses-dev libbz2-dev liblzma-dev

