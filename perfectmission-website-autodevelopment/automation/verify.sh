#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

lock_dir="$(acquire_lock verify || true)"
if [ -z "${lock_dir:-}" ]; then
  exit 0
fi
trap 'release_lock "$lock_dir"' EXIT

run_id="$(date +"%Y%m%dT%H%M%S")"
CURRENT_LOG_FILE="$AUTODEV_LOG_DIR/verify-$run_id.log"

suite_status=0
suite_report="$(run_verification_suite "$run_id")" || suite_status=$?

if [ -z "$suite_report" ]; then
  suite_report="No verification hooks configured."
fi

if [ "$suite_status" -eq 0 ]; then
  log_line "Verification completed successfully."
  append_daily_section "Verification (success)" "$suite_report"
  printf '%s\n' "$suite_report"
  exit 0
fi

log_line "Verification failed."
append_daily_section "Verification (failure)" "$suite_report"
printf '%s\n' "$suite_report"
exit 1
