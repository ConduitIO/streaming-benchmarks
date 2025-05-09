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

### Benchmark: Kafka to Snowflake

> [Click here](./results/kafka-snowflake/20250417) to see the full results.

This benchmark tests the performance of the data pipeline when reading from a
Kafka source and writing to a Snowflake destination.

We found that Conduit was able to process 13,333 messages per second, while Kafka
Connect was able to process 66,400 messages per second. The test was run for 1
minute, and the results were aggregated over the entire test duration.

It's important to note what caused the difference in throughput. Both tools
function entirely differently and have different use cases. Kafka Connect is
dumping the raw data into Snowflake, letting the user transform the data in
Snowflake in later steps. Conduit, on the other hand, is transforming the data
as it flows through the pipeline, inserting the transformed data into proper
columns in Snowflake. Additionally, Conduit deduplicates the data, while Kafka
Connect does not. This means that Conduit is doing more work than Kafka Connect,
which is reflected in the throughput numbers.

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
lint            Lint all benchmarks.
list            List all benchmarks.
run-all         Run all benchmarks. Optionally add "run-<benchmark-name>" to run a specific benchmark.
run-%           Run a specific benchmark.
rmi-conduit     Remove the Conduit docker image (use when built-in connectors get added or upgraded).
```
