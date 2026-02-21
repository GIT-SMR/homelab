# Homelab Infrastructure (Docker + Traefik + GitOps-lite)

Production-style homelab running on Ubuntu Server using Docker, Traefik, and Git as the source of truth.

---

# Overview

This repository contains all Docker Compose stacks and scripts required to rebuild the entire homelab from scratch.

Key principles:

- Git is the source of truth
- Immutable infrastructure mindset
- Reproducible deployments
- Secure reverse proxy via Traefik
- Automated backup to Synology NAS
- Minimal host configuration

---

# Host Information

OS: Ubuntu 24.04 LTS  
Container Runtime: Docker Engine  
Reverse Proxy: Traefik  
Management: Portainer, Cockpit  
Backup: Duplicati → Synology NAS  
Monitoring: Uptime Kuma  
Automation: Home Assistant + ESPHome  

---

# Directory Structure

Repository:

```
/opt/stacks-repo
├── README.md
├── scripts/
│   └── docker-update.sh
├── docs/
│   └── management/
├── stacks/
│   ├── infra/
│   ├── home/
│   ├── monitoring/
│   └── backup/
```

Runtime:

```
/opt/stacks → symlinks to stacks inside repo
```

Persistent data:

```
/opt/data
```

---

# Docker Network

All services connect to shared network:

```
edge
```

Create if missing:

```bash
docker network create edge
```

---

# Deployment

Update and deploy all stacks:

```bash
/opt/scripts/docker-update.sh
```

Manual deployment:

```bash
cd /opt/stacks/infra
docker compose pull
docker compose up -d
```

---

# Backup Strategy

Backup tool: Duplicati

Backs up:

```
/opt/data/
/opt/stacks-repo/
```

Destination:

```
Synology NAS mounted at /mnt/nas/backup
```

---

# Restore Procedure

Fresh server restore:

Install Docker:

```bash
curl -fsSL https://get.docker.com | sh
```

Clone repo:

```bash
git clone git@github.com:GIT-SMR/homelab.git /opt/stacks-repo
```

Create symlinks:

```bash
mkdir -p /opt/stacks

ln -s /opt/stacks-repo/stacks/infra /opt/stacks/infra
ln -s /opt/stacks-repo/stacks/home /opt/stacks/home
ln -s /opt/stacks-repo/stacks/monitoring /opt/stacks/monitoring
ln -s /opt/stacks-repo/stacks/backup /opt/stacks/backup
```

Create network:

```bash
docker network create edge
```

Deploy:

```bash
/opt/scripts/docker-update.sh
```

---

# Git Workflow

Make infrastructure changes:

```bash
cd /opt/stacks-repo
git add .
git commit -m "Update infrastructure"
git push
```

Deploy changes:

```bash
/opt/scripts/docker-update.sh
```

---

# Security Model

- Reverse proxy controls access
- Containers isolated via Docker networking
- No direct container exposure
- Persistent data stored outside containers
- Git provides change tracking and rollback

---

# Services

Infrastructure:
- Traefik
- Portainer
- Dozzle

Automation:
- Home Assistant
- ESPHome

Monitoring:
- Uptime Kuma

Backup:
- Duplicati

---

# Future Improvements

- Prometheus monitoring
- Grafana dashboards
- Automated health alerting
- Automated rebuild script
- Remote Git-based deployment

---

Maintainer: Sérgio Ribeiro
