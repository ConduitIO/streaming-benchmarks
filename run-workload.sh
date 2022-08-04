#!/bin/bash
CONDUIT_URL=$1
WORKLOAD=$2

bash "$WORKLOAD"

# todo print all results from this run into the same file
go run main.go --interval=5s --duration=1m --print-to=console --base-url="$CONDUIT_URL"  --workload="$WORKLOAD"
