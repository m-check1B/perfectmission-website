#!/bin/bash

set -euo pipefail

prompt_file="$1"
output_file="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC1091
source "$script_dir/lib.sh"

cd "$REPO_ROOT"
codex exec \
  --skip-git-repo-check \
  --full-auto \
  -C "$REPO_ROOT" \
  -o "$output_file" \
  - < "$prompt_file"

