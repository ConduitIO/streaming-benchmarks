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
the [official MongoDB connector](https://www.mongodb.com/docs/kafka-connector/current/)
as well
as [the Debezium connector](https://debezium.io/documentation/reference/stable/connectors/mongodb.html).

[Compared to the official connector](./results/mongo-kafka/20250422), Conduit’s
CPU usage is higher by around 13% in snapshots and 28% in CDC. When it comes to
memory usage, we see a bigger gap, this time with Conduit using less resources (
390 MB or 68%) than Kafka Connect ( 1200 MB).

While the snapshot message rates are pretty close (Conduit’s message rate is
about 9% higher), we see a greater gap in CDC, where Conduit’s message rate is
about 52% higher.

Our [comparison between Conduit and Debezium's Mongo connector](./results/mongo-kafka/20250428)
showed performance differences. Conduit's Mongo connector delivered 17% higher
CDC message throughput (37k msg/s vs. 32k msg/s). Kafka Connect with Debezium
used 25% more CPU and required 7.5 GB of memory compared to Conduit's 350 MB.

Note that tests for the official connector and the Debezium connector were
conducted on different machines, resulting in varying throughput rates for
Conduit. Due to this testing environment difference, throughput comparisons
between the official connector and Debezium should be interpreted with caution.

### Benchmark: Postgres to Kafka

> [Click here](./results/postgres-kafka/20250508) to see the full results.

This benchmark tests the performance of the data pipeline when reading from a
Postgres source and writing to a Kafka destination. We evaluated how quickly
the tools process data in both snapshot mode and CDC (Change Data Capture) mode.

The comparison included [Conduit](https://github.com/conduitio/conduit) and
[Kafka Connect](https://docs.confluent.io/platform/current/connect/index.html)
with the [Debezium Postgres connector](https://debezium.io/documentation/reference/stable/connectors/postgresql.html).

Compared to Kafka Connect, Conduit’s message throughput was about 7% higher in
CDC mode (48.060 msg/s vs. 44.889 msg/s) and about 3% higher in snapshot mode
(70.753 msg/s vs. 68.783 msg/s).

In CDC mode, Conduit used dramatically less memory (110 MB vs. 6.863 MB, or about
98% less) and required about 25% less CPU (110% vs. 147%).

In snapshot mode, Conduit used about 18% less memory (2.234 MB vs. 2.729 MB), but
required about 25% more CPU (231% vs. 184%).

These results highlight Conduit’s strong performance, particularly in CDC scenarios,
where it achieved higher throughput and much lower memory usage and CPU consumption.

In snapshot mode, although Conduit’s throughput was slightly higher and memory usage
was lower, CPU usage increased. Overall, Conduit offers a compelling choice for
Postgres-to-Kafka pipelines where efficiency and throughput are critical.

### Benchmark: Kafka to Snowflake

> [Click here](./results/kafka-snowflake/20250417) to see the full results.

This benchmark tests the performance of the data pipeline when reading from a
Kafka source and writing to a [Snowflake](https://www.snowflake.com/) destination.

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
