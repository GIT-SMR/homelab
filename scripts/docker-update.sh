#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/opt/stacks-repo"

echo "Pulling latest from Git..."
cd "$REPO_DIR"
git pull --rebase

echo "Updating running services only..."
for dir in /opt/stacks/*; do
  if [[ -f "$dir/compose.yml" ]]; then
    echo "Processing $dir"
    cd "$dir"

    running_services="$(docker compose ps --services --filter "status=running")"
    if [[ -z "$running_services" ]]; then
      echo "Skipping $dir - no running services."
      continue
    fi

    mapfile -t services <<< "$running_services"
    echo "Updating running services in $dir: ${services[*]}"
    docker compose pull "${services[@]}"
    docker compose up -d --no-deps "${services[@]}"
  fi
done

echo "Done."
