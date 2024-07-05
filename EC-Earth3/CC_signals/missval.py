import argparse
import xarray as xr

def process_file(model):
    # Define the base filename pattern
    base_filename_pattern = 'mrso_{model}_September_remapcon_new.nc'
    output_filename_pattern = 'mrso_CC_{model}_September_remapcon_missval.nc'
    
    # Replace {model} placeholder with the specified model name
    input_filename = base_filename_pattern.format(model=model)
    output_filename = output_filename_pattern.format(model=model)
    
    # Load the dataset
    ds = xr.open_dataset(input_filename)

    # Replace fill values (1.e+20f) with 1 in the 'mrso' variable
    ds['mrso'] = ds['mrso'].where(ds['mrso'] != 1.e+20, 1)

    # Save the modified dataset back to a new NetCDF file
    ds.to_netcdf(output_filename)
    print(f"Processed file saved as {output_filename}")

if __name__ == "__main__":
    # Initialize the argument parser
    parser = argparse.ArgumentParser(description="Replace fill values in a NetCDF file based on the specified model.")

    # Add the model argument
    parser.add_argument("model", type=str, choices=["MIROC6", "EC-Earth3"],
                        help="The model name to process (MIROC6 or EC-Earth3).")

    # Parse the arguments
    args = parser.parse_args()

    # Call the processing function with the provided model
    process_file(args.model)
