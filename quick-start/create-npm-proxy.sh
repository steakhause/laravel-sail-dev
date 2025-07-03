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

REQUIRED_VARS=(NPM_HOST NPM_EMAIL NPM_PASSWORD DOMAIN_NAME FORWARD_HOST FORWARD_PORT ACCESS_LIST_ID)
for var in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!var:-}" ]]; then
    echo "❌ Missing required environment variable: $var"
    exit 1
  fi
done

# Authenticate with NPM
echo "🔐 Logging in to NPM at $NPM_HOST..."
LOGIN_RESPONSE=$(curl -s -X POST "$NPM_HOST/api/tokens" \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$NPM_EMAIL\",\"secret\":\"$NPM_PASSWORD\"}")

ACCESS_TOKEN=$(echo "$LOGIN_RESPONSE" | jq -r '.token // empty')
if [[ -z "$ACCESS_TOKEN" ]]; then
  echo "❌ Login failed."
  echo "$LOGIN_RESPONSE"
  exit 1
fi
echo "✅ Login successful."

# Create proxy host
echo "🌐 Creating proxy host for $DOMAIN_NAME..."
RESPONSE=$(curl -s -X POST "$NPM_HOST/api/nginx/proxy-hosts" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"domain_names\": [\"$DOMAIN_NAME\"],
    \"forward_scheme\": \"http\",
    \"forward_host\": \"$FORWARD_HOST\",
    \"forward_port\": $FORWARD_PORT,
    \"access_list_id\": $ACCESS_LIST_ID,
    \"advanced_config\": \"\",
    \"locations\": [],
    \"enabled\": true,
    \"allow_websocket_upgrade\": true
  }")

ID=$(echo "$RESPONSE" | jq -r '.id // empty')
if [[ -z "$ID" ]]; then
  echo "❌ Failed to create proxy host."
  echo "📥 Full response:"
  echo "$RESPONSE" | jq .
  exit 1
fi

echo "✅ Proxy host created. ID: $ID"
