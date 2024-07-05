import sys
import shutil
from netCDF4 import Dataset
import numpy as np

def modify_variable(file_path, var_names, tas_cc):
    with Dataset(file_path, 'a') as nc:
        for var_name in var_names:
            var_data = nc.variables[var_name][:]
            
            # Drop the time dimension if present (assuming it's the first dimension)
            if var_data.ndim == 4:  # 4D data includes time dimension
                var_data = var_data[0]  # Select the first time step
            
            idx = np.where(var_data < 100000.0)
            
            if var_name == 'mrso':
                # For mrso, apply exponentiation and ensure broadcasting works correctly
                var_data[idx] = np.power(var_data[idx], tas_cc[0])
            else:
                # Temporary array for modification to ensure broadcasting
                temp_array = np.empty_like(var_data[idx])
                temp_array[...] = tas_cc[0]
                var_data[idx] = var_data[idx] * temp_array
            
            # Write back the modified data, adjusting dimensions if needed
            if var_data.ndim == 3:  # Originally 4D, now 3D after dropping time
                nc.variables[var_name][0, ...] = var_data.astype(np.float32)
            else:
                nc.variables[var_name][:] = var_data.astype(np.float32)

def main(model_name):
    tas_cc_file = f'tas_CC_{model_name}_global.nc_scaling_minus_1K'
    tas_cc = Dataset(tas_cc_file).variables['tas'][:]
    tas_cc = tas_cc.astype(float)
    
    # Define the files and variables you want to modify
    files_and_variables = {
        f'CC_{model_name}_3D_remapcon.nc_minus_1K': ['hur', 'ta', 'zg', 'psl'],
        f'mrso_CC_{model_name}_September_remapcon.nc_minus_1K': ['mrso'],
    }
    
    # Copy original files appending "_minus_1K"
    for original_file in files_and_variables.keys():
        shutil.copy(original_file.replace("_minus_1K", ""), original_file)
    
    # Modify the specified variables in each file
    for file_path, vars in files_and_variables.items():
        print(f"Modifying {file_path}...")
        modify_variable(file_path, vars, tas_cc)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python <script_name>.py <ModelName>")
        print("Example: python <script_name>.py EC-Earth3")
        sys.exit(1)
    
    model_name = sys.argv[1]
    main(model_name)
