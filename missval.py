import argparse
import xarray as xr
import numpy as np

def process_file(model):
    # Define the base filename pattern
    base_filename_pattern = 'mrso_CC_{model}_September_remapcon_missval.nc_minus_1K'
    output_filename_pattern = 'mrso_CC_{model}_September_remapcon.nc_minus_1K'
    
    # Replace {model} placeholder with the specified model name
    input_filename = base_filename_pattern.format(model=model)
    output_filename = output_filename_pattern.format(model=model)
    
    # Load the dataset
    ds = xr.open_dataset(input_filename)

    # Access _FillValue and missing_value from .attrs, provide defaults if not present
    mrso = ds['mrso']
    fill_value = mrso.attrs.get('_FillValue', None)
    missing_value = mrso.attrs.get('missing_value', fill_value)  # Use fill_value as default for missing_value if not specified

    # Replace fill and missing values with 1
    condition = (mrso == fill_value) | (mrso == missing_value) | np.isnan(mrso)
    mrso_filled = mrso.where(~condition, 1)
    ds['mrso'] = mrso_filled

    # It's unusual to change the _FillValue attribute when modifying data; consider leaving it as is or removing it
    # Optionally update or remove _FillValue and missing_value attributes if your workflow requires it

    # Save the modified dataset back to a new NetCDF file
    ds.to_netcdf(output_filename)
    print(f"Processed file saved as {output_filename}")

if __name__ == "__main__":
    # Initialize the argument parser
    parser = argparse.ArgumentParser(description="Replace fill and missing values in a NetCDF file for a specified model.")

    # Add the model argument
    parser.add_argument("model", type=str, choices=["MIROC6", "EC-Earth3"], help="The model name to process (MIROC6 or EC-Earth3).")

    # Parse the arguments
    args = parser.parse_args()

    # Call the processing function with the provided model
    process_file(args.model)

    base_filename_pattern = 'mrso_CC_{model}_September_remapcon_missval.nc_minus_1K'
    output_filename_pattern = 'mrso_CC_{model}_September_remapcon.nc_minus_1K'

