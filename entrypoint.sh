#!/bin/bash
set -e

# Copy default config if it doesn't exist in the volume
if [ ! -f ~/.openclaw/config.yaml ]; then
    echo "Setting up OpenClaw configuration..."
    mkdir -p ~/.openclaw
    cat > ~/.openclaw/config.yaml << 'EOF'
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
fi

# Start OpenClaw gateway
exec openclaw gateway \
    --bind lan \
    --port ${PORT:-8080}
