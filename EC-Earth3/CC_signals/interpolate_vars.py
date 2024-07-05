import numpy as np
import xarray as xr
from scipy.interpolate import interp1d
import sys

def interpolate_1d_arrays(data_array, pressure_levels):
    """Interpolate 1D arrays across all pressure levels for each lat-lon pair."""
    interpolated_values = np.full(data_array.shape, np.nan)  # Initialize with NaNs
    
    for lat_idx in range(data_array.shape[2]):
        for lon_idx in range(data_array.shape[3]):
            vertical_profile = data_array[0, :, lat_idx, lon_idx]
            valid_indices = ~vertical_profile.mask  # Indices of non-masked values
            valid_pressures = pressure_levels[valid_indices]
            valid_values = vertical_profile[valid_indices].data
            
            if len(valid_values) > 1:  # Ensure enough points for interpolation
                f_interp = interp1d(valid_pressures, valid_values, bounds_error=False, fill_value="extrapolate")
                interpolated_values[0, :, lat_idx, lon_idx] = f_interp(pressure_levels)
    
    return interpolated_values

def main(nc_file_path):
    """Load the dataset, perform interpolation for specified variables, and save the results."""
    data = xr.open_dataset(nc_file_path)
    
    # List of variable names to interpolate
    variables_to_interpolate = ['hur', 'hus', 'ta', 'zg']
    
    for var_name in variables_to_interpolate:
        if var_name in data.variables:
            print(f"Interpolating {var_name}...")
            var_data = data[var_name]
            var_masked = np.ma.masked_invalid(var_data.values)
            
            # Dynamically select the appropriate pressure levels
            pressure_dim = 'plev' if 'plev' in var_data.dims else 'plev_2'
            pressure_levels = data[pressure_dim].values
            
            var_interpolated = interpolate_1d_arrays(var_masked, pressure_levels)
            
            # Update the dataset with interpolated values
            data[var_name].values = var_interpolated
        else:
            print(f"Variable {var_name} not found in dataset. Skipping.")
    
    # Save the dataset with interpolated variables into a new NetCDF file
    output_path = nc_file_path.replace('.nc', '_all_interpolated.nc')
    data.to_netcdf(output_path)
    print(f"All interpolated data saved to {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python interpolate_multiple_variables.py <path_to_your_nc_file>")
    else:
        nc_file_path = sys.argv[1]
        main(nc_file_path)
