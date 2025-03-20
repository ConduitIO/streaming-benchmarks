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

CONNECTOR_NAME=$(get_connector_name "$CONNECTOR_JSON_PATH")

http_code=$(curl --silent --output /tmp/curl_response --write-out "%{http_code}" -X PUT "http://localhost:8083/connectors/$CONNECTOR_NAME/resume")

if [ $? -ne 0 ]; then
    echoerr "curl command failed with exit code $?"
    exit 1
fi

if [ "$http_code" != "202" ]; then
    echoerr "Pipeline start request failed with HTTP code: $http_code"
    echoerr "Response: $(cat /tmp/curl_response)"
    exit 1
fi

echo "Pipeline start request succeeded"

"$SCRIPT_DIR/await_connector_status.sh" "$CONNECTOR_JSON_PATH" "RUNNING"
