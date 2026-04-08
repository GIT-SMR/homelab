#!/usr/bin/env bash
set -Eeuo pipefail

run_cleanup() {
    log "=== GENERAL CLEANUP STARTED ==="
    run_cmd "Pruning unused Docker volumes." docker volume prune -f
    log "=== GENERAL CLEANUP COMPLETED ==="
}