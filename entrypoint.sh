#!/bin/bash
set -e

# Ensure .openclaw directory exists and has correct permissions
echo "Checking OpenClaw directory permissions..."
mkdir -p /home/node/.openclaw
chown -R node:node /home/node/.openclaw
chmod -R u+w /home/node/.openclaw

# Switch to node user and create config if needed
su - node -c '
if [ ! -f ~/.openclaw/config.yaml ]; then
    echo "Setting up OpenClaw configuration..."
    cat > ~/.openclaw/config.yaml << "EOF"
ai:
  provider: openrouter
  model: arcee-ai/trinity-large-preview:free

gateway:
  auth:
    type: token
  trustedProxies:
    - 100.64.0.0/10
    - 127.0.0.1

telegram:
  enabled: true
EOF
    echo "✓ Config created at ~/.openclaw/config.yaml"
else
    echo "✓ Using existing config at ~/.openclaw/config.yaml"
fi
'

# Start OpenClaw gateway as node user
echo "Starting OpenClaw gateway..."
exec su - node -c "openclaw gateway --bind lan --port ${PORT:-8080}"
