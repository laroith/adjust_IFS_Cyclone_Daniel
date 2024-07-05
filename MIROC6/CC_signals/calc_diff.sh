#!/bin/bash

# Loop through all scenario files
for scen_file in *scen.nc; do
    # Identify the variable name by cutting the string up to '_MIROC6_scen.nc'
    var_name=$(echo "$scen_file" | sed 's/_MIROC6_scen.nc//')

    # Construct the historical file name
    hist_file="${var_name}_MIROC6_hist.nc"

    # Construct the output difference file name
    diff_file="${var_name}_MIROC6_diff.nc"

    # Check if the historical file exists
    if [ -f "$hist_file" ]; then
        # Calculate the difference: scenario minus historical
        cdo sub "$scen_file" "$hist_file" "$diff_file"
        echo "Created difference file: $diff_file"
    else
        echo "Historical file for $var_name does not exist. Skipping..."
    fi
done
