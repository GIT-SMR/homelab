# Homelab Infrastructure (Production‑style Docker + Traefik + GitOps)

Production‑grade homelab running on Ubuntu Server using Docker, Traefik, and Git as the single source of truth.

This repository allows full infrastructure rebuild from scratch in minutes.

---

## Core Principles

- Git is the source of truth
- Reproducible infrastructure
- Minimal host configuration
- Persistent data separation
- Reverse proxy‑based access control
- Automated backup and recovery

---

## Host Environment

Server:

- OS: Ubuntu Server 24.04 LTS
- Runtime: Docker Engine
- Hardware: Intel Core2 Duo, 3.7GB RAM

Core Components:

- Reverse Proxy: Traefik
- Container Management: Portainer
- Host Management: Cockpit
- Log Monitoring: Dozzle

Automation:

- Home Assistant
- ESPHome

Monitoring:

- Prometheus
- Grafana
- Uptime Kuma

Backup:

- Duplicati
- Synology NAS (mounted at /mnt/nas/backup)

---

## Repository Structure

```text
/opt/stacks-repo
├── README.md
├── scripts/
│   ├── bootstrap.sh
│   ├── docker-update.sh
│   └── update/
│       ├── run-updates.sh
│       ├── lib/
│       │   └── common.sh
│       └── modules/
│           ├── 10-host-update.sh
│           ├── 20-docker-update.sh
│           └── 30-cleanup.sh
├── stacks/
│   ├── infra/
│   ├── home/
│   ├── monitoring/
│   └── backup/
└── docs/
```

Runtime symlinks:

```text
/opt/stacks → /opt/stacks-repo/stacks
/opt/scripts → /opt/stacks-repo/scripts
```

Persistent data:

```text
/opt/data
```

---

## Docker Network

All services connect to shared reverse proxy network:

```text
edge
```

Create manually if starting fresh:

```bash
docker network create edge
```

---

## Deployment

Recommended deployment method:

```bash
sudo /opt/scripts/docker-update.sh
```

This script updates and redeploys all Docker stacks.

For full system maintenance (host + containers):

```bash
sudo chmod +x /opt/scripts/update/run-updates.sh
sudo /opt/scripts/update/run-updates.sh
```

Important:

- Do not run Bash scripts with `sh`.
- `run-updates.sh` must be executed directly or with `bash`.
- On a recovered host, ensure the script is executable before first use.

---

## Bootstrap (Fresh Server Setup)

Fully rebuild server:

```bash
sudo /opt/stacks-repo/scripts/bootstrap.sh
```

This script will:

- Install Docker
- Create required folders
- Fix permissions
- Create Docker network
- Deploy all stacks

---

## Backup Strategy

Backup tool: Duplicati

Backed up data:

```text
/opt/data
/opt/stacks-repo
```

Destination:

```text
/mnt/nas/backup
```

This enables full disaster recovery.

---

## Restore Procedure

On new server:

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
sudo ln -s /opt/stacks-repo/stacks /opt/stacks
sudo ln -s /opt/stacks-repo/scripts /opt/scripts
```

Verify scripts path:

```bash
ls -l /opt/scripts
ls -l /opt/scripts/update
```

Set required permissions:

```bash
sudo chmod +x /opt/scripts/bootstrap.sh
sudo chmod +x /opt/scripts/docker-update.sh
sudo chmod +x /opt/scripts/update/run-updates.sh
```

Create network:

```bash
docker network create edge
```

Deploy Docker stacks:

```bash
sudo /opt/scripts/docker-update.sh
```

Run full system maintenance:

```bash
sudo /opt/scripts/update/run-updates.sh
```

Important execution rule:

```bash
sudo /opt/scripts/update/run-updates.sh
```

Do not use:

```bash
sudo sh /opt/scripts/update/run-updates.sh
```

If executed with `sh`, the script may fail because `sh` does not support Bash options such as `set -o pipefail`.

---

## Monitoring Stack

Prometheus:

```text
https://prometheus.home
```

Grafana:

```text
https://grafana.home
```

Uptime Kuma:

```text
https://kuma.home
```

---

## Management Interfaces

Traefik Dashboard:

```text
https://traefik.home
```

Portainer:

```text
https://portainer.home
```

Cockpit:

```text
https://server.home:9090
```

---

## Git Workflow

Make infrastructure changes:

```bash
cd /opt/stacks-repo

git add .
git commit -m "Infrastructure update"
git push
```

Deploy changes:

```bash
sudo /opt/scripts/docker-update.sh
```

---

## System Maintenance

System updates are modularized to keep operations simple and maintainable.

Update workflow:

```bash
sudo chmod +x /opt/scripts/update/run-updates.sh
sudo /opt/scripts/update/run-updates.sh
```

This orchestrator executes sequential maintenance modules:

Before first use on a rebuilt or recovered host, ensure the script is executable and run it directly with `sudo`.

- Host OS updates (APT packages)
- Docker image refresh and container recreation
- Optional cleanup tasks

Architecture:

- `lib/common.sh` → shared logging and helper functions
- `modules/10-host-update.sh` → operating system patching
- `modules/20-docker-update.sh` → container updates
- `modules/30-cleanup.sh` → maintenance cleanup

Logs are written to:

```bash
/var/log/system_updates
```

This modular design allows individual maintenance components to evolve independently while keeping the operational entrypoint simple.

---

## Security Model

- No direct container exposure
- Reverse proxy controlled access
- TLS encryption via Traefik
- Persistent volumes isolated
- Git‑based audit trail

---

## Disaster Recovery

Full recovery requires only:

- Server
- Docker
- Git access
- NAS backup

Recovery time: < 10 minutes

---

## Maintainer

Sérgio Ribeiro

Homelab Architecture: Docker + Traefik + GitOps‑lite
