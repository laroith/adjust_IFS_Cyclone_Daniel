import xarray as xr
import numpy as np
from scipy.spatial import cKDTree

def replace_outliers_with_nearest(data):
    # Mask for invalid values: smaller than -100, larger than 100, or exactly 1e+20 (used for missing values)
    invalid_mask = (data < 0) | (data > 5) | (data == 1e+20)
    
    # Create arrays of indices for valid and invalid points
    # Note: np.indices returns a tuple of arrays, one for each dimension of 'data'
    all_indices = np.indices(data.shape)
    valid_indices = np.column_stack([ind[~invalid_mask] for ind in all_indices])
    invalid_indices = np.column_stack([ind[invalid_mask] for ind in all_indices])
    
    if len(valid_indices) == 0 or len(invalid_indices) == 0:
        # No valid replacements or no invalid data to replace
        return data

    # Construct KDTree with valid indices for nearest neighbor search
    tree = cKDTree(valid_indices)
    # Query the tree for nearest valid indices to each invalid point
    _, nearest_indices = tree.query(invalid_indices)

    # Replace each invalid point with its nearest valid neighbor's value
    for invalid, nearest in zip(invalid_indices, nearest_indices):
        data[tuple(invalid)] = data[tuple(valid_indices[nearest])]

    return data

# Load the dataset
ds = xr.open_dataset('mrso_EC-Earth3_September_div_new.nc')
mrso = ds['mrso'].copy()

# Apply replacement function to each time slice if applicable, otherwise directly
if 'time' in mrso.dims:
    for t in range(mrso.sizes['time']):
        mrso[t, :, :] = replace_outliers_with_nearest(mrso[t, :, :].values)
else:
    mrso[:, :] = replace_outliers_with_nearest(mrso[:, :].values)

# Update the dataset with modified mrso values
ds['mrso'] = mrso

# Save the corrected dataset
ds.to_netcdf('mrso_EC-Earth3_September_div_corrected.nc')
