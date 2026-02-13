FROM node:22-bookworm-slim

# Install git (required for npm dependencies) and ca-certificates
RUN apt-get update && \
    apt-get install -y git ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install OpenClaw globally from npm
RUN npm install -g openclaw@latest

# Create non-root user for security
RUN useradd -m -u 1000 openclaw && \
    mkdir -p /home/openclaw/.openclaw && \
    chown -R openclaw:openclaw /home/openclaw

# Switch to non-root user
USER openclaw
WORKDIR /home/openclaw

# Set environment variables
ENV HOME=/home/openclaw
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
