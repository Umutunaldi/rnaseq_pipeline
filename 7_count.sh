#!/bin/bash

# Function to prompt user for reference annotation file using Zenity
select_annotation_file() {
    annotation_file=$(zenity --file-selection --file-filter="*.gtf *.gff" --title="Select reference annotation file")
    echo "$annotation_file"
}

# Function to prompt user for additional parameters using Zenity
select_additional_parameters() {
    additional_params=""
    
    mode=$(zenity --list --title="Select mode" --text="Select mode" --column="Mode" "intersection-strict" "union" "nonunique")
    additional_params+=" --mode $mode"
    
    stranded=$(zenity --list --title="Select strandedness" --text="Select strandedness" --column="Strandedness" "yes" "no" "reverse")
    additional_params+=" --stranded $stranded"
    
    minaqual_answer=$(zenity --question --title="Minimum alignment quality" --text="Do you want to specify minimum alignment quality?")
    if [ $? -eq 0 ]; then
        minaqual=$(zenity --entry --title="Minimum alignment quality" --text="Enter minimum alignment quality" --entry-text="1")
        if [ -n "$minaqual" ]; then
            additional_params+=" --minaqual $minaqual"
        fi
    fi

    type_answer=$(zenity --question --title="Feature type" --text="Do you want to specify feature type?")
    if [ $? -eq 0 ]; then
        type=$(zenity --entry --title="Feature type" --text="Enter feature type" --entry-text="exon")
        if [ -n "$type" ]; then
            additional_params+=" --type $type"
        fi
    fi

    idattr_answer=$(zenity --question --title="Feature ID attribute" --text="Do you want to specify feature ID attribute?")
    if [ $? -eq 0 ]; then
        idattr=$(zenity --entry --title="Feature ID attribute" --text="Enter feature ID attribute" --entry-text="gene_id")
        if [ -n "$idattr" ]; then
            additional_params+=" --idattr $idattr"
        fi
    fi
    
    echo "$additional_params"
}

# Prompt user for reference annotation file
annotation_file=$(select_annotation_file)

# Prompt user for additional parameters
additional_params=$(select_additional_parameters)

# Prompt user for input file
input_file=$(zenity --file-selection --file-filter="*.bam *.sam" --title="Select input BAM/SAM file")

# Prompt user for output directory
output_directory=$(zenity --file-selection --directory --title="Select output directory")

# Get the base filename without extension
base_filename=$(basename -- "$input_file")
base_filename="${base_filename%.*}"

# Construct htseq-count command
command="htseq-count --format bam --order pos $additional_params $input_file $annotation_file > $output_directory/$base_filename.tsv"

# Display the constructed command and ask for confirmation
zenity --question --title="Confirmation" --text="The constructed command is:\n$command\nDo you want to execute this command?"
if [ $? -eq 0 ]; then
    eval $command
    zenity --info --title="Success" --text="Command executed successfully!"
else
    zenity --info --title="Cancelled" --text="Command execution cancelled."
fi

