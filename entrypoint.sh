#!/bin/bash
set -e

# Ensure .openclaw directory exists and has correct permissions
echo "Checking OpenClaw directory permissions..."
mkdir -p /home/node/.openclaw
chown -R node:node /home/node/.openclaw
chmod -R u+w /home/node/.openclaw

# Create OpenClaw config with valid keys only
CONFIG_FILE=/home/node/.openclaw/openclaw.json
echo "Creating OpenClaw configuration with valid schema..."

# Create config using only officially documented keys
cat > "$CONFIG_FILE" << EOF
{
  "gateway": {
    "mode": "local",
    "trustedProxies": [
      "100.64.0.0/10",
      "127.0.0.1"
    ],
    "auth": {
      "mode": "token",
      "token": "${OPENCLAW_GATEWAY_TOKEN}"
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "openrouter/arcee-ai/trinity-large-preview:free"
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "${TELEGRAM_BOT_TOKEN}",
      "dmPolicy": "pairing"
    }
  }
}
EOF

chown node:node "$CONFIG_FILE"
echo "✓ Valid config created with Telegram channel enabled"

# Show config for debugging
echo "Config contents:"
cat "$CONFIG_FILE"

# Run OpenClaw doctor to fix configuration issues
echo "Running OpenClaw doctor to fix configuration..."
runuser -u node -- openclaw doctor --fix || echo "Doctor command completed"

# Start OpenClaw gateway as node user
echo "Starting OpenClaw gateway..."
echo "Working directory: $(pwd)"
echo "Config file exists: $(test -f $CONFIG_FILE && echo 'yes' || echo 'no')"

# Change to node user's home and start OpenClaw
cd /home/node
exec runuser -u node -- openclaw gateway --bind lan --port ${PORT:-8080}
