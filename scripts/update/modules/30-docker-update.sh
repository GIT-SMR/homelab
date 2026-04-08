#!/usr/bin/env bash
set -Eeuo pipefail

DOCKER_STACKS=(
    "/opt/stacks/backup"
    "/opt/stacks/home"
    "/opt/stacks/infra"
    "/opt/stacks/monitoring"
)

run_docker_update() {
    log "=== DOCKER UPDATE STARTED ==="

    for stack in "${DOCKER_STACKS[@]}"; do
        if [[ -f "$stack/compose.yml" || -f "$stack/docker-compose.yml" ]]; then
            log "Processing stack: $stack"
            cd "$stack"

            run_cmd "Pulling latest images in $stack." docker compose pull
            run_cmd "Recreating containers in $stack." docker compose up -d
        else
            log "Skipping $stack - no compose file found."
        fi
    done

    run_cmd "Pruning unused Docker images." docker image prune -af
    log "=== DOCKER UPDATE COMPLETED ==="
}