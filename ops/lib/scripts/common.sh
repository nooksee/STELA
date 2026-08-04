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

packet_scope_validate_literal_path() {
  local raw_value="$1"
  local value
  value="$(normalize_path_token "$raw_value")"

  if [[ -z "$value" ]]; then
    echo "ERROR: packet scope path is empty" >&2
    return 1
  fi
  if [[ "$value" == /* || "$value" == */../* || "$value" == ../* || "$value" == *'/..' ]]; then
    echo "ERROR: packet scope path must remain repository-relative: ${value}" >&2
    return 1
  fi
  if [[ "$value" =~ [[:space:]] || "$value" == *"*"* || "$value" == *"?"* || "$value" == *"["* || "$value" == *"{"* || "$value" == *"}"* ]]; then
    echo "ERROR: packet scope path must be one exact literal path: ${value}" >&2
    return 1
  fi
  if [[ ! "$value" =~ ^[A-Za-z0-9._/-]+$ || "$value" == *//* || "$value" == */ ]]; then
    echo "ERROR: packet scope path contains invalid syntax: ${value}" >&2
    return 1
  fi

  printf '%s' "$value"
}

packet_scope_parse_declared_path() {
  local declaration="$1"
  local path_token=""
  local remainder=""

  declaration="$(trim "$declaration")"
  if [[ "$declaration" == \`* ]]; then
    if [[ ! "$declaration" =~ ^\`([^\`]+)\`([[:space:]]+(.*))?$ ]]; then
      echo "ERROR: packet scope declaration has malformed backticks: ${declaration}" >&2
      return 1
    fi
    path_token="${BASH_REMATCH[1]}"
    remainder="${BASH_REMATCH[3]:-}"
  else
    path_token="${declaration%%[[:space:]]*}"
    if [[ "$declaration" == *[[:space:]]* ]]; then
      remainder="${declaration#"$path_token"}"
      remainder="$(trim "$remainder")"
    fi
  fi

  if [[ -n "$remainder" && ! "$remainder" =~ ^\([^\r\n]*\)$ ]]; then
    echo "ERROR: packet scope annotation must be parenthetical: ${declaration}" >&2
    return 1
  fi

  packet_scope_validate_literal_path "$path_token"
}

packet_scope_extract_changelog_paths() {
  local source_path="$1"
  [[ -f "$source_path" ]] || {
    echo "ERROR: packet scope source is missing: ${source_path}" >&2
    return 1
  }

  local changelog_block
  changelog_block="$(awk '
    /^### 3[.]4[.]3[[:space:]]+Changelog[[:space:]]*$/ { in_block=1; found=1; next }
    in_block && /^### 3[.]4[.]4([[:space:]]|$)/ { in_block=0; exit }
    in_block { print }
    END { if (!found) exit 2 }
  ' "$source_path")" || {
    echo "ERROR: packet scope source is missing section 3.4.3 Changelog" >&2
    return 1
  }

  local line=""
  local mode=""
  local declaration=""
  local path=""
  local mutation_count=0
  declare -A seen_paths=()

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(trim "$line")"
    [[ -n "$line" ]] || continue

    case "$line" in
      UPDATE:|ADD:|NEW:|DELETE:|NO-CHANGE:)
        mode="${line%:}"
        continue
        ;;
    esac

    if [[ "$line" =~ ^-[[:space:]]+(UPDATE|ADD|NEW|DELETE|NO-CHANGE)[[:space:]]+(.+)$ ]]; then
      mode="${BASH_REMATCH[1]}"
      declaration="${BASH_REMATCH[2]}"
    elif [[ -n "$mode" && "$line" =~ ^-[[:space:]]+(.+)$ ]]; then
      declaration="${BASH_REMATCH[1]}"
    else
      echo "ERROR: packet scope changelog line is not an exact mutation declaration: ${line}" >&2
      return 1
    fi

    path="$(packet_scope_parse_declared_path "$declaration")" || return 1
    if [[ "$mode" == "NO-CHANGE" ]]; then
      continue
    fi
    if [[ -n "${seen_paths[$path]+set}" ]]; then
      echo "ERROR: packet scope path is declared more than once: ${path}" >&2
      return 1
    fi
    seen_paths["$path"]=1
    mutation_count=$((mutation_count + 1))
    printf '%s\n' "$path"
  done <<< "$changelog_block"

  if (( mutation_count == 0 )); then
    echo "ERROR: packet scope changelog contains no mutation paths" >&2
    return 1
  fi
}

packet_scope_extract_addendum_paths() {
  local source_path="$1"
  local expected_packet_id="${2:-}"
  [[ -f "$source_path" ]] || {
    echo "ERROR: addendum scope source is missing: ${source_path}" >&2
    return 1
  }

  local base_packet
  base_packet="$(awk '/^Base Packet:[[:space:]]*/ { line=$0; sub(/^Base Packet:[[:space:]]*/, "", line); print line; exit }' "$source_path")"
  base_packet="$(trim "$base_packet")"
  if [[ ! "$base_packet" =~ ^DP-[A-Z]+-[0-9]{4,}$ ]]; then
    echo "ERROR: addendum scope has an invalid Base Packet: ${base_packet}" >&2
    return 1
  fi
  if [[ -n "$expected_packet_id" && "$base_packet" != "$expected_packet_id" ]]; then
    echo "ERROR: addendum scope base packet mismatch: expected ${expected_packet_id}, found ${base_packet}" >&2
    return 1
  fi

  local scope_block
  scope_block="$(awk '
    /^Exact paths added by this addendum [(]one per line; no globs; no brace expansion[)]:[[:space:]]*$/ { in_block=1; found=1; next }
    in_block && /^## A[.]3([[:space:]]|$)/ { in_block=0; exit }
    in_block { print }
    END { if (!found) exit 2 }
  ' "$source_path")" || {
    echo "ERROR: addendum scope is missing the exact-path block" >&2
    return 1
  }

  local line=""
  local path=""
  local count=0
  declare -A seen_paths=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="$(trim "$line")"
    [[ -n "$line" ]] || continue
    line="${line#- }"
    path="$(packet_scope_parse_declared_path "$line")" || return 1
    if [[ -n "${seen_paths[$path]+set}" ]]; then
      echo "ERROR: addendum scope path is declared more than once: ${path}" >&2
      return 1
    fi
    seen_paths["$path"]=1
    count=$((count + 1))
    printf '%s\n' "$path"
  done <<< "$scope_block"

  if (( count == 0 )); then
    echo "ERROR: addendum scope contains no exact paths" >&2
    return 1
  fi
}

path_matches_policy_set() {
  local path="$1"
  local exact_name="$2"
  local patterns_name="$3"
  local -n exact_ref="$exact_name"
  local -n patterns_ref="$patterns_name"

  if [[ -n "${exact_ref[$path]+set}" ]]; then
    return 0
  fi

  local pattern=""
  for pattern in "${patterns_ref[@]}"; do
    if [[ "$path" == $pattern ]]; then
      return 0
    fi
  done

  return 1
}

packet_scope_path_is_authorized() {
  local path="$1"
  local scope_mode="$2"
  local packet_scope_name="$3"
  local -n packet_scope_ref="$packet_scope_name"

  if [[ "$scope_mode" == "maintenance-idle" ]]; then
    return 0
  fi
  [[ "$scope_mode" == "packet-exact" ]] || return 1
  [[ -n "${packet_scope_ref[$path]+set}" ]]
}

persistent_policy_path_is_authorized() {
  local path="$1"
  local is_deleted="$2"
  local current_exact_name="$3"
  local current_patterns_name="$4"
  local head_exact_name="$5"
  local head_patterns_name="$6"

  if path_matches_policy_set "$path" "$current_exact_name" "$current_patterns_name"; then
    return 0
  fi
  if [[ "$is_deleted" == "1" ]] \
    && path_matches_policy_set "$path" "$head_exact_name" "$head_patterns_name"; then
    return 0
  fi
  return 1
}

rewrite_task_lifecycle_fields() {
  local source_path="$1"
  local out_path="$2"
  local routing_state="$3"
  local packet_state="$4"
  local packet_id="$5"
  local updated_date="$6"

  [[ -f "$source_path" ]] || die "TASK lifecycle source missing: ${source_path}"
  case "${routing_state}/${packet_state}" in
    ACTIVE/ACTIVE|IDLE/COMPLETED)
      ;;
    *)
      die "invalid TASK lifecycle pair: routing=${routing_state} packet=${packet_state}"
      ;;
  esac
  [[ "$packet_id" =~ ^DP-[A-Z]+-[0-9]{4,}$ ]] || die "invalid TASK lifecycle packet id: ${packet_id}"
  [[ "$updated_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "invalid TASK lifecycle update date: ${updated_date}"

  awk -v routing_state="$routing_state" -v packet_state="$packet_state" -v packet_id="$packet_id" -v updated_date="$updated_date" '
    /^Status:[[:space:]]*/ {
      print "Routing State: " routing_state
      print "Packet State: " packet_state
      print "Packet ID: " packet_id
      next
    }
    /^Routing State:[[:space:]]*/ { print "Routing State: " routing_state; next }
    /^Packet State:[[:space:]]*/ { print "Packet State: " packet_state; next }
    /^Packet ID:[[:space:]]*/ { print "Packet ID: " packet_id; next }
    /^Last Updated:[[:space:]]*/ { print "Last Updated: " updated_date; next }
    { print }
  ' "$source_path" > "$out_path"

  [[ "$(grep -c '^Routing State:' "$out_path" || true)" == "1" ]] || die "TASK lifecycle rewrite did not produce exactly one Routing State field"
  [[ "$(grep -c '^Packet State:' "$out_path" || true)" == "1" ]] || die "TASK lifecycle rewrite did not produce exactly one Packet State field"
  [[ "$(grep -c '^Packet ID:' "$out_path" || true)" == "1" ]] || die "TASK lifecycle rewrite did not produce exactly one Packet ID field"
  grep -Fxq "Routing State: ${routing_state}" "$out_path" || die "TASK lifecycle routing rewrite failed"
  grep -Fxq "Packet State: ${packet_state}" "$out_path" || die "TASK lifecycle packet-state rewrite failed"
  grep -Fxq "Packet ID: ${packet_id}" "$out_path" || die "TASK lifecycle packet-id rewrite failed"
  return 0
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
