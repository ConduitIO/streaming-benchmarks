# Postgres-to-Kafka results

## Date of testing

May 8th, 2025

## Setup

All of our tests were performed multiple times on a t2.xlarge AWS EC2 instance (
4 vCPUs, 16 GB RAM) with a 120 GB gp3 EBS volume. The infrastructure (Kafka and
Postgres) was provided via Docker containers. 

We ran a single Kafka broker and a
Postgres database instance. The configurations for the benchmarks can be found
[here](../../../benchmarks/postgres-kafka-snapshot/benchi.yml) and
[here](../../../benchmarks/postgres-kafka-cdc/benchi.yml).

### Conduit

We tested Conduit v0.13.2 with the Postgres connector. Conduit was run with the
[re-architectured pipeline engine](https://meroxa.com/blog/optimizing-conduit-5x-the-throughput/) with this [configuration](../../../shared/conduit/conduit.yaml).

The pipelines used can be found
[here](../../../benchmarks/postgres-kafka-snapshot/conduit/pipeline.yml) and
[here](../../../benchmarks/postgres-kafka-cdc/conduit/pipeline.yml). 

Notable configurations:

- Snapshot mode: `initial_only` for snapshots.
- CDC mode: `logrepl` with logical replication slots.

### Kafka Connect

We tested Kafka Connect v7.8.1 with the Debezium Postgres connector. The Kafka
Connect worker used the default settings. Full connector configurations can be
found [here](../../../benchmarks/postgres-kafka-snapshot/kafka-connect/data/connector.json) and
[here](../../../benchmarks/postgres-kafka-cdc/kafka-connect/data/connector.json).

Batch size and queue size were adjusted for optimal performance.

## Running the benchmarks

The benchmarks can be run by cloning or downloading this repository and then
running: `make run-postgres-kafka-cdc` or `make run-postgres-kafka-snapshot`.

## Results

The results of the benchmarks are summarized below. Detailed results can be
found in the `.csv` files under the `results/postgres-kafka/20250508` directory.

### Charts

![CPU Usage Graph](cpu-usage.svg)
<br/>
<br/>
![Memory Usage Graph](memory-usage.svg)
<br/>
<br/>
![Message Throughput Graph](message-throughput.svg)
<br/>

### Summary

| Mode        | Tool           | Message Rate (msg/s) | CPU %    | Memory (MB) |
|:------------|:--------------|---------------------:|---------:|------------:|
| **CDC**     | Conduit        | 48.060,46            | 110,15   | 110,15      |
|             | Kafka Connect* | 44.889,11            | 147,06   | 6.863,21    |
| **Snapshot**| Conduit        | 70.753,43            | 231,03   | 2.233,56    |
|             | Kafka Connect* | 68.783,48            | 184,16   | 2.729,36    |

\* Kafka Connect runs with 10 GB heap (`KAFKA_HEAP_OPTS: "-Xms10G -Xmx10G"`)

In **CDC mode**, Conduit’s message throughput was about **7% higher** than Kafka Connect (48.060 msg/s vs. 44.889 msg/s). Conduit also used **dramatically less memory** (110 MB vs. 6.863 MB), and its CPU usage was **lower** (110% vs. 147%).

In **snapshot mode**, the message rates were closer, with Conduit about **3% higher** (70.753 msg/s vs. 68.783 msg/s). Conduit used **less memory** (2.234 MB vs. 2.729 MB), but its CPU usage was **higher** (231% vs. 184%).

Overall, Conduit demonstrates both higher throughput and significantly improved memory efficiency, especially in CDC mode, where pipelines spend most of their operational lifetime. While CPU usage for Conduit is higher during snapshots, its lower resource consumption and higher throughput in CDC mode make it a strong choice for Postgres-to-Kafka pipelines.