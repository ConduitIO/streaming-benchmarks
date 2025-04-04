#!/bin/bash

# Copyright © 2025 Meroxa, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/common.sh"

cleanup() {
  echoerr "Interrupted. Exiting..."
  exit
}

trap cleanup SIGINT

# Number of records to insert
TOTAL_RECORDS=$1

# Batch size
BATCH_SIZE=10000

if [ -z "$TOTAL_RECORDS" ]; then
  echoerr "Error: Number of records to insert is required as the first argument."
  exit 1
fi

# Function to insert a batch of records
insert_batch() {
  psql -U meroxauser -d meroxadb -c "
  INSERT INTO employees (name, email, full_time, position, hire_date, salary, updated_at, created_at)
  SELECT 'John Doe', 'john.doe@example.com', true, 'Software Engineer', CURRENT_DATE, 60000.00, NOW(), NOW()
  FROM generate_series(1, $BATCH_SIZE);
  "
}

# Record start time
start_time=$(date +%s)

BATCHES=$(( (TOTAL_RECORDS + BATCH_SIZE - 1) / BATCH_SIZE ))

# Insert records in multiple batches
for ((i=1; i<=$BATCHES; i++)); do
  echo "Inserting batch $i..."
  insert_batch
done

# Record end time
end_time=$(date +%s)

# Calculate duration
duration=$((end_time - start_time))

echo "Inserted $TOTAL_RECORDS records in $duration seconds."
