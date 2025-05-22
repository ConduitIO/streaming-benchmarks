#!/bin/bash

# MongoDB replica set initialization script
# This runs once to initialize the 3-node replica set

echo "Starting replica set initialization..."

# JavaScript code to initialize the replica set
js_code='
rs.initiate({
  _id: "test-replica-set",
  members: [
    { _id: 0, host: "benchi-mongo1:30001" },
    { _id: 1, host: "benchi-mongo2:30002" },
    { _id: 2, host: "benchi-mongo3:30003" }
  ]
})
'

# Try to initialize the replica set
echo "Attempting to initialize replica set..."
if mongosh --host benchi-mongo1 --port 30001 --eval "$js_code" --quiet; then
    echo "Replica set initialization completed successfully"

    # Wait a moment for the replica set to stabilize
    echo "Waiting for replica set to stabilize..."
    sleep 10

    # Check the status
    echo "Checking replica set status..."
    mongosh --host benchi-mongo1 --port 30001 --eval "rs.status()" --quiet

    exit 0
else
    echo "Failed to initialize replica set"
    exit 1
fi