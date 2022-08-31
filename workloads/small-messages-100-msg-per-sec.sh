#!/bin/bash
echo "Creating pipeline..."
PIPELINE_ID=$(
curl -Ss -X POST 'http://localhost:8080/v1/pipelines' -d '
{
    "config":
    {
        "name": "perf-test",
        "description": "Test performance"
    }
}' | jq -r '.id'
)

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
${__dir}/gen-file.sh 1K

echo "Creating a generator source..."
SOURCE_CONN_REQ_1=$(
jq -n --arg pipeline_id "$PIPELINE_ID" '{
    "type": "TYPE_SOURCE",
    "plugin": "builtin:generator",
    "pipeline_id": $pipeline_id,
    "config":
    {
        "name": "generator-source-1",
        "settings":
        {
            "format.type": "file",
            "format.options": "/tmp/conduit-test-file",
            "readTime": "10ms",
            "recordCount": "-1"
        }
    }
}'
)
CONNECTOR_ID=$(curl -Ss -X POST 'http://localhost:8080/v1/connectors' -d "$SOURCE_CONN_REQ_1" | jq -r '.id')

echo "Creating a NoOp destination..."
DEST_CONN_REQ=$(
jq -n  --arg pipeline_id "$PIPELINE_ID" '{
     "type": "TYPE_DESTINATION",
     "plugin": "/plugins/noop-dest",
     "pipeline_id": $pipeline_id,
     "config":
     {
         "name": "my-noop-destination",
         "settings": {}
     }
 }'
)

curl -Ss -X POST 'http://localhost:8080/v1/connectors' -d "$DEST_CONN_REQ" > /dev/null

echo "Starting the pipeline..."
curl -Ss -X POST "http://localhost:8080/v1/pipelines/$PIPELINE_ID/start" > /dev/null
echo "Pipeline started!"
