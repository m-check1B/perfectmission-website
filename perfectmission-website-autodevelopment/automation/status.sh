#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

printf 'project=%s\n' "$PROJECT_NAME"
printf 'repo=%s\n' "$REPO_ROOT"
printf 'git_root=%s\n' "$AUTODEV_GIT_ROOT"
printf 'git_scope=%s\n' "$AUTODEV_GIT_SCOPE"
printf 'autodev_root=%s\n' "$AUTODEV_ROOT"
printf 'steering_dir=%s\n' "$AUTODEV_STEERING_DIR"
printf 'steering_board=%s\n' "$AUTODEV_STEERING_BOARD_FILE"
printf 'steering_active_count=%s\n' "$(steering_task_count "$AUTODEV_STEERING_ACTIVE_DIR")"
printf 'steering_inbox_count=%s\n' "$(steering_task_count "$AUTODEV_STEERING_INBOX_DIR")"
printf 'steering_done_count=%s\n' "$(steering_task_count "$AUTODEV_STEERING_DONE_DIR")"
printf 'steering_focus_source=%s\n' "$(current_focus_source || printf 'none')"
printf 'steering_focus=%s\n' "$(current_focus_label || printf 'none')"
printf 'steering_task_file=%s\n' "$(
  task_file="$(current_steering_task_path || true)"
  if [ -n "$task_file" ]; then
    steering_task_relative_path "$task_file"
  else
    printf 'none'
  fi
)"
printf 'linear_sync_status=%s\n' "$(linear_sync_status)"
printf 'memory_backend=%s\n' "$AUTODEV_MEMORY_BACKEND"
printf 'memory_backend_status=%s\n' "$(memory_backend_status_label)"
printf 'memory_backend_db=%s\n' "$AUTODEV_MEMORY_BACKEND_DB"
printf 'memory_backend_indexed_items=%s\n' "$(memory_backend_status_field indexed_count || printf '0')"
printf 'memory_backend_query_source=%s\n' "$(memory_backend_status_field query_source || printf 'none')"
printf 'memory_backend_rg=%s\n' "$(memory_backend_status_field rg_available || printf 'missing')"
printf 'memory_backend_rg_installed=%s\n' "$(memory_backend_status_field rg_installed || printf 'no')"
printf 'memory_backend_mgrep=%s\n' "$(memory_backend_status_field mgrep_available || printf 'missing')"
printf 'memory_backend_mgrep_installed=%s\n' "$(memory_backend_status_field mgrep_installed || printf 'no')"
printf 'memory_backend_mgrep_auth=%s\n' "$(memory_backend_status_field mgrep_auth || printf 'missing')"
printf 'memory_backend_mgrep_store=%s\n' "$(memory_backend_status_field mgrep_store || printf '%s' "$AUTODEV_MEMORY_MGREP_STORE")"
printf 'memory_health=%s\n' "$(
  python3 - "$AUTODEV_MEMORY_HEALTH_JSON_FILE" <<'PY'
from pathlib import Path
import json
import sys

path = Path(sys.argv[1])
if not path.is_file():
    print("unknown")
    raise SystemExit(0)

try:
    payload = json.loads(path.read_text() or "{}")
except Exception:
    print("invalid")
    raise SystemExit(0)

print(payload.get("health") or "unknown")
PY
)"
printf 'memory_health_root_cause=%s\n' "$(
  python3 - "$AUTODEV_MEMORY_HEALTH_JSON_FILE" <<'PY'
from pathlib import Path
import json
import sys

path = Path(sys.argv[1])
if not path.is_file():
    print("none")
    raise SystemExit(0)

try:
    payload = json.loads(path.read_text() or "{}")
except Exception:
    print("invalid")
    raise SystemExit(0)

print(payload.get("root_cause") or "none")
PY
)"
printf 'memory_health_openclaw_mode=%s\n' "$(
  python3 - "$AUTODEV_MEMORY_HEALTH_JSON_FILE" <<'PY'
from pathlib import Path
import json
import sys

path = Path(sys.argv[1])
if not path.is_file():
    print("unknown")
    raise SystemExit(0)

try:
    payload = json.loads(path.read_text() or "{}")
except Exception:
    print("invalid")
    raise SystemExit(0)

print(payload.get("openclaw_plugin_mode") or "unknown")
PY
)"
printf 'test_command_configured=%s\n' "$(if verification_command_configured "$AUTODEV_TEST_COMMAND"; then printf 'true'; else printf 'false'; fi)"
printf 'test_required=%s\n' "$AUTODEV_TEST_REQUIRED"
printf 'last_test_status=%s\n' "$(verification_status_value "$AUTODEV_LAST_TEST_STATUS_FILE")"
printf 'visual_test_command_configured=%s\n' "$(if verification_command_configured "$AUTODEV_VISUAL_TEST_COMMAND"; then printf 'true'; else printf 'false'; fi)"
printf 'visual_test_required=%s\n' "$AUTODEV_VISUAL_TEST_REQUIRED"
printf 'last_visual_test_status=%s\n' "$(verification_status_value "$AUTODEV_LAST_VISUAL_TEST_STATUS_FILE")"
printf 'enabled=%s\n' "$AUTODEV_ENABLED"
printf 'adapter=%s\n' "$(detect_adapter || printf 'none')"
printf 'branch=%s\n' "$(current_branch)"
printf 'auto_commit=%s\n' "$AUTODEV_AUTO_COMMIT"
printf 'auto_push=%s\n' "$AUTODEV_AUTO_PUSH"
printf 'push_remote=%s\n' "$AUTODEV_PUSH_REMOTE"
printf 'push_branch=%s\n' "$(push_branch)"
printf 'push_status=%s\n' "$(push_status)"
printf 'cycle_hours=%s\n' "$(window_label "$AUTODEV_ACTIVE_START" "$AUTODEV_ACTIVE_END")"
printf 'heartbeat_hours=%s\n' "$(window_label "$AUTODEV_HEARTBEAT_ACTIVE_START" "$AUTODEV_HEARTBEAT_ACTIVE_END")"
printf 'doctor_minute=%s\n' "$AUTODEV_DOCTOR_MINUTE"
printf 'remediator_enabled=%s\n' "$AUTODEV_REMEDIATOR_ENABLED"
printf 'remediator_minute=%s\n' "$AUTODEV_REMEDIATOR_MINUTE"
printf 'remediation_adapter=%s\n' "$AUTODEV_REMEDIATION_ADAPTER"
printf 'stats_md=%s\n' "$AUTODEV_STATS_MD_FILE"
printf 'stats_html=%s\n' "$AUTODEV_STATS_HTML_FILE"
printf 'current_hour=%s\n' "$(current_hour)"

printf '\ntracked_changes:\n'
tracked_changes || true

printf '\ncron_block:\n'
crontab -l 2>/dev/null | awk -v start="# BEGIN AUTODEV $AUTODEV_ID" -v end="# END AUTODEV $AUTODEV_ID" '
  $0 == start {print; show=1; next}
  $0 == end {print; show=0; next}
  show {print}
'

printf '\nlast_cycle_status:\n'
if [ -f "$AUTODEV_STATE_DIR/last-cycle-status.txt" ]; then
  cat "$AUTODEV_STATE_DIR/last-cycle-status.txt"
else
  printf 'none\n'
fi

printf '\ndoctor_status:\n'
if [ -f "$AUTODEV_STATE_DIR/doctor-status.txt" ]; then
  cat "$AUTODEV_STATE_DIR/doctor-status.txt"
else
  printf 'none\n'
fi

printf '\ndoctor_latest:\n'
if [ -f "$AUTODEV_STATE_DIR/doctor-latest.txt" ]; then
  cat "$AUTODEV_STATE_DIR/doctor-latest.txt"
else
  printf 'none\n'
fi

printf '\nremediator_status:\n'
if [ -f "$AUTODEV_STATE_DIR/remediator-status.txt" ]; then
  cat "$AUTODEV_STATE_DIR/remediator-status.txt"
else
  printf 'none\n'
fi

printf '\nremediator_latest:\n'
if [ -f "$AUTODEV_STATE_DIR/remediator-latest.txt" ]; then
  cat "$AUTODEV_STATE_DIR/remediator-latest.txt"
else
  printf 'none\n'
fi

printf '\nlast_cycle_summary:\n'
if [ -f "$AUTODEV_LAST_CYCLE_SUMMARY_FILE" ]; then
  cat "$AUTODEV_LAST_CYCLE_SUMMARY_FILE"
else
  printf 'none\n'
fi

printf '\nlast_cycle_commit:\n'
if [ -f "$AUTODEV_LAST_CYCLE_COMMIT_FILE" ]; then
  cat "$AUTODEV_LAST_CYCLE_COMMIT_FILE"
else
  printf 'none\n'
fi

printf '\nlast_test_summary:\n'
if [ -f "$AUTODEV_LAST_TEST_SUMMARY_FILE" ]; then
  cat "$AUTODEV_LAST_TEST_SUMMARY_FILE"
else
  printf 'none\n'
fi

printf '\nlast_visual_test_summary:\n'
if [ -f "$AUTODEV_LAST_VISUAL_TEST_SUMMARY_FILE" ]; then
  cat "$AUTODEV_LAST_VISUAL_TEST_SUMMARY_FILE"
else
  printf 'none\n'
fi

printf '\nrecent_delivery_history:\n'
if [ -f "$AUTODEV_DELIVERY_HISTORY_FILE" ]; then
  recent_delivery_history
else
  printf 'none\n'
fi

printf '\nstats_summary:\n'
if [ -f "$AUTODEV_STATS_MD_FILE" ]; then
  sed -n '1,24p' "$AUTODEV_STATS_MD_FILE"
else
  printf 'none\n'
fi
