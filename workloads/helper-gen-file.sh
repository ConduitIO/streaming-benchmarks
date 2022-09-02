#!/bin/bash
FILE_SIZE=$1
FILE_NAME=/tmp/conduit-test-file

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
