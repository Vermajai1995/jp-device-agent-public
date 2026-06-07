#!/bin/bash

set -e

INSTALL_DIR="$HOME/jp-device-agent"

echo ""
echo "Installing JP Device Agent..."
echo ""

mkdir -p "$INSTALL_DIR"

DOWNLOAD_URL="https://github.com/Vermajai1995/jp-device-agent-public/releases/latest/download/jp-device-agent.zip"

echo "Downloading latest release..."
curl -L "$DOWNLOAD_URL" -o "$INSTALL_DIR/jp-device-agent.zip"

echo "Extracting files..."
unzip -o "$INSTALL_DIR/jp-device-agent.zip" -d "$INSTALL_DIR"

rm -f "$INSTALL_DIR/jp-device-agent.zip"

cd "$INSTALL_DIR"

echo "Installing dependencies..."
npm install

echo "Starting agent in background..."
nohup npm start > "$INSTALL_DIR/agent.log" 2>&1 &

sleep 5

echo ""
echo "Installed at:"
echo "$INSTALL_DIR"
echo ""
echo "Agent started in background."
echo ""
echo "View logs:"
echo "tail -f $INSTALL_DIR/agent.log"
echo ""
echo "Installation complete."
