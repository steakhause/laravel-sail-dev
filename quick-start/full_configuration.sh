#!/bin/bash
set -euo pipefail

# Resolve root directory one level above this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
ENV_FILE="$ROOT_DIR/.env"

# Load .env
if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ .env file not found at $ENV_FILE"
  exit 1
fi

export $(grep -v '^#' "$ENV_FILE" | xargs)

# --- Laravel setup ---
# Navigate to project root (where docker-compose.yml lives)
cd "$ROOT_DIR" || {
  echo "❌ Failed to change to project root: $ROOT_DIR"
  exit 1
}

# Run Docker Compose
echo "🐳 Starting Laravel stack with Docker Compose..."
docker compose up -d --build

if [[ $? -eq 0 ]]; then
  echo "✅ Containers built and started successfully."
else
  echo "❌ Docker Compose failed."
  exit 1
fi

# --- NPM Proxy Setup ---
if [[ -n "${NPM_HOST:-}" && "$NPM_HOST" != "null" ]]; then
  echo "🌐 NPM_HOST is set to $NPM_HOST — proceeding with proxy creation"
  "$SCRIPT_DIR/create-npm-proxy.sh"
else
  echo "⏭️  Skipping Nginx Proxy Manager proxy setup — NPM_HOST is unset or set to 'null'"
fi

# --- Pi-hole Setup (optional) ---
if [[ -n "${PIHOLE_HOST:-}" && "$PIHOLE_HOST" != "null" ]]; then
  echo "🛡️  Configuring Pi-hole..."
  "$SCRIPT_DIR/configure-pihole.sh"
else
  echo "⏭️  Skipping Pi-hole config — PIHOLE_HOST is unset or set to 'null'"
fi
