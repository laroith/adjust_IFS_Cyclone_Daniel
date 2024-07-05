#!/bin/bash -x

#SBATCH -J apply_CC
#SBATCH -N 1
#SBATCH --ntasks-per-node=24
###SBATCH --partition=devel
#SBATCH --time=23:55:00
#SBATCH --time-min=01:05:00
#SBATCH -A jjsc39

#source compile.settings

module load idl

set -x

declare -a model_arr=("MIROC6")

for model_id in "${model_arr[@]}"; do
  
  # make a copy for safety reasons, if it does not exist, yet.
  # adopted to 2018 event for Isabella
  #[ ! -e ${model_id}/cas2008100100.nc_orig_W_SO_REL ] && cp ${model_id}/cas2008100100.nc ${model_id}/cas2008100100.nc_orig_W_SO_REL
  #fname=${model_id}/cas2008100100.nc
  
  let ii=0
  for ff in `ls ${model_id}/cas*.nc`; do
    let ii+=1

    fname=`basename ${ff}`
    
    idl apply_plus_4K_mrso_cas.bat -args $fname ${model_id} &
    pid[${ii}]=$!

    if [ ${ii} -ge 12 ]; then
      for (( jj=1; jj<=${ii}; jj++ )); do
        wait ${pid[${jj}]}
        [ $? -ne 0 ] &&  echo "ERROR" && exit -1
      done
      let ii=0
    fi
  done
  if [ ${ii} -ne 0 ]; then
    for (( jj=1; jj<=${ii}; jj++ )); do
      wait ${pid[${jj}]}
      [ $? -ne 0 ] &&  echo "ERROR" && exit -1
    done
  fi  

done
