import matplotlib.pyplot as plt
import xarray as xr
import cartopy.crs as ccrs

# Load the dataset
ds = xr.open_dataset('/home/lar/adjust_IFS/MIROC6/CC_signals/CC_MIROC6_3D_all_remapcon.nc')

# Select pressure levels - as an example, choosing first, middle, and last indices
plev_indices = [0, 2, 5]
zg_levels = ds['zg'][0, plev_indices, :, :]  # Assuming time is the first dimension

# Determine the global min and max across the selected pressure levels for consistent color scaling
min_zg = zg_levels.min()
max_zg = zg_levels.max()

# Plotting
fig, axes = plt.subplots(1, len(plev_indices), figsize=(15, 5), subplot_kw={'projection': ccrs.PlateCarree()})
for i, ax in enumerate(axes.flat):
    img = zg_levels.isel(plev=i).plot(ax=ax, transform=ccrs.PlateCarree(), add_colorbar=False, vmin=min_zg, vmax=max_zg)
    ax.coastlines()
    ax.set_title(f'zg change at {zg_levels["plev"].values[i]} Pa')

# Add a single colorbar for all subplots
fig.subplots_adjust(right=0.92)
cbar_ax = fig.add_axes([0.93, 0.15, 0.02, 0.7])
cbar = fig.colorbar(img, cax=cbar_ax)
cbar.set_label('Geopotential (m)')

plt.tight_layout(rect=[0, 0, 0.93, 1])
plt.savefig('geopotential_plot.png')
plt.show()
