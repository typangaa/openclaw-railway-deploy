#!/bin/bash
set -e

# Ensure .openclaw directory exists and has correct permissions
echo "Checking OpenClaw directory permissions..."
mkdir -p /home/node/.openclaw
chown -R node:node /home/node/.openclaw
chmod -R u+w /home/node/.openclaw

# Create config if it doesn't exist
CONFIG_FILE=/home/node/.openclaw/config.yaml
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Setting up OpenClaw configuration..."
else
    echo "Config exists, recreating with latest settings..."
fi

# Always recreate config to ensure it has all required fields
cat > "$CONFIG_FILE" << EOF
ai:
  provider: openrouter
  apiKey: \${OPENROUTER_API_KEY}
  model: arcee-ai/trinity-large-preview:free

gateway:
  mode: server
  auth:
    type: token
    token: \${OPENCLAW_GATEWAY_TOKEN}
  trustedProxies:
    - 100.64.0.0/10
    - 127.0.0.1

telegram:
  enabled: true
  token: \${TELEGRAM_BOT_TOKEN}
EOF

chown node:node "$CONFIG_FILE"
echo "✓ Config created at $CONFIG_FILE"

# Show config for debugging
echo "Config contents:"
cat /home/node/.openclaw/config.yaml

# Start OpenClaw gateway as node user with explicit HOME
echo "Starting OpenClaw gateway..."
exec su node -c "HOME=/home/node openclaw gateway --bind lan --port ${PORT:-8080}"
