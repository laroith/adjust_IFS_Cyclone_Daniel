#!/bin/bash -x

# calculate CC profiles for the spin-up period

#declare -a var_arr=("ta" "hus" "hur" "zg" "psl")

declare -a var_arr=("tos")
declare -a model_arr=("HadGEM2-CC" "IPSL-CM5A-MR" "MIROC-ESM" "GFDL-ESM2M" )


for model_id in "${model_arr[@]}"; do
  
  for var in "${var_arr[@]}"; do

    parent_experiment_rip='r1i1p1'

    echo ${model_id} ${parent_experiment_rip}
    
    f1='../CMIP5_dom_tos_only/day/historical/'${var}'/'${var}_day_${model_id}_historical_${parent_experiment_rip}.nc_fldavg_ydaymean_runmean
    f2='../CMIP5_rcp_dom_tos_only/day/rcp85/'${var}'/'${var}_day_${model_id}_rcp85_${parent_experiment_rip}.nc_fldavg_ydaymean_runmean
    
    ncdiff -O ${f2} ${f1} ${var}_CC_${model_id}_SPIP.nc
  
  done
  
  cdo -O merge /data/users/het/EASICLIM/adjust_IFS/CC_${model_id}_SPIP.nc ${var}_CC_${model_id}_SPIP.nc CC_${model_id}_SPIP.nc
  
done
