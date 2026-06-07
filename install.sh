#!/bin/bash

set -e

INSTALL_DIR="$HOME/jp-device-agent"

echo ""
echo "Installing JP Device Agent..."
echo ""

mkdir -p "$INSTALL_DIR"

DOWNLOAD_URL="https://github.com/Vermajai1995/jp-device-agent-public/releases/latest/download/jp-device-agent.zip"

curl -L "$DOWNLOAD_URL" -o "$INSTALL_DIR/jp-device-agent.zip"

unzip -o "$INSTALL_DIR/jp-device-agent.zip" -d "$INSTALL_DIR"

echo ""
echo "Installed at:"
echo "$INSTALL_DIR"
echo ""
echo "Installation complete."
