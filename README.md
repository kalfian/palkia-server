# Palkia Server

A Docker Compose-based home server stack running on Orange Pi (Debian, ARM). Each service is self-contained with its own `docker-compose.yml`.

---

## Stack Overview

| Service | Description | Port(s) | Local URL |
|---------|-------------|---------|-----------|
| AdGuard Home | DNS filtering & ad-blocking | 53, 8080 | `adguard.palkia.local` |
| Nginx Proxy Manager | Reverse proxy & SSL for `*.palkia.local` | 80, 81, 443 | `npm.palkia.local` |
| Portainer | Docker container management UI | 9000, 9443 | `portainer.palkia.local` |
| Homepage | Home dashboard for all services | 3000 | `home.palkia.local` |
| Uptime Kuma | Service & device uptime monitoring | 3001 | `uptime.palkia.local` |
| CUPS | Network print server (USB passthrough) | 631 (host) | `cups.palkia.local` |
| Cloudflare Tunnel | Remote access via Cloudflare | — | — |

### Network Devices

| Device | IP |
|--------|-----|
| MikroTik Router | `10.20.30.1` |
| Synology NAS | `10.20.30.11:1234` |
| Palkia Server (Orange Pi) | `10.20.30.100` |

---

## Quick Start

### One-Command Install

```bash
git clone https://github.com/kalfian/palkia-server.git
cd palkia-server
bash install.sh
```

The script will:
1. Check Docker & Docker Compose are installed
2. Create the `palkia_network` Docker network
3. Generate all `.env` files from templates — **you fill them in**
4. Wait for your confirmation before proceeding
5. Deploy all services in the correct order
6. Optionally configure Nginx Proxy Manager proxy hosts

### Manual Deploy (Single Service)

```bash
cd <service-dir>
docker compose up -d
```

---

## Environment Variables

Some services require `.env` files before they can run. The install script creates these automatically from `.env.example` templates, but you can also do it manually.

### Cloudflare Tunnel

```bash
cp cloudflare-tunnel/.env.example cloudflare-tunnel/.env
```

| Variable | Description | How to Get |
|----------|-------------|------------|
| `TUNNEL_TOKEN` | Cloudflare tunnel authentication token | [Cloudflare Zero Trust](https://one.dash.cloudflare.com/) → Networks → Tunnels → Create/select tunnel → Copy token from the provided command |

### CUPS

```bash
cp cups/.env.example cups/.env
```

| Variable | Description | Default |
|----------|-------------|---------|
| `CUPS_ADMIN` | Web interface admin username | `admin` |
| `CUPS_PASSWORD` | Web interface admin password | `gantipassword` |

### Homepage

```bash
cp homepage/.env.example homepage/.env
```

| Variable | Description | How to Get |
|----------|-------------|------------|
| `HOMEPAGE_VAR_PORTAINER_KEY` | Portainer API access token | Portainer UI → My Account → Access Tokens → Add access token |
| `HOMEPAGE_VAR_ADGUARD_USER` | AdGuard Home login username | Same credentials you set during AdGuard initial setup |
| `HOMEPAGE_VAR_ADGUARD_PASS` | AdGuard Home login password | Same credentials you set during AdGuard initial setup |

> **Note:** The Portainer API key can only be generated after Portainer is running and you have created an admin account. You can deploy Homepage first and update this later.

### Nginx Proxy Manager

```bash
cp nginx-proxy-manager/.env.npm.example nginx-proxy-manager/.env.npm
```

| Variable | Description | Default |
|----------|-------------|---------|
| `NPM_EMAIL` | NPM login email | `admin@example.com` |
| `NPM_PASSWORD` | NPM login password | `changeme` |

> **Note:** This file is used by `setup-proxy-hosts.sh` to auto-configure proxy hosts via the NPM API. Update the values after you change the default NPM credentials.

---

## Architecture

```
                         Internet
                            │
                    ┌───────┴───────┐
                    │  Cloudflare   │
                    │    Tunnel     │
                    └───────┬───────┘
                            │
┌───────────────────────────┼──────────────────────────────┐
│  Palkia Server (10.20.30.100)                            │
│                           │                              │
│  ┌────────────────────────┴─────────────────────────┐    │
│  │  Nginx Proxy Manager (:80/:81/:443)              │    │
│  │  Routes *.palkia.local to internal services      │    │
│  └──┬──────┬──────┬──────┬──────┬───────────────────┘    │
│     │      │      │      │      │                        │
│     ▼      ▼      ▼      ▼      ▼                        │
│  Homepage Uptime Portainer AdGuard CUPS                  │
│   :3000   Kuma    :9000   :8080  :631                    │
│           :3001                  (host)                   │
│                                                          │
│  ── All on palkia_network (except CUPS: host network) ── │
└──────────────────────────────────────────────────────────┘
         │
    ┌────┴────┐
    │ AdGuard │──── DNS (port 53)
    │  Home   │     resolves *.palkia.local
    └─────────┘
```

All services (except CUPS) share the external Docker network `palkia_network`. CUPS uses host networking for USB printer passthrough.

---

## DNS Setup

For `*.palkia.local` domains to work, your network DNS must point to AdGuard Home (`10.20.30.100`).

**MikroTik Router:**
1. Go to **IP → DNS** → Set **Servers** to `10.20.30.100`
2. Go to **IP → DHCP Server → Networks** → Select your network → Set **DNS Server** to `10.20.30.100`

All devices on the network will then automatically resolve `*.palkia.local` to the server via AdGuard Home.

---

## Common Commands

```bash
# Deploy / restart a service
cd <service-dir> && docker compose up -d

# Force recreate after config changes
cd <service-dir> && docker compose up -d --force-recreate

# Stop a service
cd <service-dir> && docker compose down

# View logs
cd <service-dir> && docker compose logs -f

# Setup NPM proxy hosts (after NPM is running)
bash nginx-proxy-manager/setup-proxy-hosts.sh

# Regenerate folder tree in this README
python3 generate_tree.py
```

---

<!-- FOLDER_TREE_START -->
## 📁 Folder Structure

```
palkia-stack/
├── adguard/
│   └── docker-compose.yml
│
├── cloudflare-tunnel/
│   └── docker-compose.yml
│
├── cups/
│   └── docker-compose.yml
│
├── homepage/
│   └── docker-compose.yml
│
├── nginx-proxy-manager/
│   └── docker-compose.yml
│
├── portainer/
│   └── docker-compose.yml
│
├── uptime-kuma/
│   └── docker-compose.yml
│
├── generate_tree.py
├── .gitignore
└── README.md
```
<!-- FOLDER_TREE_END -->

---

## Credits

- [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome)
- [Homepage](https://github.com/gethomepage/homepage)
- [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- [Portainer](https://github.com/portainer/portainer)
- [Nginx Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager)
- [CUPS](https://github.com/anujdatar/cups-docker)
