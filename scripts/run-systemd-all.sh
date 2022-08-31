#!/bin/bash
# This scripts runs all workloads against a Conduit service, managed by systemd.
# The first parameter is the Conduit image.
CONDUIT_IMAGE=$1

cat << EOF


When interpreting test results, please take into account,
that if built-in plugins are used, their resource usage is part of Conduit's usage too.


EOF

SLEEP_TIME=60
for w in workloads/*.sh; do
  __dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source ${__dir}/run-systemd-workload.sh "$w"

  echo "sleeping for $SLEEP_TIME seconds"
  sleep $SLEEP_TIME
done
