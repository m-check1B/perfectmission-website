#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

lock_dir="$(acquire_lock doctor || true)"
if [ -z "${lock_dir:-}" ]; then
  exit 0
fi
trap 'release_lock "$lock_dir"' EXIT

run_id="$(date +"%Y%m%dT%H%M%S")"
CURRENT_LOG_FILE="$AUTODEV_LOG_DIR/doctor-$run_id.log"

health="healthy"
report=""
push_state=""
tracked_changes_now=""

add_report() {
  report="${report}$1"$'\n'
}

memory_health_field() {
  local field="$1"

  python3 - "$AUTODEV_MEMORY_HEALTH_JSON_FILE" "$field" <<'PY'
from pathlib import Path
import json
import sys

path = Path(sys.argv[1])
field = sys.argv[2]

if not path.is_file():
    raise SystemExit(0)

try:
    payload = json.loads(path.read_text() or "{}")
except Exception:
    raise SystemExit(0)

value = payload.get(field)
if value is None:
    raise SystemExit(0)

print(value)
PY
}

automation_paused() {
  [ "$AUTODEV_ENABLED" != "true" ]
}

mark_degraded() {
  if [ "$health" = "healthy" ]; then
    health="degraded"
  fi
}

mark_failing() {
  health="failing"
}

check_freshness() {
  local label="$1"
  local pattern="$2"
  local max_age="$3"
  local latest age

  latest="$(latest_matching_file "$pattern" || true)"
  if [ -z "$latest" ]; then
    mark_failing
    add_report "$label: missing"
    return
  fi

  age="$(file_age_minutes "$latest")"
  add_report "$label: ok (${age}m old)"
  if [ "$age" -gt "$max_age" ]; then
    mark_failing
    add_report "$label: stale (>${max_age}m)"
  fi
}

adapter="$(detect_adapter || true)"
if [ -z "$adapter" ]; then
  mark_failing
  add_report "adapter: missing"
elif adapter_ready "$adapter"; then
  add_report "adapter: ready ($adapter)"
else
  mark_failing
  add_report "adapter: unavailable ($adapter)"
fi

if automation_paused; then
  add_report "automation: paused"
fi

if cron_block_present; then
  add_report "cron: installed"
else
  mark_failing
  add_report "cron: missing"
fi

push_state="$(push_status)"
add_report "push: $push_state"
if [ "$AUTODEV_AUTO_PUSH" = "true" ]; then
  case "$push_state" in
    ahead-unsafe:*)
      mark_degraded
      add_report "push: blocked by non-autodev pending commits"
      ;;
    remote-missing|branch-missing)
      mark_failing
      ;;
  esac
fi

test_status="$(verification_status_value "$AUTODEV_LAST_TEST_STATUS_FILE")"
if verification_command_configured "$AUTODEV_TEST_COMMAND"; then
  add_report "automated-test: $test_status"
  case "$test_status" in
    success|not-configured)
      ;;
    none)
      mark_degraded
      add_report "automated-test: no recorded result yet"
      ;;
    *)
      mark_failing
      ;;
  esac
elif [ "$AUTODEV_TEST_REQUIRED" = "true" ]; then
  mark_failing
  add_report "automated-test: missing-required"
else
  add_report "automated-test: not-configured"
fi

visual_test_status="$(verification_status_value "$AUTODEV_LAST_VISUAL_TEST_STATUS_FILE")"
if verification_command_configured "$AUTODEV_VISUAL_TEST_COMMAND"; then
  add_report "visual-test: $visual_test_status"
  case "$visual_test_status" in
    success|not-configured)
      ;;
    none)
      mark_degraded
      add_report "visual-test: no recorded result yet"
      ;;
    *)
      mark_failing
      ;;
  esac
elif [ "$AUTODEV_VISUAL_TEST_REQUIRED" = "true" ]; then
  mark_failing
  add_report "visual-test: missing-required"
else
  add_report "visual-test: not-configured"
fi

check_freshness "memory-sync" "$AUTODEV_LOG_DIR/memory-sync-*.log" "$AUTODEV_DOCTOR_MAX_MEMORY_AGE_MINUTES"

memory_health_age=""
memory_health_status=""
memory_health_root_cause=""
memory_health_openclaw_mode=""
memory_health_remediation_file=""

if [ -f "$AUTODEV_MEMORY_HEALTH_JSON_FILE" ]; then
  memory_health_age="$(file_age_minutes "$AUTODEV_MEMORY_HEALTH_JSON_FILE")"
  memory_health_status="$(memory_health_field health || true)"
  memory_health_root_cause="$(memory_health_field root_cause || true)"
  memory_health_openclaw_mode="$(memory_health_field openclaw_plugin_mode || true)"
  memory_health_remediation_file="$(memory_health_field remediation_file || true)"

  add_report "memory-health: ${memory_health_status:-unknown} (${memory_health_age}m old)"
  if [ -n "$memory_health_root_cause" ]; then
    add_report "memory-health-root-cause: $memory_health_root_cause"
  fi
  if [ -n "$memory_health_openclaw_mode" ]; then
    add_report "memory-health-openclaw-mode: $memory_health_openclaw_mode"
  fi
  if [ -n "$memory_health_remediation_file" ]; then
    add_report "memory-health-remediation-file: $memory_health_remediation_file"
  fi

  if [ "$memory_health_age" -gt "$AUTODEV_DOCTOR_MAX_MEMORY_AGE_MINUTES" ]; then
    mark_degraded
    add_report "memory-health: stale (>${AUTODEV_DOCTOR_MAX_MEMORY_AGE_MINUTES}m)"
  fi

  case "$memory_health_status" in
    healthy)
      ;;
    degraded)
      mark_degraded
      ;;
    failing)
      mark_failing
      ;;
    *)
      mark_degraded
      add_report "memory-health: unreadable"
      ;;
  esac
else
  mark_degraded
  add_report "memory-health: missing"
fi

if hour_in_window "$(current_hour)" "$AUTODEV_HEARTBEAT_ACTIVE_START" "$AUTODEV_HEARTBEAT_ACTIVE_END"; then
  check_freshness "heartbeat" "$AUTODEV_LOG_DIR/heartbeat-*.log" "$AUTODEV_DOCTOR_MAX_HEARTBEAT_AGE_MINUTES"
else
  add_report "heartbeat: outside active window"
fi

if automation_paused; then
  add_report "cycle: paused"
elif hour_in_window "$(current_hour)" "$AUTODEV_ACTIVE_START" "$AUTODEV_ACTIVE_END"; then
  check_freshness "cycle" "$AUTODEV_LOG_DIR/cycle-*.log" "$AUTODEV_DOCTOR_MAX_CYCLE_AGE_MINUTES"

  tracked_changes_now="$(tracked_changes)"

  if [ "$AUTODEV_REQUIRE_CLEAN_TREE" = "true" ] && [ -n "$tracked_changes_now" ]; then
    mark_degraded
    add_report "cycle: blocked by tracked changes"
  fi

  if [ -f "$AUTODEV_STATE_DIR/last-cycle-status.txt" ]; then
    last_cycle_status="$(cat "$AUTODEV_STATE_DIR/last-cycle-status.txt")"
    add_report "last-cycle-status: $last_cycle_status"
    if [ "$last_cycle_status" = "failure" ]; then
      if [ "$push_state" = "clean" ] && [ -z "$tracked_changes_now" ]; then
        mark_degraded
        add_report "last-cycle-status: failure, but current repo state is clean; waiting for the next successful cycle to confirm recovery"
      else
        mark_failing
      fi
    elif [ "$last_cycle_status" = "noop" ] || [ "$last_cycle_status" = "skipped-governance" ]; then
      mark_degraded
    fi
  else
    mark_degraded
    add_report "last-cycle-status: missing"
  fi
else
  add_report "cycle: outside active window"
fi

doctor_report=$(
  cat <<EOF
Project: $PROJECT_NAME
Health: $health
Generated: $(timestamp_utc)
Adapter: ${adapter:-none}
Cycle hours: $(window_label "$AUTODEV_ACTIVE_START" "$AUTODEV_ACTIVE_END")
Heartbeat hours: $(window_label "$AUTODEV_HEARTBEAT_ACTIVE_START" "$AUTODEV_HEARTBEAT_ACTIVE_END")

$report
EOF
)

printf '%s\n' "$health" > "$AUTODEV_STATE_DIR/doctor-status.txt"
printf '%s\n' "$doctor_report" > "$AUTODEV_STATE_DIR/doctor-latest.txt"
refresh_stats_reports
append_daily_section "Doctor ($health)" "$doctor_report"
log_line "Doctor completed with status: $health"
