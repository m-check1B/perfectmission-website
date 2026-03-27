#!/bin/bash

set -euo pipefail

AUTODEV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$AUTODEV_SCRIPT_DIR/lib.sh"

ensure_dirs

if [ "$AUTODEV_REMEDIATOR_ENABLED" != "true" ]; then
  exit 0
fi

if [ "$AUTODEV_ENABLED" != "true" ]; then
  printf '%s\n' "paused" > "$AUTODEV_LAST_REMEDIATION_STATUS_FILE"
  remediation_report=$(
    cat <<EOF
Project: $PROJECT_NAME
Status: paused
Generated: $(timestamp_utc)
Remediation adapter: ${AUTODEV_REMEDIATION_ADAPTER:-none}

result: automation is paused; no remediation actions were attempted
EOF
  )
  printf '%s\n' "$remediation_report" > "$AUTODEV_LAST_REMEDIATION_FILE"
  refresh_stats_reports
  append_daily_section "Remediator (paused)" "Automation is paused in the local environment file. No remediation actions were attempted."
  exit 0
fi

lock_dir="$(acquire_lock remediator || true)"
if [ -z "${lock_dir:-}" ]; then
  exit 0
fi
trap 'release_lock "$lock_dir"' EXIT

run_id="$(date +"%Y%m%dT%H%M%S")"
CURRENT_LOG_FILE="$AUTODEV_LOG_DIR/remediator-$run_id.log"

status="no-action"
report=""

add_report() {
  report="${report}$1"$'\n'
}

mark_status() {
  status="$1"
}

safe_push_backlog() {
  local current_push_status
  current_push_status="$(push_status)"

  case "$current_push_status" in
    ahead:*)
      if push_project_branch >> "$CURRENT_LOG_FILE" 2>&1; then
        add_report "push: succeeded for pending safe backlog"
        mark_status "repaired"
        return 0
      fi
      add_report "push: failed while attempting pending safe backlog"
      mark_status "attention"
      return 1
      ;;
    *)
      return 1
      ;;
  esac
}

repair_github_https_remote() {
  if ! github_https_remote; then
    return 1
  fi

  if ! github_ssh_ready; then
    add_report "remote: GitHub HTTPS remote detected but SSH auth is not ready"
    mark_status "attention"
    return 1
  fi

  if rewrite_push_remote_to_github_ssh; then
    add_report "remote: rewrote ${AUTODEV_PUSH_REMOTE} to GitHub SSH for unattended push"
    mark_status "repaired"
    return 0
  fi

  add_report "remote: failed to rewrite ${AUTODEV_PUSH_REMOTE} to GitHub SSH"
  mark_status "attention"
  return 1
}

write_supervision_note() {
  local supervision_adapter="$AUTODEV_REMEDIATION_ADAPTER"
  local prompt_file output_file

  [ -n "$supervision_adapter" ] || return 0
  if ! adapter_ready "$supervision_adapter"; then
    add_report "supervision: adapter unavailable (${supervision_adapter})"
    return 0
  fi

  prompt_file="$AUTODEV_STATE_DIR/remediator-$run_id.prompt.md"
  output_file="$AUTODEV_STATE_DIR/remediator-$run_id.output.md"

  {
    printf '# Repo-Local Automation Supervision\n\n'
    printf 'You are supervising a repo-local open-kraliki automation package.\n'
    printf 'Do not change files. Diagnose only. Provide a short analysis with:\n'
    printf '1. most likely root cause\n2. why deterministic repair did or did not fix it\n3. next safe action\n\n'
    printf '## Project\n- name: %s\n- root: %s\n- autodev-root: %s\n\n' "$PROJECT_NAME" "$PROJECT_ROOT" "$AUTODEV_ROOT"
    printf '## Current Status\n\n'
    printf -- '- adapter: %s\n' "$(detect_adapter || printf 'none')"
    printf -- '- remediation-adapter: %s\n' "$supervision_adapter"
    printf -- '- push-status: %s\n' "$(push_status)"
    printf -- '- remote-url: %s\n' "$(push_remote_url)"
    printf -- '- last-cycle-status: %s\n\n' "$(cat "$AUTODEV_STATE_DIR/last-cycle-status.txt" 2>/dev/null || printf 'missing')"
    if [ -f "$AUTODEV_STATE_DIR/doctor-latest.txt" ]; then
      printf '## Doctor Report\n\n'
      cat "$AUTODEV_STATE_DIR/doctor-latest.txt"
      printf '\n\n'
    fi
    if [ -f "$AUTODEV_LAST_CYCLE_SUMMARY_FILE" ]; then
      printf '## Last Cycle Summary\n\n'
      cat "$AUTODEV_LAST_CYCLE_SUMMARY_FILE"
      printf '\n\n'
    fi
    printf '## Recent Delivery History\n\n'
    recent_delivery_history || true
    printf '\n'
  } > "$prompt_file"

  if run_adapter "$supervision_adapter" "$prompt_file" "$output_file" >> "$CURRENT_LOG_FILE" 2>&1; then
    add_report "supervision: wrote diagnosis with ${supervision_adapter}"
    {
      printf 'Remediator status: %s\nGenerated: %s\n\n' "$status" "$(timestamp_utc)"
      cat "$output_file"
    } > "$AUTODEV_LAST_REMEDIATION_FILE"
  else
    add_report "supervision: ${supervision_adapter} diagnosis failed"
  fi
}

cleared_locks="$(clear_stale_locks)"
if [ "${cleared_locks:-0}" -gt 0 ]; then
  add_report "locks: cleared ${cleared_locks} stale lock(s)"
  mark_status "repaired"
fi

current_push_status="$(push_status)"
add_report "push: ${current_push_status}"

if [ "$AUTODEV_AUTO_PUSH" = "true" ]; then
  case "$current_push_status" in
    ahead:*)
      safe_push_backlog || true
      ;;
    remote-missing|branch-missing)
      add_report "push: missing remote or branch configuration"
      mark_status "attention"
      ;;
    clean)
      ;;
    ahead-unsafe:*)
      add_report "push: pending backlog includes commits outside allowed prefixes"
      mark_status "attention"
      ;;
  esac
fi

post_push_status="$(push_status)"
if [ "$AUTODEV_AUTO_PUSH" = "true" ] && [ "$post_push_status" != "clean" ] && github_https_remote; then
  if repair_github_https_remote; then
    if [ "$(push_status)" != "clean" ]; then
      safe_push_backlog || true
    fi
  fi
fi

final_push_status="$(push_status)"
add_report "final-push: ${final_push_status}"

if [ "$status" = "no-action" ] && [ "$final_push_status" = "clean" ]; then
  add_report "result: no remediation needed"
fi

if [ "$final_push_status" != "clean" ]; then
  write_supervision_note
fi

remediation_report=$(
  cat <<EOF
Project: $PROJECT_NAME
Status: $status
Generated: $(timestamp_utc)
Remediation adapter: ${AUTODEV_REMEDIATION_ADAPTER:-none}

$report
EOF
)

printf '%s\n' "$status" > "$AUTODEV_LAST_REMEDIATION_STATUS_FILE"
if [ "$final_push_status" = "clean" ] || [ ! -f "$AUTODEV_LAST_REMEDIATION_FILE" ]; then
  printf '%s\n' "$remediation_report" > "$AUTODEV_LAST_REMEDIATION_FILE"
fi
refresh_stats_reports
append_daily_section "Remediator ($status)" "$remediation_report"
log_line "Remediator completed with status: $status"
