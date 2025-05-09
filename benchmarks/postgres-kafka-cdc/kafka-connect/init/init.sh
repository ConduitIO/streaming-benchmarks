#!/bin/sh
set -e

# Create a temporary directory for downloading and extraction
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "Downloading Debezium Postgres Connector..."
curl -sSL "https://repo1.maven.org/maven2/io/debezium/debezium-connector-postgres/3.1.1.Final/debezium-connector-postgres-3.1.1.Final-plugin.tar.gz" -o connector.tar.gz

echo "Extracting archive..."
tar -xzf connector.tar.gz

echo "Copying connector files to /usr/share/java..."
cp -r debezium-connector-postgres /usr/share/java/

echo "Cleaning up temporary files..."
cd /
rm -rf "$TMP_DIR"

echo "Debezium Postgres Connector installation complete!"
