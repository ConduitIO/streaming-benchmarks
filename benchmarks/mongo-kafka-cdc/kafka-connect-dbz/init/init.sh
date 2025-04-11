#!/bin/sh
set -e

# Create a temporary directory for downloading and extraction
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "Downloading Debezium MongoDB connector..."
curl -sSL "https://repo1.maven.org/maven2/io/debezium/debezium-connector-mongodb/3.1.0.Final/debezium-connector-mongodb-3.1.0.Final-plugin.tar.gz" -o connector.tar.gz

echo "Extracting archive..."
tar -xzf connector.tar.gz

echo "Copying connector files to /usr/share/java..."
cp -r debezium-connector-mongodb /usr/share/java/

echo "Cleaning up temporary files..."
cd /
rm -rf "$TMP_DIR"

echo "Debezium MongoDB connector installation complete!"