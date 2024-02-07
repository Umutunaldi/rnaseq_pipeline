# Prepared by Umutcan Unaldi
# Please contact umutcanunaldi@gmail.com for any question or errors.

Run "chmod +x *.sh" in the folder to give permission to the all bash scripts.



You can either run the scripts "./script_name.sh", or copy
the lines into terminal and install it yourself. 


# 1. First run packages.sh

This can take some time dependent on how many packages your
system has already.


# 2. Run cmake.sh


# 3. Run the tool scripts


# 4. Run add_executables.sh

This script will add the executable. Just select the executable.
For example, choose fastqc in the FastQC folder, and it will
add it to the ~/.bashrc. You can also do this step manually.
However, this step is important for other scripts to run.

Picard and Trimmomatic are java packages so they don't need to be
added, they can only be used with aliases. 

That wouldn't be also necessary because the scripts will ask
to select executables for both Trimmomatic and Picard. 



