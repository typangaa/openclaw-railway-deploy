FROM node:22-bookworm-slim

# Install git (required for npm dependencies) and ca-certificates
RUN apt-get update && \
    apt-get install -y git ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install OpenClaw globally from npm
RUN npm install -g openclaw@latest

# Use existing node user (already has UID 1000)
RUN mkdir -p /home/node/.openclaw && \
    chown -R node:node /home/node/.openclaw

# Switch to non-root user
USER node
WORKDIR /home/node

# Set environment variables
ENV HOME=/home/node
ENV NODE_ENV=production

# Expose Railway's dynamic port
EXPOSE $PORT

# Start OpenClaw gateway
# CRITICAL: Use shell form (not exec form) for variable expansion
# --bind lan: Binds to 0.0.0.0 (required for Railway)
# --port: Uses Railway's $PORT variable (fallback to 18789)
# --allow-unconfigured: Starts without existing config file
CMD openclaw gateway \
    --bind lan \
    --port ${PORT:-18789} \
    --allow-unconfigured
