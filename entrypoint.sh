#!/bin/bash
set -e

# Ensure .openclaw directory exists and has correct permissions
echo "Checking OpenClaw directory permissions..."
mkdir -p /home/node/.openclaw
chown -R node:node /home/node/.openclaw
chmod -R u+w /home/node/.openclaw

# Create config with environment variable substitution
CONFIG_FILE=/home/node/.openclaw/config.yaml
echo "Creating OpenClaw configuration with environment variables..."

# Substitute environment variables and write config
cat > "$CONFIG_FILE" << EOF
ai:
  provider: openrouter
  apiKey: ${OPENROUTER_API_KEY}
  model: arcee-ai/trinity-large-preview:free

gateway:
  mode: server
  auth:
    type: token
    token: ${OPENCLAW_GATEWAY_TOKEN}
  trustedProxies:
    - 100.64.0.0/10
    - 127.0.0.1

telegram:
  enabled: true
  token: ${TELEGRAM_BOT_TOKEN}
EOF

chown node:node "$CONFIG_FILE"
echo "✓ Config created at $CONFIG_FILE with substituted values"

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
