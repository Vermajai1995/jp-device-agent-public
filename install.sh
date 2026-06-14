#!/bin/bash

set -e

INSTALL_DIR="$HOME/jp-device-agent"
PID_FILE="$INSTALL_DIR/agent.pid"
LOG_FILE="$INSTALL_DIR/agent.log"

# ── Step 1 ──
echo "[1/8] Preparing installation..."
echo ""
mkdir -p "$INSTALL_DIR"

DEVICE_ID="${DEVICE_ID:-other}"
DEVICE_NAME="${DEVICE_NAME:-other}"
CORE_BACKEND_URL="${CORE_BACKEND_URL:-https://core-backend-navy.vercel.app}"

echo "  Install directory: $INSTALL_DIR"

# ── Step 2 ──
echo ""
echo "[2/8] Stopping existing agent..."
AGENT_STOPPED=false
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
        echo "  Stopping PID $OLD_PID..."
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
            echo "  Process did not stop gracefully, force killing..."
            kill -9 "$OLD_PID" 2>/dev/null || true
        fi
        echo "✓ Existing agent stopped"
        AGENT_STOPPED=true
    fi
    rm -f "$PID_FILE"
fi
if [ "$AGENT_STOPPED" = false ]; then
    echo "  No existing agent found."
fi

# ── Step 3 ──
echo ""
echo "[3/8] Downloading latest release..."
DOWNLOAD_URL="https://github.com/Vermajai1995/jp-device-agent-public/releases/latest/download/jp-device-agent.zip"
curl -sS -L "$DOWNLOAD_URL" -o "$INSTALL_DIR/jp-device-agent.zip"
echo "✓ Release downloaded"

# ── Step 4 ──
echo ""
echo "[4/8] Extracting files..."
unzip -o -q "$INSTALL_DIR/jp-device-agent.zip" -d "$INSTALL_DIR"
rm -f "$INSTALL_DIR/jp-device-agent.zip"
echo "✓ Files extracted"

cd "$INSTALL_DIR"

# ── Step 5 ──
echo ""
echo "[5/8] Writing configuration..."
cat > "$INSTALL_DIR/.env.local" << EOF
DEVICE_ID=${DEVICE_ID}
DEVICE_NAME=${DEVICE_NAME}
CORE_BACKEND_URL=${CORE_BACKEND_URL}
EOF
echo "✓ Configuration written"

# ── Step 6 ──
echo ""
echo "[6/8] Installing dependencies..."
npm ci --omit=dev 2>&1 | tail -1
echo "✓ Dependencies installed"

# ── Step 7 ──
echo ""
echo "[7/8] Starting agent..."
nohup npm start > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"
sleep 3
NEW_PID=$(cat "$PID_FILE")
echo "✓ Agent started (PID $NEW_PID)"

# ── Step 8 ──
echo ""
echo "[8/8] Installation complete."
echo ""
echo "## Installation Summary"
echo ""
echo "  Install Directory: $INSTALL_DIR"
echo "  Device ID:         $DEVICE_ID"
echo "  Device Name:       $DEVICE_NAME"
echo "  Backend URL:       $CORE_BACKEND_URL"
echo "  Agent PID:         $NEW_PID"
echo ""
echo "  View logs:"
echo "  tail -f $LOG_FILE"
echo ""