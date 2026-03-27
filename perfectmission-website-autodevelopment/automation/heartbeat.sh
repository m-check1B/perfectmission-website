#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

lock_dir="$(acquire_lock heartbeat || true)"
if [ -z "${lock_dir:-}" ]; then
  exit 0
fi
trap 'release_lock "$lock_dir"' EXIT

run_id="$(date +"%Y%m%dT%H%M%S")"
CURRENT_LOG_FILE="$AUTODEV_LOG_DIR/heartbeat-$run_id.log"

if ! require_active_window "heartbeat" "$AUTODEV_HEARTBEAT_ACTIVE_START" "$AUTODEV_HEARTBEAT_ACTIVE_END" "Heartbeat skipped"; then
  exit 0
fi

adapter="$(detect_adapter || printf 'none')"
branch="$(current_branch)"
status_file="$AUTODEV_STATE_DIR/last-cycle-status.txt"
last_status="unknown"
if [ -f "$status_file" ]; then
  last_status="$(cat "$status_file")"
fi

body=$(
  cat <<EOF
Project: $PROJECT_NAME
Branch: $branch
Adapter: $adapter
Automation enabled: $AUTODEV_ENABLED
Auto commit: $AUTODEV_AUTO_COMMIT
Cycle hours: $(window_label "$AUTODEV_ACTIVE_START" "$AUTODEV_ACTIVE_END")
Heartbeat hours: $(window_label "$AUTODEV_HEARTBEAT_ACTIVE_START" "$AUTODEV_HEARTBEAT_ACTIVE_END")
Last cycle status: $last_status

Git status:
$(repo_status_short)

Recent commits:
$(repo_recent_commits)
EOF
)

printf '%s\n' "$body" > "$AUTODEV_STATE_DIR/heartbeat-latest.txt"
append_daily_section "Heartbeat" "$body"
log_line "Heartbeat written."
