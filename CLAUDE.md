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

**Services and ports:**

| Service | Dir | Port(s) |
|---|---|---|
| Homepage (dashboard) | `homepage/` | 3000 |
| Uptime Kuma (monitoring) | `uptime-kuma/` | 3001 |
| Portainer (Docker UI) | `portainer/` | 9000, 9443 |
| Nginx Proxy Manager | `nginx-proxy-manager/` | 80, 81, 443 |
| AdGuard Home (DNS) | `adguard/` | 53, 8080 |
| CUPS (print server) | `cups/` | 631 (host network) |
| Cloudflare Tunnel | `cloudflare-tunnel/` | none |

**Environment files:** CUPS and Cloudflare Tunnel require `.env` files (see `.env.example` in each). Secrets should never be committed.

**Homepage config:** Dashboard layout is in `homepage/config/` (YAML files for services, widgets, bookmarks, settings). It reads the Docker socket for container status.

## Conventions

- Each service is self-contained in its own directory with its own `docker-compose.yml`
- Data/config/logs directories are gitignored (see `.gitignore`) — only compose files and config templates are tracked
- Timezone is `Asia/Jakarta` across services
- The `generate_tree.py` script updates the folder structure section in `README.md` between the `FOLDER_TREE_START` / `FOLDER_TREE_END` markers
