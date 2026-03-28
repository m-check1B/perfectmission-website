#!/bin/bash
# linear-sync.sh — Call the packaged Linear sync helper with pull, push, or sync.

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

action="${1:-sync}"
case "$action" in
  pull|push|sync) ;;
  *)
    printf 'Usage: %s [pull|push|sync]\n' "$0" >&2
    exit 2
    ;;
esac

lock_dir="$(acquire_lock linear-sync || true)"
if [ -z "${lock_dir:-}" ]; then
  exit 0
fi
trap 'release_lock "$lock_dir"' EXIT

# Source Linear API key from .zshrc if not in environment
if [ -z "${LINEAR_API_KEY:-}" ]; then
  LINEAR_API_KEY="$(grep -m1 '^export LINEAR_API_KEY=' ~/.zshrc 2>/dev/null | sed 's/export LINEAR_API_KEY=//' | tr -d '"' | tr -d "'")" || true
  export LINEAR_API_KEY
fi

if [ -z "${LINEAR_API_KEY:-}" ]; then
  log_line "linear-sync: skipped (LINEAR_API_KEY not set)"
  exit 0
fi

# Source team config
if [ -z "${LINEAR_TEAM_KEY:-}" ]; then
  LINEAR_TEAM_KEY="$(grep -m1 '^export LINEAR_TEAM_KEY=' ~/.zshrc 2>/dev/null | sed 's/export LINEAR_TEAM_KEY=//' | tr -d '"' | tr -d "'")" || true
  export LINEAR_TEAM_KEY
fi
if [ -z "${LINEAR_TEAM_ID:-}" ]; then
  LINEAR_TEAM_ID="$(grep -m1 '^export LINEAR_TEAM_ID=' ~/.zshrc 2>/dev/null | sed 's/export LINEAR_TEAM_ID=//' | tr -d '"' | tr -d "'")" || true
  export LINEAR_TEAM_ID
fi

LINEAR_SYNC_SCRIPT="${AUTODEV_SCRIPT_DIR}/linear-sync.py"

if [ ! -f "$LINEAR_SYNC_SCRIPT" ]; then
  log_line "linear-sync: skipped (linear-sync.py not found)"
  exit 0
fi

if [ -z "${LINEAR_TEAM_ID:-}" ] && [ -z "${LINEAR_TEAM_KEY:-}" ]; then
  log_line "linear-sync: skipped (LINEAR_TEAM_ID or LINEAR_TEAM_KEY not set)"
  exit 0
fi

run_id="$(date +"%Y%m%dT%H%M%S")"
CURRENT_LOG_FILE="$AUTODEV_LOG_DIR/linear-sync-$run_id.log"

output="$(python3 "$LINEAR_SYNC_SCRIPT" "$action" --autodev-root "$AUTODEV_ROOT" 2>&1)"

append_daily_section "Linear sync" "$output"
log_line "linear-sync: ${action} completed"
printf '%s\n' "$output"
