#!/bin/bash

# Function to prompt user for executable path using zenity
select_executable() {
    trimmomatic_path=$(zenity --file-selection --title="Select trimmomatic executable")
    if [ -z "$trimmomatic_path" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    echo "$trimmomatic_path"
}

# Function to prompt user for input file(s) using zenity
select_input_files() {
    input_files=$(zenity --file-selection --file-filter="*.fastq *.fastq.gz *.fq" --multiple --separator=" " --title="Select input FastQ file(s)")
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

# Function to prompt user for number of threads using zenity
prompt_user() {
    result=$(zenity --entry --title="$1" --text="$1" --entry-text="$2")
    if [ -z "$result" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    echo "$result"
}

# Function to get base name without extension
get_base_name() {
    filename=$(basename -- "$1")
    echo "${filename%.*}"
}

# Function to prompt user for optional parameters using zenity
prompt_optional_parameters() {
    parameters=""
    for param in "${@}"; do
        result=$(zenity --question --title="Optional Parameter" --text="Do you want to include $param?")
        if [ $? -eq 0 ]; then
            if [ "$param" == "ILLUMINACLIP" ]; then
                illuminaclip_file=$(zenity --file-selection --file-filter="*.fa" --title="Select $param file (.fa)")
                if [ -z "$illuminaclip_file" ]; then
                    echo "User cancelled. Exiting..."
                    exit 1
                fi
                parameters+=" $param:$illuminaclip_file"
            elif [ "$param" == "HEADCROP" ]; then
                value=$(zenity --entry --title="$param" --text="Enter value for $param")
                if [ -n "$value" ]; then
                    parameters+=" $param:$value"
                fi
            else
                value=$(zenity --entry --title="$param" --text="Enter value for $param")
                if [ -n "$value" ]; then
                    parameters+=" $param:$value"
                fi
            fi
        fi
    done

    # Prompt for additional commands
    additional_commands=$(zenity --entry --title="Additional Commands" --text="Enter any other commands you want to include (leave blank if none)")
    if [ -n "$additional_commands" ]; then
        parameters+=" $additional_commands"
    fi

    echo "$parameters"
}

# Prompt user for trimmomatic executable path
trimmomatic_path=$(select_executable)

# Prompt user for mode (PE or SE)
mode=$(zenity --list --title="Select mode" --column="Mode" "PE" "SE")
if [ -z "$mode" ]; then
    echo "User cancelled. Exiting..."
    exit 1
fi

# Prompt user for input file(s)
if [ "$mode" == "PE" ]; then
    input_forward=$(zenity --file-selection --file-filter="*.fastq *.fastq.gz *.fq" --title="Select forward input FastQ file")
    if [ -z "$input_forward" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    input_reverse=$(zenity --file-selection --file-filter="*.fastq *.fastq.gz *.fq" --title="Select reverse input FastQ file")
    if [ -z "$input_reverse" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    base_name=$(get_base_name "$input_forward")
else
    input_files=$(select_input_files)
    base_name=$(get_base_name "$(echo $input_files | awk '{print $1}')")
fi

# Prompt user for output directory
output_directory=$(select_output_directory)

# Prompt user for number of threads
threads=$(prompt_user "Enter number of threads" "1")

# Prompt user for quality metric
quality_metric=$(zenity --list --title="Select quality metric" --column="Metric" "phred33" "phred64")
if [ -z "$quality_metric" ]; then
    echo "User cancelled. Exiting..."
    exit 1
fi

# Prompt user for optional parameters
optional_parameters=$(prompt_optional_parameters "ILLUMINACLIP" "SLIDINGWINDOW" "LEADING" "TRAILING" "CROP" "MINLEN" "HEADCROP")

# Construct trimmomatic command based on user inputs
if [ "$mode" == "PE" ]; then
    output_forward_paired="${base_name}_output_forward_paired.fastq"
    output_forward_unpaired="${base_name}_output_forward_unpaired.fastq"
    output_reverse_paired="${base_name}_output_reverse_paired.fastq"
    output_reverse_unpaired="${base_name}_output_reverse_unpaired.fastq"
    command="java -jar $trimmomatic_path PE -threads $threads -$quality_metric $input_forward $input_reverse $output_directory/$output_forward_paired $output_directory/$output_forward_unpaired $output_directory/$output_reverse_paired $output_directory/$output_reverse_unpaired$optional_parameters"
else
    output_files="${base_name}_output.fastq"
    command="java -jar $trimmomatic_path SE -$quality_metric $input_files $output_directory/$output_files$optional_parameters"
fi

# Display the constructed command and ask for confirmation
zenity --question --title="Confirmation" --text="The constructed command is:\n$command\nDo you want to execute this command?"
if [ $? -eq 0 ]; then
    eval $command
    zenity --info --title="Success" --text="Command executed successfully!"
else
    zenity --info --title="Cancelled" --text="Command execution cancelled."
fi

