#!/bin/bash 
#SBATCH --job-name=CREATE_COUNTERFACTUAL_sst
#SBATCH --time=05:00:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=128   
#SBATCH --ntasks-per-core=1
#SBATCH --partition=zen3_0512
#SBATCH --qos=zen3_0512
#SBATCH -A p72281

echo "Current working directory: $(pwd)"

# Ensure the output directory exists
echo "Ensuring output directory ${3} exists..."
mkdir -p ${3}

# Define variables
#GCM_NAME=$2
INPUT_DIR_CAS=$2
OUTPUT_DIR_CAS=$3


# Find all files matching the pattern given as the first argument
echo "Looking for CAS files in ${INPUT_DIR_CAS} with pattern $1"
FILES=$(find ${INPUT_DIR_CAS} -maxdepth 1 -name "$1")
echo "Found files:"
echo "${FILES}"

# Loop through each found file and process it
for FILE in ${FILES}
do
    OUTPUT_FILE="${OUTPUT_DIR_CAS}/$(basename ${FILE})"
    
    if [ -f "${OUTPUT_FILE}" ]; then
        echo "Output file ${OUTPUT_FILE} already exists. Skipping..."
        continue
    fi
    
    echo "Processing file: ${FILE}"
    python apply_sst.py --cas_input_dir=${INPUT_DIR_CAS} --output_dir=${OUTPUT_DIR_CAS}
    echo "Done processed ${FILE}"
done


# Change directory to the output directory where the processed files are
cd ${OUTPUT_DIR_CAS}

# Print the directory you're working in now
echo "Now working in directory: $(pwd)"

# Loop through each .nc file in the output directory
for FILE in ${FILES}; 
do 
    FILE=$(basename ${FILE})
    echo "Appending variables from original file to: ${FILE}"

    # Determine the original file path
    original_file="/gpfs/data/fs72281/lar/change_temp/CC_signals_Laurenz/${FILE:0:3}2023${FILE:7}"

    # Append variables from the original file
    ncks -A -v akm,bkm,time_bnds "${original_file}" "${FILE}"
done

echo "Appended variables from original file!"
