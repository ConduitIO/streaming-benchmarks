#!/bin/bash
CONDUIT_URL=$1
WORKLOAD=$2

echo "conduit url $CONDUIT_URL"
echo "workload script $WORKLOAD"
bash "$WORKLOAD"

# todo print all results from this run into the same file
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
${__dir}/benchmark --interval=15s --duration=30m --print-to=csv --base-url="$CONDUIT_URL"  --workload="$WORKLOAD"
