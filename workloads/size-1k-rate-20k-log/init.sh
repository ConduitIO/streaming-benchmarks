#!/bin/bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
