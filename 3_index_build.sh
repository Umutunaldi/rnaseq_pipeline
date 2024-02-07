#!/bin/bash

# Function to prompt user for genome.fa file using zenity
select_genome_file() {
    genome_file=$(zenity --file-selection --file-filter="*.fa" --title="Select genome.fa file")
    if [ -z "$genome_file" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    echo "$genome_file"
}

# Function to prompt user for index name using zenity
select_index_name() {
    index_name=$(zenity --entry --title="Enter index name" --text="Enter index name (leave blank for default 'genome')")
    if [ -z "$index_name" ]; then
        echo "genome"
    else
        echo "$index_name"
    fi
}

# Prompt user for genome.fa file
genome_file=$(select_genome_file)

# Prompt user for index name
index_name=$(select_index_name)

# Build HISAT2 index command
command="hisat2-build $genome_file $index_name"

# Display the constructed command and ask for confirmation
zenity --question --title="Confirmation" --text="The constructed command is:\n$command\nDo you want to execute this command?"
if [ $? -eq 0 ]; then
    eval $command
    zenity --info --title="Success" --text="Command executed successfully!"
else
    zenity --info --title="Cancelled" --text="Command execution cancelled."
fi

