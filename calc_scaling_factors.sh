#!/bin/bash -x

declare -a model_arr=("HadGEM2-CC" "IPSL-CM5A-MR" "MIROC-ESM" "GFDL-ESM2M" )

# 1. step: calculate global mean temperature changes between the 
#          EASICLIM historical and future periods

for model_id in "${model_arr[@]}"; do
  
  # concatenate files and extract historical period
  dstart='1975-01-01'
  dend='2004-12-31'
  period='historical'
  
  for ff in `ls /data/reloclim/normal/CMIP5_monthly/${model_id}/${period}/tas_*.nc`; do
  
    fname=`basename $ff`
    
    cdo -O fldmean $ff ${fname}_fldmean
    [ $? -ne 0 ] && exit -1
    
  done

  cdo -O cat *_fldmean tmp.nc 
  [ $? -ne 0 ] && exit -1
  
  rm *_fldmean
  
  cdo -O seldate,${dstart},${dend} tmp.nc tas_${model_id}_${period}.nc
  [ $? -ne 0 ] && exit -1
  
  rm tmp.nc
  
  # concatenate files and extract future period
  dstart='2070-01-01'
  dend='2099-12-31'
  period='rcp85'
  
  for ff in `ls /data/reloclim/normal/CMIP5_monthly/${model_id}/${period}/tas_*.nc`; do
  
    fname=`basename $ff`
    
    cdo -O fldmean $ff ${fname}_fldmean
    [ $? -ne 0 ] && exit -1
    
  done

  cdo -O cat *_fldmean tmp.nc 
  [ $? -ne 0 ] && exit -1
  
  rm *_fldmean
  
  cdo -O seldate,${dstart},${dend} tmp.nc tas_${model_id}_${period}.nc
  [ $? -ne 0 ] && exit -1
  
  rm tmp.nc
  
  
  # calcaulate global mean climate change signal
  
  cdo -O sub -timmean tas_${model_id}_rcp85.nc -timmean tas_${model_id}_historical.nc tas_CC_${model_id}_global.nc
  [ $? -ne 0 ] && exit -1
  
  # calculate scaling factor to emulate -1 K global temperature change
  
  ncap2 -O -s 'tas=-1/tas' tas_CC_${model_id}_global.nc tas_CC_${model_id}_global.nc_scaling_minus_1K
  
  idl calc_minus_1K_CC.bat -args ${model_id}
  
done  
  
