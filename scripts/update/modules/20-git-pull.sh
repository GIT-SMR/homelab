#!/usr/bin/env bash
set -Eeuo pipefail

run_git_pull() {
    log "=== GIT PULL STARTED ==="

    local repo_dir="/opt/stacks-repo"

    if [[ -n "$repo_dir" ]]; then
        if [[ ! -d "$repo_dir/.git" ]]; then
            fail "Unable to run git pull: $repo_dir is not a git repository."
        fi
    else
        if git -C "$PWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            repo_dir="$(git -C "$PWD" rev-parse --show-toplevel)"
        else
            fail "Unable to determine git repository. Set STACKS_REPO_DIR or run the script from inside a git repo."
        fi
    fi

    # Pull latest changes for the determined repository
    run_cmd "Pulling latest changes in $repo_dir." git -C "$repo_dir" pull --ff-only

    log "=== GIT PULL COMPLETED ==="
}
