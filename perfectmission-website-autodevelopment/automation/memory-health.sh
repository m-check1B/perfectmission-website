#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

lock_dir="$(acquire_lock memory-health || true)"
if [ -z "${lock_dir:-}" ]; then
  exit 0
fi
trap 'release_lock "$lock_dir"' EXIT

run_id="$(date +"%Y%m%dT%H%M%S")"
CURRENT_LOG_FILE="$AUTODEV_LOG_DIR/memory-health-$run_id.log"

health="healthy"
report=""
hindsight_banks_json=""

add_report() {
  report="${report}$1"$'\n'
}

mark_degraded() {
  if [ "$health" = "healthy" ]; then
    health="degraded"
  fi
}

mark_failing() {
  health="failing"
}

http_get() {
  local url="$1"
  curl -fsS --max-time "$AUTODEV_MEMORY_HEALTH_HTTP_TIMEOUT_SECONDS" "$url"
}

check_backend_contract() {
  if [ "$AUTODEV_MEMORY_BACKEND" = "hindsight" ] || [ "$AUTODEV_MEMORY_BACKEND" = "hindsight-hybrid" ]; then
    add_report "memory-backend: ok ($AUTODEV_MEMORY_BACKEND)"
    return
  fi
  mark_failing
  add_report "memory-backend: nonstandard ($AUTODEV_MEMORY_BACKEND)"
}

check_hindsight_api() {
  local endpoint="$AUTODEV_MEMORY_HINDSIGHT_API_URL/v1/default/banks"
  if hindsight_banks_json="$(http_get "$endpoint" 2>/dev/null)"; then
    add_report "hindsight-api: ok ($AUTODEV_MEMORY_HINDSIGHT_API_URL)"
    return
  fi
  mark_failing
  add_report "hindsight-api: unreachable ($AUTODEV_MEMORY_HINDSIGHT_API_URL)"
}

check_openclaw() {
  local mode="$AUTODEV_MEMORY_HEALTH_OPENCLAW_MODE"
  local listing=""
  local plugin="$AUTODEV_MEMORY_HEALTH_OPENCLAW_PLUGIN"

  if [ "$mode" = "off" ]; then
    add_report "openclaw: skipped"
    return
  fi

  if ! command -v openclaw >/dev/null 2>&1; then
    if [ "$mode" = "required" ]; then
      mark_failing
      add_report "openclaw: missing"
    else
      add_report "openclaw: unavailable"
    fi
    return
  fi

  if ! listing="$(openclaw plugins list 2>/dev/null)"; then
    if [ "$mode" = "required" ]; then
      mark_failing
    else
      mark_degraded
    fi
    add_report "openclaw: plugin listing failed"
    return
  fi

  if printf '%s\n' "$listing" | grep -F "$plugin" | grep -F "loaded" >/dev/null 2>&1; then
    add_report "openclaw: ok ($plugin loaded)"
    return
  fi

  if [ "$mode" = "required" ]; then
    mark_failing
  else
    mark_degraded
  fi
  add_report "openclaw: plugin not loaded ($plugin)"
}

check_backend_status() {
  local age status indexed_count indexed_at bank_id hindsight_status document_count

  if [ ! -f "$AUTODEV_MEMORY_BACKEND_STATUS_FILE" ]; then
    mark_failing
    add_report "bank-sync: missing status file"
    return
  fi

  age="$(file_age_minutes "$AUTODEV_MEMORY_BACKEND_STATUS_FILE")"
  status="$(memory_backend_status_field status || true)"
  indexed_count="$(memory_backend_status_field indexed_count || true)"
  indexed_at="$(memory_backend_status_field indexed_at || true)"
  bank_id="$(python3 - "$AUTODEV_MEMORY_BACKEND_STATUS_FILE" <<'PY'
from pathlib import Path
import json
import sys

payload = json.loads(Path(sys.argv[1]).read_text() or "{}")
print(((payload.get("hindsight") or {}).get("bank_id")) or "")
PY
)"
  hindsight_status="$(python3 - "$AUTODEV_MEMORY_BACKEND_STATUS_FILE" <<'PY'
from pathlib import Path
import json
import sys

payload = json.loads(Path(sys.argv[1]).read_text() or "{}")
print(((payload.get("hindsight") or {}).get("status")) or "")
PY
)"
  document_count="$(python3 - "$AUTODEV_MEMORY_BACKEND_STATUS_FILE" <<'PY'
from pathlib import Path
import json
import sys

payload = json.loads(Path(sys.argv[1]).read_text() or "{}")
value = (payload.get("hindsight") or {}).get("document_count")
print("" if value is None else value)
PY
)"

  if [ "$age" -gt "$AUTODEV_DOCTOR_MAX_MEMORY_AGE_MINUTES" ]; then
    mark_degraded
    add_report "bank-sync: stale (${age}m old)"
  fi

  if [ "$status" != "ok" ] || [ "$hindsight_status" != "ok" ]; then
    mark_failing
    add_report "bank-sync: failing (status=${status:-unknown}, hindsight=${hindsight_status:-unknown})"
    return
  fi

  add_report "bank-sync: ok (bank=${bank_id:-unknown}, docs=${document_count:-0}, indexed=${indexed_count:-0}, indexed_at=${indexed_at:-unknown})"

  if [ -n "$hindsight_banks_json" ] && [ -n "$bank_id" ]; then
    if python3 - "$bank_id" <<'PY' <<<"$hindsight_banks_json"
import json
import sys

bank_id = sys.argv[1]
payload = json.load(sys.stdin)
banks = payload.get("banks") or []
raise SystemExit(0 if any(bank.get("bank_id") == bank_id for bank in banks if isinstance(bank, dict)) else 1)
PY
    then
      add_report "hindsight-bank: present ($bank_id)"
    else
      mark_failing
      add_report "hindsight-bank: missing ($bank_id)"
    fi
  fi
}

check_swarm() {
  if [ -z "$AUTODEV_MEMORY_HEALTH_SWARM_URL" ]; then
    add_report "swarm: skipped"
    return
  fi

  if http_get "$AUTODEV_MEMORY_HEALTH_SWARM_URL" >/dev/null 2>&1; then
    add_report "swarm: ok ($AUTODEV_MEMORY_HEALTH_SWARM_URL)"
    return
  fi

  mark_failing
  add_report "swarm: unreachable ($AUTODEV_MEMORY_HEALTH_SWARM_URL)"
}

check_backend_contract
check_hindsight_api
check_openclaw
check_backend_status
check_swarm

memory_health_report=$(
  cat <<EOF
Project: $PROJECT_NAME
Health: $health
Generated: $(timestamp_utc)
Backend: $AUTODEV_MEMORY_BACKEND
Hindsight API: $AUTODEV_MEMORY_HINDSIGHT_API_URL

$report
EOF
)

printf '%s\n' "$health" > "$AUTODEV_MEMORY_HEALTH_STATUS_FILE"
printf '%s\n' "$memory_health_report" > "$AUTODEV_MEMORY_HEALTH_REPORT_FILE"
python3 - "$AUTODEV_MEMORY_HEALTH_JSON_FILE" "$health" "$PROJECT_NAME" "$AUTODEV_MEMORY_BACKEND" "$AUTODEV_MEMORY_HINDSIGHT_API_URL" "$AUTODEV_MEMORY_HEALTH_SWARM_URL" <<'PY'
from pathlib import Path
import json
import sys

output = Path(sys.argv[1])
payload = {
    "health": sys.argv[2],
    "project": sys.argv[3],
    "backend": sys.argv[4],
    "hindsight_api_url": sys.argv[5],
    "swarm_url": sys.argv[6],
}
output.write_text(json.dumps(payload, indent=2) + "\n")
PY

printf '%s\n' "$memory_health_report"
log_line "Memory health completed with status: $health"

[ "$health" = "healthy" ]
