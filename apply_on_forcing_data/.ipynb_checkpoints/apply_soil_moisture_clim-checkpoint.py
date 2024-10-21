import xarray as xr
import sys
import numpy as np
from scipy import interpolate
import argparse
from pathlib import Path
import pandas as pd

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

# Now you can use args.cas_filename, args.gcm_name, args.input_dir, and args.output_dir in your script

mrso_climatology_file_path = "/home/lar/adjust_IFS/soil_moisture_clim/climatology.nc"

# open cas-file, to be modified
file_cas_original=xr.open_dataset(args.cas_filename)

# remove time dimension
file_cas = file_cas_original.isel(time=0)



# open file containing CC profiles and select by month and day
mrso_CC = xr.open_dataset(mrso_climatology_file_path)

# Define the soil1 coordinate
soil1_depths = [0.035, 0.175, 0.64, 1.945]

# Stack the data variables into a single DataArray with a new 'soil1' coordinate
mrso_stacked = xr.concat(
    [mrso_CC['swvl1'], mrso_CC['swvl2'], mrso_CC['swvl3'], mrso_CC['swvl4']],
    dim=pd.Index(soil1_depths, name='soil1')
)

# extract volume fraction of condensed water in soil pores
W_SO_REL = file_cas.W_SO_REL # ratio of volume fraction of soil moisture to pore volume [1]


# Rename the latitude and longitude coordinates
mrso_stacked = mrso_stacked.rename({'latitude': 'lat', 'longitude': 'lon'})

# Reassign lat and lon coordinates in mrso_regridded to match W_SO_REL
mrso_stacked = mrso_stacked.assign_coords(lat=W_SO_REL['lat'], lon=W_SO_REL['lon'])


# Convert 'soil1' coordinate in mrso_regridded to float32
mrso_stacked = mrso_stacked.assign_coords(soil1=mrso_stacked['soil1'].astype('float32'))



# Reassign the 'soil1' coordinate to exactly match W_SO_REL
mrso_redimensioned = mrso_stacked.assign_coords(soil1=W_SO_REL['soil1'])



print("mrso_stacked:")
print(mrso_redimensioned)


# Interpolate mrso_stacked to match W_SO_REL's latitude and longitude
#mrso_regridded = mrso_stacked.interp(lat=W_SO_REL.lat, lon=W_SO_REL.lon, method="linear")

#print("mrso_regridded:")
#print(mrso_regridded)

print("W_SO_REL:")
print(W_SO_REL)

#mrso_CC_da = (mrso_CC['anomaly_rel'] / 100) + 1 

#W_SO_REL_broadcasted, mrso_CC_da_broadcasted = xr.broadcast(W_SO_REL, mrso_CC_da)


#print("mrso_CC_da_expanded:")
#print(mrso_CC_da_broadcasted)

# Perform the operation

#print('Climatology added!')

#===========================================================================
#                            save output
#===========================================================================


file_cas_new = xr.open_dataset(args.cas_filename)
condition = np.isfinite(mrso_redimensioned) & (mrso_redimensioned > 0)
 

file_cas_new['W_SO_REL'] = xr.where(condition, mrso_redimensioned, W_SO_REL)


filename_output = args.cas_filename
output_file_path = Path(args.output_dir_cas) / filename_output

file_cas_new.to_netcdf(output_file_path)


print('cas-file adjusted!')
