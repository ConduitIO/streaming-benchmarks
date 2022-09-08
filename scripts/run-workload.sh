#!/bin/bash
# This scripts runs a workload against a Conduit service, available at a given endpoint,
# and then periodically collects metrics, using the benchmark tool.
# The first parameter is Conduit's base URL.
# The second parameter is a path to the workload script.
CONDUIT_URL=$1
WORKLOAD=$2

echo "conduit url $CONDUIT_URL"
echo "workload script $WORKLOAD"
bash "$WORKLOAD"

# todo print all results from this run into the same file
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
${__dir}/benchmark --interval=15s --duration=10m --print-to=csv --base-url="$CONDUIT_URL"  --workload="$WORKLOAD"
