#!/bin/bash

# Developer: 0xDolan
# GitHub Repo: https://github.com/0xdolan/web_crt

# Check if the user provided a website as a parameter
if [ -z "$1" ]; then
  echo "Usage: web_crt <website>"
  echo "Example: web_crt example.com"
  exit 1
fi

# Trim the input to remove any newline characters or spaces
website=$(echo "$1" | sed 's/^[ \t]*//;s/[ \t]*$//')

# Define the output file in the current working directory
output_file="$(pwd)/${website}_subdomains"

# Function to display a progress bar
progress_bar() {
  duration=$1
  already_done() { for ((done = 0; done < $elapsed; done++)); do printf "▇"; done; }
  remaining() { for ((remain = $elapsed; remain < $duration; remain++)); do printf " "; done; }
  percentage() { printf "| %s%%" $(((($elapsed) * 100) / ($duration) * 100 / 100)); }
  clean_line() { printf "\r"; }
  for ((elapsed = 1; elapsed <= $duration; elapsed++)); do
    already_done
    remaining
    percentage
    sleep 1
    clean_line
  done
  printf "\n"
}

# Define a reasonable duration for the progress bar (in seconds)
duration=50

# Start the progress bar in the background
progress_bar $duration &

# Fetch data from crt.sh for the specified website in JSON format
response=$(curl -s "https://crt.sh/?q=$website&output=json")

# Wait for the progress bar to finish
wait

# Save the response to a temporary file for debugging
echo "$response" >${website}_response_data.json

# Check if the response is valid JSON
if echo "$response" | jq empty >/dev/null 2>&1; then
  # If valid JSON, extract the subdomain names using jq
  echo "$response" | jq -r '.[].name_value' | grep -Po '(\w+\.\w+\.\w+)$' | anew >"$output_file"
  echo "Subdomains have been saved to '$output_file'."
else
  echo "Error: The response is not valid JSON. Please check the response.json file for debugging."
fi
