#!/bin/bash
CONDUIT_IMAGE=$1
WORKLOAD=$2

printf "\n-- Running %s with %s\n" "$WORKLOAD" "$CONDUIT_IMAGE"

docker stop conduit-perf-test || true

docker run --rm --name conduit-perf-test --memory 4g --cpus=6 -v "$(pwd)/plugins":/plugins -p 8080:8080 -d "$CONDUIT_IMAGE"
sleep 1

bash "$WORKLOAD"

# todo print all results from this run into the same file
go run main.go --interval=5s --duration=5m --print-to=console --workload="$WORKLOAD"

docker stop conduit-perf-test || true
