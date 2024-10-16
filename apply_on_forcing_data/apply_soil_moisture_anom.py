import xarray as xr
import sys
import numpy as np
from scipy import interpolate
import argparse
from pathlib import Path

# Set up argument parsing
parser = argparse.ArgumentParser(description="Process CAS files with given parameters.")
parser.add_argument("cas_filename", help="Filename of the CAS-file")
#parser.add_argument("gcm_name", help="Name of the GCM (e.g., MIROC6, EC-Earth3)")
parser.add_argument("input_dir_cas", help="Input directory")
parser.add_argument("output_dir_cas", help="Output directory")
#parser.add_argument("input_dir_CC_mrso", help="Input directory containing the climate change signals")

# Parse arguments
args = parser.parse_args()

print(f"Opening CAS file: {args.cas_filename}")
#print(f"Climate change signals will be read from: {args.input_dir_CC_mrso}/CC_{args.gcm_name}_3D_remapcon_TS_TSKIN.nc_minus_1K")

# [Your existing Python script code continues here...]

# Now you can use args.cas_filename, args.gcm_name, args.input_dir, and args.output_dir in your script

mrso_signal_file_path = "/home/lar/adjust_IFS/soil_moisture_anom/ESOTC_2023_DATA_SOIL_MOISTURE_FIGURE_3/ESOTC_2023_monitoring_SoilMoisture_c3s_Figure3a.nc"

# open cas-file, to be modified
file_cas_original=xr.open_dataset(args.cas_filename)

# remove time dimension
file_cas = file_cas_original.isel(time=0)



# open file containing CC profiles and select by month and day
file_mrso = xr.open_dataset(mrso_signal_file_path)



mrso_CC = file_mrso.isel(month=7).sel(lat=slice(46.625, 40), lon=slice(12.125, 27.625)) # [0,0,0] removes the coordinates time, lat, lon

print("mrso_CC:")
print(mrso_CC)

# extract volume fraction of condensed water in soil pores
W_SO_REL = file_cas.W_SO_REL # ratio of volume fraction of soil moisture to pore volume [1]

print("W_SO_REL:")
print(W_SO_REL)

mrso_CC_da = (mrso_CC['anomaly_rel'] / 100) + 1 

W_SO_REL_broadcasted, mrso_CC_da_broadcasted = xr.broadcast(W_SO_REL, mrso_CC_da)


print("mrso_CC_da_expanded:")
print(mrso_CC_da_broadcasted)

# Perform the operation
W_SO_REL_new = W_SO_REL_broadcasted * mrso_CC_da_broadcasted

print('Climate change signals added!')

#===========================================================================
#                            save output
#===========================================================================


file_cas_new = xr.open_dataset(args.cas_filename)


file_cas_new['W_SO_REL'] = file_cas_new['W_SO_REL'] * 0 + W_SO_REL_new.values


filename_output = args.cas_filename
output_file_path = Path(args.output_dir_cas) / filename_output

file_cas_new.to_netcdf(output_file_path)


print('cas-file adjusted!')
