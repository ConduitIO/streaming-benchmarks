#!/bin/bash
# Uploads the benchmark (scripts and helper binaries) to a target AWS EC2 instance.
KEY_FILE=$1
TARGET=$2

rm scripts/benchmark
make scripts/benchmark

rm plugins/noop-dest
make plugins/noop-dest

rsync -v -e "ssh -i $KEY_FILE" -aR scripts/ workloads/ plugins/ ec2-user@"$TARGET":/home/ec2-user/streaming-benchmarks/
