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

            local running_services
            running_services="$(docker compose ps --services --filter "status=running")"
            if [[ -z "$running_services" ]]; then
                log "Skipping $stack - no running services."
                continue
            fi

            local -a services
            mapfile -t services <<< "$running_services"
            log "Running services in $stack: ${services[*]}"
            run_cmd "Pulling latest images for running services in $stack." docker compose pull "${services[@]}"
            run_cmd "Recreating running services in $stack." docker compose up -d --no-deps "${services[@]}"
        else
            log "Skipping $stack - no compose file found."
        fi
    done

    run_cmd "Pruning unused Docker images." docker image prune -af
    log "=== DOCKER UPDATE COMPLETED ==="
}
