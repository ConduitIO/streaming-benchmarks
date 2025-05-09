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

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/common.sh"

CONNECTOR_JSON_PATH=$1
check_connector_json_path "$CONNECTOR_JSON_PATH"

# Create a temporary file
temp_file=$(mktemp)

# Replace environment variables
cat "$CONNECTOR_JSON_PATH" > "$temp_file"

# Extract all unique environment variable patterns like ${VAR}
grep -o '\${[A-Za-z0-9_]\+}' "$CONNECTOR_JSON_PATH" | sort | uniq | while read VAR_PATTERN; do
    # Extract the variable name without ${} wrapper
    VAR_NAME=$(echo "$VAR_PATTERN" | sed 's/^\${//;s/}$//')

    # Get the variable value using eval and handle unset variables
    VAR_VALUE=$(eval echo \$$VAR_NAME 2>/dev/null)

    # Escape special characters in both the pattern and replacement value for sed
    ESCAPED_PATTERN=$(echo "$VAR_PATTERN" | sed 's/[\/&]/\\&/g')
    ESCAPED_VALUE=$(echo "$VAR_VALUE" | sed 's/[\/&]/\\&/g')

    # Replace all occurrences of the pattern with the value
    sed -i "s/$ESCAPED_PATTERN/$ESCAPED_VALUE/g" "$temp_file"
done

# Send the request
http_code=$(curl --silent --output /tmp/curl_response --write-out "%{http_code}" \
  -X POST -H "Content-Type: application/json" \
  -d @"$temp_file" localhost:8083/connectors)

if [ $? -ne 0 ]; then
    echoerr "curl command failed with exit code $?"
    exit 1
fi

if [ "$http_code" != "201" ]; then
    echoerr "Create pipeline request failed with HTTP code: $http_code"
    echoerr "Response: $(cat /tmp/curl_response)"
    exit 1
fi

echo "Create pipeline request succeeded"
