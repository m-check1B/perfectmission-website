#!/bin/bash

set -euo pipefail

prompt_file="$1"
output_file="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$script_dir/lib.sh"

if [ -z "$AUTODEV_CUSTOM_COMMAND" ]; then
  printf 'AUTODEV_CUSTOM_COMMAND is empty.\n' >&2
  exit 1
fi

cd "$REPO_ROOT"
env PROMPT_FILE="$prompt_file" OUTPUT_FILE="$output_file" REPO_ROOT="$REPO_ROOT" \
  /bin/bash -lc "$AUTODEV_CUSTOM_COMMAND"
