import numpy as np
from scipy.interpolate import interp1d

def custom_vertical_interpolation(plevs, values):
    # Assuming values are sorted by ascending plevs (descending altitude)
    valid_indices = np.where(values != 1e+20)[0]
    
    if len(valid_indices) == 0:
        # If no valid values are present, return the original array
        return values
    
    # If the first valid value is not at the top, extrapolate to fill above
    if valid_indices[0] > 0:
        top_extrapolate = interp1d(plevs[valid_indices[0]:valid_indices[0]+2], 
                                    values[valid_indices[0]:valid_indices[0]+2], 
                                    fill_value="extrapolate")
        for i in range(valid_indices[0]):
            values[i] = top_extrapolate(plevs[i])
    
    # Interpolate or extrapolate between valid values
    for i in range(len(valid_indices) - 1):
        start, end = valid_indices[i], valid_indices[i + 1]
        if end - start > 1:  # Gap detected
            interp_func = interp1d(plevs[[start, end]], values[[start, end]], fill_value="extrapolate")
            for j in range(start + 1, end):
                values[j] = interp_func(plevs[j])
    
    # If the last valid value is not at the bottom, extrapolate to fill below
    if valid_indices[-1] < len(plevs) - 1:
        bottom_extrapolate = interp1d(plevs[valid_indices[-2]:valid_indices[-1]+1], 
                                       values[valid_indices[-2]:valid_indices[-1]+1], 
                                       fill_value="extrapolate")
        for i in range(valid_indices[-1] + 1, len(plevs)):
            values[i] = bottom_extrapolate(plevs[i])

    return values

# Example usage
plevs = np.array([1000, 85000, 90000, 100000])  # Example pressure levels in Pa
values = np.array([290, 275, 265, 1e+20])       # Example values with 1e+20 as missing

# Perform custom vertical interpolation
interpolated_values = custom_vertical_interpolation(plevs, values)
print(interpolated_values)
