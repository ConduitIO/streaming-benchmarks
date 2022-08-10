#!/bin/bash
CONDUIT_IMAGE=$1
WORKLOAD=$2

printf "\n-- Running %s with %s\n" "$WORKLOAD" "$CONDUIT_IMAGE"

sudo systemctl stop conduit.service
rm -rf /var/lib/conduit/conduit.db/

sudo systemctl start conduit.service
sleep 1

./run-workload.sh "http://localhost:8080" "$WORKLOAD"

sudo systemctl stop conduit.service
rm -rf /var/lib/conduit/conduit.db/