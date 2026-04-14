#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

print_header() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

print_step() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

wait_for_confirm() {
    echo ""
    echo -e "${YELLOW}Sudah selesai mengisi semua file .env di atas?${NC}"
    read -p "Ketik Y untuk melanjutkan instalasi: " confirm
    if [[ "$confirm" != "Y" && "$confirm" != "y" ]]; then
        echo -e "${RED}Instalasi dibatalkan.${NC}"
        exit 1
    fi
    echo ""
}

deploy_service() {
    local dir="$1"
    local name="$2"
    echo -e "${GREEN}[→]${NC} Deploying ${name}..."
    cd "$BASE_DIR/$dir"
    docker compose up -d
    print_step "${name} berhasil di-deploy!"
    echo ""
}

# ============================================================
# START
# ============================================================
print_header "Palkia Server - Full Installation"

echo "Script ini akan menginstall semua service secara berurutan."
echo "Service yang butuh .env akan disiapkan terlebih dahulu."
echo ""

# ============================================================
# STEP 1: Pre-check
# ============================================================
print_header "Step 1: Pre-check"

# Check docker
if ! command -v docker &> /dev/null; then
    print_error "Docker belum terinstall! Install Docker terlebih dahulu."
    exit 1
fi
print_step "Docker terdeteksi"

# Check docker compose
if ! docker compose version &> /dev/null; then
    print_error "Docker Compose belum terinstall! Install Docker Compose terlebih dahulu."
    exit 1
fi
print_step "Docker Compose terdeteksi"

# ============================================================
# STEP 2: Create Docker network
# ============================================================
print_header "Step 2: Docker Network"

if docker network inspect palkia_network &> /dev/null 2>&1; then
    print_step "Network 'palkia_network' sudah ada"
else
    docker network create palkia_network
    print_step "Network 'palkia_network' berhasil dibuat"
fi

# ============================================================
# STEP 3: Setup semua .env files
# ============================================================
print_header "Step 3: Setup Environment Files (.env)"

echo "Berikut service yang membutuhkan file .env:"
echo ""

# --- Cloudflare Tunnel ---
ENV_FILE="$BASE_DIR/cloudflare-tunnel/.env"
ENV_EXAMPLE="$BASE_DIR/cloudflare-tunnel/.env.example"
if [[ -f "$ENV_FILE" ]]; then
    print_step "cloudflare-tunnel/.env sudah ada"
else
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    print_warn "cloudflare-tunnel/.env dibuat dari .env.example"
    echo "       Isi TUNNEL_TOKEN di: $ENV_FILE"
fi

# --- CUPS ---
ENV_FILE="$BASE_DIR/cups/.env"
ENV_EXAMPLE="$BASE_DIR/cups/.env.example"
if [[ -f "$ENV_FILE" ]]; then
    print_step "cups/.env sudah ada"
else
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    print_warn "cups/.env dibuat dari .env.example"
    echo "       Isi CUPS_ADMIN dan CUPS_PASSWORD di: $ENV_FILE"
fi

# --- Homepage ---
ENV_FILE="$BASE_DIR/homepage/.env"
ENV_EXAMPLE="$BASE_DIR/homepage/.env.example"
if [[ -f "$ENV_FILE" ]]; then
    print_step "homepage/.env sudah ada"
else
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    print_warn "homepage/.env dibuat dari .env.example"
    echo "       Isi HOMEPAGE_VAR_PORTAINER_KEY, HOMEPAGE_VAR_ADGUARD_USER, HOMEPAGE_VAR_ADGUARD_PASS di: $ENV_FILE"
fi

# --- Nginx Proxy Manager ---
ENV_FILE="$BASE_DIR/nginx-proxy-manager/.env.npm"
ENV_EXAMPLE="$BASE_DIR/nginx-proxy-manager/.env.npm.example"
if [[ -f "$ENV_FILE" ]]; then
    print_step "nginx-proxy-manager/.env.npm sudah ada"
else
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    print_warn "nginx-proxy-manager/.env.npm dibuat dari .env.npm.example"
    echo "       Isi NPM_EMAIL dan NPM_PASSWORD di: $ENV_FILE"
fi

echo ""
echo -e "${YELLOW}─────────────────────────────────────────────${NC}"
echo -e "${YELLOW}  Silakan edit file .env yang belum diisi:${NC}"
echo ""
echo "  1. cloudflare-tunnel/.env   → TUNNEL_TOKEN"
echo "  2. cups/.env                → CUPS_ADMIN, CUPS_PASSWORD"
echo "  3. homepage/.env            → PORTAINER_KEY, ADGUARD credentials"
echo "  4. nginx-proxy-manager/.env.npm → NPM_EMAIL, NPM_PASSWORD"
echo -e "${YELLOW}─────────────────────────────────────────────${NC}"

wait_for_confirm

# ============================================================
# STEP 4: Deploy services (berurutan)
# ============================================================
print_header "Step 4: Deploy Services"

echo "Urutan deploy:"
echo "  1. AdGuard Home (DNS - dibutuhkan service lain)"
echo "  2. Nginx Proxy Manager (Reverse Proxy)"
echo "  3. Portainer (Docker Management)"
echo "  4. Uptime Kuma (Monitoring)"
echo "  5. Homepage (Dashboard)"
echo "  6. CUPS (Print Server)"
echo "  7. Cloudflare Tunnel"
echo ""

# 1. AdGuard Home - DNS harus pertama
deploy_service "adguard" "AdGuard Home (DNS)"

# 2. Nginx Proxy Manager - reverse proxy
deploy_service "nginx-proxy-manager" "Nginx Proxy Manager"

# 3. Portainer
deploy_service "portainer" "Portainer"

# 4. Uptime Kuma
deploy_service "uptime-kuma" "Uptime Kuma"

# 5. Homepage
deploy_service "homepage" "Homepage Dashboard"

# 6. CUPS
deploy_service "cups" "CUPS Print Server"

# 7. Cloudflare Tunnel
deploy_service "cloudflare-tunnel" "Cloudflare Tunnel"

# ============================================================
# STEP 5: Setup NPM Proxy Hosts (optional)
# ============================================================
print_header "Step 5: Setup NPM Proxy Hosts (Optional)"

SETUP_SCRIPT="$BASE_DIR/nginx-proxy-manager/setup-proxy-hosts.sh"
if [[ -f "$SETUP_SCRIPT" ]]; then
    echo "Mau otomatis setup proxy hosts di Nginx Proxy Manager?"
    echo "(Pastikan NPM sudah fully running dulu, tunggu ~15 detik setelah deploy)"
    read -p "Jalankan setup-proxy-hosts.sh? (Y/n): " run_npm
    if [[ "$run_npm" == "Y" || "$run_npm" == "y" ]]; then
        echo "Menunggu NPM ready (15 detik)..."
        sleep 15
        cd "$BASE_DIR/nginx-proxy-manager"
        bash setup-proxy-hosts.sh
        print_step "NPM proxy hosts berhasil di-setup!"
    else
        print_warn "Skipped. Jalankan manual nanti: bash nginx-proxy-manager/setup-proxy-hosts.sh"
    fi
else
    print_warn "setup-proxy-hosts.sh tidak ditemukan, skip NPM proxy setup."
fi

# ============================================================
# DONE
# ============================================================
print_header "Instalasi Selesai!"

echo "Semua service berhasil di-deploy. Akses via:"
echo ""
echo "  Homepage        → http://10.20.30.100:3000  atau  http://home.palkia.local"
echo "  Uptime Kuma     → http://10.20.30.100:3001  atau  http://uptime.palkia.local"
echo "  Portainer       → http://10.20.30.100:9000  atau  http://portainer.palkia.local"
echo "  NPM             → http://10.20.30.100:81    atau  http://npm.palkia.local"
echo "  AdGuard Home    → http://10.20.30.100:8080  atau  http://adguard.palkia.local"
echo "  CUPS            → http://10.20.30.100:631   atau  http://cups.palkia.local"
echo ""
echo -e "${GREEN}Done! 🎉${NC}"
