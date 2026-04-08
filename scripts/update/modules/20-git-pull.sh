#!/usr/bin/env bash
set -Eeuo pipefail

run_git_pull() {
    log "=== GIT PULL STARTED ==="

    local repo_dir
    repo_dir="$(dirname "$BASE_DIR")"

    if [[ ! -d "$repo_dir/.git" ]]; then
        fail "Unable to run git pull: $repo_dir is not a git repository."
    fi

    # Pull latest changes for the repository even if this script is invoked elsewhere
    run_cmd "Pulling latest changes in $repo_dir." git -C "$repo_dir" pull

    log "=== GIT PULL COMPLETED ==="
}
