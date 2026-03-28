#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

lock_dir="$(acquire_lock memory-sync || true)"
if [ -z "${lock_dir:-}" ]; then
  exit 0
fi
trap 'release_lock "$lock_dir"' EXIT

run_id="$(date +"%Y%m%dT%H%M%S")"
CURRENT_LOG_FILE="$AUTODEV_LOG_DIR/memory-sync-$run_id.log"

snapshot=$(
  cat <<EOF
Branch: $(current_branch)

Git status:
$(repo_status_short)

Recent commits:
$(repo_recent_commits)
EOF
)

refresh_steering_state >/dev/null
refresh_semantic_memory
refresh_active_memory
refresh_skill_memory >/dev/null
refresh_memory_backend >/dev/null
refresh_memory_retrieval "$(current_focus_label || true)" >/dev/null
printf '%s\n' "$snapshot" > "$AUTODEV_STATE_DIR/latest-snapshot.txt"
append_daily_section "Memory sync" "$snapshot"
log_line "Memory snapshot and structured memory surfaces updated."
