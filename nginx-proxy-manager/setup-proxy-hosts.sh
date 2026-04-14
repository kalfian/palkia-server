#!/bin/bash
# Auto-setup NPM proxy hosts for all Palkia services
# Usage: ./setup-proxy-hosts.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env.npm"
NPM_API="http://localhost:81/api"

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: .env.npm not found. Copy .env.npm.example to .env.npm and fill in credentials."
  exit 1
fi

source "$ENV_FILE"

echo "Logging in to NPM..."
TOKEN=$(curl -sf "$NPM_API/tokens" -X POST \
  -H "Content-Type: application/json" \
  -d "{\"identity\":\"$NPM_EMAIL\",\"secret\":\"$NPM_PASSWORD\"}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['token'])")

if [ -z "$TOKEN" ]; then
  echo "Error: Failed to login. Check .env.npm credentials."
  exit 1
fi
echo "Logged in."

# Fetch existing proxy hosts to avoid duplicates
EXISTING=$(curl -sf "$NPM_API/nginx/proxy-hosts" \
  -H "Authorization: Bearer $TOKEN" \
  | python3 -c "
import sys,json
hosts = json.load(sys.stdin)
for h in hosts:
    for d in h['domain_names']:
        print(d)
")

create_proxy() {
  local domain="$1"
  local forward_host="$2"
  local forward_port="$3"
  local advanced_config="${4:-}"

  if echo "$EXISTING" | grep -qx "$domain"; then
    echo "SKIP: $domain (already exists)"
    return
  fi

  echo -n "Creating: $domain -> $forward_host:$forward_port ... "
  RESULT=$(curl -sf "$NPM_API/nginx/proxy-hosts" -X POST \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"domain_names\": [\"$domain\"],
      \"forward_scheme\": \"http\",
      \"forward_host\": \"$forward_host\",
      \"forward_port\": $forward_port,
      \"block_exploits\": true,
      \"allow_websocket_upgrade\": true,
      \"access_list_id\": 0,
      \"certificate_id\": 0,
      \"ssl_forced\": false,
      \"meta\": {\"letsencrypt_agree\": false, \"dns_challenge\": false},
      \"advanced_config\": \"$advanced_config\",
      \"locations\": [],
      \"caching_enabled\": false,
      \"hsts_enabled\": false,
      \"hsts_subdomains\": false,
      \"http2_support\": false
    }")

  if echo "$RESULT" | python3 -c "import sys,json; json.load(sys.stdin)['id']" &>/dev/null; then
    echo "OK"
  else
    echo "FAILED"
    echo "$RESULT"
  fi
}

echo ""
echo "Setting up proxy hosts..."
echo "========================="

# Docker services (container names resolve via palkia_network)
create_proxy "home.palkia.local"      "homepage"            3000
# Strip X-Frame-Options and CSP headers to allow iframe embedding in Homepage
create_proxy "uptime.palkia.local"    "uptime-kuma"         3001 "proxy_hide_header X-Frame-Options;\nproxy_hide_header Content-Security-Policy;"
create_proxy "portainer.palkia.local" "portainer"           9000
create_proxy "npm.palkia.local"       "nginx-proxy-manager" 81
create_proxy "adguard.palkia.local"   "adguard-home"        80
create_proxy "cups.palkia.local"      "host.docker.internal" 631

# External devices
create_proxy "mikrotik.palkia.local" "10.20.30.1"  80
create_proxy "nas.palkia.local"      "10.20.30.11" 1234

echo ""
echo "Done!"
