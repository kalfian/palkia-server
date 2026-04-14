# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Palkia is a Docker Compose-based home server stack running on an Orange Pi (Debian, ARM). Each service lives in its own directory with an independent `docker-compose.yml`.

## Common Commands

```bash
# Deploy/restart a single service
cd <service-dir> && docker compose up -d

# Stop a service
cd <service-dir> && docker compose down

# View logs
cd <service-dir> && docker compose logs -f

# Rebuild after config changes
cd <service-dir> && docker compose up -d --force-recreate

# Regenerate folder tree in README.md
python3 generate_tree.py
```

## Architecture

**Networking:** All services (except CUPS) connect via the external Docker network `palkia_network`. CUPS uses host networking for USB printer passthrough. This network must exist before deploying services (`docker network create palkia_network`).

**Reverse proxy:** Nginx Proxy Manager (ports 80/81/443) routes traffic to services using `*.palkia.local` DNS names. AdGuard Home (port 53) provides local DNS resolution pointing these names to the server.

**Services, ports, and internal URLs:**

| Service | Dir | Host Port(s) | Internal URL (Docker network) | Public URL |
|---|---|---|---|---|
| Homepage (dashboard) | `homepage/` | 3000 | `http://homepage:3000` | `home.palkia.local` |
| Uptime Kuma (monitoring) | `uptime-kuma/` | 3001 | `http://uptime-kuma:3001` | `uptime.palkia.local` |
| Portainer (Docker UI) | `portainer/` | 9000, 9443 | `http://portainer:9000` | `portainer.palkia.local` |
| Nginx Proxy Manager | `nginx-proxy-manager/` | 80, 81, 443 | `http://nginx-proxy-manager:81` | `npm.palkia.local` |
| AdGuard Home (DNS) | `adguard/` | 53, 8080 | `http://adguard-home:8080` | `adguard.palkia.local` |
| CUPS (print server) | `cups/` | 631 (host network) | `http://10.20.30.100:631` | `cups.palkia.local` |
| Cloudflare Tunnel | `cloudflare-tunnel/` | none | — | — |

**Network devices (not Docker):**

| Device | IP |
|---|---|
| MikroTik Router | `10.20.30.1` |
| Synology NAS | `10.20.30.11:1234` |
| Palkia Server (Orange Pi) | `10.20.30.100` |

**Environment files:** CUPS, Cloudflare Tunnel, and Homepage require `.env` files (see `.env.example` in each). Secrets should never be committed.

**Homepage config:** Dashboard layout is in `homepage/config/` (YAML files for services, widgets, bookmarks, settings). It reads the Docker socket for container status.

## Conventions

- Each service is self-contained in its own directory with its own `docker-compose.yml`
- Data/config/logs directories are gitignored (see `.gitignore`) — only compose files and config templates are tracked
- Timezone is `Asia/Jakarta` across services
- The `generate_tree.py` script updates the folder structure section in `README.md` between the `FOLDER_TREE_START` / `FOLDER_TREE_END` markers
- Always `docker compose up -d --force-recreate` after config changes — don't ask, just do it

## Preferences

- Language: communicate in Indonesian (Bahasa), code/docs in English
- Uptime Kuma: use iframe widget (`/status/palkia-server`), not native widget — native is too minimal
- Don't probe unreachable APIs repeatedly — if it fails, ask or give manual instructions
- Network devices use `siteMonitor` (HTTP check) instead of `ping` — ICMP doesn't work from Docker containers
- AdGuard config: prefer direct file edit over API (API has auth issues)
- NPM config: prefer API script (`setup-proxy-hosts.sh`)
