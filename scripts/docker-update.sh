#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/opt/stacks-repo"

echo "Pulling latest from Git..."
cd "$REPO_DIR"
git pull --rebase

echo "Updating all stacks..."
for dir in /opt/stacks/*; do
  if [[ -f "$dir/compose.yml" ]]; then
    echo "Updating $dir"
    docker compose -f "$dir/compose.yml" pull
    docker compose -f "$dir/compose.yml" up -d
  fi
done

echo "Done."
