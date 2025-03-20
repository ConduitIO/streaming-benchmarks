# Streaming Benchmarks

This repository contains the tools and scripts used to run performance
benchmarks for data streaming tools like
[Conduit](https://github.com/conduitio/conduit) and
[Kafka Connect](https://docs.confluent.io/platform/current/connect/index.html).
The tools are tested under the same conditions using
[Benchi](https://github.com/conduitio/benchi), to ensure that the results are
comparable.

## Results

The raw results of the benchmarks can be found in the [results](./results)
directory. Here we are just posting the aggregated results.

### Benchmark: MongoDB to Kafka

> [Click here](./results/TODO) to see the full results.

This benchmark tests the performance of the data pipeline when reading from a
MongoDB source and writing to a Kafka destination.

> TODO aggregated results table and graph

## Running the benchmarks

To run the benchmarks yourself, you need to have Docker and Docker Compose
installed on your machine (see [Docker Desktop](https://docs.docker.com/desktop/)).

Run all benchmarks using:

```sh
make install-tools run-all
```

The [`Makefile`](./Makefile) contains a number of useful targets to make it easy
to work with the benchmarks. Use `make help` to see the available targets.

```sh
$ make help
install-tools   Install all tools required for benchmarking.
install-benchi  Install latest version of benchi.
install-csvtk   Install csvtk for processing CSV files.
list            List all benchmarks.
run-all         Run all benchmarks. Optionally add "run-<benchmark-name>" to run a specific benchmark.
run-%           Run a specific benchmark.
rmi-conduit     Remove the Conduit docker image (use when built-in connectors get added or upgraded).
```