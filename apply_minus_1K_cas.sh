#!/bin/bash -x

#SBATCH -J apply_CC
#SBATCH -N 1
#SBATCH --ntasks-per-node=24
###SBATCH --partition=devel
#SBATCH --time=23:55:00
#SBATCH --time-min=01:05:00
#SBATCH -A jjsc39

source compile.settings

module load IDL

declare -a model_arr=("MIROC6" "EC-Earth3" )

#cd input
#for ff in `ls /p/scratch/cjjsc39/jjsc3904/PRE/SPIP_EAS_N03_IFS_ACT01/input/cas_IFS/cas*.tar`; do
#  tar -xf $ff &
#done
#wait
#exit

for model_id in "${model_arr[@]}"; do
  
  # create output folder
  mkdir ${model_id}
  
  let ii=0
  for ff in `ls input/cas*.nc`; do
    let ii+=1

    fname=`basename ${ff}`
    
    # what date is this?
    date_str=${fname:3:8}
    phase='event'
    [ $date_str -lt '2023090100' ] && phase='SPIP'
    
    idl apply_minus_1K_cas.bat -args $fname ${model_id} ${phase} &
    pid[${ii}]=$!

    if [ ${ii} -ge 24 ]; then
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

./apply_minus_1K_mrso.sh

