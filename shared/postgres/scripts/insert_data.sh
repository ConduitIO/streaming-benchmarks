#!/bin/bash

cleanup() {
  echo "Interrupted. Exiting..."
  exit
}

trap cleanup SIGINT

# Number of records per batch
batch_size=80000

# Number of batches
batches=200

# Function to insert a batch of records
insert_batch() {
  psql -U meroxauser -d meroxadb -c "
  INSERT INTO employees (name, full_time, updated_at)
  SELECT 'John Doe', true, NOW()
  FROM generate_series(1, $batch_size);
  "
}

# Record start time
start_time=$(date +%s)

# Insert records in multiple batches
for ((i=1; i<=batches; i++)); do
  echo "Inserting batch $i..."
  insert_batch
done

# Record end time
end_time=$(date +%s)

# Calculate duration
duration=$((end_time - start_time))

echo "Inserted $((batch_size * batches)) records in $duration seconds."
