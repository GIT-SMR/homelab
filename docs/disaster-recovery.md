# Disaster Recovery Runbook (Homelab)

This document describes how to rebuild the homelab from scratch after a host failure, OS reinstall, or disk replacement.

## Scope

- Host: Ubuntu 24.04 LTS
- Runtime: Docker Engine + Compose v2 plugin
- Stacks: Traefik (reverse proxy), Portainer, Dozzle, Home Assistant, ESPHome, Uptime Kuma, Duplicati
- Source of truth: Git repository (`/opt/stacks-repo`)
- Persistent data: `/opt/data`
- Backup target: Synology NAS (mounted under `/mnt/nas/backup`)

---

## 0) What you need before you start

- SSH access to the rebuilt server
- Access to your Git repo (SSH key or HTTPS token)
- Your NAS credentials / mount method (CIFS/NFS)
- Backup set available on NAS (Duplicati)
- Any local TLS material if you keep custom certs (optional; Traefik can regenerate self-signed if that’s your current model)

---

## 1) Reinstall the OS

1. Install Ubuntu 24.04 LTS
2. Set a static IP or DHCP reservation (recommended)
3. Ensure DNS resolution works

Verify:

```bash
ping -c2 1.1.1.1
ping -c2 google.com
```

---

## 2) Install Docker

Recommended (Ubuntu packages):

```bash
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo systemctl enable --now docker
```

(Optional) Allow your user to run Docker without sudo:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

---

## 3) Restore Git-managed infrastructure

### Option A: Run bootstrap script (fastest)

```bash
sudo bash bootstrap.sh git@github.com:GIT-SMR/homelab.git
```

This will:
- ensure `/opt/stacks-repo`, `/opt/stacks`, `/opt/data`
- ensure Docker network `edge`
- clone repo
- create symlinks under `/opt/stacks`
- deploy infra first, then the remaining stacks

### Option B: Manual restore

```bash
sudo mkdir -p /opt/stacks-repo /opt/stacks /opt/data
sudo chown -R $USER:$USER /opt/stacks-repo /opt/stacks
git clone git@github.com:GIT-SMR/homelab.git /opt/stacks-repo

docker network inspect edge >/dev/null 2>&1 || docker network create edge

ln -s /opt/stacks-repo/stacks/infra      /opt/stacks/infra
ln -s /opt/stacks-repo/stacks/home       /opt/stacks/home
ln -s /opt/stacks-repo/stacks/monitoring /opt/stacks/monitoring
ln -s /opt/stacks-repo/stacks/backup     /opt/stacks/backup
```

Deploy:

```bash
docker compose -f /opt/stacks/infra/compose.yml up -d
/opt/scripts/docker-update.sh
```

---

## 4) Restore persistent data from NAS (Duplicati)

### 4.1 Mount the NAS on the host

Your desired mapping:
- `//NAS/backup`  → `/mnt/nas/backup`  → `/backup` (inside Duplicati container)

Create mount point:

```bash
sudo mkdir -p /mnt/nas/backup
```

Mount (CIFS example):

```bash
sudo apt install -y cifs-utils
sudo mount -t cifs //NAS/backup /mnt/nas/backup -o username=YOURUSER,vers=3.0
```

> Tip: store credentials in `/etc/samba/credentials` and use `/etc/fstab` for persistence.

### 4.2 Restore using Duplicati

1. Start Duplicati stack if not running:
   ```bash
   docker compose -f /opt/stacks/backup/compose.yml up -d
   ```
2. Open Duplicati UI (via Traefik): `https://duplicati.local`
3. Use **Restore**:
   - Source: `/backup` (your NAS mount inside container)
   - Choose the latest backup versions
   - Restore into `/restore` (temporary) or directly back into `/source/...` if you are confident

Recommended restore targets:
- `/opt/data/homeassistant`
- `/opt/data/esphome`
- `/opt/stacks-repo` (if you back it up too; usually Git is enough)

---

## 5) Validate services

### 5.1 Containers healthy
```bash
docker ps
```

### 5.2 Core URLs
- Traefik: `https://traefik.local`
- Portainer: `https://portainer.local` (if configured)
- Dozzle: `https://dozzle.local`
- Home Assistant: `http://HOMEASSISTANT_IP:8123` (host-mode)
- ESPHome: `https://esphome.local`
- Uptime Kuma: `https://kuma.local`
- Duplicati: `https://duplicati.local`

### 5.3 HomeKit bridge
If you use HA → HomeKit, verify the bridge entities respond after restore. If not:
- restart HA container
- re-check HA HomeKit integration and pairing on iOS

---

## 6) Rollback plan (if a change broke the system)

1. Check Git history:
   ```bash
   cd /opt/stacks-repo
   git log --oneline --max-count=20
   ```
2. Reset to a known good commit:
   ```bash
   git reset --hard <COMMIT>
   ```
3. Redeploy:
   ```bash
   /opt/scripts/docker-update.sh
   ```

---

## 7) Post-DR hardening checklist

- [ ] Verify firewall rules (Cockpit 9090 restricted to LAN)
- [ ] Confirm `edge` network exists and Traefik is routing
- [ ] Confirm backups run and test a small restore
- [ ] Pin critical images to versions (avoid `latest` for key services)
- [ ] Document secrets handling (`.env` not committed)
