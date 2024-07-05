# sea_level_pressure.py
import matplotlib.pyplot as plt
import numpy as np
import xarray as xr
import cartopy.crs as ccrs

# Load the dataset
ds = xr.open_dataset('~/adjust_IFS/EC-Earth3/CC_signals/CC_EC-Earth3_3D_remapcon.nc')

# Extract the sea level pressure
psl = ds['psl'][0, :, :]  # Assuming time dimension is the first and only one

# Plotting
plt.figure(figsize=(10, 6))
ax = plt.axes(projection=ccrs.PlateCarree())
psl.plot(ax=ax, transform=ccrs.PlateCarree(), cbar_kwargs={'label': 'Pa'})
ax.coastlines()
ax.set_title('Mean Sea Level Pressure Change September (2071 to 2100 minus 1971 to 2000')
plt.savefig('sea_level_pressure.png')
plt.show()
