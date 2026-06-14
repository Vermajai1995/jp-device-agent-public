#!/bin/bash

set -e

INSTALL_DIR="$HOME/jp-device-agent"
PID_FILE="$INSTALL_DIR/agent.pid"
LOG_FILE="$INSTALL_DIR/agent.log"

echo ""
echo "Installing JP Device Agent..."
echo ""

mkdir -p "$INSTALL_DIR"

DEVICE_ID="${DEVICE_ID:-other}"
DEVICE_NAME="${DEVICE_NAME:-other}"
CORE_BACKEND_URL="${CORE_BACKEND_URL:-https://core-backend-navy.vercel.app}"

cat > "$INSTALL_DIR/.env.local" << EOF
DEVICE_ID=${DEVICE_ID}
DEVICE_NAME=${DEVICE_NAME}
CORE_BACKEND_URL=${CORE_BACKEND_URL}
EOF

# ── Stop existing agent process if running ──
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        echo "Stopping existing JP Device Agent (PID $OLD_PID)..."
        kill "$OLD_PID" 2>/dev/null || true
        # Wait up to 5 seconds for graceful shutdown
        for i in $(seq 1 5); do
            if ! kill -0 "$OLD_PID" 2>/dev/null; then
                break
            fi
            sleep 1
        done
        # Force kill if still running
        if kill -0 "$OLD_PID" 2>/dev/null; then
            echo "Agent did not stop gracefully, force killing..."
            kill -9 "$OLD_PID" 2>/dev/null || true
        fi
        echo "Agent stopped."
    fi
    rm -f "$PID_FILE"
fi

DOWNLOAD_URL="https://github.com/Vermajai1995/jp-device-agent-public/releases/latest/download/jp-device-agent.zip"

echo "Downloading latest release..."
curl -L "$DOWNLOAD_URL" -o "$INSTALL_DIR/jp-device-agent.zip"

echo "Extracting files..."
unzip -o "$INSTALL_DIR/jp-device-agent.zip" -d "$INSTALL_DIR"

rm -f "$INSTALL_DIR/jp-device-agent.zip"

cd "$INSTALL_DIR"

echo "Installing dependencies..."
npm ci --omit=dev

echo "Starting agent in background..."
nohup npm start > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

sleep 3

echo ""
echo "Installed at:"
echo "$INSTALL_DIR"
echo ""
echo "Agent started (PID $(cat "$PID_FILE"))."
echo ""
echo "View logs:"
echo "tail -f $LOG_FILE"
echo ""
echo "Installation complete."