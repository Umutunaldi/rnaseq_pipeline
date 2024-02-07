#!/bin/bash

# Function to prompt user for input files using zenity
select_input_files() {
    input_files=$(zenity --file-selection --multiple --separator=" " --title="Select input file(s)")
    if [ -z "$input_files" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    echo "$input_files"
}

# Function to prompt user for parallel threading option using zenity
prompt_parallel_threading() {
    zenity --question --title="Parallel Threading" --text="Do you want to use parallel threading?"
    if [ $? -eq 0 ]; then
        echo "-t $(echo "$1" | tr ' ' '\n' | wc -l)"
    else
        echo ""
    fi
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

# Prompt user to select input files
input_files=$(select_input_files)

# Prompt user for parallel threading option
parallel_threading_option=$(prompt_parallel_threading "$input_files")

# Prompt user to select output directory
output_directory=$(select_output_directory)

# Construct fastqc command
fastqc_command="fastqc $input_files $parallel_threading_option -o \"$output_directory\""

# Display the constructed command and ask for confirmation
zenity --question --title="Confirmation" --text="The constructed command is:\n$fastqc_command\nDo you want to execute this command?"
if [ $? -eq 0 ]; then
    eval $fastqc_command
    zenity --info --title="Success" --text="Command executed successfully!"
else
    zenity --info --title="Cancelled" --text="Command execution cancelled."
fi

