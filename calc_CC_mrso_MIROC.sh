#!/bin/bash

# Define variables and model array
declare -a var_arr=("mrso")
declare -a model_arr=("MIROC6")

for model_id in "${model_arr[@]}"; do
    for var in "${var_arr[@]}"; do
        parent_experiment_rip='r1i1p1f1'
        echo "${model_id} ${parent_experiment_rip}"

        # Process historical data from 1970 to 1999
        for year in {1970..1999}; do
            # Historical files are named by decade
            if (( year % 10 == 0 )); then
                decade_end=$((year + 9))
                file1="/data/reloclim/normal/CMIP6/CMIP/MIROC/MIROC6/historical/${parent_experiment_rip}/day/${var}/gn/v20191016/mrso_day_${model_id}_historical_${parent_experiment_rip}_gn_${year}0101-${decade_end}1231.nc"
                if [[ -f "$file1" ]]; then
                    echo "Processing file: $file1"
                    # Insert your processing command here
		cdo monavg ${file1} /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gn_${year}0101-${decade_end}1231.nc_monavg
#                cdo -O fldmean /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gn_${year}0101-${decade_end}1231.nc_monavg /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gn_${year}0101-${decade_end}1231.nc_monavg_fldavg
                cdo ymonmean /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gn_${year}0101-${decade_end}1231.nc_monavg /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gn_${year}0101-${decade_end}1231.nc_ymonmean
                cdo mergetime /home/lar/adjust_IFS/mrso_day_${model_id}_historical_${parent_experiment_rip}_gn_${year}0101-${decade_end}1231.nc_ymonmean /home/lar/adjust_IFS/mrso_${model_id}_historical.nc_ymonmean
		else
                    echo "File does not exist: $file1"
                fi
            fi
        done

        # Process scenario data from 2075 to 2100
        # Adjusting to the correct pattern for scenario files
        declare -a scenario_periods=("20750101-20841231" "20850101-20941231" "20950101-21001231")
        for period in "${scenario_periods[@]}"; do
            file2="/data/reloclim/normal/CMIP6/ScenarioMIP/MIROC/MIROC6/ssp585/${parent_experiment_rip}/day/${var}/gn/v20191016/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gn_${period}.nc"
            if [[ -f "$file2" ]]; then
                echo "Processing file: $file2"
                # Insert your processing command here
		cdo monavg ${file2} /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gn_${period}.nc_monavg
#                cdo -O fldmean /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gn_${period}.nc_monavg /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gn_${period}.nc_monavg_fldavg
                cdo ymonmean /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gn_${period}.nc_monavg /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gn_${period}.nc_ymonmean
		cdo mergetime /home/lar/adjust_IFS/mrso_day_${model_id}_ssp585_${parent_experiment_rip}_gn_${period}.nc_ymonmean /home/lar/adjust_IFS/mrso_${model_id}_ssp585.nc_ymonmean
            else
                echo "File does not exist: $file2"
            fi
        done

    cdo div /home/lar/adjust_IFS/mrso_${model_id}_ssp585.nc_ymonmean /home/lar/adjust_IFS/mrso_${model_id}_historical.nc_ymonmean /home/lar/adjust_IFS/${var}_CC_${model_id}_div.nc
    cdo -sellonlatbox,-16.6114,43.8839,22.5868,47.5721  -selmon,9 /home/lar/adjust_IFS/${var}_CC_${model_id}_div.nc /home/lar/adjust_IFS/${var}_CC_${model_id}_September.nc

    done
done



