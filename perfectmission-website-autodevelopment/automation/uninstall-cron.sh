#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

start="# BEGIN AUTODEV $AUTODEV_ID"
end="# END AUTODEV $AUTODEV_ID"
existing="$(mktemp)"

(crontab -l 2>/dev/null || true) > "$existing"

awk -v start="$start" -v end="$end" '
  $0 == start {skip=1; next}
  $0 == end {skip=0; next}
  !skip {print}
' "$existing" | crontab -

rm -f "$existing"
printf 'Removed cron block for %s\n' "$AUTODEV_ID"

