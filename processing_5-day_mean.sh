#!/bin/bash

# Define start and end dates
start_date="2000-01-01"
end_date="2019-12-31"

# Paths for input and output data
output_path="/data/datos/MERCATOR/glorys_12v1/"
input_path="/home/cow/Desktop/experimento_01/croco-v2.0.1/Run_experiment_01/DATA/5daily/"

echo "Downloading data from $start_date to $end_date"
current_date="$start_date"

# Initialize the current month tracker
current_month=$(date -d "$current_date" +%Y-%m)
monthly_files=()  # Array to store temporary 5-day files for each month

# Loop through dates in 5-day intervals
while [ "$(date -d "$current_date" +%s)" -le "$(date -d "$end_date" +%s)" ]; do
  # Define the last day of the 5-day block
  next_date=$(date -d "$current_date +4 days" +%Y-%m-%d)
  file_list=""
  temp_date="$current_date"

  # Collect all daily NetCDF files within the 5-day range
  while [ "$(date -d "$temp_date" +%s)" -le "$(date -d "$next_date" +%s)" ]; do
    file_list+="${output_path}glorys12v1_${temp_date}.nc "
    temp_date=$(date -d "$temp_date +1 day" +%Y-%m-%d)
  done

  # Define the output file for the 5-day average
  output_5d="${input_path}mercator_${current_date}.nc"
  echo "Processing files from $current_date to $next_date -> $output_5d"

  # Merge all daily files within the 5-day period into one
  cdo -O -P 40 mergetime $file_list "$output_5d"

  # Store the 5-day file in the monthly array
  monthly_files+=("$output_5d")

  # Check if the month has changed
  new_month=$(date -d "$current_date" +%Y-%m)
  if [[ "$new_month" != "$current_month" ]]; then
    # Merge all 5-day files into a single monthly file
    monthly_output="${input_path}mercator_${current_month}.nc"
    echo "Merging monthly files into $monthly_output"
    cdo -O -P 40 mergetime "${monthly_files[@]}" "$monthly_output"

    # Remove temporary 5-day files after merging
    rm -f "${monthly_files[@]}"

    # Reset the array and update the current month
    monthly_files=()
    current_month="$new_month"
  fi

  # Move to the next 5-day block
  current_date=$(date -d "$current_date +5 days" +%Y-%m-%d)
done

# Ensure the last month's data is merged if not already processed
if [ ${#monthly_files[@]} -gt 0 ]; then
  monthly_output="${input_path}mercator_${current_month}.nc"
  echo "Final merging monthly files into $monthly_output"
  cdo -O -P 40 mergetime "${monthly_files[@]}" "$monthly_output"
  rm -f "${monthly_files[@]}"
fi
