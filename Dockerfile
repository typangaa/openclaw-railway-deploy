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

# Copy entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set working directory (but stay as root for entrypoint to fix permissions)
WORKDIR /home/node

# Set environment variables
ENV HOME=/home/node
ENV NODE_ENV=production

# Expose Railway's dynamic port
EXPOSE $PORT

# Start OpenClaw gateway via entrypoint script
# Script runs as root to fix volume permissions, then switches to node user
# Creates config.yaml if it doesn't exist, then starts the gateway
CMD ["/usr/local/bin/entrypoint.sh"]
