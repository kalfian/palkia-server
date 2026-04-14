# Palkia Stack – My Home Server Setup

Welcome to Palkia, my lightweight yet powerful home server built on Docker Compose, running on an Orange Pi with Debian.

This repo contains all my Docker Compose configurations to manage network, monitor services, and provide a smooth homelab experience.

---

## Stack Overview

Service              | Description                                  | Port
---------------------|----------------------------------------------|-------
Portainer            | Manage Docker containers via Web UI          | 9000, 9443
Homepage             | Home dashboard for all services & shortcuts  | 3000
CUPS                 | Print server for USB printers over network   | 631 (host network)
AdGuard Home         | DNS filtering & ad-blocking                  | 53, 8080
Uptime Kuma          | Monitor uptime for services & devices        | 3001
Nginx Proxy Manager  | Reverse proxy & SSL for *.palkia.local       | 80, 81, 443
Cloudflare Tunnel    | Remote access to internal services           | (via domain)

All services are deployed via individual Docker Compose files, located in their respective folders.

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

## How to Deploy

1. Clone this repository:
   git clone https://github.com/yourusername/palkia-stack.git

2. Deploy one of the services:
   cd uptime-kuma
   docker compose up -d

---

## DNS Setup

To access services via `*.palkia.local` domains, your network's DNS must point to the AdGuard Home server (e.g. `10.20.30.100`).

**Example: MikroTik Router**

1. Go to **IP → DNS**, set **Servers** to `10.20.30.100`
2. Go to **IP → DHCP Server → Networks**, select your network, set **DNS Server** to `10.20.30.100`

This ensures all devices on the network automatically resolve `*.palkia.local` to the correct server via AdGuard Home.

---

## Notes

- AdGuard Home requires port 53 to be available (see `adguard/README.md` for prerequisites)
- CUPS runs in host network mode for USB printer access and requires credentials via `.env` (see `cups/.env.example`)
- Cloudflare Tunnel requires a tunnel token via `.env` (see `cloudflare-tunnel/.env.example`)
- All services (except CUPS) share the external `palkia_network` Docker network
- All stacks use bind volumes, so configs persist even after reboot

---

## Credits

- [AdGuard Home](https://github.com/AdguardTeam/AdGuardHome)
- [Homepage](https://github.com/gethomepage/homepage)
- [Uptime Kuma](https://github.com/louislam/uptime-kuma)
- [Portainer](https://github.com/portainer/portainer)
- [Nginx Proxy Manager](https://github.com/NginxProxyManager/nginx-proxy-manager)
- [CUPS](https://github.com/anujdatar/cups-docker)

---

