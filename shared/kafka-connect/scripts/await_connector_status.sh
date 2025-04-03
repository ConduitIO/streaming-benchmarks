#!/bin/sh

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

# This script waits for a connector to be in the given state.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/common.sh"

CONNECTOR_JSON_PATH=$1
check_connector_json_path "$CONNECTOR_JSON_PATH"

CONNECTOR_NAME=$(get_connector_name "$CONNECTOR_JSON_PATH")

KAFKA_CONNECT_URL="http://localhost:8083"
# The script is usually run before a test, to make sure that a pipeline started.
# However, metrics are started just before a test runs.
# The connector might start just after we checked its status, which means
# that if the retry interval is too large, the connector might read a lot of
# or all the data.
# Because of that, the retry interval should be kept small.
MAX_RETRIES=20
RETRY_INTERVAL=0.5

DESIRED_STATUS="${2:-RUNNING}"

if [ "$DESIRED_STATUS" != "RUNNING" ] && [ "$DESIRED_STATUS" != "PAUSED" ]; then
  echoerr "Error: Invalid desired status. Must be 'RUNNING' or 'PAUSED'."
  exit 1
fi

echo "Waiting for connector '$CONNECTOR_NAME' to be in $DESIRED_STATUS state..."

i=1
while [ $i -le $MAX_RETRIES ]; do
  echo "Attempt $i of $MAX_RETRIES..."

  STATUS=$(curl -s "$KAFKA_CONNECT_URL/connectors/$CONNECTOR_NAME/status" | jq -r '.connector.state')

  # Check if curl failed
  if [ $? -ne 0 ]; then
    echoerr "Failed to connect to Kafka Connect REST API. Retrying in $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
    i=$((i+1))
    continue
  fi

  # Check if connector doesn't exist
  if echo "$STATUS" | grep -q "404" || [ -z "$STATUS" ]; then
    echo "Connector '$CONNECTOR_NAME' not found. Retrying in $RETRY_INTERVAL seconds..."
    sleep $RETRY_INTERVAL
    i=$((i+1))
    continue
  fi

  echo "Current connector state: $STATUS"

  # Check if connector is in the desired state
  if [ "$STATUS" = "$DESIRED_STATUS" ]; then
    echo "Success! Connector '$CONNECTOR_NAME' is now in $DESIRED_STATUS state."
    exit 0
  elif [ "$STATUS" = "FAILED" ] && [ "$DESIRED_STATUS" != "FAILED" ]; then
    echoerr "Error: Connector entered FAILED state."
    # Get more details about the failure
    curl -s "$KAFKA_CONNECT_URL/connectors/$CONNECTOR_NAME/status"
    exit 1
  fi

  echo "Waiting $RETRY_INTERVAL seconds before next check..."
  sleep $RETRY_INTERVAL
  i=$((i+1))
done

echoerr "Timeout waiting for connector '$CONNECTOR_NAME' to reach $DESIRED_STATUS state."
exit 1
