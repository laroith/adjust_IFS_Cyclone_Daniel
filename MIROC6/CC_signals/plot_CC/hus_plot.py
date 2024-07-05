import matplotlib.pyplot as plt
import xarray as xr
import cartopy.crs as ccrs

# Load the dataset
ds = xr.open_dataset('/home/lar/adjust_IFS/MIROC6/CC_signals/CC_MIROC6_3D_all_remapcon.nc')

# Select pressure levels - as an example, choosing first, middle, and last indices
plev_indices = [0, 2, 5]
hus_levels = ds['hus'][0, plev_indices, :, :]  # Assuming time is the first dimension

# Determine the global min and max across the selected pressure levels for consistent color scaling
min_hus = hus_levels.min()
max_hus = hus_levels.max()

# Plotting
fig, axes = plt.subplots(1, len(plev_indices), figsize=(15, 5), subplot_kw={'projection': ccrs.PlateCarree()})
for i, ax in enumerate(axes.flat):
    img = hus_levels.isel(plev_2=i).plot(ax=ax, transform=ccrs.PlateCarree(), add_colorbar=False, vmin=min_hus, vmax=max_hus)
    ax.coastlines()
    ax.set_title(f'Hus change at {hus_levels["plev_2"].values[i]} Pa')

# Add a single colorbar for all subplots
fig.subplots_adjust(right=0.92)
cbar_ax = fig.add_axes([0.93, 0.15, 0.02, 0.7])
cbar = fig.colorbar(img, cax=cbar_ax)
cbar.set_label('Specific Humidity (1)')

plt.tight_layout(rect=[0, 0, 0.93, 1])
plt.savefig('specific_humidity_plot.png')
plt.show()
