#!/bin/bash 
#SBATCH --job-name=CREATE_COUNTERFACTUAL_sst
#SBATCH --time=00:10:00
#SBATCH -N 1
#SBATCH --ntasks-per-node=128   
#SBATCH --ntasks-per-core=1
#SBATCH --partition=zen3_0512
#SBATCH --qos=zen3_0512_devel
#SBATCH -A p72281

echo "Current working directory: $(pwd)"

# Ensure the output directory exists
echo "Ensuring output directory ${3} exists..."
mkdir -p ${3}

# Define variables
CAS_FILE=$1
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
    python apply_sst.py --cas_file=${cas_file} --cas_input_dir=${INPUT_DIR_CAS} --output_dir=${OUTPUT_DIR_CAS}
    echo "Done processed ${FILE}"
done


