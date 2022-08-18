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

FILE_SIZE=1KB
echo "Generating a file of size ${FILE_SIZE}"
rm -f /tmp/conduit-test-file
fallocate -l $FILE_SIZE /tmp/conduit-test-file

for i in {1..5}
do
   echo "Creating a generator source ($i)..."
   SOURCE_CONN_REQ=$(
   jq -n --arg pipeline_id "$PIPELINE_ID" --arg source_id "$i" '{
       "type": "TYPE_SOURCE",
       "plugin": "builtin:generator",
       "pipeline_id": $pipeline_id,
       "config":
       {
           "name": "generator-source-$source_id",
           "settings":
           {
               "format.type": "file",
               "format.options": "/tmp/conduit-test-file",
               "readTime": "0.1ms",
               "recordCount": "-1"
           }
       }
   }'
   )
   CONNECTOR_ID=$(curl -Ss -X POST 'http://localhost:8080/v1/connectors' -d "$SOURCE_CONN_REQ" | jq -r '.id')
done

echo "Creating a File destination..."
DEST_CONN_REQ=$(
jq -n  --arg pipeline_id "$PIPELINE_ID" '{
     "type": "TYPE_DESTINATION",
     "plugin": "builtin:file",
     "pipeline_id": $pipeline_id,
     "config":
     {
         "name": "my-file-destination",
         "settings": {
             "path": "/tmp/conduit-perf-test-destination"
         }
     }
 }'
)

curl -Ss -X POST 'http://localhost:8080/v1/connectors' -d "$DEST_CONN_REQ" > /dev/null

echo "Starting the pipeline..."
curl -Ss -X POST "http://localhost:8080/v1/pipelines/$PIPELINE_ID/start" > /dev/null
echo "Pipeline started!"
