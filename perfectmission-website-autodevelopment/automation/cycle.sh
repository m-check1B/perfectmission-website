#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

lock_dir="$(acquire_lock cycle || true)"
if [ -z "${lock_dir:-}" ]; then
  exit 0
fi
trap 'release_lock "$lock_dir"' EXIT

run_id="$(date +"%Y%m%dT%H%M%S")"
CURRENT_LOG_FILE="$AUTODEV_LOG_DIR/cycle-$run_id.log"
output_file="$AUTODEV_LOG_DIR/cycle-$run_id.last.txt"
prompt_file="$AUTODEV_STATE_DIR/cycle-$run_id.prompt.md"
focus="$(current_focus_label || true)"
starting_head="$(current_head)"

log_line "Starting autonomous cycle for $PROJECT_NAME"

if [ "$AUTODEV_ENABLED" != "true" ]; then
  log_line "Automation disabled in $ENV_FILE"
  append_daily_section "Cycle disabled" "Automation is disabled in the local environment file."
  exit 0
fi

if ! require_active_window "cycle" "$AUTODEV_ACTIVE_START" "$AUTODEV_ACTIVE_END" "Cycle skipped"; then
  exit 0
fi

if ! require_clean_tree; then
  exit 0
fi

refresh_steering_state >/dev/null
refresh_memory_backend >/dev/null

adapter="$(detect_adapter || true)"
if [ -z "$adapter" ]; then
  log_line "No supported adapter detected."
  append_daily_section "Cycle failed" "No supported adapter is configured or installed."
  exit 1
fi

build_prompt_bundle "$prompt_file" "development-cycle"
log_line "Built prompt bundle at $prompt_file"

GOVERNANCE_STATUS=0
GOVERNANCE_RESULT=$(python3 "$AUTODEV_ROOT/security/runtime_governance.py" --scope cycle --prompt-file "$prompt_file" 2>>"$CURRENT_LOG_FILE") || GOVERNANCE_STATUS=$?
if [ "$GOVERNANCE_STATUS" -ne 0 ]; then
  printf '%s\n' "skipped-governance" > "$AUTODEV_STATE_DIR/last-cycle-status.txt"
  printf '%s\n' "$run_id" > "$AUTODEV_STATE_DIR/last-cycle-id.txt"
  write_last_cycle_summary "skipped-governance" "$focus" "" "$GOVERNANCE_RESULT"
  advance_focus_cursor
  log_line "Cycle blocked by governance."
  append_daily_section "Cycle skipped by governance" "$GOVERNANCE_RESULT"
  exit 0
fi

status="success"
if ! run_adapter "$adapter" "$prompt_file" "$output_file" >> "$CURRENT_LOG_FILE" 2>&1; then
  status="failure"
fi

summary="$(extract_output_summary "$output_file" || true)"
changes="$(project_change_report || true)"
commit_sha=""
ending_head="$(current_head)"
verification_report=""

if [ "$status" = "success" ] && [ -z "$changes" ] && [ -n "$starting_head" ] && [ -n "$ending_head" ] && [ "$starting_head" != "$ending_head" ]; then
  commit_sha="$ending_head"
  changes="$(commit_change_report "$ending_head" || true)"
fi

if [ "$status" = "success" ] && [ -z "$changes" ]; then
  status="noop"
fi

if [ "$status" = "success" ]; then
  verification_status=0
  verification_report="$(run_verification_suite "$run_id")" || verification_status=$?
  if [ -n "$verification_report" ]; then
    summary="${summary}"$'\n\n'"Verification:\n$verification_report"
  fi
  if [ "$verification_status" -ne 0 ]; then
    status="failure"
    summary="${summary}"$'\n\n'"Automated verification failed. See latest verification summaries and logs."
  fi
fi

if [ "$status" = "success" ] && [ -z "$commit_sha" ] && [ "$AUTODEV_AUTO_COMMIT" = "true" ]; then
  if ! commit_project_changes "$run_id" "$focus" >> "$CURRENT_LOG_FILE" 2>&1; then
    status="failure"
    summary="${summary}"$'\n\n'"Auto-commit failed. See cycle log for details."
  else
    commit_sha="$(current_head)"
  fi
fi

if [ "$status" != "failure" ] && [ "$AUTODEV_AUTO_PUSH" = "true" ]; then
  pending_pushes="$(pending_push_count)"
  if [ "${pending_pushes:-0}" -gt 0 ]; then
    if ! push_project_branch >> "$CURRENT_LOG_FILE" 2>&1; then
      status="failure"
      summary="${summary}"$'\n\n'"Auto-push failed. See cycle log for details."
    else
      summary="${summary}"$'\n\n'"Auto-push succeeded to ${AUTODEV_PUSH_REMOTE}:$(push_branch)."
    fi
  fi
fi

printf '%s\n' "$status" > "$AUTODEV_STATE_DIR/last-cycle-status.txt"
printf '%s\n' "$run_id" > "$AUTODEV_STATE_DIR/last-cycle-id.txt"
write_last_cycle_summary "$status" "$focus" "$changes" "$summary" "$commit_sha"
write_last_cycle_commit "$commit_sha"
record_delivery_event "$run_id" "$status" "$focus" "$commit_sha" "${changes:-- none}"
record_cycle_memory "$run_id" "$status" "$focus" "$changes" "$summary" "$commit_sha" "$output_file"
refresh_skill_memory >/dev/null || true
refresh_stats_reports
advance_focus_cursor

append_daily_section \
  "Development cycle ($status)" \
  "Adapter: $adapter\nFocus: ${focus:-none}\nPrompt: $prompt_file\nOutput: $output_file\n\nChanged files:\n${changes:-- none}\n\n$summary"

if [ "$status" != "success" ]; then
  if [ "$status" = "noop" ]; then
    log_line "Autonomous cycle completed without product changes."
    exit 0
  fi

  log_line "Autonomous cycle failed."
  exit 1
fi

log_line "Autonomous cycle completed successfully."
