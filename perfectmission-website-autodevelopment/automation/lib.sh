#!/bin/bash

set -euo pipefail

AUTODEV_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUTODEV_ROOT="${AUTODEV_ROOT:-$(cd "$AUTODEV_LIB_DIR/.." && pwd)}"
ENV_FILE="${ENV_FILE:-$AUTODEV_ROOT/.env}"

PATH="${PATH:-/usr/bin:/bin}"
PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Library/Apple/usr/bin:$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:/Applications/Codex.app/Contents/Resources:$PATH"
export PATH

if [ -f "$ENV_FILE" ]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
fi

canonical_dir() {
  (
    cd "$1" >/dev/null 2>&1 && pwd
  )
}

resolve_git_root() {
  git -C "$1" rev-parse --show-toplevel 2>/dev/null || printf '%s\n' "$1"
}

relative_to_root() {
  python3 - "$1" "$2" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1]).resolve()
root = Path(sys.argv[2]).resolve()

try:
    rel = path.relative_to(root)
except ValueError:
    print(".")
else:
    print("." if str(rel) == "." else rel.as_posix())
PY
}

PROJECT_ROOT="${PROJECT_ROOT:-$(cd "$AUTODEV_ROOT/.." && pwd)}"
PROJECT_ROOT="$(canonical_dir "$PROJECT_ROOT")"
REPO_ROOT="$PROJECT_ROOT"
AUTODEV_GIT_ROOT="${AUTODEV_GIT_ROOT:-$(resolve_git_root "$PROJECT_ROOT")}"
AUTODEV_GIT_ROOT="$(canonical_dir "$AUTODEV_GIT_ROOT")"
AUTODEV_GIT_SCOPE="${AUTODEV_GIT_SCOPE:-$(relative_to_root "$PROJECT_ROOT" "$AUTODEV_GIT_ROOT")}"
AUTODEV_INTERNAL_GIT_SCOPE="${AUTODEV_INTERNAL_GIT_SCOPE:-$(relative_to_root "$AUTODEV_ROOT" "$AUTODEV_GIT_ROOT")}"

PROJECT_NAME="${PROJECT_NAME:-$(basename "$PROJECT_ROOT")}"
AUTODEV_ID="${AUTODEV_ID:-$PROJECT_NAME-autodevelopment}"
AUTODEV_ENABLED="${AUTODEV_ENABLED:-false}"
AUTODEV_ADAPTER="${AUTODEV_ADAPTER:-auto}"
AUTODEV_AUTO_COMMIT="${AUTODEV_AUTO_COMMIT:-false}"
AUTODEV_AUTO_PUSH="${AUTODEV_AUTO_PUSH:-false}"
AUTODEV_COMMIT_MESSAGE_PREFIX="${AUTODEV_COMMIT_MESSAGE_PREFIX:-autodev}"
AUTODEV_PUSH_REMOTE="${AUTODEV_PUSH_REMOTE:-origin}"
AUTODEV_PUSH_BRANCH="${AUTODEV_PUSH_BRANCH:-}"
AUTODEV_PUSH_ALLOWED_PREFIXES="${AUTODEV_PUSH_ALLOWED_PREFIXES:-${AUTODEV_COMMIT_MESSAGE_PREFIX}:}"
AUTODEV_REQUIRE_CLEAN_TREE="${AUTODEV_REQUIRE_CLEAN_TREE:-true}"
AUTODEV_CLEAN_TREE_EXCLUDES="${AUTODEV_CLEAN_TREE_EXCLUDES:-}"
AUTODEV_CONTEXT_FILES="${AUTODEV_CONTEXT_FILES:-README.md AGENTS.md}"
AUTODEV_MAX_CONTEXT_LINES="${AUTODEV_MAX_CONTEXT_LINES:-220}"
AUTODEV_MAX_OUTPUT_BYTES="${AUTODEV_MAX_OUTPUT_BYTES:-4000}"

AUTODEV_MEMORY_DIR="${AUTODEV_MEMORY_DIR:-$AUTODEV_ROOT/memory}"
AUTODEV_MEMORY_BACKEND_DIR="${AUTODEV_MEMORY_BACKEND_DIR:-$AUTODEV_ROOT/.agent}"
AUTODEV_MEMORY_BACKEND_DB="${AUTODEV_MEMORY_BACKEND_DB:-$AUTODEV_MEMORY_BACKEND_DIR/index.sqlite3}"
AUTODEV_MEMORY_BACKEND_GRAPH_FILE="${AUTODEV_MEMORY_BACKEND_GRAPH_FILE:-$AUTODEV_MEMORY_BACKEND_DIR/entity_graph.json}"
AUTODEV_MEMORY_BACKEND_RUN_SUMMARIES_FILE="${AUTODEV_MEMORY_BACKEND_RUN_SUMMARIES_FILE:-$AUTODEV_MEMORY_BACKEND_DIR/run_summaries.jsonl}"
AUTODEV_CURATED_DIR="${AUTODEV_CURATED_DIR:-$AUTODEV_MEMORY_DIR/curated}"
AUTODEV_DAILY_DIR="${AUTODEV_DAILY_DIR:-$AUTODEV_MEMORY_DIR/daily}"
AUTODEV_SEMANTIC_DIR="${AUTODEV_SEMANTIC_DIR:-$AUTODEV_MEMORY_DIR/semantic}"
AUTODEV_EPISODIC_DIR="${AUTODEV_EPISODIC_DIR:-$AUTODEV_MEMORY_DIR/episodic}"
AUTODEV_SESSION_DIR="${AUTODEV_SESSION_DIR:-$AUTODEV_EPISODIC_DIR/sessions}"
AUTODEV_ACTIVE_DIR="${AUTODEV_ACTIVE_DIR:-$AUTODEV_MEMORY_DIR/active}"
AUTODEV_STEERING_DIR="${AUTODEV_STEERING_DIR:-$AUTODEV_ROOT/steering}"
AUTODEV_STEERING_BOARD_FILE="${AUTODEV_STEERING_BOARD_FILE:-$AUTODEV_STEERING_DIR/board.md}"
AUTODEV_STEERING_TEMPLATE_FILE="${AUTODEV_STEERING_TEMPLATE_FILE:-$AUTODEV_STEERING_DIR/TASK_TEMPLATE.md}"
AUTODEV_STEERING_INBOX_DIR="${AUTODEV_STEERING_INBOX_DIR:-$AUTODEV_STEERING_DIR/inbox}"
AUTODEV_STEERING_ACTIVE_DIR="${AUTODEV_STEERING_ACTIVE_DIR:-$AUTODEV_STEERING_DIR/active}"
AUTODEV_STEERING_DONE_DIR="${AUTODEV_STEERING_DONE_DIR:-$AUTODEV_STEERING_DIR/done}"
AUTODEV_STEERING_ARCHIVE_DIR="${AUTODEV_STEERING_ARCHIVE_DIR:-$AUTODEV_STEERING_DIR/archive}"
AUTODEV_STEERING_LINEAR_DIR="${AUTODEV_STEERING_LINEAR_DIR:-$AUTODEV_STEERING_DIR/providers/linear}"
AUTODEV_STEERING_LINEAR_MIRROR_DIR="${AUTODEV_STEERING_LINEAR_MIRROR_DIR:-$AUTODEV_STEERING_LINEAR_DIR/mirror}"
AUTODEV_STEERING_LINEAR_MAP_FILE="${AUTODEV_STEERING_LINEAR_MAP_FILE:-$AUTODEV_STEERING_LINEAR_DIR/map.json}"
AUTODEV_STEERING_LINEAR_LAST_SYNC_FILE="${AUTODEV_STEERING_LINEAR_LAST_SYNC_FILE:-$AUTODEV_STEERING_LINEAR_DIR/last-sync.json}"
AUTODEV_STEERING_LINEAR_OUTBOX_FILE="${AUTODEV_STEERING_LINEAR_OUTBOX_FILE:-$AUTODEV_STEERING_LINEAR_DIR/outbox.jsonl}"
AUTODEV_STATE_DIR="${AUTODEV_STATE_DIR:-$AUTODEV_ROOT/state}"
AUTODEV_LOG_DIR="${AUTODEV_LOG_DIR:-$AUTODEV_ROOT/logs}"
AUTODEV_LOCK_DIR="${AUTODEV_LOCK_DIR:-$AUTODEV_STATE_DIR/locks}"
AUTODEV_SKILLS_DIR="${AUTODEV_SKILLS_DIR:-$AUTODEV_ROOT/skills}"

AUTODEV_OBJECTIVE_FILE="${AUTODEV_OBJECTIVE_FILE:-$AUTODEV_CURATED_DIR/OBJECTIVE.md}"
AUTODEV_PROJECT_FILE="${AUTODEV_PROJECT_FILE:-$AUTODEV_CURATED_DIR/PROJECT.md}"
AUTODEV_MEMORY_FILE="${AUTODEV_MEMORY_FILE:-$AUTODEV_CURATED_DIR/MEMORY.md}"
AUTODEV_PROJECT_MAP_FILE="${AUTODEV_PROJECT_MAP_FILE:-$AUTODEV_SEMANTIC_DIR/project-map.md}"
AUTODEV_ARCHITECTURE_FILE="${AUTODEV_ARCHITECTURE_FILE:-$AUTODEV_SEMANTIC_DIR/architecture.md}"
AUTODEV_INVARIANTS_FILE="${AUTODEV_INVARIANTS_FILE:-$AUTODEV_SEMANTIC_DIR/invariants.md}"
AUTODEV_COMMANDS_FILE="${AUTODEV_COMMANDS_FILE:-$AUTODEV_SEMANTIC_DIR/commands.md}"
AUTODEV_OWNERSHIP_FILE="${AUTODEV_OWNERSHIP_FILE:-$AUTODEV_SEMANTIC_DIR/ownership.md}"
AUTODEV_DECISIONS_FILE="${AUTODEV_DECISIONS_FILE:-$AUTODEV_EPISODIC_DIR/decisions.md}"
AUTODEV_FAILURES_FILE="${AUTODEV_FAILURES_FILE:-$AUTODEV_EPISODIC_DIR/failures.md}"
AUTODEV_CHANGELOG_FILE="${AUTODEV_CHANGELOG_FILE:-$AUTODEV_EPISODIC_DIR/changelog.md}"
AUTODEV_CURRENT_TASK_FILE="${AUTODEV_CURRENT_TASK_FILE:-$AUTODEV_ACTIVE_DIR/current-task.md}"
AUTODEV_OPEN_QUESTIONS_FILE="${AUTODEV_OPEN_QUESTIONS_FILE:-$AUTODEV_ACTIVE_DIR/open-questions.md}"
AUTODEV_NEXT_ACTIONS_FILE="${AUTODEV_NEXT_ACTIONS_FILE:-$AUTODEV_ACTIVE_DIR/next-actions.md}"
AUTODEV_MEMORY_SKILL_FILE="${AUTODEV_MEMORY_SKILL_FILE:-$AUTODEV_SKILLS_DIR/autodev-instance-ops/SKILL.md}"
AUTODEV_QUEUE_FILE="${AUTODEV_QUEUE_FILE:-$AUTODEV_ROOT/queue/TODO.md}"
AUTODEV_PROMPT_TEMPLATE="${AUTODEV_PROMPT_TEMPLATE:-$AUTODEV_ROOT/prompts/development-cycle.md}"
AUTODEV_MEMORY_BACKEND="${AUTODEV_MEMORY_BACKEND:-hybrid-sqlite}"
AUTODEV_MEMORY_BACKEND_STATUS_FILE="${AUTODEV_MEMORY_BACKEND_STATUS_FILE:-$AUTODEV_STATE_DIR/memory-backend-status.json}"
AUTODEV_MEMORY_RETRIEVAL_FILE="${AUTODEV_MEMORY_RETRIEVAL_FILE:-$AUTODEV_STATE_DIR/memory-retrieval.md}"
AUTODEV_MEMORY_RETRIEVE_LIMIT="${AUTODEV_MEMORY_RETRIEVE_LIMIT:-8}"
AUTODEV_MEMORY_USE_RG="${AUTODEV_MEMORY_USE_RG:-true}"
AUTODEV_MEMORY_RG_MAX_MATCHES="${AUTODEV_MEMORY_RG_MAX_MATCHES:-12}"
AUTODEV_MEMORY_USE_MGREP="${AUTODEV_MEMORY_USE_MGREP:-false}"
AUTODEV_MEMORY_MGREP_STORE="${AUTODEV_MEMORY_MGREP_STORE:-$AUTODEV_ID}"
AUTODEV_MEMORY_MGREP_SYNC="${AUTODEV_MEMORY_MGREP_SYNC:-true}"
AUTODEV_MEMORY_MGREP_MAX_COUNT="${AUTODEV_MEMORY_MGREP_MAX_COUNT:-8}"
AUTODEV_MEMORY_MGREP_MAX_FILE_SIZE="${AUTODEV_MEMORY_MGREP_MAX_FILE_SIZE:-5242880}"
AUTODEV_MEMORY_MGREP_MAX_FILE_COUNT="${AUTODEV_MEMORY_MGREP_MAX_FILE_COUNT:-5000}"

AUTODEV_MEMORY_INTERVAL_MINUTES="${AUTODEV_MEMORY_INTERVAL_MINUTES:-20}"
AUTODEV_RUN_INTERVAL_MINUTES="${AUTODEV_RUN_INTERVAL_MINUTES:-30}"
AUTODEV_HEARTBEAT_MINUTE="${AUTODEV_HEARTBEAT_MINUTE:-17}"
AUTODEV_DOCTOR_MINUTE="${AUTODEV_DOCTOR_MINUTE:-7}"
AUTODEV_REMEDIATOR_MINUTE="${AUTODEV_REMEDIATOR_MINUTE:-37}"
AUTODEV_ACTIVE_START="${AUTODEV_ACTIVE_START:-8}"
AUTODEV_ACTIVE_END="${AUTODEV_ACTIVE_END:-20}"
AUTODEV_HEARTBEAT_ACTIVE_START="${AUTODEV_HEARTBEAT_ACTIVE_START:-$AUTODEV_ACTIVE_START}"
AUTODEV_HEARTBEAT_ACTIVE_END="${AUTODEV_HEARTBEAT_ACTIVE_END:-24}"
AUTODEV_DOCTOR_MAX_MEMORY_AGE_MINUTES="${AUTODEV_DOCTOR_MAX_MEMORY_AGE_MINUTES:-70}"
AUTODEV_DOCTOR_MAX_CYCLE_AGE_MINUTES="${AUTODEV_DOCTOR_MAX_CYCLE_AGE_MINUTES:-90}"
AUTODEV_DOCTOR_MAX_HEARTBEAT_AGE_MINUTES="${AUTODEV_DOCTOR_MAX_HEARTBEAT_AGE_MINUTES:-180}"
AUTODEV_REMEDIATOR_ENABLED="${AUTODEV_REMEDIATOR_ENABLED:-true}"
AUTODEV_REMEDIATION_ADAPTER="${AUTODEV_REMEDIATION_ADAPTER:-claude}"
AUTODEV_REMEDIATOR_MAX_LOCK_AGE_MINUTES="${AUTODEV_REMEDIATOR_MAX_LOCK_AGE_MINUTES:-180}"
AUTODEV_TEST_COMMAND="${AUTODEV_TEST_COMMAND:-}"
AUTODEV_TEST_REQUIRED="${AUTODEV_TEST_REQUIRED:-false}"
AUTODEV_TEST_TIMEOUT_SECONDS="${AUTODEV_TEST_TIMEOUT_SECONDS:-900}"
AUTODEV_VISUAL_TEST_COMMAND="${AUTODEV_VISUAL_TEST_COMMAND:-}"
AUTODEV_VISUAL_TEST_REQUIRED="${AUTODEV_VISUAL_TEST_REQUIRED:-false}"
AUTODEV_VISUAL_TEST_TIMEOUT_SECONDS="${AUTODEV_VISUAL_TEST_TIMEOUT_SECONDS:-1200}"
AUTODEV_CUSTOM_COMMAND="${AUTODEV_CUSTOM_COMMAND:-}"
AUTODEV_QUEUE_CURSOR_FILE="${AUTODEV_QUEUE_CURSOR_FILE:-$AUTODEV_STATE_DIR/queue-focus-index.txt}"
AUTODEV_LAST_CYCLE_SUMMARY_FILE="${AUTODEV_LAST_CYCLE_SUMMARY_FILE:-$AUTODEV_STATE_DIR/last-cycle-summary.txt}"
AUTODEV_LAST_CYCLE_CHANGES_FILE="${AUTODEV_LAST_CYCLE_CHANGES_FILE:-$AUTODEV_STATE_DIR/last-cycle-changes.txt}"
AUTODEV_LAST_CYCLE_COMMIT_FILE="${AUTODEV_LAST_CYCLE_COMMIT_FILE:-$AUTODEV_STATE_DIR/last-cycle-commit.txt}"
AUTODEV_LAST_TEST_STATUS_FILE="${AUTODEV_LAST_TEST_STATUS_FILE:-$AUTODEV_STATE_DIR/last-test-status.txt}"
AUTODEV_LAST_TEST_SUMMARY_FILE="${AUTODEV_LAST_TEST_SUMMARY_FILE:-$AUTODEV_STATE_DIR/last-test-summary.txt}"
AUTODEV_LAST_VISUAL_TEST_STATUS_FILE="${AUTODEV_LAST_VISUAL_TEST_STATUS_FILE:-$AUTODEV_STATE_DIR/last-visual-test-status.txt}"
AUTODEV_LAST_VISUAL_TEST_SUMMARY_FILE="${AUTODEV_LAST_VISUAL_TEST_SUMMARY_FILE:-$AUTODEV_STATE_DIR/last-visual-test-summary.txt}"
AUTODEV_DELIVERY_HISTORY_FILE="${AUTODEV_DELIVERY_HISTORY_FILE:-$AUTODEV_STATE_DIR/delivery-history.log}"
AUTODEV_LAST_REMEDIATION_FILE="${AUTODEV_LAST_REMEDIATION_FILE:-$AUTODEV_STATE_DIR/remediator-latest.txt}"
AUTODEV_LAST_REMEDIATION_STATUS_FILE="${AUTODEV_LAST_REMEDIATION_STATUS_FILE:-$AUTODEV_STATE_DIR/remediator-status.txt}"
AUTODEV_STATS_MD_FILE="${AUTODEV_STATS_MD_FILE:-$AUTODEV_STATE_DIR/stats.md}"
AUTODEV_STATS_HTML_FILE="${AUTODEV_STATS_HTML_FILE:-$AUTODEV_STATE_DIR/stats.html}"

CURRENT_LOG_FILE="${CURRENT_LOG_FILE:-}"

timestamp_utc() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

today_stamp() {
  date +"%Y-%m-%d"
}

current_hour() {
  local hour_text
  hour_text="$(date +"%H")"
  printf '%s\n' "$((10#$hour_text))"
}

window_label() {
  local start="$1"
  local end="$2"
  printf '%s-%s\n' "$start" "$end"
}

hour_in_window() {
  local hour="$1"
  local start="$2"
  local end="$3"

  if [ "$start" -eq "$end" ]; then
    return 0
  fi

  if [ "$start" -lt "$end" ]; then
    [ "$hour" -ge "$start" ] && [ "$hour" -lt "$end" ]
    return $?
  fi

  [ "$hour" -ge "$start" ] || [ "$hour" -lt "$end" ]
}

require_active_window() {
  local label="$1"
  local start="$2"
  local end="$3"
  local note_title="$4"
  local hour
  hour="$(current_hour)"

  if hour_in_window "$hour" "$start" "$end"; then
    return 0
  fi

  log_line "Outside active hours for $label ($(window_label "$start" "$end")), current hour=${hour}. Skipping."
  append_daily_section "$note_title" "Outside active hours for $label: $(window_label "$start" "$end")\nCurrent hour: $hour"
  return 1
}

ensure_dirs() {
  mkdir -p \
    "$AUTODEV_MEMORY_BACKEND_DIR" \
    "$AUTODEV_CURATED_DIR" \
    "$AUTODEV_DAILY_DIR" \
    "$AUTODEV_SEMANTIC_DIR" \
    "$AUTODEV_EPISODIC_DIR" \
    "$AUTODEV_SESSION_DIR" \
    "$AUTODEV_ACTIVE_DIR" \
    "$AUTODEV_STEERING_INBOX_DIR" \
    "$AUTODEV_STEERING_ACTIVE_DIR" \
    "$AUTODEV_STEERING_DONE_DIR" \
    "$AUTODEV_STEERING_ARCHIVE_DIR" \
    "$AUTODEV_STEERING_LINEAR_DIR" \
    "$AUTODEV_STEERING_LINEAR_MIRROR_DIR" \
    "$AUTODEV_STATE_DIR" \
    "$AUTODEV_LOG_DIR" \
    "$AUTODEV_LOCK_DIR" \
    "$AUTODEV_SKILLS_DIR"
}

log_line() {
  local line
  line="[$(timestamp_utc)] $*"
  if [ -n "$CURRENT_LOG_FILE" ]; then
    printf '%s\n' "$line" | tee -a "$CURRENT_LOG_FILE"
  else
    printf '%s\n' "$line"
  fi
}

daily_note_path() {
  printf '%s/%s.md\n' "$AUTODEV_DAILY_DIR" "$(today_stamp)"
}

append_daily_section() {
  local title="$1"
  local body="$2"
  local note
  note="$(daily_note_path)"
  ensure_dirs
  {
    printf '## %s - %s\n\n' "$title" "$(timestamp_utc)"
    printf '%b\n\n' "$body"
  } >> "$note"
}

recent_session_files() {
  [ -d "$AUTODEV_SESSION_DIR" ] || return 0
  find "$AUTODEV_SESSION_DIR" -maxdepth 1 -type f -name '*.md' ! -name 'README.md' | sort | tail -n 3
}

steering_task_files() {
  local dir="$1"
  [ -d "$dir" ] || return 0
  find "$dir" -maxdepth 1 -type f -name '*.md' ! -name 'README.md' ! -name 'TASK_TEMPLATE.md' | sort
}

steering_task_count() {
  local dir="$1"
  steering_task_files "$dir" | awk 'END {print NR + 0}'
}

steering_frontmatter_value() {
  local task_file="$1"
  local field="$2"

  [ -f "$task_file" ] || return 0

  python3 - "$task_file" "$field" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
field = sys.argv[2]
text = path.read_text()

match = re.match(r"(?s)^---\n(.*?)\n---\n?", text)
if not match:
    raise SystemExit(0)

for line in match.group(1).splitlines():
    if ":" not in line:
        continue
    key, value = line.split(":", 1)
    if key.strip() != field:
        continue
    value = value.strip().strip('"').strip("'")
    print(value)
    raise SystemExit(0)
PY
}

steering_task_title() {
  local task_file="$1"
  local title

  [ -f "$task_file" ] || return 0
  title="$(steering_frontmatter_value "$task_file" title || true)"
  if [ -n "$title" ]; then
    printf '%s\n' "$title"
    return 0
  fi

  python3 - "$task_file" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
for line in path.read_text().splitlines():
    stripped = line.strip()
    if stripped.startswith("# "):
        print(stripped[2:].strip())
        raise SystemExit(0)
print(path.stem.replace("-", " "))
PY
}

steering_task_relative_path() {
  local task_file="$1"
  [ -n "$task_file" ] || return 0
  relative_to_root "$task_file" "$AUTODEV_ROOT"
}

current_steering_task_path() {
  local task_file

  task_file="$(steering_task_files "$AUTODEV_STEERING_ACTIVE_DIR" | head -n 1 || true)"
  if [ -n "$task_file" ]; then
    printf '%s\n' "$task_file"
    return 0
  fi

  task_file="$(steering_task_files "$AUTODEV_STEERING_INBOX_DIR" | head -n 1 || true)"
  if [ -n "$task_file" ]; then
    printf '%s\n' "$task_file"
  fi
}

current_steering_source() {
  local task_file
  task_file="$(current_steering_task_path || true)"
  [ -n "$task_file" ] || return 0

  case "$task_file" in
    "$AUTODEV_STEERING_ACTIVE_DIR"/*) printf 'steering/active\n' ;;
    "$AUTODEV_STEERING_INBOX_DIR"/*) printf 'steering/inbox\n' ;;
  esac
}

current_steering_focus() {
  local task_file title relative_path

  task_file="$(current_steering_task_path || true)"
  [ -n "$task_file" ] || return 0

  title="$(steering_task_title "$task_file" || true)"
  relative_path="$(steering_task_relative_path "$task_file" || true)"

  if [ -n "$title" ] && [ -n "$relative_path" ]; then
    printf '%s (%s)\n' "$title" "$relative_path"
    return 0
  fi

  if [ -n "$title" ]; then
    printf '%s\n' "$title"
    return 0
  fi

  printf '%s\n' "$relative_path"
}

current_focus_source() {
  local steering_source
  steering_source="$(current_steering_source || true)"
  if [ -n "$steering_source" ]; then
    printf '%s\n' "$steering_source"
    return 0
  fi

  if [ -n "$(current_queue_focus || true)" ]; then
    printf 'queue\n'
  fi
}

current_focus_label() {
  local steering_focus queue_focus
  steering_focus="$(current_steering_focus || true)"
  if [ -n "$steering_focus" ]; then
    printf '%s\n' "$steering_focus"
    return 0
  fi

  queue_focus="$(current_queue_focus || true)"
  if [ -n "$queue_focus" ]; then
    printf '%s\n' "$queue_focus"
  fi
}

advance_focus_cursor() {
  if [ -n "$(current_steering_task_path || true)" ]; then
    return 0
  fi
  advance_queue_focus
}

linear_sync_status() {
  [ -f "$AUTODEV_STEERING_LINEAR_LAST_SYNC_FILE" ] || {
    printf 'unconfigured\n'
    return 0
  }

  python3 - "$AUTODEV_STEERING_LINEAR_LAST_SYNC_FILE" <<'PY'
from pathlib import Path
import json
import sys

path = Path(sys.argv[1])
try:
    payload = json.loads(path.read_text() or "{}")
except Exception:
    print("unknown")
    raise SystemExit(0)

status = payload.get("status")
timestamp = payload.get("synced_at")
extras = []
for key, label in (
    ("mirror_count", "mirror"),
    ("imported_count", "imported"),
    ("existing_count", "existing"),
    ("outbox_count", "outbox"),
):
    value = payload.get(key)
    if value is not None:
        extras.append(f"{label}={value}")

suffix = f" ({', '.join(extras)})" if extras else ""
if status and timestamp:
    print(f"{status} @ {timestamp}{suffix}")
elif status:
    print(f"{status}{suffix}")
elif timestamp:
    print(f"synced @ {timestamp}{suffix}")
else:
    print("never")
PY
}

memory_backend_available() {
  [ "$AUTODEV_MEMORY_BACKEND" != "none" ]
}

memory_backend_status_field() {
  local field="$1"

  [ -f "$AUTODEV_MEMORY_BACKEND_STATUS_FILE" ] || return 0

  python3 - "$AUTODEV_MEMORY_BACKEND_STATUS_FILE" "$field" <<'PY'
from pathlib import Path
import json
import sys

path = Path(sys.argv[1])
field = sys.argv[2]
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

memory_backend_status_label() {
  local status indexed query_source

  status="$(memory_backend_status_field status || true)"
  indexed="$(memory_backend_status_field indexed_count || true)"
  query_source="$(memory_backend_status_field query_source || true)"

  if [ -z "$status" ]; then
    printf 'unindexed\n'
    return 0
  fi

  if [ -n "$indexed" ] || [ -n "$query_source" ]; then
    printf '%s' "$status"
    if [ -n "$indexed" ]; then
      printf ' (indexed=%s' "$indexed"
      if [ -n "$query_source" ]; then
        printf ', query=%s' "$query_source"
      fi
      printf ')'
    elif [ -n "$query_source" ]; then
      printf ' (query=%s)' "$query_source"
    fi
    printf '\n'
    return 0
  fi

  printf '%s\n' "$status"
}

refresh_memory_backend() {
  if ! memory_backend_available; then
    return 0
  fi

  python3 "$AUTODEV_ROOT/automation/memory-backend-index.py" \
    --autodev-root "$AUTODEV_ROOT" \
    --project-root "$PROJECT_ROOT" \
    --context-files "$AUTODEV_CONTEXT_FILES" \
    --output-status "$AUTODEV_MEMORY_BACKEND_STATUS_FILE" \
    --db-path "$AUTODEV_MEMORY_BACKEND_DB" \
    --graph-path "$AUTODEV_MEMORY_BACKEND_GRAPH_FILE" \
    --run-summaries "$AUTODEV_MEMORY_BACKEND_RUN_SUMMARIES_FILE" \
    --use-rg "$AUTODEV_MEMORY_USE_RG" \
    --use-mgrep "$AUTODEV_MEMORY_USE_MGREP" \
    --mgrep-store "$AUTODEV_MEMORY_MGREP_STORE"
}

refresh_memory_retrieval() {
  local query="$1"

  if ! memory_backend_available; then
    return 0
  fi

  [ -n "$query" ] || query="$(current_focus_label || true)"
  [ -n "$query" ] || query="$(head -n 1 "$AUTODEV_OBJECTIVE_FILE" 2>/dev/null || true)"
  [ -n "$query" ] || query="$PROJECT_NAME"

  python3 "$AUTODEV_ROOT/automation/memory-backend-retrieve.py" \
    --autodev-root "$AUTODEV_ROOT" \
    --db-path "$AUTODEV_MEMORY_BACKEND_DB" \
    --status-file "$AUTODEV_MEMORY_BACKEND_STATUS_FILE" \
    --output "$AUTODEV_MEMORY_RETRIEVAL_FILE" \
    --project-root "$PROJECT_ROOT" \
    --query "$query" \
    --limit "$AUTODEV_MEMORY_RETRIEVE_LIMIT" \
    --use-rg "$AUTODEV_MEMORY_USE_RG" \
    --rg-max-matches "$AUTODEV_MEMORY_RG_MAX_MATCHES" \
    --use-mgrep "$AUTODEV_MEMORY_USE_MGREP" \
    --mgrep-store "$AUTODEV_MEMORY_MGREP_STORE" \
    --mgrep-sync "$AUTODEV_MEMORY_MGREP_SYNC" \
    --mgrep-max-count "$AUTODEV_MEMORY_MGREP_MAX_COUNT" \
    --mgrep-max-file-size "$AUTODEV_MEMORY_MGREP_MAX_FILE_SIZE" \
    --mgrep-max-file-count "$AUTODEV_MEMORY_MGREP_MAX_FILE_COUNT"
}

refresh_steering_state() {
  python3 - \
    "$AUTODEV_ROOT" \
    "$AUTODEV_STEERING_ACTIVE_DIR" \
    "$AUTODEV_STEERING_INBOX_DIR" \
    "$AUTODEV_STEERING_DONE_DIR" \
    "$AUTODEV_STEERING_ARCHIVE_DIR" \
    "$AUTODEV_STEERING_LINEAR_MIRROR_DIR" \
    "$AUTODEV_STEERING_LINEAR_MAP_FILE" \
    "$AUTODEV_STEERING_LINEAR_OUTBOX_FILE" \
    "$AUTODEV_STEERING_LINEAR_LAST_SYNC_FILE" <<'PY'
from __future__ import annotations

from datetime import datetime, timezone
import json
from pathlib import Path
import re
import sys

autodev_root = Path(sys.argv[1]).resolve()
active_dir = Path(sys.argv[2]).resolve()
inbox_dir = Path(sys.argv[3]).resolve()
done_dir = Path(sys.argv[4]).resolve()
archive_dir = Path(sys.argv[5]).resolve()
mirror_dir = Path(sys.argv[6]).resolve()
map_path = Path(sys.argv[7]).resolve()
outbox_path = Path(sys.argv[8]).resolve()
last_sync_path = Path(sys.argv[9]).resolve()

bucket_dirs = {
    "active": active_dir,
    "inbox": inbox_dir,
    "done": done_dir,
    "archive": archive_dir,
}


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def slugify(value: str) -> str:
    slug = re.sub(r"[^a-zA-Z0-9]+", "-", value.strip().lower()).strip("-")
    return slug or "task"


def parse_frontmatter(text: str) -> tuple[dict[str, str], str]:
    match = re.match(r"(?s)^---\n(.*?)\n---\n?", text)
    if not match:
      return {}, text

    frontmatter: dict[str, str] = {}
    for line in match.group(1).splitlines():
        if ":" not in line:
            continue
        key, value = line.split(":", 1)
        frontmatter[key.strip()] = value.strip().strip('"').strip("'")
    return frontmatter, text[match.end():].lstrip()


def first_heading(body: str) -> str:
    for line in body.splitlines():
        stripped = line.strip()
        if stripped.startswith("# "):
            return stripped[2:].strip()
    return ""


def classify_bucket(status: str) -> str:
    normalized = status.strip().lower().replace("_", "-")
    if normalized in {"active", "in-progress", "doing", "current"}:
        return "active"
    if normalized in {"done", "completed", "closed", "resolved", "accepted"}:
        return "done"
    if normalized in {"archive", "archived", "stale", "cancelled", "canceled"}:
        return "archive"
    return "inbox"


def read_task(path: Path, bucket: str) -> dict[str, str]:
    text = path.read_text()
    frontmatter, body = parse_frontmatter(text)
    title = frontmatter.get("title") or first_heading(body) or path.stem.replace("-", " ")
    linear_id = frontmatter.get("linear_id", "")
    task_id = frontmatter.get("id") or path.stem
    status = frontmatter.get("status") or bucket
    updated_at = frontmatter.get("updated_at") or datetime.fromtimestamp(path.stat().st_mtime, timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    source = frontmatter.get("source") or "local"
    return {
        "id": task_id,
        "title": title,
        "linear_id": linear_id,
        "status": status,
        "bucket": bucket,
        "source": source,
        "updated_at": updated_at,
        "path": str(path.relative_to(autodev_root)),
        "body": body.strip(),
    }


def write_task(path: Path, payload: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    body = payload.get("body", "").strip()
    body = body or "# Task\n\n## Goal\n\n- fill in goal\n"
    frontmatter_lines = [
        "---",
        f"id: {payload['id']}",
        f"title: {payload['title']}",
        f"status: {payload['status']}",
        f"priority: {payload.get('priority', 'medium')}",
        f"source: {payload.get('source', 'local')}",
        f"linear_id: {payload.get('linear_id', '')}",
        f"area: {payload.get('area', '')}",
        f"updated_at: {payload['updated_at']}",
        "---",
        "",
    ]
    path.write_text("\n".join(frontmatter_lines) + body.rstrip() + "\n")


try:
    imported_count = 0
    existing_count = 0
    local_tasks: list[dict[str, str]] = []
    by_linear_id: dict[str, dict[str, str]] = {}
    by_task_id: dict[str, dict[str, str]] = {}

    for bucket, bucket_dir in bucket_dirs.items():
        for task_path in sorted(bucket_dir.glob("*.md")):
            if task_path.name == "README.md":
                continue
            task = read_task(task_path, bucket)
            local_tasks.append(task)
            if task["linear_id"]:
                by_linear_id[task["linear_id"]] = task
            by_task_id[task["id"]] = task

    mirror_tasks: list[dict[str, str]] = []
    if mirror_dir.is_dir():
        for mirror_path in sorted(mirror_dir.glob("*.md")):
            if mirror_path.name == "README.md":
                continue
            frontmatter, body = parse_frontmatter(mirror_path.read_text())
            title = frontmatter.get("title") or first_heading(body) or mirror_path.stem.replace("-", " ")
            linear_id = frontmatter.get("linear_id") or mirror_path.stem
            task_id = frontmatter.get("id") or f"linear-{slugify(linear_id)}"
            status = frontmatter.get("status") or "inbox"
            updated_at = frontmatter.get("updated_at") or datetime.fromtimestamp(mirror_path.stat().st_mtime, timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
            task = {
                "id": task_id,
                "title": title,
                "linear_id": linear_id,
                "status": status,
                "bucket": classify_bucket(status),
                "source": frontmatter.get("source") or "linear-mirror",
                "updated_at": updated_at,
                "path": str(mirror_path.relative_to(autodev_root)),
                "body": body.strip(),
            }
            mirror_tasks.append(task)

            local_match = by_linear_id.get(linear_id) or by_task_id.get(task_id)
            if local_match:
                existing_count += 1
                continue

            local_name = f"linear-{slugify(linear_id)}.md"
            target_dir = bucket_dirs[task["bucket"]]
            target_path = target_dir / local_name
            payload = dict(task)
            payload["path"] = str(target_path.relative_to(autodev_root))
            payload["source"] = "linear-mirror"
            write_task(target_path, payload)
            imported_count += 1
            local_tasks.append(read_task(target_path, task["bucket"]))
            by_linear_id[linear_id] = local_tasks[-1]
            by_task_id[task_id] = local_tasks[-1]

    map_payload = {
        "generated_at": now_iso(),
        "tasks": [
            {
                "id": task["id"],
                "title": task["title"],
                "linear_id": task["linear_id"],
                "status": task["status"],
                "bucket": task["bucket"],
                "source": task["source"],
                "updated_at": task["updated_at"],
                "path": task["path"],
            }
            for task in sorted(local_tasks, key=lambda item: item["path"])
        ],
    }
    map_path.parent.mkdir(parents=True, exist_ok=True)
    map_path.write_text(json.dumps(map_payload, indent=2) + "\n")

    outbox_records = []
    for task in sorted(local_tasks, key=lambda item: item["path"]):
        if not task["linear_id"]:
            continue
        outbox_records.append(
            {
                "op": "upsert",
                "id": task["id"],
                "title": task["title"],
                "linear_id": task["linear_id"],
                "status": task["status"],
                "bucket": task["bucket"],
                "source": task["source"],
                "updated_at": task["updated_at"],
                "path": task["path"],
            }
        )
    outbox_path.parent.mkdir(parents=True, exist_ok=True)
    outbox_path.write_text("".join(json.dumps(item) + "\n" for item in outbox_records))

    last_sync_payload = {
        "status": "ok" if mirror_tasks else "local-only",
        "synced_at": now_iso(),
        "mirror_count": len(mirror_tasks),
        "imported_count": imported_count,
        "existing_count": existing_count,
        "outbox_count": len(outbox_records),
    }
except Exception as exc:  # noqa: BLE001
    last_sync_payload = {
        "status": "error",
        "synced_at": now_iso(),
        "error": str(exc),
    }

last_sync_path.parent.mkdir(parents=True, exist_ok=True)
last_sync_path.write_text(json.dumps(last_sync_payload, indent=2) + "\n")
print(json.dumps(last_sync_payload))
PY
}

extract_next_step_from_output() {
  local output_file="$1"

  [ -f "$output_file" ] || return 0

  python3 - "$output_file" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text()
patterns = [
    r"(?ims)^5\.\s+.*?(?:next best step|next step).*?\n(.*?)(?=^\d+\.\s|\Z)",
    r"(?ims)^#+\s*(?:5\.\s*)?next best step\s*\n(.*?)(?=^#|\Z)",
]
for pattern in patterns:
    match = re.search(pattern, text)
    if not match:
        continue
    body = re.split(r"(?i)\bauto-push succeeded\b|\bauto-push failed\b|\bcommit:\b", match.group(1), maxsplit=1)[0]
    body_lines = [line.strip() for line in body.splitlines() if line.strip()]
    body = body_lines[0] if body_lines else body
    body = re.sub(r"\s+", " ", body).strip(" -:\n\t")
    if body:
        print(body)
        raise SystemExit(0)

lines = [line.strip() for line in text.splitlines() if line.strip()]
for line in reversed(lines):
    lower = line.lower()
    if lower.startswith("5. ") or "next best step" in lower or lower.startswith("next:"):
        cleaned = re.sub(r"^\d+\.\s*", "", line).strip()
        cleaned = re.sub(r"(?i)^next(?: best)? step[:\s-]*", "", cleaned).strip()
        cleaned = re.split(r"(?i)\bauto-push succeeded\b|\bauto-push failed\b|\bcommit:\b", cleaned, maxsplit=1)[0].strip()
        if cleaned:
            print(cleaned)
            raise SystemExit(0)
PY
}

refresh_semantic_memory() {
  python3 - "$PROJECT_NAME" "$PROJECT_ROOT" "$AUTODEV_GIT_ROOT" "$AUTODEV_GIT_SCOPE" "$AUTODEV_PROJECT_MAP_FILE" "$AUTODEV_COMMANDS_FILE" <<'PY'
from __future__ import annotations

from collections import Counter
import json
import os
from pathlib import Path
import re
import subprocess
import sys

project_name = sys.argv[1]
repo_root = Path(sys.argv[2]).resolve()
git_root = Path(sys.argv[3]).resolve()
git_scope = sys.argv[4]
project_map_path = Path(sys.argv[5])
commands_path = Path(sys.argv[6])

scan_skip_dirs = {
    ".git",
    ".hg",
    ".svn",
    "node_modules",
    ".venv",
    "venv",
    "__pycache__",
    "dist",
    "build",
    ".next",
    ".svelte-kit",
    ".turbo",
}
doc_candidates = [
    "AGENTS.md",
    "README.md",
    "CLAUDE.md",
    "docs/README.md",
    "docs/reference-projects.md",
    "ROADMAP.md",
    "ARCHITECTURE.md",
]
language_map = {
    ".py": "Python",
    ".ts": "TypeScript",
    ".tsx": "TypeScript",
    ".js": "JavaScript",
    ".jsx": "JavaScript",
    ".svelte": "Svelte",
    ".go": "Go",
    ".rs": "Rust",
    ".sh": "Shell",
    ".md": "Markdown",
    ".yml": "YAML",
    ".yaml": "YAML",
    ".json": "JSON",
    ".toml": "TOML",
}
area_markers = {
    "package.json",
    "pyproject.toml",
    "requirements.txt",
    "Pipfile",
    "go.mod",
    "Cargo.toml",
    "Makefile",
    "svelte.config.js",
    "svelte.config.ts",
    "next.config.js",
    "next.config.ts",
    "Dockerfile",
}
package_manager_markers = [
    ("pnpm", "pnpm-lock.yaml"),
    ("yarn", "yarn.lock"),
    ("npm", "package-lock.json"),
    ("bun", "bun.lockb"),
    ("uv", "uv.lock"),
    ("poetry", "poetry.lock"),
    ("pip", "requirements.txt"),
]
preferred_make_targets = [
    "setup",
    "onboard",
    "dev",
    "dev-up",
    "dev-status",
    "beta-up",
    "beta-status",
    "test",
    "test-smoke",
    "build",
    "check",
    "lint",
    "validate-paths",
]
preferred_package_scripts = ["dev", "build", "check", "test", "lint", "start"]


def run_cmd(args: list[str], cwd: Path) -> subprocess.CompletedProcess[str]:
    return subprocess.run(args, cwd=cwd, capture_output=True, text=True, check=False)


def tracked_files() -> list[Path]:
    result = run_cmd(["git", "ls-files", "-z"], git_root)
    if result.returncode != 0:
        return fallback_files()
    files: list[Path] = []
    for raw in result.stdout.split("\0"):
        if not raw:
            continue
        rel = Path(raw)
        if git_scope != ".":
            try:
                rel = rel.relative_to(git_scope)
            except ValueError:
                continue
        files.append(rel)
    return files


def fallback_files() -> list[Path]:
    results: list[Path] = []
    for current_root, dirnames, filenames in os.walk(repo_root):
        dirnames[:] = [name for name in dirnames if name not in scan_skip_dirs and not name.startswith(".")]
        current_path = Path(current_root)
        for filename in filenames:
            if filename.startswith(".") and filename not in {".gitignore", ".env.example"}:
                continue
            results.append((current_path / filename).relative_to(repo_root))
            if len(results) >= 5000:
                return results
    return results


def detect_docs(files: list[Path]) -> list[str]:
    file_set = {path.as_posix() for path in files}
    docs = [candidate for candidate in doc_candidates if candidate in file_set]
    if docs:
        return docs
    return [path.as_posix() for path in files if path.suffix.lower() == ".md"][:8]


def detect_languages(files: list[Path]) -> list[tuple[str, int]]:
    counter: Counter[str] = Counter()
    for path in files:
        language = language_map.get(path.suffix.lower())
        if language:
            counter[language] += 1
    return counter.most_common(8)


def detect_package_managers(files: list[Path]) -> list[str]:
    file_set = {path.as_posix() for path in files}
    managers: list[str] = []
    for manager, marker in package_manager_markers:
        if marker in file_set or (repo_root / marker).exists():
            managers.append(manager)
    return managers


def infer_area_kind(path: Path, markers: list[str]) -> str:
    marker_set = set(markers)
    if "package.json" in marker_set and ("svelte.config.js" in marker_set or "svelte.config.ts" in marker_set):
        return "frontend-app"
    if "package.json" in marker_set and ("next.config.js" in marker_set or "next.config.ts" in marker_set):
        return "frontend-app"
    if "pyproject.toml" in marker_set or "requirements.txt" in marker_set:
        if "package.json" in marker_set:
            return "mixed-service"
        return "python-service"
    if "package.json" in marker_set:
        if "packages" in path.parts or "libs" in path.parts:
            return "shared-package"
        return "node-package"
    if "go.mod" in marker_set:
        return "go-service"
    if "Cargo.toml" in marker_set:
        return "rust-service"
    if "Makefile" in marker_set:
        return "make-driven-area"
    return "module"


def detect_areas() -> list[dict[str, str]]:
    areas: list[dict[str, str]] = []
    seen: set[str] = set()
    for current_root, dirnames, filenames in os.walk(repo_root):
        current_path = Path(current_root)
        depth = len(current_path.relative_to(repo_root).parts)
        dirnames[:] = [name for name in dirnames if name not in scan_skip_dirs and not name.startswith(".")]
        if depth > 3:
            dirnames[:] = []
            continue
        markers = sorted(set(filenames) & area_markers)
        if not markers and current_path != repo_root:
            continue
        rel = "." if current_path == repo_root else current_path.relative_to(repo_root).as_posix()
        if rel in seen:
            continue
        seen.add(rel)
        areas.append({"path": rel, "kind": infer_area_kind(current_path.relative_to(repo_root) if current_path != repo_root else Path("."), markers), "markers": ", ".join(markers) if markers else "no markers"})
    areas.sort(key=lambda item: (0 if item["path"] == "." else item["path"].count("/"), item["path"]))
    return areas[:16]


def parse_make_targets() -> list[str]:
    makefile_path = repo_root / "Makefile"
    if not makefile_path.is_file():
        return []
    pattern = re.compile(r"^([A-Za-z0-9][A-Za-z0-9._-]+):(?:\s|$)")
    targets: list[str] = []
    for line in makefile_path.read_text().splitlines():
        match = pattern.match(line)
        if match and not match.group(1).startswith("."):
            targets.append(match.group(1))
    return targets


def read_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text())
    except Exception:
        return {}


def package_manager_for(path: Path) -> str | None:
    current = path
    while True:
        for manager, marker in package_manager_markers:
            if manager in {"uv", "poetry", "pip"}:
                continue
            if (current / marker).exists():
                return manager
        if current == repo_root:
            break
        current = current.parent
    return None


def render_package_command(manager: str | None, rel_path: str, script_name: str) -> str:
    if manager == "pnpm":
        return f"pnpm {script_name}" if rel_path == "." else f"pnpm --dir {rel_path} {script_name}"
    if manager == "yarn":
        return f"yarn {script_name}" if rel_path == "." else f"yarn --cwd {rel_path} {script_name}"
    if manager == "bun":
        return f"bun run {script_name}" if rel_path == "." else f"bun --cwd {rel_path} run {script_name}"
    if manager == "npm":
        return f"npm run {script_name}" if rel_path == "." else f"npm --prefix {rel_path} run {script_name}"
    return f"run {script_name} in {rel_path}"


def detect_command_hints(areas: list[dict[str, str]]) -> list[str]:
    hints: list[str] = []
    make_targets = parse_make_targets()
    for target in preferred_make_targets:
        if target in make_targets:
            hints.append(f"make {target}")

    for area in areas:
        area_path = repo_root if area["path"] == "." else repo_root / area["path"]
        package_json = area_path / "package.json"
        if package_json.is_file():
            payload = read_json(package_json)
            scripts = payload.get("scripts", {}) if isinstance(payload, dict) else {}
            manager = package_manager_for(area_path)
            for script_name in preferred_package_scripts:
                if script_name in scripts:
                    hints.append(render_package_command(manager, area["path"], script_name))
        if (area_path / "pyproject.toml").is_file() or (area_path / "requirements.txt").is_file():
            if (repo_root / "uv.lock").is_file() or (area_path / "uv.lock").is_file():
                hints.append("uv run pytest" if area["path"] == "." else f"cd {area['path']} && uv run pytest")
            else:
                hints.append("python3 -m pytest" if area["path"] == "." else f"cd {area['path']} && python3 -m pytest")

    deduped: list[str] = []
    seen: set[str] = set()
    for hint in hints:
        if hint in seen:
            continue
        seen.add(hint)
        deduped.append(hint)
    return deduped[:16]


files = tracked_files()
docs = detect_docs(files)
languages = detect_languages(files)
managers = detect_package_managers(files)
areas = detect_areas()
commands = detect_command_hints(areas)
surface = "repo-local-autodevelopment" if repo_root != git_root else "centralized-launchd"
reason = (
    "The target path lives inside a larger git repository, so the scoped repo-local package is the safer starting surface."
    if repo_root != git_root
    else "The target is a standalone git repository, so the canonical dedicated-clone control plane remains the strongest full-system path."
)

project_map = [
    f"# Project Map: {project_name}",
    "",
    "**Auto-generated from the current repository shape.**",
    "",
    "## Repository Shape",
    "",
    f"- repo root: `{repo_root}`",
    f"- git root: `{git_root}`",
    f"- git scope: `{git_scope}`",
    "",
    "## Docs And Context",
    "",
]
project_map.extend([f"- `{item}`" for item in docs] or ["- none detected"])
project_map.extend(["", "## Detected Stack", "", "### Languages", ""])
project_map.extend([f"- {language}: {count} tracked files" for language, count in languages] or ["- none detected"])
project_map.extend(["", "### Package Managers", ""])
project_map.extend([f"- {manager}" for manager in managers] or ["- none detected"])
project_map.extend(["", "## Likely Project Areas", ""])
project_map.extend([f"- `{item['path']}` — {item['kind']} ({item['markers']})" for item in areas] or ["- none detected"])
project_map.extend(
    [
        "",
        "## Recommended Automation Policy",
        "",
        "- canonical full system: `centralized-launchd`",
        f"- best starting surface: `{surface}`",
        f"- reason: {reason}",
        "- recommended adapter: `auto`",
        "- require clean tree: `true`",
        "- auto commit: `false`",
        "- auto push: `false`",
    ]
)
project_map_path.write_text("\n".join(project_map) + "\n")

commands_md = [
    "# Commands",
    "",
    "**Auto-generated command hints from the current repository shape.**",
    "",
    "Use these as starting points. Keep only verified commands here.",
    "",
]
commands_md.extend([f"- `{command}`" for command in commands] or ["- no commands inferred yet"])
commands_path.write_text("\n".join(commands_md) + "\n")
PY
}

refresh_active_memory() {
  local last_status focus commit_sha next_step changes_text steering_source steering_task steering_task_relative
  local test_status visual_test_status
  last_status="none"
  focus="$(current_focus_label || true)"
  commit_sha="-"
  next_step=""
  changes_text="- none"
  steering_source="$(current_steering_source || true)"
  steering_task="$(current_steering_task_path || true)"
  steering_task_relative="$(steering_task_relative_path "$steering_task" || true)"
  test_status="$(verification_status_value "$AUTODEV_LAST_TEST_STATUS_FILE")"
  visual_test_status="$(verification_status_value "$AUTODEV_LAST_VISUAL_TEST_STATUS_FILE")"

  if [ -f "$AUTODEV_STATE_DIR/last-cycle-status.txt" ]; then
    last_status="$(cat "$AUTODEV_STATE_DIR/last-cycle-status.txt")"
  fi

  if [ -f "$AUTODEV_LAST_CYCLE_COMMIT_FILE" ]; then
    commit_sha="$(cat "$AUTODEV_LAST_CYCLE_COMMIT_FILE")"
  fi

  if [ -f "$AUTODEV_LAST_CYCLE_CHANGES_FILE" ]; then
    changes_text="$(cat "$AUTODEV_LAST_CYCLE_CHANGES_FILE")"
  fi

  if [ -f "$AUTODEV_LAST_CYCLE_SUMMARY_FILE" ]; then
    next_step="$(python3 - "$AUTODEV_LAST_CYCLE_SUMMARY_FILE" <<'PY'
from pathlib import Path
import re
import sys

text = Path(sys.argv[1]).read_text()
match = re.search(r"(?ims)^Output excerpt:\n(.*)$", text)
body = match.group(1) if match else text
patterns = [
    r"(?ims)^5\.\s+.*?(?:next best step|next step).*?\n(.*?)(?=^\d+\.\s|\Z)",
    r"(?ims)^#+\s*(?:5\.\s*)?next best step\s*\n(.*?)(?=^#|\Z)",
]
for pattern in patterns:
    found = re.search(pattern, body)
    if not found:
        continue
    line = re.split(r"(?i)\bauto-push succeeded\b|\bauto-push failed\b|\bcommit:\b", found.group(1), maxsplit=1)[0]
    line_lines = [entry.strip() for entry in line.splitlines() if entry.strip()]
    line = line_lines[0] if line_lines else line
    line = re.sub(r"\s+", " ", line).strip(" -:\n\t")
    if line:
      print(line)
      raise SystemExit(0)
PY
)"
  fi

  {
    printf '# Current Task\n\n'
    printf -- '- project: `%s`\n' "$PROJECT_NAME"
    printf -- '- focus source: `%s`\n' "${steering_source:-queue-or-none}"
    printf -- '- current focus: %s\n' "${focus:-none}"
    if [ -n "$steering_task_relative" ]; then
      printf -- '- steering task file: `%s`\n' "$steering_task_relative"
    fi
    printf -- '- last cycle status: `%s`\n' "$last_status"
    printf -- '- last commit: `%s`\n' "${commit_sha:-none}"
    printf -- '- last automated test: `%s`\n' "$test_status"
    printf -- '- last visual test: `%s`\n' "$visual_test_status"
    printf '\n## Files touched\n\n%s\n' "$changes_text"
    if [ -n "$steering_task" ] && [ -f "$steering_task" ]; then
      printf '\n## Steering Task\n\n'
      cat "$steering_task"
      printf '\n'
    fi
  } > "$AUTODEV_CURRENT_TASK_FILE"

  {
    printf '# Open Questions\n\n'
    printf -- '- none captured automatically\n'
    printf -- '- promote unresolved architecture or product questions here when they matter across cycles\n'
  } > "$AUTODEV_OPEN_QUESTIONS_FILE"

  {
    printf '# Next Actions\n\n'
    if [ -n "$next_step" ]; then
      printf -- '- %s\n' "$next_step"
    elif [ -n "$focus" ]; then
      printf -- '- Continue the current focus: %s\n' "$focus"
    else
      printf -- '- Review steering/inbox or the fallback queue and choose one narrow high-value step\n'
    fi
  } > "$AUTODEV_NEXT_ACTIONS_FILE"
}

record_cycle_memory() {
  local run_id="$1"
  local status="$2"
  local focus="$3"
  local changes="$4"
  local summary="$5"
  local commit_sha="$6"
  local output_file="${7:-}"
  local session_file next_step timestamp steering_source steering_task steering_task_relative

  timestamp="$(timestamp_utc)"
  session_file="$AUTODEV_SESSION_DIR/${run_id}.md"
  next_step="$(extract_next_step_from_output "$output_file" || true)"
  steering_source="$(current_steering_source || true)"
  steering_task="$(current_steering_task_path || true)"
  steering_task_relative="$(steering_task_relative_path "$steering_task" || true)"

  {
    printf '# Session %s\n\n' "$run_id"
    printf -- '- generated: %s\n' "$timestamp"
    printf -- '- project: `%s`\n' "$PROJECT_NAME"
    printf -- '- status: `%s`\n' "$status"
    printf -- '- focus: %s\n' "${focus:-none}"
    printf -- '- focus source: `%s`\n' "${steering_source:-queue-or-none}"
    if [ -n "$steering_task_relative" ]; then
      printf -- '- steering task: `%s`\n' "$steering_task_relative"
    fi
    printf -- '- commit: `%s`\n' "${commit_sha:-none}"
    printf '\n## Files Changed\n\n'
    if [ -n "$changes" ]; then
      printf '%s\n' "$changes"
    else
      printf -- '- none\n'
    fi
    if [ -n "$summary" ]; then
      printf '\n## Agent Summary\n\n%s\n' "$summary"
    fi
    if [ -n "$next_step" ]; then
      printf '\n## Next Step\n\n- %s\n' "$next_step"
    fi
  } > "$session_file"

  {
    printf '## %s — %s\n' "${timestamp%%T*}" "$status"
    printf -- '- focus: %s\n' "${focus:-none}"
    printf -- '- source: %s\n' "${steering_source:-queue-or-none}"
    if [ -n "$steering_task_relative" ]; then
      printf -- '- steering-task: `%s`\n' "$steering_task_relative"
    fi
    printf -- '- commit: `%s`\n' "${commit_sha:-none}"
    if [ -n "$changes" ]; then
      printf -- '- files: %s\n' "$(single_line_text "$changes")"
    else
      printf -- '- files: none\n'
    fi
    if [ -n "$next_step" ]; then
      printf -- '- next: %s\n' "$next_step"
    fi
    printf '\n'
  } >> "$AUTODEV_CHANGELOG_FILE"

  if [ "$status" = "failure" ]; then
    {
      printf '## %s — autonomous cycle failure\n' "${timestamp%%T*}"
      printf -- '- cause: see session `%s`\n' "$run_id"
      printf -- '- signal: cycle status `failure`\n'
      printf -- '- guardrail: review `%s` before re-running broad edits\n' "$session_file"
      printf -- '- evidence: `%s`\n\n' "$session_file"
    } >> "$AUTODEV_FAILURES_FILE"
  fi

  refresh_active_memory
}

is_excluded_change() {
  local path="$1"
  local pattern

  case "$path" in
    "$AUTODEV_INTERNAL_GIT_SCOPE"|"$AUTODEV_INTERNAL_GIT_SCOPE"/*)
      return 0
      ;;
  esac

  [ -z "$AUTODEV_CLEAN_TREE_EXCLUDES" ] && return 1

  for pattern in $AUTODEV_CLEAN_TREE_EXCLUDES; do
    case "$path" in
      $pattern) return 0 ;;
    esac
  done

  return 1
}

scoped_git_status() {
  local untracked_mode="$1"
  if [ "$AUTODEV_GIT_SCOPE" = "." ]; then
    git -C "$AUTODEV_GIT_ROOT" status --porcelain=v1 --untracked-files="$untracked_mode" --ignore-submodules=all
  else
    git -C "$AUTODEV_GIT_ROOT" status --porcelain=v1 --untracked-files="$untracked_mode" --ignore-submodules=all -- "$AUTODEV_GIT_SCOPE"
  fi
}

filter_status_lines() {
  local line path output
  output=""

  while IFS= read -r line; do
    [ -z "$line" ] && continue
    path="${line#?? }"
    if is_excluded_change "$path"; then
      continue
    fi
    output="${output}${line}"$'\n'
  done

  printf '%s' "$output"
}

tracked_changes() {
  filter_status_lines < <(scoped_git_status no)
}

project_changes() {
  filter_status_lines < <(scoped_git_status all)
}

project_changed_paths() {
  local path
  {
    if [ "$AUTODEV_GIT_SCOPE" = "." ]; then
      git -C "$AUTODEV_GIT_ROOT" diff --name-only --diff-filter=ACDMRTUXB
      git -C "$AUTODEV_GIT_ROOT" diff --cached --name-only --diff-filter=ACDMRTUXB
      git -C "$AUTODEV_GIT_ROOT" ls-files --others --exclude-standard
    else
      git -C "$AUTODEV_GIT_ROOT" diff --name-only --diff-filter=ACDMRTUXB -- "$AUTODEV_GIT_SCOPE"
      git -C "$AUTODEV_GIT_ROOT" diff --cached --name-only --diff-filter=ACDMRTUXB -- "$AUTODEV_GIT_SCOPE"
      git -C "$AUTODEV_GIT_ROOT" ls-files --others --exclude-standard -- "$AUTODEV_GIT_SCOPE"
    fi
  } | awk 'NF && !seen[$0]++' | while IFS= read -r path; do
    [ -z "$path" ] && continue
    if is_excluded_change "$path"; then
      continue
    fi
    printf '%s\n' "$path"
  done
}

project_change_report() {
  local path output
  output=""

  while IFS= read -r path; do
    [ -z "$path" ] && continue
    output="${output}- ${path}"$'\n'
  done < <(project_changed_paths)

  printf '%s' "$output"
}

prompt_status_snapshot() {
  local dirty
  dirty="$(tracked_changes)"
  if [ -n "$dirty" ]; then
    printf '%s' "$dirty"
    return 0
  fi

  printf '(no tracked changes in project scope)\n'
}

repo_status_short() {
  scoped_git_status all
}

repo_recent_commits() {
  if [ "$AUTODEV_GIT_SCOPE" = "." ]; then
    git -C "$AUTODEV_GIT_ROOT" log --oneline --max-count=5 2>/dev/null || true
  else
    git -C "$AUTODEV_GIT_ROOT" log --oneline --max-count=5 -- "$AUTODEV_GIT_SCOPE" 2>/dev/null || true
  fi
}

current_branch() {
  git -C "$AUTODEV_GIT_ROOT" branch --show-current 2>/dev/null || true
}

push_branch() {
  if [ -n "$AUTODEV_PUSH_BRANCH" ]; then
    printf '%s\n' "$AUTODEV_PUSH_BRANCH"
    return 0
  fi

  current_branch
}

push_remote_available() {
  git -C "$AUTODEV_GIT_ROOT" remote get-url "$AUTODEV_PUSH_REMOTE" >/dev/null 2>&1
}

push_remote_url() {
  git -C "$AUTODEV_GIT_ROOT" remote get-url "$AUTODEV_PUSH_REMOTE" 2>/dev/null || true
}

push_upstream_ref() {
  local branch
  branch="$(push_branch)"
  [ -n "$branch" ] || return 1
  printf '%s/%s\n' "$AUTODEV_PUSH_REMOTE" "$branch"
}

pending_push_count() {
  local branch upstream
  branch="$(push_branch)"
  [ -n "$branch" ] || {
    printf '0\n'
    return 0
  }

  if ! push_remote_available; then
    printf '0\n'
    return 0
  fi

  upstream="$(push_upstream_ref || true)"
  if [ -n "$upstream" ] && git -C "$AUTODEV_GIT_ROOT" rev-parse --verify "$upstream" >/dev/null 2>&1; then
    git -C "$AUTODEV_GIT_ROOT" rev-list --count "${upstream}..HEAD"
    return 0
  fi

  git -C "$AUTODEV_GIT_ROOT" rev-list --count HEAD
}

push_allowed_prefix_match() {
  local subject="$1"
  local prefix

  for prefix in $AUTODEV_PUSH_ALLOWED_PREFIXES; do
    case "$subject" in
      "$prefix"*) return 0 ;;
    esac
  done

  return 1
}

pending_pushes_are_safe() {
  local branch upstream subject
  branch="$(push_branch)"
  [ -n "$branch" ] || return 1

  if ! push_remote_available; then
    return 1
  fi

  upstream="$(push_upstream_ref || true)"
  if [ -n "$upstream" ] && git -C "$AUTODEV_GIT_ROOT" rev-parse --verify "$upstream" >/dev/null 2>&1; then
    while IFS= read -r subject; do
      [ -z "$subject" ] && continue
      if ! push_allowed_prefix_match "$subject"; then
        return 1
      fi
    done < <(git -C "$AUTODEV_GIT_ROOT" log --format=%s "${upstream}..HEAD")
    return 0
  fi

  return 0
}

push_status() {
  local count branch
  branch="$(push_branch)"
  count="$(pending_push_count)"

  if [ -z "$branch" ]; then
    printf 'branch-missing\n'
    return 0
  fi

  if ! push_remote_available; then
    printf 'remote-missing\n'
    return 0
  fi

  if [ "$count" -eq 0 ]; then
    printf 'clean\n'
    return 0
  fi

  if pending_pushes_are_safe; then
    printf 'ahead:%s\n' "$count"
  else
    printf 'ahead-unsafe:%s\n' "$count"
  fi
}

push_project_branch() {
  local branch
  branch="$(push_branch)"
  [ -n "$branch" ] || {
    printf 'Push target branch is missing.\n' >&2
    return 1
  }

  if ! push_remote_available; then
    printf 'Push remote %s is missing.\n' "$AUTODEV_PUSH_REMOTE" >&2
    return 1
  fi

  if ! pending_pushes_are_safe; then
    printf 'Refusing to push because pending commits include subjects outside AUTODEV_PUSH_ALLOWED_PREFIXES.\n' >&2
    return 1
  fi

  git -C "$AUTODEV_GIT_ROOT" push "$AUTODEV_PUSH_REMOTE" "HEAD:$branch"
  git -C "$AUTODEV_GIT_ROOT" fetch "$AUTODEV_PUSH_REMOTE" "$branch" --quiet >/dev/null 2>&1 || true
}

github_https_remote() {
  case "$(push_remote_url)" in
    https://github.com/*.git) return 0 ;;
    *) return 1 ;;
  esac
}

github_ssh_url_for_remote() {
  local url path
  url="$(push_remote_url)"
  case "$url" in
    https://github.com/*.git)
      path="${url#https://github.com/}"
      printf 'git@github.com:%s\n' "$path"
      ;;
    *)
      return 1
      ;;
  esac
}

github_ssh_ready() {
  local ssh_url
  ssh_url="$(github_ssh_url_for_remote || true)"
  [ -n "$ssh_url" ] || return 1
  git ls-remote "$ssh_url" -h >/dev/null 2>&1
}

rewrite_push_remote_to_github_ssh() {
  local ssh_url
  ssh_url="$(github_ssh_url_for_remote || true)"
  [ -n "$ssh_url" ] || return 1
  git -C "$AUTODEV_GIT_ROOT" remote set-url "$AUTODEV_PUSH_REMOTE" "$ssh_url"
}

current_head() {
  git -C "$AUTODEV_GIT_ROOT" rev-parse HEAD 2>/dev/null || true
}

commit_change_report() {
  local commit_sha="$1"
  local path output
  output=""

  if [ "$AUTODEV_GIT_SCOPE" = "." ]; then
    while IFS= read -r path; do
      [ -z "$path" ] && continue
      if is_excluded_change "$path"; then
        continue
      fi
      output="${output}- ${path}"$'\n'
    done < <(git -C "$AUTODEV_GIT_ROOT" diff-tree --no-commit-id --name-only -r "$commit_sha")
  else
    while IFS= read -r path; do
      [ -z "$path" ] && continue
      if is_excluded_change "$path"; then
        continue
      fi
      output="${output}- ${path}"$'\n'
    done < <(git -C "$AUTODEV_GIT_ROOT" diff-tree --no-commit-id --name-only -r "$commit_sha" -- "$AUTODEV_GIT_SCOPE")
  fi

  printf '%s' "$output"
}

queue_priority_count() {
  if [ ! -f "$AUTODEV_QUEUE_FILE" ]; then
    printf '0\n'
    return 0
  fi

  awk '/^- / {count++} END {print count + 0}' "$AUTODEV_QUEUE_FILE"
}

current_queue_focus() {
  local count index target

  count="$(queue_priority_count)"
  [ "$count" -eq 0 ] && return 0

  index=0
  if [ -f "$AUTODEV_QUEUE_CURSOR_FILE" ]; then
    index="$(tr -cd '0-9' < "$AUTODEV_QUEUE_CURSOR_FILE")"
    [ -z "$index" ] && index=0
  fi

  target=$((index % count + 1))
  awk -v target="$target" '
    /^- / {
      seen++
      if (seen == target) {
        sub(/^- /, "", $0)
        print
        exit
      }
    }
  ' "$AUTODEV_QUEUE_FILE"
}

advance_queue_focus() {
  local count index

  count="$(queue_priority_count)"
  [ "$count" -eq 0 ] && return 0

  index=0
  if [ -f "$AUTODEV_QUEUE_CURSOR_FILE" ]; then
    index="$(tr -cd '0-9' < "$AUTODEV_QUEUE_CURSOR_FILE")"
    [ -z "$index" ] && index=0
  fi

  printf '%s\n' "$(((index + 1) % count))" > "$AUTODEV_QUEUE_CURSOR_FILE"
}

write_last_cycle_summary() {
  local status="$1"
  local focus="$2"
  local changes="$3"
  local summary="$4"
  local commit_sha="${5:-}"

  {
    printf 'Status: %s\n' "$status"
    printf 'Focus: %s\n' "${focus:-none}"
    if [ -n "$changes" ]; then
      printf 'Changed files:\n%s\n' "$changes"
    else
      printf 'Changed files:\n- none\n'
    fi
    if [ -n "$summary" ]; then
      printf '\nOutput excerpt:\n%s\n' "$summary"
    fi
    if [ -n "$commit_sha" ]; then
      printf '\nCommit: %s\n' "$commit_sha"
    fi
  } > "$AUTODEV_LAST_CYCLE_SUMMARY_FILE"

  if [ -n "$changes" ]; then
    printf '%s\n' "$changes" > "$AUTODEV_LAST_CYCLE_CHANGES_FILE"
  else
    printf -- '- none\n' > "$AUTODEV_LAST_CYCLE_CHANGES_FILE"
  fi
}

single_line_text() {
  printf '%s' "$1" | tr '\n' ' ' | tr '\t' ' ' | sed 's/  */ /g; s/^ //; s/ $//'
}

write_last_cycle_commit() {
  local commit_sha="${1:-}"
  if [ -n "$commit_sha" ]; then
    printf '%s\n' "$commit_sha" > "$AUTODEV_LAST_CYCLE_COMMIT_FILE"
  else
    rm -f "$AUTODEV_LAST_CYCLE_COMMIT_FILE"
  fi
}

record_delivery_event() {
  local run_id="$1"
  local status="$2"
  local focus="$3"
  local commit_sha="${4:-}"
  local changes="${5:-}"
  local change_count

  change_count="$(printf '%s\n' "$changes" | awk 'NF && $0 != "- none" {count++} END {print count + 0}')"

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$(timestamp_utc)" \
    "$run_id" \
    "$status" \
    "${commit_sha:-none}" \
    "$change_count" \
    "$(single_line_text "$focus")" >> "$AUTODEV_DELIVERY_HISTORY_FILE"
}

verification_command_configured() {
  [ -n "$(printf '%s' "${1:-}" | tr -d '[:space:]')" ]
}

verification_status_value() {
  local status_file="$1"
  if [ -f "$status_file" ]; then
    cat "$status_file"
  else
    printf 'none\n'
  fi
}

write_verification_summary() {
  local label="$1"
  local status="$2"
  local command_text="$3"
  local log_file="$4"
  local summary_file="$5"
  local excerpt="(no output)"
  local relative_log_file

  if [ -f "$log_file" ]; then
    excerpt="$(tail -n 40 "$log_file" 2>/dev/null || true)"
    [ -n "$excerpt" ] || excerpt="(no output)"
  fi

  relative_log_file="$(relative_to_root "$log_file" "$AUTODEV_ROOT")"

  {
    printf 'Label: %s\n' "$label"
    printf 'Status: %s\n' "$status"
    if verification_command_configured "$command_text"; then
      printf 'Command: %s\n' "$command_text"
    else
      printf 'Command: (not configured)\n'
    fi
    printf 'Log: %s\n' "$relative_log_file"
    printf '\nOutput excerpt:\n%s\n' "$excerpt"
  } > "$summary_file"
}

run_command_with_timeout() {
  local command_text="$1"
  local timeout_seconds="$2"
  local log_file="$3"

  python3 - "$PROJECT_ROOT" "$timeout_seconds" "$command_text" "$log_file" <<'PY'
from pathlib import Path
import subprocess
import sys

cwd = Path(sys.argv[1]).resolve()
timeout_seconds = int(sys.argv[2])
command_text = sys.argv[3]
log_path = Path(sys.argv[4]).resolve()
log_path.parent.mkdir(parents=True, exist_ok=True)

with log_path.open("w") as handle:
    try:
        result = subprocess.run(
            ["/bin/bash", "-lc", command_text],
            cwd=str(cwd),
            stdout=handle,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=timeout_seconds,
            check=False,
        )
    except subprocess.TimeoutExpired:
        handle.write(f"\n[TIMEOUT after {timeout_seconds}s]\n")
        raise SystemExit(124)

raise SystemExit(result.returncode)
PY
}

run_verification_step() {
  local label="$1"
  local command_text="$2"
  local timeout_seconds="$3"
  local required="$4"
  local status_file="$5"
  local summary_file="$6"
  local run_id="$7"
  local slug log_file status exit_code relative_log_file

  slug="$(printf '%s' "$label" | tr '[:upper:]' '[:lower:]' | tr ' /' '--' | tr -cd 'a-z0-9-')"
  log_file="$AUTODEV_LOG_DIR/${slug}-${run_id}.log"

  if ! verification_command_configured "$command_text"; then
    status="not-configured"
    if [ "$required" = "true" ]; then
      status="missing-required"
    fi
    printf '%s\n' "$status" > "$status_file"
    write_verification_summary "$label" "$status" "$command_text" "$log_file" "$summary_file"
    printf '%s: %s\n' "$label" "$status"
    [ "$required" = "true" ] && return 1
    return 0
  fi

  log_line "Running $label command: $command_text" >/dev/null
  status="success"
  exit_code=0
  if run_command_with_timeout "$command_text" "$timeout_seconds" "$log_file"; then
    exit_code=0
  else
    exit_code=$?
    status="failure"
    if [ "$exit_code" -eq 124 ]; then
      status="timeout"
    fi
  fi

  printf '%s\n' "$status" > "$status_file"
  write_verification_summary "$label" "$status" "$command_text" "$log_file" "$summary_file"
  relative_log_file="$(relative_to_root "$log_file" "$AUTODEV_ROOT")"
  printf '%s: %s (%s)\n' "$label" "$status" "$relative_log_file"

  [ "$status" = "success" ]
}

run_verification_suite() {
  local run_id="$1"
  local report=""
  local step_output=""
  local failure=0

  step_output="$(run_verification_step "automated-test" "$AUTODEV_TEST_COMMAND" "$AUTODEV_TEST_TIMEOUT_SECONDS" "$AUTODEV_TEST_REQUIRED" "$AUTODEV_LAST_TEST_STATUS_FILE" "$AUTODEV_LAST_TEST_SUMMARY_FILE" "$run_id")" || failure=1
  [ -n "$step_output" ] && report="${report}${step_output}"$'\n'

  step_output="$(run_verification_step "visual-test" "$AUTODEV_VISUAL_TEST_COMMAND" "$AUTODEV_VISUAL_TEST_TIMEOUT_SECONDS" "$AUTODEV_VISUAL_TEST_REQUIRED" "$AUTODEV_LAST_VISUAL_TEST_STATUS_FILE" "$AUTODEV_LAST_VISUAL_TEST_SUMMARY_FILE" "$run_id")" || failure=1
  [ -n "$step_output" ] && report="${report}${step_output}"$'\n'

  printf '%s' "$report" | sed '/^$/d'
  return "$failure"
}

recent_delivery_history() {
  if [ ! -f "$AUTODEV_DELIVERY_HISTORY_FILE" ]; then
    return 0
  fi

  tail -n 5 "$AUTODEV_DELIVERY_HISTORY_FILE"
}

commit_project_changes() {
  local run_id="$1"
  local focus="$2"
  local subject
  local files=()
  local path

  while IFS= read -r path; do
    [ -z "$path" ] && continue
    files+=("$path")
  done < <(project_changed_paths)

  [ "${#files[@]}" -eq 0 ] && return 0

  git -C "$AUTODEV_GIT_ROOT" add -- "${files[@]}"

  if git -C "$AUTODEV_GIT_ROOT" diff --cached --quiet --; then
    return 0
  fi

  subject="${AUTODEV_COMMIT_MESSAGE_PREFIX}: ${PROJECT_NAME} cycle"
  if [ -n "$focus" ]; then
    subject="${subject} - ${focus}"
  fi
  subject="$(printf '%s' "$subject" | cut -c1-72)"

  git -C "$AUTODEV_GIT_ROOT" commit -m "$subject" -m "Run: $run_id" -m "Project root: $PROJECT_ROOT"
}

last_cycle_summary_section() {
  if [ -f "$AUTODEV_LAST_CYCLE_SUMMARY_FILE" ]; then
    printf '## Last Cycle Summary\n\n'
    cat "$AUTODEV_LAST_CYCLE_SUMMARY_FILE"
    printf '\n\n'
  fi
}

adapter_command_name() {
  local adapter="$1"
  case "$adapter" in
    codex|claude|opencode|kimi)
      printf '%s\n' "$adapter"
      ;;
    *)
      return 1
      ;;
  esac
}

adapter_ready() {
  local adapter="$1"
  local command_name

  if [ "$adapter" = "custom" ]; then
    [ -n "$AUTODEV_CUSTOM_COMMAND" ]
    return $?
  fi

  if ! command_name="$(adapter_command_name "$adapter")"; then
    return 1
  fi

  command -v "$command_name" >/dev/null 2>&1
}

detect_adapter() {
  if [ "$AUTODEV_ADAPTER" != "auto" ]; then
    printf '%s\n' "$AUTODEV_ADAPTER"
    return 0
  fi

  for candidate in codex claude opencode kimi; do
    if command -v "$candidate" >/dev/null 2>&1; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if [ -n "$AUTODEV_CUSTOM_COMMAND" ]; then
    printf 'custom\n'
    return 0
  fi

  return 1
}

acquire_lock() {
  local name="$1"
  local lock_dir="$AUTODEV_LOCK_DIR/$name.lock"
  if mkdir "$lock_dir" 2>/dev/null; then
    printf '%s\n' "$lock_dir"
    return 0
  fi
  return 1
}

release_lock() {
  local lock_dir="$1"
  rm -rf "$lock_dir"
}

lock_age_minutes() {
  local lock_dir="$1"
  local now_epoch modified_epoch

  [ -e "$lock_dir" ] || return 1
  now_epoch="$(date +%s)"
  modified_epoch="$(stat -f %m "$lock_dir")"
  printf '%s\n' "$(((now_epoch - modified_epoch) / 60))"
}

clear_stale_locks() {
  local cleared=0 lock_dir age

  [ -d "$AUTODEV_LOCK_DIR" ] || {
    printf '0\n'
    return 0
  }

  for lock_dir in "$AUTODEV_LOCK_DIR"/*.lock; do
    [ -e "$lock_dir" ] || continue
    age="$(lock_age_minutes "$lock_dir" || printf '0')"
    if [ "$age" -gt "$AUTODEV_REMEDIATOR_MAX_LOCK_AGE_MINUTES" ]; then
      rm -rf "$lock_dir"
      cleared=$((cleared + 1))
    fi
  done

  printf '%s\n' "$cleared"
}

latest_matching_file() {
  local pattern="$1"
  local matches=()
  local had_nullglob=0

  shopt -q nullglob || had_nullglob=1
  shopt -s nullglob
  matches=($pattern)
  if [ "$had_nullglob" -eq 1 ]; then
    shopt -u nullglob
  fi

  if [ "${#matches[@]}" -eq 0 ]; then
    return 1
  fi

  ls -1t "${matches[@]}" 2>/dev/null | head -n1
}

file_age_minutes() {
  local path="$1"
  local now_epoch modified_epoch

  now_epoch="$(date +%s)"
  modified_epoch="$(stat -f %m "$path")"
  printf '%s\n' "$(((now_epoch - modified_epoch) / 60))"
}

cron_block_present() {
  crontab -l 2>/dev/null | awk -v start="# BEGIN AUTODEV $AUTODEV_ID" '
    $0 == start {found=1}
    END { exit(found ? 0 : 1) }
  '
}

require_clean_tree() {
  local dirty
  dirty="$(tracked_changes)"
  if [ "$AUTODEV_REQUIRE_CLEAN_TREE" = "true" ] && [ -n "$dirty" ]; then
    append_daily_section "Skipped cycle" "Tracked working tree changes already exist in the project scope.\n\n$dirty"
    log_line "Skipping AI cycle because tracked project-scope changes are already present."
    return 1
  fi
  return 0
}

context_section() {
  local path="$1"
  local full_path=""

  if [ -f "$path" ]; then
    full_path="$path"
  elif [ -f "$REPO_ROOT/$path" ]; then
    full_path="$REPO_ROOT/$path"
  elif [ -d "$REPO_ROOT/$path" ]; then
    full_path="$REPO_ROOT/$path"
  else
    return 0
  fi

  if [ -d "$full_path" ]; then
    printf '## Context Directory: %s\n\n' "$full_path"
    find "$full_path" -maxdepth 2 -type f | sort | sed -n '1,80p'
    printf '\n\n'
    return 0
  fi

  printf '## Context File: %s\n\n' "$full_path"
  sed -n "1,${AUTODEV_MAX_CONTEXT_LINES}p" "$full_path"
  printf '\n\n'
}

build_prompt_bundle() {
  local out_file="$1"
  local mode="$2"
  local focus focus_source queue_focus steering_task
  focus="$(current_focus_label || true)"
  focus_source="$(current_focus_source || true)"
  queue_focus="$(current_queue_focus || true)"
  steering_task="$(current_steering_task_path || true)"

  refresh_memory_retrieval "$focus" >/dev/null || true

  {
    printf '# Runtime Metadata\n\n'
    printf -- '- project: %s\n' "$PROJECT_NAME"
    printf -- '- project-root: %s\n' "$PROJECT_ROOT"
    printf -- '- git-root: %s\n' "$AUTODEV_GIT_ROOT"
    printf -- '- git-scope: %s\n' "$AUTODEV_GIT_SCOPE"
    printf -- '- adapter: %s\n' "$(detect_adapter || printf 'none')"
    printf -- '- mode: %s\n' "$mode"
    printf -- '- clean-tree-required: %s\n' "$AUTODEV_REQUIRE_CLEAN_TREE"
    printf -- '- clean-tree-policy: tracked-changes-in-scope-only\n'
    printf -- '- focus-source: %s\n' "${focus_source:-none}"
    printf -- '- focus-label: %s\n' "${focus:-none}"
    printf -- '- memory-backend: %s\n' "$AUTODEV_MEMORY_BACKEND"
    printf -- '- memory-backend-status: %s\n' "$(memory_backend_status_label | tr '\n' ' ' | sed 's/ *$//')"
    printf -- '- memory-backend-rg: %s\n' "$(memory_backend_status_field rg_available || printf 'missing')"
    printf -- '- memory-backend-mgrep: %s\n' "$(memory_backend_status_field mgrep_available || printf 'missing')"
    printf -- '- memory-backend-mgrep-store: %s\n' "$(memory_backend_status_field mgrep_store || printf '%s' "$AUTODEV_MEMORY_MGREP_STORE")"
    printf -- '- automated-test-command: %s\n' "$(if verification_command_configured "$AUTODEV_TEST_COMMAND"; then printf '%s' "$AUTODEV_TEST_COMMAND"; else printf 'none'; fi)"
    printf -- '- automated-test-required: %s\n' "$AUTODEV_TEST_REQUIRED"
    printf -- '- visual-test-command: %s\n' "$(if verification_command_configured "$AUTODEV_VISUAL_TEST_COMMAND"; then printf '%s' "$AUTODEV_VISUAL_TEST_COMMAND"; else printf 'none'; fi)"
    printf -- '- visual-test-required: %s\n' "$AUTODEV_VISUAL_TEST_REQUIRED"
    printf -- '- auto-commit-allowed: %s\n\n' "$AUTODEV_AUTO_COMMIT"

    for file in \
      "$AUTODEV_MEMORY_SKILL_FILE" \
      "$AUTODEV_OBJECTIVE_FILE" \
      "$AUTODEV_PROJECT_FILE" \
      "$AUTODEV_MEMORY_FILE" \
      "$AUTODEV_STEERING_BOARD_FILE" \
      "$AUTODEV_PROJECT_MAP_FILE" \
      "$AUTODEV_INVARIANTS_FILE" \
      "$AUTODEV_ARCHITECTURE_FILE" \
      "$AUTODEV_COMMANDS_FILE" \
      "$AUTODEV_OWNERSHIP_FILE" \
      "$AUTODEV_FAILURES_FILE" \
      "$AUTODEV_DECISIONS_FILE" \
      "$AUTODEV_CHANGELOG_FILE" \
      "$AUTODEV_CURRENT_TASK_FILE" \
      "$AUTODEV_OPEN_QUESTIONS_FILE" \
      "$AUTODEV_NEXT_ACTIONS_FILE" \
      "$AUTODEV_PROMPT_TEMPLATE"; do
      if [ -f "$file" ]; then
        printf '## Source File: %s\n\n' "$file"
        cat "$file"
        printf '\n\n'
      fi
    done

    if [ -n "$steering_task" ] && [ -f "$steering_task" ]; then
      printf '## Source File: %s\n\n' "$steering_task"
      cat "$steering_task"
      printf '\n\n'
    fi

    if [ -f "$AUTODEV_QUEUE_FILE" ]; then
      printf '## Source File: %s\n\n' "$AUTODEV_QUEUE_FILE"
      cat "$AUTODEV_QUEUE_FILE"
      printf '\n\n'
    fi

    if [ -f "$AUTODEV_STEERING_LINEAR_LAST_SYNC_FILE" ]; then
      printf '## Source File: %s\n\n' "$AUTODEV_STEERING_LINEAR_LAST_SYNC_FILE"
      cat "$AUTODEV_STEERING_LINEAR_LAST_SYNC_FILE"
      printf '\n\n'
    fi

    if [ -f "$AUTODEV_MEMORY_RETRIEVAL_FILE" ]; then
      printf '## Source File: %s\n\n' "$AUTODEV_MEMORY_RETRIEVAL_FILE"
      cat "$AUTODEV_MEMORY_RETRIEVAL_FILE"
      printf '\n\n'
    fi

    while IFS= read -r session_file; do
      [ -z "$session_file" ] && continue
      printf '## Source File: %s\n\n' "$session_file"
      cat "$session_file"
      printf '\n\n'
    done < <(recent_session_files)

    printf '## Repository Snapshot\n\n'
    printf '### Branch\n\n%s\n\n' "$(current_branch)"
    printf '### Git Status (Clean-Tree Policy View)\n\n'
    prompt_status_snapshot
    printf '\n\n### Recent Commits\n\n'
    repo_recent_commits
    printf '\n\n'

    if [ -n "$focus" ]; then
      printf '## Current Focus\n\n'
      printf -- '- source: %s\n' "${focus_source:-none}"
      printf -- '- focus: %s\n\n' "$focus"
    fi

    if [ -n "$queue_focus" ] && [ "${focus_source:-}" != "queue" ]; then
      printf '## Queue Fallback Focus\n\n%s\n\n' "$queue_focus"
    fi

    last_cycle_summary_section

    for file in $AUTODEV_CONTEXT_FILES; do
      context_section "$file"
    done
  } > "$out_file"
}

extract_output_summary() {
  local output_file="$1"
  if [ ! -f "$output_file" ]; then
    return 0
  fi
  head -c "$AUTODEV_MAX_OUTPUT_BYTES" "$output_file"
}

run_adapter() {
  local adapter="$1"
  local prompt_file="$2"
  local output_file="$3"
  local script="$AUTODEV_ROOT/automation/adapters/$adapter.sh"

  if [ ! -x "$script" ]; then
    log_line "Adapter script missing or not executable: $script"
    return 1
  fi

  "$script" "$prompt_file" "$output_file"
}

refresh_stats_reports() {
  local status_file doctor_file remediator_file history_file output_md output_html
  status_file="$AUTODEV_STATE_DIR/last-cycle-status.txt"
  doctor_file="$AUTODEV_STATE_DIR/doctor-status.txt"
  remediator_file="$AUTODEV_LAST_REMEDIATION_STATUS_FILE"
  history_file="$AUTODEV_DELIVERY_HISTORY_FILE"
  output_md="$AUTODEV_STATS_MD_FILE"
  output_html="$AUTODEV_STATS_HTML_FILE"

  python3 - "$PROJECT_NAME" "$output_md" "$output_html" "$history_file" "$status_file" "$doctor_file" "$remediator_file" "$(push_status)" "$(timestamp_utc)" <<'PY'
from __future__ import annotations

from datetime import datetime, timedelta, timezone
from html import escape
from pathlib import Path
import sys

project_name = sys.argv[1]
output_md = Path(sys.argv[2])
output_html = Path(sys.argv[3])
history_file = Path(sys.argv[4])
status_file = Path(sys.argv[5])
doctor_file = Path(sys.argv[6])
remediator_file = Path(sys.argv[7])
push_status = sys.argv[8]
generated_at = sys.argv[9]


def read_text(path: Path, default: str = "none") -> str:
    if not path.exists():
        return default
    value = path.read_text().strip()
    return value or default


def parse_history(path: Path):
    rows = []
    if not path.exists():
        return rows

    for raw_line in path.read_text().splitlines():
        if not raw_line.strip():
            continue
        parts = raw_line.split("\t")
        if len(parts) < 6:
            continue
        timestamp, run_id, status, commit_sha, change_count, focus = parts[:6]
        try:
            parsed_at = datetime.strptime(timestamp, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
        except ValueError:
            continue
        rows.append(
            {
                "timestamp": timestamp,
                "dt": parsed_at,
                "run_id": run_id,
                "status": status,
                "commit_sha": commit_sha,
                "change_count": int(change_count or "0"),
                "focus": focus,
            }
        )
    return rows


history = parse_history(history_file)
now = datetime.strptime(generated_at, "%Y-%m-%dT%H:%M:%SZ").replace(tzinfo=timezone.utc)
last_24h_cutoff = now - timedelta(hours=24)
last_24h = [row for row in history if row["dt"] >= last_24h_cutoff]

def count(rows, status):
    return sum(1 for row in rows if row["status"] == status)


def first_match(rows, status):
    for row in reversed(rows):
        if row["status"] == status:
            return row
    return None


def short_commit(commit_sha: str) -> str:
    if not commit_sha or commit_sha == "none":
        return "-"
    return commit_sha[:8]


summary_rows = [
    ("Current cycle status", read_text(status_file)),
    ("Doctor status", read_text(doctor_file)),
    ("Remediator status", read_text(remediator_file)),
    ("Push status", push_status),
    ("Total recorded cycles", str(len(history))),
    ("Success cycles", str(count(history, "success"))),
    ("No-op cycles", str(count(history, "noop"))),
    ("Failure cycles", str(count(history, "failure"))),
    ("Governance skips", str(count(history, "skipped-governance"))),
    ("Runs in last 24h", str(len(last_24h))),
    ("Successes in last 24h", str(count(last_24h, "success"))),
    ("Commits in last 24h", str(sum(1 for row in last_24h if row["commit_sha"] != "none"))),
    ("Changed files in last 24h", str(sum(row["change_count"] for row in last_24h))),
]

last_success = first_match(history, "success")
last_failure = first_match(history, "failure")
if last_success:
    summary_rows.append(("Last success", f'{last_success["timestamp"]} ({short_commit(last_success["commit_sha"])})'))
if last_failure:
    summary_rows.append(("Last failure", f'{last_failure["timestamp"]} ({short_commit(last_failure["commit_sha"])})'))

recent_rows = list(reversed(history[-10:]))

markdown_lines = [
    f"# Automation Stats: {project_name}",
    "",
    f"Generated: {generated_at}",
    "",
    "## Summary",
    "",
    "| Metric | Value |",
    "| --- | --- |",
]
markdown_lines.extend(f"| {label} | {value} |" for label, value in summary_rows)
markdown_lines.extend(
    [
        "",
        "## Recent Runs",
        "",
        "| UTC | Status | Commit | Files | Focus |",
        "| --- | --- | --- | ---: | --- |",
    ]
)
for row in recent_rows:
    markdown_lines.append(
        f'| {row["timestamp"]} | {row["status"]} | {short_commit(row["commit_sha"])} | {row["change_count"]} | {row["focus"]} |'
    )
markdown = "\n".join(markdown_lines) + "\n"

html_summary_rows = "\n".join(
    f"<tr><th>{escape(label)}</th><td>{escape(value)}</td></tr>" for label, value in summary_rows
)
html_recent_rows = "\n".join(
    "<tr>"
    f"<td>{escape(row['timestamp'])}</td>"
    f"<td>{escape(row['status'])}</td>"
    f"<td>{escape(short_commit(row['commit_sha']))}</td>"
    f"<td>{row['change_count']}</td>"
    f"<td>{escape(row['focus'])}</td>"
    "</tr>"
    for row in recent_rows
)

html = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>Automation Stats: {escape(project_name)}</title>
  <style>
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      margin: 24px;
      color: #1f2937;
      background: #f8fafc;
    }}
    h1, h2 {{ margin-bottom: 12px; }}
    .meta {{ color: #475569; margin-bottom: 20px; }}
    table {{
      border-collapse: collapse;
      width: 100%;
      background: white;
      margin-bottom: 24px;
    }}
    th, td {{
      border: 1px solid #cbd5e1;
      padding: 8px 10px;
      text-align: left;
      vertical-align: top;
    }}
    th {{
      background: #e2e8f0;
      font-weight: 600;
    }}
    .narrow {{ width: 160px; }}
  </style>
</head>
<body>
  <h1>Automation Stats: {escape(project_name)}</h1>
  <div class="meta">Generated: {escape(generated_at)}</div>
  <h2>Summary</h2>
  <table>
    <tbody>
      {html_summary_rows}
    </tbody>
  </table>
  <h2>Recent Runs</h2>
  <table>
    <thead>
      <tr>
        <th class="narrow">UTC</th>
        <th>Status</th>
        <th>Commit</th>
        <th>Files</th>
        <th>Focus</th>
      </tr>
    </thead>
    <tbody>
      {html_recent_rows}
    </tbody>
  </table>
</body>
</html>
"""

output_md.write_text(markdown)
output_html.write_text(html)
PY
}
