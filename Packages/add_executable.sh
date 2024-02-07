#!/bin/bash

# Function to prompt user for the path of the executable using Zenity
select_executable_path() {
    executable_path=$(zenity --file-selection --file-filter="Executable files (*)|*" --title="Select the executable file")
    echo "$executable_path"
}

# Get the selected executable path
executable_path=$(select_executable_path)

# Check if the path exists
if [ -x "$executable_path" ]; then
    # Extract the directory path
    directory_path=$(dirname "$executable_path")

    # Append the export command to ~/.bashrc
    echo "export PATH=$directory_path:\$PATH" >> ~/.bashrc
    echo "Executable path added to ~/.bashrc. Please restart your terminal or run 'source ~/.bashrc'."
else
    echo "Error: The specified executable path does not exist or is not executable."
fi

