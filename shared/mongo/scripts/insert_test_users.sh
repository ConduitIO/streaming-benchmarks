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

COLLECTION_NAME=$1
COUNT=$2

if [ -z "$COLLECTION_NAME" ]; then
  echoerr "Error: Collection name is required."
  exit 1
fi

if [ -z "$COUNT" ]; then
  echoerr "Error: Count is required."
  exit 1
fi

"$SCRIPT_DIR/eval.sh" "var collection='$COLLECTION_NAME', totalDocs=$COUNT" "$SCRIPT_DIR/insert_test_users.js"
