#!/bin/bash
set -e

# Ensure .openclaw directory exists and has correct permissions
echo "Checking OpenClaw directory permissions..."
mkdir -p /home/node/.openclaw
chown -R node:node /home/node/.openclaw
chmod -R u+w /home/node/.openclaw

# Create config if it doesn't exist
if [ ! -f /home/node/.openclaw/config.yaml ]; then
    echo "Setting up OpenClaw configuration..."
    cat > /home/node/.openclaw/config.yaml << 'EOF'
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
    chown node:node /home/node/.openclaw/config.yaml
    echo "✓ Config created at /home/node/.openclaw/config.yaml"
else
    echo "✓ Using existing config at /home/node/.openclaw/config.yaml"
fi

# Show config for debugging
echo "Config contents:"
cat /home/node/.openclaw/config.yaml

# Start OpenClaw gateway as node user with explicit HOME
echo "Starting OpenClaw gateway..."
exec su node -c "HOME=/home/node openclaw gateway --bind lan --port ${PORT:-8080}"
