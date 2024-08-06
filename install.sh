#!/bin/bash

set -e

# This script installs the custom Wordpress Bash CLI tool

REPO_URL="https://github.com/mahmoud-alawad/wordpress-cli"
INSTALL_DIR="$HOME/.ma/cli"
CLI_NAME="ma"
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

echo "Downloading the latest release of $CLI_NAME..."
curl -sL "$REPO_URL/releases/latest/download/$CLI_NAME.tar.gz" -o "$TEMP_DIR/$CLI_NAME.tar.gz"

if [[ $? -ne 0 ]]; then
    echo "Error downloading the release tarball."
    exit 1
fi

echo "Extracting files..."
tar -xzf "$TEMP_DIR/$CLI_NAME.tar.gz" -C "$TEMP_DIR"

if [[ $? -ne 0 ]]; then
    echo "Error extracting the tarball."
    exit 1
fi

# Move the CLI tool to the installation directory
echo "Installing $CLI_NAME to $INSTALL_DIR..."

mv "$TEMP_DIR/$CLI_NAME" "$INSTALL_DIR/"

if [[ $? -ne 0 ]]; then
    echo "Error moving the CLI tool to $INSTALL_DIR."
    exit 1
fi

# Make the CLI tool executable
echo "Setting executable permissions..."
chmod +x "$INSTALL_DIR/$CLI_NAME"

if [[ $? -ne 0 ]]; then
    echo "Error setting executable permissions."
    exit 1
fi

echo "$CLI_NAME installed successfully!"
