#!/bin/bash
# This scripts runs all workloads in Docker containers.
# The first parameter is the Conduit image.
CONDUIT_IMAGE=$1

cat << EOF


When interpreting test results, please take into account,
that if built-in plugins are used, their resource usage is part of Conduit's usage too.


EOF

SLEEP_TIME=120
for w in workloads/*; do
    if [ -d "$w" ]; then
      __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
      source ${__dir}/run-docker-workload.sh $CONDUIT_IMAGE "$w"

      # The sleep time here creates a "gap" in monitoring tools,
      # which makes it clear when a workload ended
      # and when the next one started.
      echo "sleeping for $SLEEP_TIME seconds"
      sleep $SLEEP_TIME
    fi
done
