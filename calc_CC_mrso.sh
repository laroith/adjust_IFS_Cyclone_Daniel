#!/bin/bash -x

# calculate CC profiles for the spin-up period

declare -a var_arr=("mrso")
declare -a model_arr=("HadGEM2-CC" "IPSL-CM5A-MR" "MIROC-ESM" "GFDL-ESM2M" )


for model_id in "${model_arr[@]}"; do
  
  for var in "${var_arr[@]}"; do

    parent_experiment_rip='r1i1p1'

    echo ${model_id} ${parent_experiment_rip}
    
    f1='../CMIP5_dom/day/historical/'${var}'/'${var}_day_${model_id}_historical_${parent_experiment_rip}_*.nc_monavg_fldavg
    f2='../CMIP5_rcp85_dom/day/rcp85/'${var}'/'${var}_day_${model_id}_rcp85_${parent_experiment_rip}_*.nc_monavg_fldavg
    
    cdo ymonmean ${f1} ${f1}_ymonmean
    cdo ymonmean ${f2} ${f2}_ymonmean
    
    cdo div ${f2}_ymonmean ${f1}_ymonmean ${var}_CC_${model_id}_SPIP.nc
    cdo selmon,10 ${var}_CC_${model_id}_SPIP.nc ${var}_CC_${model_id}_October.nc
  
  done
  
done
