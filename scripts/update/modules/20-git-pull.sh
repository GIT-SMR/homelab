#!/usr/bin/env bash
set -Eeuo pipefail

run_git_pull() {
    log "=== GIT PULL STARTED ==="

    local repo_dir="${STACKS_REPO_DIR:-}"

    if [[ -n "$repo_dir" && ! -d "$repo_dir/.git" ]]; then
        log "Configured STACKS_REPO_DIR ($repo_dir) is not a git repository. Falling back to auto-detection."
        repo_dir=""
    fi

    if [[ -z "$repo_dir" ]]; then
        if git -C "$PWD" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            repo_dir="$(git -C "$PWD" rev-parse --show-toplevel)"
        else
            fail "Unable to determine git repository. Set STACKS_REPO_DIR or run the script from inside a git repo."
        fi
    fi

    local git_args=(git -C "$repo_dir" pull --ff-only)

    if [[ "${EUID}" -eq 0 && "${STACKS_REPO_USER:-root}" != "root" ]]; then
        run_cmd "Pulling latest changes in $repo_dir as ${STACKS_REPO_USER}." sudo -H -u "$STACKS_REPO_USER" "${git_args[@]}"
    else
        run_cmd "Pulling latest changes in $repo_dir." "${git_args[@]}"
    fi

    log "=== GIT PULL COMPLETED ==="
}
