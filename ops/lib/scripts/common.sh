#!/usr/bin/env bash
set -euo pipefail

# Shared utility library for ops-tier scripts.
# Callers must resolve SCRIPT_DIR via BASH_SOURCE anchor pattern, then source
# this file through a deterministic relative path from that anchor.

die() {
  echo "ERROR: $*" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

normalize_path_token() {
  local value
  value="$(trim "$1")"
  value="${value#\`}"; value="${value%\`}"
  value="${value#\"}"; value="${value%\"}"
  value="${value#./}"
  if [[ "$value" == "${REPO_ROOT}/"* ]]; then
    value="${value#${REPO_ROOT}/}"
  fi
  printf '%s' "$value"
}
