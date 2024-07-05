# air_temperature_profile_and_spatial_variation.py
import matplotlib.pyplot as plt
import numpy as np
import xarray as xr
import cartopy.crs as ccrs

# Load the dataset
ds = xr.open_dataset('/home/lar/adjust_IFS/EC-Earth3/CC_signals/CC_EC-Earth3_3D_remapcon.nc')

# Extract air temperature
ta = ds['ta'][0, :, :, :]  # Assuming time is the first dimension

# Average for vertical profile
ta_mean = ta.mean(dim=['lat', 'lon'])

# Select pressure levels for spatial variation plots - using first, middle, and last index as examples
plev_indices = [0, len(ds['plev']) // 2, len(ds['plev']) - 1]
ta_selected = ta.sel(plev=[ds['plev'][i].values for i in plev_indices])

# Determine global min and max for consistent color scale
ta_min = ta_selected.min()
ta_max = ta_selected.max()

# Plotting
fig = plt.figure(figsize=(20, 5))
# Plot vertical profile
ax1 = fig.add_subplot(1, 4, 1)
ax1.plot(ta_mean, ds['plev'])
ax1.set_ylabel('Pressure (Pa)')
ax1.set_xlabel('Temperature (K)')
ax1.invert_yaxis()
ax1.set_title('Spatially averaged Vertical Temperature Profile Change September')

# Plot spatial variations with projection for the other subplots
for i in range(1, 4):
    ax = fig.add_subplot(1, 4, i+1, projection=ccrs.PlateCarree())
    ta_plot = ta_selected.isel(plev=i-1)
    img = ta_plot.plot(ax=ax, transform=ccrs.PlateCarree(), add_colorbar=False, vmin=ta_min, vmax=ta_max)
    ax.coastlines()
    ax.set_title(f'Air Temp Change at {ta_selected["plev"].values[i-1]} Pa')

# Add a single colorbar for the spatial plots
fig.subplots_adjust(right=0.8)
cbar_ax = fig.add_axes([0.88, 0.15, 0.02, 0.7])
fig.colorbar(img, cax=cbar_ax, label='K')

plt.tight_layout(rect=[0, 0, 0.85, 1])
plt.savefig('air_temperature_variation.png')
plt.show()
