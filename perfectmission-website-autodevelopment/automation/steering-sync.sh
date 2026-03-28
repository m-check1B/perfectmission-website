#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

lock_dir="$(acquire_lock steering-sync || true)"
if [ -z "${lock_dir:-}" ]; then
  exit 0
fi
trap 'release_lock "$lock_dir"' EXIT

run_id="$(date +"%Y%m%dT%H%M%S")"
CURRENT_LOG_FILE="$AUTODEV_LOG_DIR/steering-sync-$run_id.log"

linear_pull_output=""
if [ -f "$AUTODEV_SCRIPT_DIR/linear-sync.sh" ]; then
  linear_pull_output="$("$AUTODEV_SCRIPT_DIR/linear-sync.sh" pull 2>&1)" || log_line "linear-sync pull: non-fatal error"
fi

result="$(refresh_steering_state)"
refresh_active_memory

linear_push_output=""
if [ -f "$AUTODEV_SCRIPT_DIR/linear-sync.sh" ]; then
  linear_push_output="$("$AUTODEV_SCRIPT_DIR/linear-sync.sh" push 2>&1)" || log_line "linear-sync push: non-fatal error"
fi

combined_result="$result"
if [ -n "$linear_pull_output" ]; then
  combined_result="${combined_result}"$'\n\n'"Linear pull:"$'\n'"${linear_pull_output}"
fi
if [ -n "$linear_push_output" ]; then
  combined_result="${combined_result}"$'\n\n'"Linear push:"$'\n'"${linear_push_output}"
fi

append_daily_section "Steering sync" "$combined_result"
log_line "Steering state refreshed."
