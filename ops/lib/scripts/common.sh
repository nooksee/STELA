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

emit_diag_field() {
  local key="$1"
  local value="${2-}"
  printf '  %s: %s\n' "$key" "$value" >&2
  return 0
}

emit_diag_path_field() {
  local key="$1"
  local value="${2-}"
  if [[ -n "$value" ]]; then
    value="$(normalize_path_token "$value")"
  else
    value="(none)"
  fi
  emit_diag_field "$key" "$value"
  return 0
}

die_guard_failure() {
  local message="$1"
  local guard_condition="$2"
  shift 2

  echo "ERROR: ${message}" >&2
  emit_diag_field "guard_condition" "$guard_condition"

  while [[ "$#" -ge 2 ]]; do
    local key="$1"
    local value="$2"
    if [[ "$key" == *_path ]]; then
      emit_diag_path_field "$key" "$value"
    else
      emit_diag_field "$key" "$value"
    fi
    shift 2
  done

  exit 1
}

# ---------------------------------------------------------------------------
# Leaf Primitives (SSOT for distributed telemetry leaf emission)
# ---------------------------------------------------------------------------

# timestamp_token_utc: compact UTC timestamp suitable for leaf filenames.
timestamp_token_utc() {
  date -u +%Y%m%dT%H%M%SZ
}

# utc_now: ISO 8601 UTC timestamp for leaf created_at fields.
utc_now() {
  date -u +%Y-%m-%dT%H:%M:%SZ
}

# short_hash VALUE: first 8 hex chars of SHA-256 of VALUE.
# Falls back to shasum if sha256sum is unavailable.
short_hash() {
  local value="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    printf '%s' "$value" | sha256sum | cut -c1-8
  elif command -v shasum >/dev/null 2>&1; then
    printf '%s' "$value" | shasum -a 256 | cut -c1-8
  else
    printf '%s' "$value" | cksum | awk '{printf "%08x", $1}'
  fi
}

# slugify_token VALUE: lowercase alphanumeric slug with hyphens.
slugify_token() {
  local value="$1"
  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  value="$(printf '%s' "$value" | tr -cs 'a-z0-9' '-')"
  value="${value#-}"
  value="${value%-}"
  printf '%s' "$value"
}

# emit_binary_leaf CALLER LABEL [TRACE_ID]
#
# Writes logs/{caller-slug}-{label}-{stamp}-{trace-digest}.md and updates
# logs/{caller-slug}.telemetry.head. Safe to call from sourced library
# scripts and from binary EXIT traps. Never fails the caller process.
#
# Leaf schema (YAML frontmatter + body):
#   trace_id, caller, label, created_at, previous
#
# TRACE_ID resolution order:
#   1. Third positional argument if provided.
#   2. STELA_TRACE_ID environment variable.
#   3. Literal "untraced" (leaf is still written; never blocks execution).
emit_binary_leaf() {
  local caller="${1:-unknown}"
  local label="${2:-event}"
  local trace_id="${3:-${STELA_TRACE_ID:-untraced}}"

  local leaf_repo_root
  leaf_repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"
  local logs_dir="${leaf_repo_root}/logs"

  # Silently return if logs/ cannot be created (e.g., read-only CI runner).
  mkdir -p "$logs_dir" 2>/dev/null || return 0

  local caller_slug
  caller_slug="$(slugify_token "$caller")"

  local head_path="${logs_dir}/${caller_slug}.telemetry.head"
  local previous="(none)"
  if [[ -f "$head_path" ]]; then
    local prev_raw
    prev_raw="$(trim "$(cat "$head_path")")"
    [[ -n "$prev_raw" ]] && previous="$prev_raw"
  fi

  local stamp trace_digest
  stamp="$(timestamp_token_utc)"
  trace_digest="$(short_hash "$trace_id")"

  local leaf_rel="logs/${caller_slug}-${label}-${stamp}-${trace_digest}.md"
  local leaf_abs="${leaf_repo_root}/${leaf_rel}"

  # Write leaf; silently return on any I/O error.
  cat > "$leaf_abs" 2>/dev/null <<EOF || return 0
---
trace_id: ${trace_id}
caller: ${caller}
label: ${label}
created_at: $(utc_now)
previous: ${previous}
---
EOF

  printf '%s\n' "$leaf_rel" > "$head_path" 2>/dev/null || true
}
