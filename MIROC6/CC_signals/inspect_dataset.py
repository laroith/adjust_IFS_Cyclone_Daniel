from netCDF4 import Dataset

# Load the dataset
file_path = 'CC_MIROC6_3D_copy.nc'  
ds = Dataset(file_path, 'r')

# Print out the structure of the dataset
print("Variables in the dataset:")
for var in ds.variables:
    print(f"- {var}: dimensions {ds.variables[var].dimensions}, shape {ds.variables[var].shape}")

ds.close()
