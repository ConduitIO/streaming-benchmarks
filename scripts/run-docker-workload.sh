#!/bin/bash
# This scripts runs a workload in a Docker containers.
# The first parameter is the Conduit image.
# The second parameter is a path to the workload script.
CONDUIT_IMAGE=$1
WORKLOAD=$2

printf "\n-- Running %s with %s\n" "$WORKLOAD" "$CONDUIT_IMAGE"

docker stop conduit-perf-test || true

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

parent_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKLOAD_DATA="$parent_dir/$WORKLOAD/data"
WORKLOAD_PIPELINES="$parent_dir/$WORKLOAD/pipelines"
WORKLOAD_CONNECTORS="$parent_dir/$WORKLOAD/connectors"

docker run \
  --name conduit-perf-test \
  --memory 1g \
  --cpus=2 \
  -v "$WORKLOAD_DATA":/app/data \
  -v "$WORKLOAD_PIPELINES":/app/pipelines \
  -v "$WORKLOAD_CONNECTORS":/app/connectors \
  -p 8080:8080 \
  -d "$CONDUIT_IMAGE"

sleep 1

source ${__dir}/run-workload.sh "http://localhost:8080" "$WORKLOAD"

docker stop conduit-perf-test || true
