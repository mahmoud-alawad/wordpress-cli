#!/bin/bash

set -e

# This script installs the custom Wordpress Bash CLI tool

REPO_URL="https://github.com/mahmoud-alawad/wordpress-cli"
INSTALL_DIR="$HOME/.ma/cli"
CLI_NAME="ma"
VERSION="1.0.0"
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}

trap cleanup EXIT

echo "Downloading the latest release of $CLI_NAME..."
curl -sL "$REPO_URL/archive/refs/tags/$VERSION.zip" -o "$TEMP_DIR/$VERSION.zip"

if [[ $? -ne 0 ]]; then
    echo "Error downloading the release tarball."
    exit 1
fi

echo "Extracting files..."
unzip "$TEMP_DIR/$VERSION.zip" -d "$TEMP_DIR"

if [[ $? -ne 0 ]]; then
    echo "Error extracting the zip file."
    exit 1
fi

# Assume the extracted folder is named "wordpress-cli-1.0.0"
EXTRACTED_DIR="$TEMP_DIR/wordpress-cli-$VERSION"

if [[ ! -d "$EXTRACTED_DIR" ]]; then
    echo "Extracted directory not found."
    exit 1
fi

# Move the CLI tool to the installation directory
echo "Installing $CLI_NAME to $INSTALL_DIR..."
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"  # Create the installation directory, including parents if needed
mv "$EXTRACTED_DIR"/* "$INSTALL_DIR/"

if [[ $? -ne 0 ]]; then
    echo "Error moving the CLI tool to $INSTALL_DIR."
    exit 1
fi

# Make the CLI tool executable
echo "Setting executable permissions..."
ls -l "$HOME/.ma/cli/bin/ma"
sleep 1s
chmod +x "$INSTALL_DIR/bin/$CLI_NAME"
export PATH="$HOME/.ma/cli/bin:$PATH"

if [[ $? -ne 0 ]]; then
    echo "Error setting executable permissions."
    exit 1
fi
