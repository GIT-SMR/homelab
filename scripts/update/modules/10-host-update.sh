#!/usr/bin/env bash
set -Eeuo pipefail

run_host_update() {
    log "=== HOST UPDATE STARTED ==="

    run_cmd "Updating apt package lists." apt-get update
    run_cmd "Upgrading installed packages." apt-get full-upgrade -y
    run_cmd "Removing unnecessary packages." apt-get autoremove -y
    run_cmd "Cleaning apt cache." apt-get autoclean -y

    log "=== HOST UPDATE COMPLETED ==="
}