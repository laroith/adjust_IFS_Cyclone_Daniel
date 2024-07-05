import numpy as np
import netCDF4 as nc
from scipy.interpolate import interp1d

def refined_interpolation(file_path, var_name, plev_name):
    with nc.Dataset(file_path, 'r+') as ds:
        # Load the data, ensuring it's in numpy array format directly
        var_data = ds.variables[var_name][:]
        plevs = ds.variables[plev_name][:]

        # Convert pressure levels to their logarithmic scale if necessary
        log_plevs = np.log(plevs)

        # Iterate through each latitude and longitude grid point
        for lat_idx in range(var_data.shape[2]):
            for lon_idx in range(var_data.shape[3]):
                profile = var_data[0, :, lat_idx, lon_idx].data  # Use .data to ensure numpy array
                
                # Handle masked or NaN values directly
                mask_or_nan = np.ma.getmaskarray(profile) | np.isnan(profile)
                valid_indices = np.where(~mask_or_nan)[0]
                
                # Skip profiles with insufficient data points
                if len(valid_indices) < 2:
                    continue

                # Only interpolate within the range of existing, valid data
                valid_log_plevs = log_plevs[valid_indices]
                valid_profile = profile[valid_indices]

                # Create interpolation function
                interp_function = interp1d(valid_log_plevs, valid_profile, kind='linear', bounds_error=False, fill_value=np.nan)

                # Apply the interpolation function across the valid range
                profile[valid_indices] = interp_function(valid_log_plevs)

                # Update the dataset with the interpolated values
                var_data[0, :, lat_idx, lon_idx] = profile

        # Update the original dataset variable
        ds.variables[var_name][:] = var_data

# Correct usage with the actual file path
file_path = 'CC_MIROC6_3D_1.nc'
refined_interpolation(file_path, 'hur', 'plev')
