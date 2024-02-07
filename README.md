# Prepared by Umutcan Unaldi
# Please contact umutcanunaldi@gmail.com for any question or errors.


# 1. INSTALLATION

Run "chmod +x *.sh" in the folder to give permission to the all bash scripts.

Please read the /Packages/README.txt. All packages, and tools must be installed.
All tools must be added to bashrc file in order for these scripts to work. 


# 2. Pipeline

# 2.1 Quality Control

Run quality_control.sh for the reads. This is where you decide if you want to
use trimming or not. You can check official documentation on how to
handle good reads/bad reads.
 
https://www.bioinformatics.babraham.ac.uk/projects/fastqc/

Preferably you can use MultiQC if you have too many reads.

# 2.2 Trimming

If you had bad reads, you need to proceed with this step. Simply,
run trimming.sh for each read that needs to be trimmed. Optional
parameters are the essential part of this process. Please, check
the usage of the optional parameters from the Trimmomatic documentation.

**ILLUMINACLIP: Cut adapter and other illumina-specific sequences from the read.
**SLIDINGWINDOW: Performs a sliding window trimming approach. It starts
scanning at the 5‟ end and clips the read once the average quality within the window
falls below a threshold.
**LEADING: Cut bases off the start of a read, if below a threshold quality
**TRAILING: Cut bases off the end of a read, if below a threshold quality
**CROP: Cut the read to a specified length by removing bases from the end
**HEADCROP: Cut the specified number of bases from the start of the read
**MINLEN: Drop the read if it is below a specified length

http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf

You can use QC (2.1) again to check the trimmed reads.

# 2.3 Building Index of the Reference Genome

You can build your indices with index_build.sh. This step takes
high memory resources. This is why it is advised to use
pre-built indices from http://daehwankimlab.github.io/hisat2/download/


# 2.4 Alignment to reference genome

Run alignment.sh to start alignment process. Most used parameters
are added in the script. You can check the usage of the parameters, or
more parameters in the original documentation for HISAT2.  Please,
select --dta option if you are going to work with StringTie later on.

http://daehwankimlab.github.io/hisat2/manual/

You can either choose to sort the result to BAM files or you can choose
to skip that part and do it manually. You can use FastQC (2.1) again
for SAM/BAM files after this step.

Or you can use other tools of choice for QC of the aligned reads. 


# 2.5 Merge the BAM files

Run BAM_merge.sh to merge the BAM files if you want one BAM file
of the aligned reads. Check Picard's documentation.

https://broadinstitute.github.io/picard/

If you have problem running picard, you probably have outdated java.
So, please update your java version.


# 2.6 Expression Estimates

Run expression.sh. You can either choose to have reference annotation file.
If you choose that option you will have two other options to choose from.
If you are goıing to proceed with Ballgown R package for DEG, then please
include -B option when the script prompts. Please check StringTie documentation
for additional parameters.

http://ccb.jhu.edu/software/stringtie/index.shtml?t=manual

Run count.sh to get raw count numbers. You can merge the results to a single matrix
if you like.


# 2.7 Further Steps (DEG, Annotation, etc.)

I didn't provide anything for the next steps. This is mainly because it differs
based on characteristics of every studies. However, if you want to proceed with
Ballgown, you can the use following instructions:

https://bioconductor.org/packages/release/bioc/vignettes/ballgown/inst/doc/ballgown.html

Also, you can run PrepDE.py in StringTie folder to proceed with other DEG
methods pipelines (DeSEQ,EdgeR,etc.).








