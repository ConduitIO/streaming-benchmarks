#!/bin/sh

# Script to install the latest version of shenwei356/csvtk

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

# Get the latest version from GitHub API
echo "Fetching the latest version of csvtk..."
if command -v curl >/dev/null 2>&1; then
    LATEST_VERSION=$(curl -s https://api.github.com/repos/shenwei356/csvtk/releases/latest | grep -o '"tag_name": "v[^"]*' | grep -o '[0-9.]*')
elif command -v wget >/dev/null 2>&1; then
    LATEST_VERSION=$(wget -qO- https://api.github.com/repos/shenwei356/csvtk/releases/latest | grep -o '"tag_name": "v[^"]*' | grep -o '[0-9.]*')
else
    echo "Error: Neither curl nor wget found. Please install one of them and try again."
    exit 1
fi

if [ -z "$LATEST_VERSION" ]; then
    echo "Error: Could not determine the latest version. Please check your internet connection and try again."
    exit 1
fi

echo "Latest version: $LATEST_VERSION"
echo "Installing csvtk $LATEST_VERSION for $OS/$ARCH..."

# Create temporary directory
mkdir -p ./tmp

# Download csvtk
echo "Downloading csvtk..."
if command -v curl >/dev/null 2>&1; then
    curl -s -L -o ./tmp/csvtk.tar.gz "https://github.com/shenwei356/csvtk/releases/download/v${LATEST_VERSION}/csvtk_${OS}_${ARCH}.tar.gz"
else
    wget -O ./tmp/csvtk.tar.gz "https://github.com/shenwei356/csvtk/releases/download/v${LATEST_VERSION}/csvtk_${OS}_${ARCH}.tar.gz"
fi

# Extract archive
echo "Extracting archive..."
tar -xzf ./tmp/csvtk.tar.gz -C ./tmp

# Make binary executable
chmod +x ./tmp/csvtk

# Install to /usr/local/bin/ (try without sudo first, then with sudo if needed)
echo "Installing to /usr/local/bin/..."
if mv ./tmp/csvtk /usr/local/bin/ 2>/dev/null; then
    echo "Installed csvtk to /usr/local/bin/"
else
    echo "Attempting to install with sudo..."
    sudo mv ./tmp/csvtk /usr/local/bin/
    echo "Installed csvtk to /usr/local/bin/ with sudo"
fi

# Clean up
rm -rf ./tmp

echo "csvtk $LATEST_VERSION installed successfully"
csvtk version
