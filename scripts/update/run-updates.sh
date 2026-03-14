#!/usr/bin/env bash
set -Eeuo pipefail

BASE_DIR="/opt/scripts/update"
export LOGFILE=""

source "$BASE_DIR/lib/common.sh"
source "$BASE_DIR/modules/10-host-update.sh"
source "$BASE_DIR/modules/20-docker-update.sh"
source "$BASE_DIR/modules/30-cleanup.sh"

trap 'release_lock' EXIT

main() {
    require_root
    init_logging
    acquire_lock
    cleanup_old_logs

    log "===== SERVER UPDATE WORKFLOW STARTED ====="

    run_host_update
    run_docker_update
    run_cleanup

    if [[ -f /var/run/reboot-required ]]; then
        log "Reboot required."
        log "===== SERVER UPDATE WORKFLOW COMPLETED ====="
        # comment the next line for no automatic reboot
        reboot
    else
        log "No reboot required."
        log "===== SERVER UPDATE WORKFLOW COMPLETED ====="
    fi
}

main "$@"