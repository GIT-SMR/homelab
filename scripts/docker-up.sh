#!/usr/bin/env bash
set -euo pipefail

echo "Starting all services in all Docker stacks."
echo "This is an intentional full-start script and may start stopped containers."

for dir in /opt/stacks/*; do
  if [[ -f "$dir/compose.yml" ]]; then
    echo "Starting all services in $dir"
    docker compose -f "$dir/compose.yml" up -d
  fi
done

echo "Done."
