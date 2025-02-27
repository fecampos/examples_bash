#!/bin/bash

# Activate the Conda environment for Copernicus Marine data processing
conda activate copernicusmarine

# Define the start and end dates (year-month format)
start_date="2001-01"
end_date="2019-12"

# Define the paths for input (processed data) and output (original data)
output_path="/data/datos/MERCATOR/glorys_12v1/"  # Location of original NetCDF files
input_path="/home/cow/Desktop/experimento_01/croco-v2.0.1/Run_experiment_01/DATA/"  # Output directory

echo "Downloading data from $start_date to $end_date"

# Ensure the initial date is in the full YYYY-MM-DD format
current_date="${start_date}-01"

# Loop through each month from start_date to end_date
while [ "$(date -d "$current_date" +%s)" -le "$(date -d "${end_date}-01" +%s)" ]; do
  # Extract the year and month from the current date
  year=$(date -d "$current_date" +%Y)  
  month=$(date -d "$current_date" +%m)  

  # Define the output filename for the merged monthly file
  merged_file="${input_path}mercator_Y${year}M${month}.nc"

  # Define the output filename for the resampled file
  output_resampled="${input_path}mercator_Y${year}M${month}_1d.nc"

  echo "Merging files for $year-$month..."

  # Merge all NetCDF files for the current month into a single file
  cdo -O -P 40 mergetime "${output_path}glorys12v1_${year}-${month}-"*.nc "$merged_file"

  # Process the merged file using a Python script (e.g., for regridding or filtering)
  python3 process_mercator.py "$merged_file" "$output_resampled"

  # Replace the original merged file with the processed version
  mv -r $output_resampled $merged_file

  # Move to the next month
  current_date=$(date -d "$current_date +1 month" +%Y-%m-%d)
done
