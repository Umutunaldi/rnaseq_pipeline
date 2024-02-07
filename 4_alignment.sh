#!/bin/bash

# Function to prompt user for index path using zenity
select_index_path() {
    index_path=$(zenity --file-selection --directory --title="Select HISAT2 index directory")
    if [ -z "$index_path" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    prefix=$(zenity --entry --title="Enter prefix for index files" --text="Enter a prefix for the index files (default: genome)" --entry-text="genome")
    if [ -z "$prefix" ]; then
        prefix="genome"
    fi
    echo "$index_path/$prefix"
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

# Function to prompt user for optional parameters using zenity
prompt_optional_parameters() {
    parameters=""
    
    dta=$(zenity --question --title="Include --dta?" --text="Do you want to include --dta?")
    if [ $? -eq 0 ]; then
        parameters+=" --dta"
    fi

    rg_id=$(zenity --question --title="Include --rg-id?" --text="Do you want to include --rg-id?")
    if [ $? -eq 0 ]; then
        rg_id_value=$(zenity --entry --title="--rg-id" --text="Enter value for --rg-id")
        if [ -n "$rg_id_value" ]; then
            parameters+=" --rg-id $rg_id_value"
        fi
    fi

    strandness=""
    if [ "$mode" == "PE" ]; then
        strandness=$(select_strandness_pe)
    elif [ "$mode" == "SE" ]; then
        strandness=$(select_strandness_se)
    fi

    if [ -n "$strandness" ]; then
        parameters+=" --rna-strandness $strandness"
    fi

    threads=$(zenity --entry --title="Enter number of threads" --text="Enter number of threads" --entry-text="4")
    if [ -n "$threads" ]; then
        parameters+=" -p $threads"
    fi

    # Prompt for additional commands
    additional_commands=$(zenity --entry --title="Additional Commands" --text="Enter any other commands you want to include (leave blank if none)")
    if [ -n "$additional_commands" ]; then
        parameters+=" $additional_commands"
    fi

    echo "$parameters"
}

# Function to prompt user for RNA strandness in PE mode
select_strandness_pe() {
    strandness=$(zenity --list --title="Select RNA strandness" --column="Strandness" "RF" "FR")
    echo "$strandness"
}

# Function to prompt user for RNA strandness in SE mode
select_strandness_se() {
    strandness=$(zenity --list --title="Select RNA strandness" --column="Strandness" "R" "F")
    echo "$strandness"
}

# Function to prompt user for sorting option using zenity
prompt_sort_option() {
    sort_option=$(zenity --question --title="Sort SAM to BAM?" --text="Do you want to sort the SAM file to BAM?")
    if [ $? -eq 0 ]; then
        echo "yes"
    else
        echo "no"
    fi
}

# Function to prompt user for the number of threads for samtools sort process
prompt_samtools_threads() {
    samtools_threads=$(zenity --entry --title="Enter number of threads for samtools sort" --text="Enter number of threads for samtools sort (leave blank to use default)")
    echo "$samtools_threads"
}

# Prompt user for mode (PE or SE)
mode=$(zenity --list --title="Select mode" --column="Mode" "PE" "SE")
if [ -z "$mode" ]; then
    echo "User cancelled. Exiting..."
    exit 1
fi

# Common prompts for both PE and SE modes
index_path=$(select_index_path)

# PE mode prompts
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
    output_directory=$(select_output_directory)
    base_name=$(basename -- "$input_forward" | cut -d. -f1)
    optional_parameters=$(prompt_optional_parameters)
    sort_option=$(prompt_sort_option)

    # Construct HISAT2 command for PE mode
    command="hisat2 -x $index_path $optional_parameters -1 $input_forward -2 $input_reverse"
    if [ "$sort_option" == "yes" ]; then
        samtools_threads=$(prompt_samtools_threads)
        if [ -n "$samtools_threads" ]; then
            command+=" | samtools sort -@ $samtools_threads -o $output_directory/$base_name.bam"
        else
            command+=" | samtools sort -o $output_directory/$base_name.bam"
        fi
    else
        command+=" -S $output_directory/$base_name.sam"
    fi

fi

# SE mode prompts
if [ "$mode" == "SE" ]; then
    input_files=$(select_input_files)
    output_directory=$(select_output_directory)
    base_name=$(basename -- "$(echo $input_files | awk '{print $1}')")
    optional_parameters=$(prompt_optional_parameters)
    sort_option=$(prompt_sort_option)

    # Construct HISAT2 command for SE mode
    command="hisat2 -x $index_path $optional_parameters -U $input_files"
    if [ "$sort_option" == "yes" ]; then
        samtools_threads=$(prompt_samtools_threads)
        if [ -n "$samtools_threads" ]; then
            command+=" | samtools sort -@ $samtools_threads -o $output_directory/$base_name.bam"
        else
            command+=" | samtools sort -o $output_directory/$base_name.bam"
        fi
    else
        command+=" -S $output_directory/$base_name.sam"
    fi
fi

# Display the constructed command and ask for confirmation
zenity --question --title="Confirmation" --text="The constructed command is:\n$command\nDo you want to execute this command?"
if [ $? -eq 0 ]; then
    eval $command
    zenity --info --title="Success" --text="Command executed successfully!"
else
    zenity --info --title="Cancelled" --text="Command execution cancelled."
fi

