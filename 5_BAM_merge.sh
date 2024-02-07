#!/bin/bash

# Function to prompt user for picard.jar file using zenity
select_picard_jar() {
    picard_jar=$(zenity --file-selection --file-filter="*.jar" --title="Select picard.jar file")
    if [ -z "$picard_jar" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    echo "$picard_jar"
}

# Function to prompt user for input files using zenity
select_input_files() {
    input_files=$(zenity --file-selection --file-filter="*.bam *.sam" --multiple --separator=" " --title="Select input BAM/SAM file(s)")
    if [ -z "$input_files" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    echo "$input_files"
}

# Function to prompt user for output directory using zenity
select_output_directory() {
    output_directory=$(zenity --file-selection --directory --title="Select output directory")
    if [ -z "$output_directory" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    echo "$output_directory"
}

# Function to prompt user for output filename using zenity
select_output_filename() {
    output_filename=$(zenity --entry --title="Enter output filename" --text="Enter output filename (without extension)")
    if [ -z "$output_filename" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    echo "$output_filename"
}

# Prompt user for picard.jar file
picard_jar=$(select_picard_jar)

# Prompt user for input files
input_files=$(select_input_files)

# Prompt user for output directory
output_directory=$(select_output_directory)

# Prompt user for output filename
output_filename=$(select_output_filename)

# Build Picard MergeSamFiles command
command="java -Xmx2g -jar $picard_jar MergeSamFiles -OUTPUT $output_directory/$output_filename.bam"

# Add input files to the command
for input_file in $input_files; do
    command+=" -INPUT $input_file"
done

# Display the constructed command and ask for confirmation
zenity --question --title="Confirmation" --text="The constructed command is:\n$command\nDo you want to execute this command?"
if [ $? -eq 0 ]; then
    eval $command
    zenity --info --title="Success" --text="Command executed successfully!"
else
    zenity --info --title="Cancelled" --text="Command execution cancelled."
fi

