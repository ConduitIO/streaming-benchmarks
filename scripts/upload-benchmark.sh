#!/bin/bash
KEY_FILE=$1
TARGET=$2

make scripts/benchmark
make plugins/noop-dest

rsync -v -e "ssh -i $KEY_FILE" -aR scripts/ workloads/ plugins/ ec2-user@"$TARGET":/home/ec2-user/streaming-benchmarks/
