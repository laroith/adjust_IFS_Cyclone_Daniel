#!/bin/bash -x

module load idl

set -x


declare -a model_arr=("EC-Earth3" "MIROC6")

for model_id in "${model_arr[@]}"; do 
  echo "Processing model: ${model_id}"
  
  # Adjusted IDL command
  idl -quiet -e "main" -args ${model_id}
  
  # Error handling based on IDL execution result
  if [ $? -ne 0 ]; then
    echo "IDL processing for ${model_id} failed."
    exit 1
  else
    echo "IDL processing for ${model_id} completed successfully."
  fi
done

echo "All models processed."
