import sys
import xarray as xr

# Receive arguments from the Bash script
input_file = sys.argv[1]  # Input NetCDF file
output_file = sys.argv[2]  # Output NetCDF file

print(f"Processing {input_file} -> {output_file}")

# Open the NetCDF file using xarray with parallel processing enabled
ds = xr.open_mfdataset(input_file, parallel=True)

# Resample the dataset to **monthly means** using a 1-month frequency
ds_resampled = ds.resample(time="1ME").mean(dim="time")

# Save the processed dataset in NetCDF format (NETCDF3_CLASSIC for compatibility)
ds_resampled.to_netcdf(output_file, format='NETCDF3_CLASSIC')

print(f"Saved: {output_file}")
