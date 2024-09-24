#!/bin/bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_connector() {
  # Define variables
  local url="https://github.com/conduitio-labs/conduit-connector-chaos/releases/download/v0.1.1/conduit-connector-chaos_0.1.1_Linux_x86_64.tar.gz"
  local archive_name="conduit-connector-chaos_0.1.1_Linux_x86_64.tar.gz"
  local connectors_dir="$__dir/connectors"
  local binary_name="conduit-connector-chaos"

  # Download the archive
  echo "Downloading archive..."
  curl -s -L -o "$archive_name" "$url" || { echo "Failed to download the archive"; return 1; }

  # Extract the conduit binary
  echo "Extracting $binary_name binary..."
  tar -xzf "$archive_name" "$binary_name" || { echo "Failed to extract $binary_name binary"; return 1; }

  # Create the connectors directory with appropriate permissions
  echo "Creating $connectors_dir..."
  mkdir -p "$connectors_dir" || { echo "Failed to create $connectors_dir"; return 1; }

  # Copy the conduit binary to the connectors directory
  echo "Copying $binary_name binary to $connectors_dir..."
  cp "$binary_name" "$connectors_dir/" || { echo "Failed to copy $binary_name binary"; return 1; }

  # Clean up
  echo "Cleaning up..."
  rm "$archive_name"
  rm "$binary_name"

  echo "Done!"
}

create_tmp_file() {
  # todo reuse script
  FILE_SIZE=1K

  # todo standardize this directory, pre-create
  mkdir -p "$__dir/data"
  FILE_NAME="$__dir/data/conduit-test-file"

  echo "Generating a file of size ${FILE_SIZE}"
  rm -f /tmp/conduit-test-file
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    fallocate -l $FILE_SIZE $FILE_NAME
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    mkfile -n $FILE_SIZE $FILE_NAME
  else
    echo "The operating system $OSTYPE is not supported."
    exit 1
  fi
}

# Call the function
install_connector

create_tmp_file
