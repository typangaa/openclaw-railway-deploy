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

# Copy entrypoint script
COPY --chown=node:node entrypoint.sh /home/node/entrypoint.sh
RUN chmod +x /home/node/entrypoint.sh

# Switch to non-root user
USER node
WORKDIR /home/node

# Set environment variables
ENV HOME=/home/node
ENV NODE_ENV=production

# Expose Railway's dynamic port
EXPOSE $PORT

# Start OpenClaw gateway via entrypoint script
# The script creates config.yaml if it doesn't exist in the volume
# Then starts the gateway with Railway's dynamic port
CMD ["/home/node/entrypoint.sh"]
