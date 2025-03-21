#!/bin/sh

# Copyright © 2025 Meroxa, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Script to install shenwei356/csvtk

CSVTK_VERSION="0.29.0"
UNAME_S=$(uname -s)
UNAME_M=$(uname -m)

# Determine OS type for the download URL
if [ "$UNAME_S" = "Linux" ]; then
    OS="linux"
elif [ "$UNAME_S" = "Darwin" ]; then
    OS="macOS"
else
    echo "Error: Unsupported operating system: $UNAME_S"
    exit 1
fi

# Determine architecture for the download URL
if [ "$UNAME_M" = "x86_64" ]; then
    ARCH="amd64"
elif [ "$UNAME_M" = "aarch64" ] || [ "$UNAME_M" = "arm64" ]; then
    ARCH="arm64"
else
    echo "Error: Unsupported architecture: $UNAME_M"
    exit 1
fi

echo "Installing csvtk $CSVTK_VERSION for $OS/$ARCH..."

# Create temporary directory
mkdir -p ./tmp

# Download csvtk
curl -s -L -o ./tmp/csvtk.tar.gz "https://github.com/shenwei356/csvtk/releases/download/v${CSVTK_VERSION}/csvtk_${OS}_${ARCH}.tar.gz"

# Extract archive
tar -xzf ./tmp/csvtk.tar.gz -C ./tmp

# Make binary executable
chmod +x ./tmp/csvtk

# Install to /usr/local/bin/ (try without sudo first, then with sudo if needed)
if mv ./tmp/csvtk /usr/local/bin/ 2>/dev/null; then
    echo "Installed csvtk to /usr/local/bin/"
else
    echo "Attempting to install with sudo..."
    sudo mv ./tmp/csvtk /usr/local/bin/
    echo "Installed csvtk to /usr/local/bin/ with sudo"
fi

# Clean up
rm -rf ./tmp

echo "csvtk $CSVTK_VERSION installed successfully"
csvtk version
