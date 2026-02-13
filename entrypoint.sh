#!/bin/bash
set -e

# Ensure .openclaw directory exists and has correct permissions
echo "Checking OpenClaw directory permissions..."
mkdir -p /home/node/.openclaw
chown -R node:node /home/node/.openclaw
chmod -R u+w /home/node/.openclaw

# Create OpenClaw config with Telegram enabled
CONFIG_FILE=/home/node/.openclaw/openclaw.json
echo "Creating OpenClaw configuration with Telegram..."

# Create config with Telegram explicitly enabled
cat > "$CONFIG_FILE" << EOF
{
  "gateway": {
    "mode": "local",
    "trustedProxies": [
      "100.64.0.0/10",
      "127.0.0.1"
    ]
  },
  "channels": {
    "telegram": {
      "enabled": true
    }
  }
}
EOF

chown node:node "$CONFIG_FILE"
echo "✓ Config created with Telegram enabled"

# Show config for debugging
echo "Config contents:"
cat /home/node/.openclaw/config.yaml

# Run OpenClaw doctor to fix configuration issues
echo "Running OpenClaw doctor to fix configuration..."
runuser -u node -- openclaw doctor --fix || echo "Doctor command completed"

# Start OpenClaw gateway as node user
echo "Starting OpenClaw gateway..."
echo "Working directory: $(pwd)"
echo "Config file exists: $(test -f /home/node/.openclaw/config.yaml && echo 'yes' || echo 'no')"

# Change to node user's home and start OpenClaw
cd /home/node
exec runuser -u node -- openclaw gateway --bind lan --port ${PORT:-8080}
