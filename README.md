# OpenClaw Railway Deployment

Railway deployment configuration for OpenClaw using npm package installation.

## Overview

OpenClaw is a TypeScript/Node.js personal AI assistant that provides a unified gateway for connecting to 15+ messaging platforms (WhatsApp, Telegram, Discord, Slack, etc.). This repository contains the Railway deployment configuration for running OpenClaw in production.

## Files

- `Dockerfile` - Railway-optimized container using openclaw npm package
- `railway.toml` - Railway platform configuration
- `.dockerignore` - Build context exclusions

## Deployment

Connected to Railway for automatic deployment on push to main branch.

### Build Method

This deployment uses the **npm package installation method** (`npm install -g openclaw@latest`):
- Uses stable, published OpenClaw releases
- Eliminates build complexity (no pnpm, no build steps)
- Reduces deployment time to ~1-2 minutes
- Results in smaller Docker images (~500MB vs 1.5GB+)
- Simplifies maintenance and updates

## Environment Variables Required

### Essential Variables

| Variable | Description | How to Get |
|----------|-------------|-----------|
| `OPENCLAW_GATEWAY_TOKEN` | Gateway authentication token | Generate: `openssl rand -hex 32` |
| `ANTHROPIC_API_KEY` | Claude API key | https://console.anthropic.com/ |
| `TELEGRAM_BOT_TOKEN` | Telegram bot token | @BotFather on Telegram |
| `NODE_ENV` | Node environment | Set to `production` |

### Optional AI Provider Keys

| Variable | Description |
|----------|-------------|
| `OPENAI_API_KEY` | OpenAI API key for GPT models |
| `GEMINI_API_KEY` | Google Gemini API key |
| `OPENROUTER_API_KEY` | OpenRouter API key |

## Railway Setup Steps

### 1. Create Railway Project

1. Go to https://railway.app
2. Click "New Project" → "Deploy from GitHub repo"
3. Authorize Railway and select this repository
4. Select the `main` branch
5. Railway will auto-detect the Dockerfile

### 2. Configure Environment Variables

In Railway Dashboard → Variables tab:

```bash
# Generate gateway token
OPENCLAW_GATEWAY_TOKEN=$(openssl rand -hex 32)

# Add your API keys
ANTHROPIC_API_KEY=sk-ant-xxxxx
TELEGRAM_BOT_TOKEN=xxxx:xxxxxxx

# Set environment
NODE_ENV=production
```

Mark sensitive variables (tokens, API keys) as "Sensitive" in Railway.

### 3. Set Up Persistent Storage

In Railway Dashboard → Settings → Volumes:

1. Click "New Volume"
2. **Mount Path:** `/home/openclaw/.openclaw`
3. **Initial Size:** 10GB
4. Click "Add"

This persists configuration and workspace data across deployments.

### 4. Deploy

Push to main branch or click "Deploy" in Railway dashboard.

Expected deployment time: ~2-3 minutes

### 5. Configure Telegram Webhook

After deployment, get your Railway URL and set the webhook:

```bash
# Method 1: Via browser
https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook?url=https://<your-service>.railway.app/telegram

# Method 2: Via curl
curl -X POST "https://api.telegram.org/bot<YOUR_BOT_TOKEN>/setWebhook" \
  -d "url=https://<your-service>.railway.app/telegram"

# Verify webhook
https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getWebhookInfo
```

## Getting Telegram Bot Token

1. Open Telegram and search for [@BotFather](https://t.me/botfather)
2. Send `/newbot` command
3. Follow prompts to create bot
4. Copy the token provided
5. Add to Railway environment variables

## Continuous Deployment

Railway automatically deploys when you push to the main branch:

```bash
git add .
git commit -m "Your changes"
git push origin main
```

Railway will:
- Build new Docker image
- Deploy new version
- Keep old version running until new one is healthy
- Route traffic to new deployment

## Troubleshooting

### Application Failed to Respond

**Check:**
- Logs show "Listening on 0.0.0.0:XXXX" (not 127.0.0.1)
- `--bind lan` flag is in Dockerfile
- CMD uses shell form (no brackets)

### Configuration Resets

**Check:**
- Volume mounted at `/home/openclaw/.openclaw`
- Volume shows "Mounted" status in Railway

### Telegram Bot Not Responding

**Check:**
- Webhook URL matches Railway deployment URL
- Railway logs show incoming webhook requests
- Bot token is correct

## Cost Estimation

**Railway Plans:**
- Hobby Plan: $5/month (500 execution hours, 512MB RAM)
- Pro Plan: $20/month (unlimited hours, 8GB RAM) - **Recommended**

**Volume Storage:**
- $0.25/GB/month
- 10GB = $2.50/month

**Total:** ~$7.50/month (Hobby) or ~$22.50/month (Pro)

## Local Testing

Test the Docker image locally before deploying:

```bash
# Build image
docker build -t openclaw-test .

# Run container
docker run -p 18789:18789 \
  -e OPENCLAW_GATEWAY_TOKEN=test-token \
  -e ANTHROPIC_API_KEY=your-key \
  openclaw-test

# Test connection
curl http://localhost:18789
```

## Additional Resources

- [OpenClaw Documentation](https://open-claw.org/)
- [Railway Docs - Dockerfiles](https://docs.railway.com/guides/dockerfiles)
- [Railway Docs - Environment Variables](https://docs.railway.com/variables)
- [Railway Docs - Volumes](https://docs.railway.com/volumes)
- [Telegram Bot API](https://core.telegram.org/bots/api)

## Support

For issues with:
- **OpenClaw:** https://github.com/openclaw/openclaw/issues
- **Railway:** https://railway.app/help
- **This deployment:** Create an issue in this repository
