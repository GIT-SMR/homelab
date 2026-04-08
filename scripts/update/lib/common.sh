#!/usr/bin/env bash
set -Eeuo pipefail

LOGDIR="/var/log/system_updates"
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
LOGFILE="${LOGFILE:-$LOGDIR/update_${TIMESTAMP}.log}"
LOCKFILE="/var/run/server-update.lock"

init_logging() {
    mkdir -p "$LOGDIR"
    touch "$LOGFILE"
    chmod 644 "$LOGFILE"
}

log() {
    local msg="${1:-}"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ${msg}" | tee -a "$LOGFILE"
}

fail() {
    local msg="${1:-Unknown error}"
    log "ERROR: $msg"
    exit 1
}

run_cmd() {
    local description="$1"
    shift
    log "$description"
    if ! "$@" 2>&1 | tee -a "$LOGFILE"; then
        local status=${PIPESTATUS[0]:-$?}
        log "Command failed with exit code $status: $*"
        exit "$status"
    fi
}

cleanup_old_logs() {
    find "$LOGDIR" -type f -name "update_*.log" -mtime +60 -delete || true
    log "Old logs cleanup completed."
}

acquire_lock() {
    if [[ -e "$LOCKFILE" ]]; then
        fail "Another update process appears to be running: $LOCKFILE exists."
    fi
    touch "$LOCKFILE"
}

release_lock() {
    rm -f "$LOCKFILE"
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        fail "This script must be run as root."
    fi
}
