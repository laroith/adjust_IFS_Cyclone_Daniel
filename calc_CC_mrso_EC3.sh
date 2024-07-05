#!/bin/bash

# Define variables and model array
declare -a var_arr=("mrso")
declare -a model_arr=("EC-Earth3")

for model_id in "${model_arr[@]}"; do
    for var in "${var_arr[@]}"; do
        parent_experiment_rip='r1i1p1f1'
        echo "${model_id} ${parent_experiment_rip}"

        # Process historical data from 1970 to 1999
        for year in {1970..1999}; do
            # Historical files are named by decade
            file1="/data/reloclim/normal/CMIP6/CMIP/EC-Earth-Consortium/EC-Earth3/historical/r1i1p1f1/day/mrso/gr/v20210324/mrso_day_${model_id}_historical_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc"
            if [[ -f "$file1" ]]; then
                echo "Processing file: $file1"
                    # Insert your processing command here
	cdo monavg ${file1} /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_monavg
#        cdo -O fldmean /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_monavg /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_monavg_fldavg
        cdo ymonmean /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_monavg /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_ymonmean
        cdo mergetime /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_ymonmean /home/lar/adjust_IFS/mrso_${model_id}_historical.nc_ymonmean
	else
                echo "File does not exist: $file1"
            fi
        done

        # Process scenario data from 2075 to 2100
        # Adjusting to the correct pattern for scenario files
        for year in {2075..2100}; do
            file2="/data/reloclim/normal/CMIP6/ScenarioMIP/EC-Earth-Consortium/EC-Earth3/ssp585/r1i1p1f1/day/mrso/gr/v20210324/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc"
            if [[ -f "$file2" ]]; then
                echo "Processing file: $file2"
                # Insert your processing command here
		cdo monavg ${file2} /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_monavg
#                cdo -O fldmean /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_monavg /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_monavg_fldavg
                cdo ymonmean /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_monavg /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_ymonmean
		cdo mergetime /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gr_${year}0101-${year}1231.nc_ymonmean /home/lar/adjust_IFS/mrso_${model_id}_ssp585.nc_ymonmean
        else
                echo "File does not exist: $file2"
            fi
	done

    cdo div /home/lar/adjust_IFS/mrso_${model_id}_ssp585.nc_ymonmean /home/lar/adjust_IFS/mrso_${model_id}_historical.nc_ymonmean /home/lar/adjust_IFS/${var}_CC_${model_id}_div.nc
    cdo selmon,9 /home/lar/adjust_IFS/${var}_CC_${model_id}_div.nc /home/lar/adjust_IFS/${var}_CC_${model_id}_September.nc

    done
done



