#!/bin/bash

# Function to prompt user for input BAM files using zenity
select_input_files() {
    input_files=$(zenity --file-selection --file-filter="*.bam" --multiple --separator=" " --title="Select input BAM file(s)")
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
    usage="$1"
    output_filename=$(zenity --entry --title="Enter filename" --text="Enter the filename for $usage" --entry-text="$2")
    if [ -z "$output_filename" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    echo "$output_filename"
}

# Prompt user for input files
input_files=$(select_input_files)

# Prompt user for output directory
output_directory=$(select_output_directory)

# Prompt user for number of threads
threads=$(zenity --entry --title="Enter number of threads" --text="Enter number of threads" --entry-text="4")
if [ -z "$threads" ]; then
    echo "User cancelled. Exiting..."
    exit 1
fi

# Prompt user for long reads processing mode
long_reads=$(zenity --question --title="Enable long reads processing mode?" --text="Do you want to enable long reads processing mode (-L)?")
if [ $? -eq 0 ]; then
    long_reads_option="-L"
else
    long_reads_option=""
fi

# Prompt user for reference annotation file
annotation_file=$(zenity --question --title="Use reference annotation file?" --text="Do you want to use a reference annotation file (-G)?")
if [ $? -eq 0 ]; then
    annotation_file=$(zenity --file-selection --file-filter="*.gtf *.gff3" --title="Select reference annotation file")
    if [ -z "$annotation_file" ]; then
        echo "User cancelled. Exiting..."
        exit 1
    fi
    use_annotation="-G $annotation_file"
else
    use_annotation=""
fi

# Prompt user for expression estimation mode
if [ -n "$use_annotation" ]; then
    expression_estimation=$(zenity --question --title="Enable expression estimation mode?" --text="Do you want to enable expression estimation mode (-e)?")
    if [ $? -eq 0 ]; then
        expression_estimation_option="-e"
    else
        expression_estimation_option=""
    fi
fi

# Prompt user for fully covered transcripts output file
if [ -n "$use_annotation" ]; then
    covered_output=$(zenity --question --title="Enable output of fully covered transcripts?" --text="Do you want to output a file with fully covered transcripts (-C)?")
    if [ $? -eq 0 ]; then
        covered_filename=$(select_output_filename "cov_refs (-C)" "covered_reads")
        fully_covered_option="-C $output_directory/$covered_filename.gtf"
    else
        fully_covered_option=""
    fi
fi

# Prompt user for Ballgown input table files
if [ -n "$use_annotation" ]; then
    ballgown_table=$(zenity --question --title="Enable Ballgown input table files?" --text="Do you want to enable Ballgown input table files (-B)?")
    if [ $? -eq 0 ]; then
        ballgown_option="-B"
    else
        ballgown_option=""
    fi
else
    ballgown_option=""
fi


# Prompt user for gene abundance output
gene_abundance=$(zenity --question --title="Enable gene abundance output?" --text="Do you want to output gene abundance (-A)?")
if [ $? -eq 0 ]; then
    abundance_filename=$(select_output_filename "gene abundances (-A)" "gene_abundances")
    abundance_option="-A $output_directory/$abundance_filename.tsv"
else
    abundance_option=""
fi

# Prompt user for output filename for transcripts
transcript_output_filename=$(select_output_filename "output transcripts (-o)" "transcripts")

# Ask user for additional parameters
additional_params=$(zenity --entry --title="Additional parameters" --text="Enter any additional parameters (leave blank if none)")

# Construct stringtie command
command="stringtie -p $threads $long_reads_option $use_annotation $expression_estimation_option $fully_covered_option $ballgown_option $abundance_option -o $output_directory/$transcript_output_filename.gtf $input_files $additional_params"

# Display the constructed command and ask for confirmation
zenity --question --title="Confirmation" --text="The constructed command is:\n$command\nDo you want to execute this command?"
if [ $? -eq 0 ]; then
    eval $command
    zenity --info --title="Success" --text="Command executed successfully!"
else
    zenity --info --title="Cancelled" --text="Command execution cancelled."
fi

