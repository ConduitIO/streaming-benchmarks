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

echoerr() { echo "$@" 1>&2; }

check_connector_json_path() {
  if [ -z "$1" ]; then
    echoerr "Error: Connector JSON path is required."
    exit 1
  fi
}

get_connector_name() {
  jq -r '.name' "$1"
}

check_curl_exit_code() {
  if [ $? -ne 0 ]; then
    echoerr "curl command failed with exit code $?"
    exit 1
  fi
}

check_http_code() {
  if [ "$1" != "$2" ]; then
    echoerr "Request failed with HTTP code: $1"
    echoerr "Response: $(cat /tmp/curl_response)"
    exit 1
  fi
}