#!/usr/bin/env bash
set -Eeuo pipefail

run_git_pull() {
    log "=== GIT PULL STARTED ==="

    # Pull latest changes for in repository
    run_cmd "Pulling latest changes on git." git pull

    log "=== GIT PULL COMPLETED ==="
}