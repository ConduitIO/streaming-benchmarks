#!/bin/bash
WORKLOAD=$1

printf "\n-- Running %s with %s\n" "$WORKLOAD"

echo "stopping service"
sudo systemctl stop conduit.service

echo "cleaning up DB"
rm -rf /var/lib/conduit/conduit.db/

echo "starting service"
sudo systemctl start conduit.service
sleep 1

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source ${__dir}/run-workload.sh "http://localhost:8080" "$WORKLOAD"

echo "stopping service"
sudo systemctl stop conduit.service

echo "cleaning up DB"
rm -rf /var/lib/conduit/conduit.db/
