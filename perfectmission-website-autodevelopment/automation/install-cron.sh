#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

start="# BEGIN AUTODEV $AUTODEV_ID"
end="# END AUTODEV $AUTODEV_ID"
existing="$(mktemp)"
filtered="$(mktemp)"

(crontab -l 2>/dev/null || true) > "$existing"

awk -v start="$start" -v end="$end" '
  $0 == start {skip=1; next}
  $0 == end {skip=0; next}
  !skip {print}
' "$existing" > "$filtered"

{
  cat "$filtered"
  printf '%s\n' "$start"
  printf '%s * * * * /bin/bash %q >> %q 2>&1\n' "$AUTODEV_DOCTOR_MINUTE" "$AUTODEV_ROOT/automation/doctor.sh" "$AUTODEV_LOG_DIR/cron.log"
  if [ "$AUTODEV_REMEDIATOR_ENABLED" = "true" ]; then
    printf '%s * * * * /bin/bash %q >> %q 2>&1\n' "$AUTODEV_REMEDIATOR_MINUTE" "$AUTODEV_ROOT/automation/remediator.sh" "$AUTODEV_LOG_DIR/cron.log"
  fi
  printf '*/%s * * * * /bin/bash %q >> %q 2>&1\n' "$AUTODEV_MEMORY_INTERVAL_MINUTES" "$AUTODEV_ROOT/automation/memory-sync.sh" "$AUTODEV_LOG_DIR/cron.log"
  printf '%s * * * * /bin/bash %q >> %q 2>&1\n' "$AUTODEV_HEARTBEAT_MINUTE" "$AUTODEV_ROOT/automation/heartbeat.sh" "$AUTODEV_LOG_DIR/cron.log"
  printf '*/%s * * * * /bin/bash %q >> %q 2>&1\n' "$AUTODEV_RUN_INTERVAL_MINUTES" "$AUTODEV_ROOT/automation/cycle.sh" "$AUTODEV_LOG_DIR/cron.log"
  printf '%s\n' "$end"
} | crontab -

rm -f "$existing" "$filtered"
printf 'Installed cron block for %s\n' "$AUTODEV_ID"
