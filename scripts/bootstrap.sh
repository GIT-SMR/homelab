#!/usr/bin/env bash
set -euo pipefail

# Homelab bootstrap (Ubuntu + Docker + GitOps-lite)
# - Installs prerequisites (git, curl)
# - Installs Docker Engine + Compose plugin (Ubuntu packages)
# - Creates /opt structure and shared 'edge' network
# - Clones/updates homelab repo into /opt/stacks-repo
# - Creates /opt/stacks symlinks to repo stacks
# - Deploys infra first, then all stacks
#
# Usage:
#   sudo bash bootstrap.sh git@github.com:GIT-SMR/homelab.git
# Optional env:
#   REPO_DIR=/opt/stacks-repo
#   STACKS_DIR=/opt/stacks
#   BRANCH=main

REPO_URL="${1:-}"
if [[ -z "${REPO_URL}" ]]; then
  echo "ERROR: Missing repo URL."
  echo "Example: sudo bash bootstrap.sh git@github.com:GIT-SMR/homelab.git"
  exit 1
fi

REPO_DIR="${REPO_DIR:-/opt/stacks-repo}"
STACKS_DIR="${STACKS_DIR:-/opt/stacks}"
DATA_DIR="${DATA_DIR:-/opt/data}"
BRANCH="${BRANCH:-main}"

echo "==> Installing prerequisites"
apt-get update -y
apt-get install -y git curl ca-certificates gnupg lsb-release

echo "==> Installing Docker (Ubuntu packages)"
apt-get install -y docker.io docker-compose-plugin
systemctl enable --now docker

echo "==> Creating base directories"
mkdir -p "${REPO_DIR}" "${STACKS_DIR}" "${DATA_DIR}"
chown -R "${SUDO_USER:-root}:${SUDO_USER:-root}" "${REPO_DIR}" || true
chown -R "${SUDO_USER:-root}:${SUDO_USER:-root}" "${STACKS_DIR}" || true

echo "==> Ensuring shared Docker network 'edge' exists"
docker network inspect edge >/dev/null 2>&1 || docker network create edge

echo "==> Cloning/updating repo into ${REPO_DIR}"
if [[ -d "${REPO_DIR}/.git" ]]; then
  git -C "${REPO_DIR}" fetch --all --prune
  git -C "${REPO_DIR}" checkout "${BRANCH}"
  git -C "${REPO_DIR}" pull --rebase
else
  rm -rf "${REPO_DIR:?}"/*
  git clone --branch "${BRANCH}" "${REPO_URL}" "${REPO_DIR}"
fi

echo "==> Creating /opt/stacks symlinks"
# Remove any existing entries (symlinks) that conflict
for d in infra home monitoring backup; do
  if [[ -e "${STACKS_DIR}/${d}" || -L "${STACKS_DIR}/${d}" ]]; then
    rm -rf "${STACKS_DIR:?}/${d}"
  fi
done

ln -s "${REPO_DIR}/stacks/infra"      "${STACKS_DIR}/infra"
ln -s "${REPO_DIR}/stacks/home"       "${STACKS_DIR}/home"
ln -s "${REPO_DIR}/stacks/monitoring" "${STACKS_DIR}/monitoring"
ln -s "${REPO_DIR}/stacks/backup"     "${STACKS_DIR}/backup"

echo "==> Deploying infra first (Traefik, Portainer, Dozzle)"
docker compose -f "${STACKS_DIR}/infra/compose.yml" pull
docker compose -f "${STACKS_DIR}/infra/compose.yml" up -d

echo "==> Deploying remaining stacks"
for dir in "${STACKS_DIR}"/*; do
  if [[ -f "${dir}/compose.yml" && "${dir}" != "${STACKS_DIR}/infra" ]]; then
    echo "----> ${dir}"
    docker compose -f "${dir}/compose.yml" pull
    docker compose -f "${dir}/compose.yml" up -d
  fi
done

echo "==> Done."
echo "Next checks:"
echo "  docker ps"
echo "  curl -I http://10.10.10.5 -H 'Host: traefik.local'"
