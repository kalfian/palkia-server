# Palkia Stack – My Home Server Setup

Welcome to Palkia, my lightweight yet powerful home server built on Docker Compose, running on an Orange Pi with Debian.

This repo contains all my Docker Compose configurations to manage network, monitor services, and provide a smooth homelab experience.

---

## Stack Overview

Service         | Description                                      | Port
----------------|--------------------------------------------------|-------
Portainer       | Manage Docker containers via Web UI             | 9000
Homarr          | Home dashboard for all services & shortcuts     | 7575
Pi-hole         | DNS filtering, ad-blocking (config not saved)   | 8080
Uptime Kuma     | Monitor uptime for services & devices           | 3001
Cloudflare Tunnel | (soon) Remote access to internal services     | (via domain)

All services are deployed via individual Docker Compose files, located in their respective folders.

---
## 📁 Folder Structure

```
palkia-stack/
├── homarr/
│   └── docker-compose.yml
│
├── pihole/
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

---
Stack Overview

Service         | Description                                      | Port
----------------|--------------------------------------------------|-------
Portainer       | Manage Docker containers via Web UI             | 9000
Homarr          | Home dashboard for all services & shortcuts     | 7575
Pi-hole         | DNS filtering, ad-blocking (config not saved)   | 8080
Uptime Kuma     | Monitor uptime for services & devices           | 3001
Cloudflare Tunnel | (soon) Remote access to internal services     | (via domain)

All services are deployed via individual Docker Compose files, located in their respective folders.

---
## 📁 Folder Structure

```
palkia-stack/
├── homarr/
│   └── docker-compose.yml
│
├── pihole/
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

## How to Deploy

1. Clone this repository:
   git clone https://github.com/yourusername/palkia-stack.git

2. Deploy one of the services:
   cd uptime-kuma
   docker compose up -d

---

## Notes

- Pi-hole config is intentionally excluded for permission & security reasons
- Cloudflare Tunnel will be added soon
- All stacks use bind volumes, so configs persist even after reboot

---

## Credits

- Pi-hole
- Homarr
- Uptime Kuma
- Portainer

---

Maintained by:
Kukuh – home server tinkerer, devops enthusiast, and network space-time guardian.

