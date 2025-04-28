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

> [Click here](./results/mongo-kafka) to see the full results.

This benchmark tests the performance of the data pipeline when reading from a
MongoDB source and writing to a Kafka destination. We tested the speed at which
the tools read the data in snapshot mode and CDC mode. We also tested
the [official MongoDB connector](https://www.mongodb.com/docs/kafka-connector/current/
as well
as [the Debezium connector](https://debezium.io/documentation/reference/stable/connectors/mongodb.html).

[Compared to the official connector](./results/mongo-kafka/20250422), Conduit’s
CPU usage is higher by around 13% in snapshots and 28% in CDC. When it comes to
memory usage, we see a bigger gap, this time with Conduit using less resources (
390 MB or 68%) than Kafka Connect ( 1200 MB).

While the snapshot message rates are pretty close (Conduit’s message rate is
about 9% higher), we see a greater gap in CDC, where Conduit’s message rate is
about 52% higher.

On the other hand, when
we [compared Conduit to Debezium's Mongo connector](./results/mongo-kafka/20250428)),
we found that the message throughput in CDC with Conduit and its Mongo connector
is 15% higher than with Kafka Connect and the Debezium connector. Kafka Connect
and Debezium used about 25% more CPU and nearly 21x more memory (7.5 GB vs. 350
MB).

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