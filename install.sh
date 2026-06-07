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

PLIST="$HOME/Library/LaunchAgents/com.jai.deviceagent.plist"

cat > "$PLIST" <<EOF

<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">

<plist version="1.0">
<dict>

```
<key>Label</key>
<string>com.jai.deviceagent</string>

<key>ProgramArguments</key>
<array>
    <string>/usr/bin/env</string>
    <string>npm</string>
    <string>start</string>
</array>

<key>WorkingDirectory</key>
<string>$INSTALL_DIR</string>

<key>RunAtLoad</key>
<true/>

<key>KeepAlive</key>
<true/>

<key>StandardOutPath</key>
<string>$INSTALL_DIR/agent.log</string>

<key>StandardErrorPath</key>
<string>$INSTALL_DIR/agent-error.log</string>
```

</dict>
</plist>
EOF

launchctl unload "$PLIST" >/dev/null 2>&1 || true
launchctl load "$PLIST"

echo ""
echo "JP Device Agent installed."
echo ""
echo "Service started."
echo ""
echo "Logs:"
echo "tail -f $INSTALL_DIR/agent.log"
echo ""
