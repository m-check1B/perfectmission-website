#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs
refresh_stats_reports

if [ "${1:-}" = "--quiet" ]; then
  exit 0
fi

cat "$AUTODEV_STATS_MD_FILE"
