#!/bin/bash

# Initialize an empty string to hold the model name
model_name=""

# Initialize an empty string to hold input files for merging
input_files=""

# Loop through all files ending with _diff.nc to prepare for merging and extract model name
for file in *_diff_ensmean.nc; do
  # Add the file to the list of input files
  input_files="$input_files $file"
  
  # Extract model name if it hasn't been set
  if [ -z "$model_name" ]; then
    model_name=$(echo "$file" | sed -n 's/^\(.*\)_[^_]*_diff_ensmean\.nc$/\1/p')
  fi
done

# Check if no _diff.nc files were found
if [ -z "$input_files" ]; then
  echo "No _diff.nc files found in the current directory."
  exit 1
fi

# Use the extracted model name and input files to merge and create the combined file
output_file="CC_${model_name}_September.nc"
cdo merge $input_files "$output_file"

echo "Merging complete. Output file: $output_file"

