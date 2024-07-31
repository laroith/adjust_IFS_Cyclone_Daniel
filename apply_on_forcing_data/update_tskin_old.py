import xarray as xr
import numpy as np
import sys

def main(t_skin_file, fr_land_file, sst_file, output_file):
    t_skin_ds = xr.open_dataset(t_skin_file)
    fr_land_ds = xr.open_dataset(fr_land_file)
    sst_ds = xr.open_dataset(sst_file)

    # Handle 'time' dimension in sst_ds, if it exists
    if 'time' in sst_ds.dims:
        sst_ds = sst_ds.isel(time=0)  # Use the first time step for simplicity

    # Assuming 'sst' is in Celsius and needs conversion to Kelvin
    if 'sst' in sst_ds.variables:
        sst_ds['sst'] = sst_ds['sst'] + 273.15  # Convert from °C to K

    if 'lev' in t_skin_ds['T_SKIN'].dims:
        t_skin_ds['T_SKIN'] = t_skin_ds['T_SKIN'].isel(lev=0).drop('lev')

    # Perform the conditional update on T_SKIN based on FR_LAND
    t_skin_updated = xr.where(fr_land_ds['FR_LAND'] == 0, sst_ds['sst'], t_skin_ds['T_SKIN'])

    t_skin_filled = t_skin_updated.where(~np.isnan(t_skin_updated), t_skin_ds['T_SKIN'])

    # Instead of creating a new dataset for T_SKIN, update the data directly
    # Ensure we are modifying the data array, not the dataset directly, to avoid _FillValue issues
    t_skin_ds['T_SKIN'].values = t_skin_filled.values

    # Save the original dataset with the updated T_SKIN values
    t_skin_ds.to_netcdf(output_file, format='NETCDF4')


if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python update_tskin.py <t_skin.nc> <fr_land.nc> <sst_file.nc> <output_file.nc>")
        sys.exit(1)
    main(*sys.argv[1:])

