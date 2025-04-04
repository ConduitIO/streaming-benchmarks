#!/bin/bash

echoerr() { echo "$@" 1>&2; }

TOPIC=$1
COUNT=$2

if [ -z "$TOPIC" ]; then
  echoerr "Error: Topic is required."
  exit 1
fi

if [ -z "$COUNT" ]; then
  echoerr "Error: Count is required."
  exit 1
fi

# Produce records similar to this.
# NOTE: is one of the records that the Kafka destination would receive from Postgres.
# {
#   "full_time": true,
#   "id": 399951,
#   "name": "John Doe",
#   "updated_at": "2025-03-04T11:58:13.910712Z"
# }

START_TIME=$(date +%s)

UPDATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
awk -v count="$COUNT" -v ts="$UPDATED_AT" '
BEGIN {
  for (i = 1; i <= count; i++) {
    printf "{\"full_time\":true,\"id\":%d,\"name\":\"John Doe\",\"updated_at\":\"%s\"}\n", i, ts
  }
}
' | /opt/kafka/bin/kafka-console-producer.sh --broker-list "benchi-kafka:9092" --topic "$TOPIC"


END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "Produced $COUNT messages in $DURATION seconds."
