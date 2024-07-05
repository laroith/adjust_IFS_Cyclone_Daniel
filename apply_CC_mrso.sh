#!/bin/bash

#SBATCH -J apply_CC
#SBATCH -N 1
#SBATCH --ntasks-per-node=24
###SBATCH --partition=devel
#SBATCH --time=23:55:00
#SBATCH --time-min=01:05:00
#SBATCH -A jjsc39
#SBATCH -L idl@tuwien


#source compile.settings

module load idl

set -x

#declare -a model_arr=("HadGEM2-CC")
declare -a model_arr=("MIROC6")

for model_id in "${model_arr[@]}"; do
  
  # make a copy for safety reasons, if it does not exist, yet.
  [ ! -e ${model_id}/cas2008100100.nc_orig_W_SO_REL ] && cp ${model_id}/cas2008100100.nc ${model_id}/cas2008100100.nc_orig_W_SO_REL
  
  fname=${model_id}/cas2008100100.nc

  idl apply_CC_mrso_cas.bat -args $fname ${model_id}

done
