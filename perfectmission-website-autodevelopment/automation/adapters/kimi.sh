#!/bin/bash

set -euo pipefail

prompt_file="$1"
output_file="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$script_dir/lib.sh"

prompt="$(cat "$prompt_file")"
cd "$REPO_ROOT"
kimi --print --yolo -w "$REPO_ROOT" -p "$prompt" > "$output_file"

