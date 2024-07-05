#!/bin/bash -x

declare -a model_arr=("EC-Earth3")

# 1. step: calculate global mean temperature changes between the 
#          EASICLIM historical and future periods

for model_id in "${model_arr[@]}"; do
  
  # concatenate files and extract historical period
  dstart='1971-01-01'
  dend='2000-12-31'
  period='historical'
  
  for ff in `ls /data/reloclim/normal/CMIP6/CMIP/EC-Earth-Consortium/${model_id}/${period}/r1i1p1f1/Amon/tas/gr/v20200310/tas_Amon_EC-Earth3_historical_r1i1p1f1_gr_*.nc`; do
  
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
  dstart='2071-01-01'
  dend='2100-12-31'
  period='ssp585'
  
  for ff in `ls /data/reloclim/normal/CMIP6/ScenarioMIP/EC-Earth-Consortium/${model_id}/${period}/r1i1p1f1/Amon/tas/gr/v20200310/tas_Amon_EC-Earth3_ssp585_r1i1p1f1_gr_*.nc`; do
  
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
  
  cdo -O sub -timmean tas_${model_id}_ssp585.nc -timmean tas_${model_id}_historical.nc tas_CC_${model_id}_global.nc
  [ $? -ne 0 ] && exit -1
  
  # calculate scaling factor to emulate -1 K global temperature change
  
  ncap2 -O -s 'tas=-1/tas' tas_CC_${model_id}_global.nc tas_CC_${model_id}_global.nc_scaling_minus_1K
  
  idl calc_minus_1K_CC.bat -args ${model_id}
  
done  
  
