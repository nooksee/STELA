#!/usr/bin/env bash
set -euo pipefail

# This function must execute in the pipeline before any artifact write operation.
# This ordering constraint is a security requirement, not a style convention.
redact_stream() {
  sed -E \
    -e 's/AKIA[0-9A-Z]{16}/[REDACTED]/g' \
    -e 's/ASIA[0-9A-Z]{16}/[REDACTED]/g' \
    -e 's/AIza[0-9A-Za-z_-]{35}/[REDACTED]/g' \
    -e 's/xox[baprs]-[0-9A-Za-z-]{10,48}/[REDACTED]/g' \
    -e 's/ghp_[0-9A-Za-z]{36}/[REDACTED]/g' \
    -e 's/ghs_[0-9A-Za-z]{36}/[REDACTED]/g' \
    -e 's/-----BEGIN [A-Z ]+ PRIVATE KEY-----/[REDACTED PRIVATE KEY]/g'
}

iso_utc_now() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

generate_trace_id() {
  local stamp
  local suffix
  stamp="$(date -u '+%Y%m%dT%H%M%SZ')"
  suffix="$(printf '%04x%04x' "$RANDOM" "$RANDOM")"
  printf 'stela-%s-%s' "$stamp" "$suffix"
}

resolve_trace_id() {
  local trace_id="${STELA_TRACE_ID:-}"
  if [[ -z "$trace_id" ]]; then
    trace_id="$(generate_trace_id)"
  fi
  printf '%s' "$trace_id"
}

trace_suffix_from_id() {
  local trace_id="$1"
  if [[ "$trace_id" =~ -([0-9a-fA-F]{8})$ ]]; then
    printf '%s' "$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:upper:]' '[:lower:]')"
    return 0
  fi
  local fallback
  fallback="$(git -C "$REPO_ROOT" rev-parse --short=8 HEAD 2>/dev/null || true)"
  fallback="$(printf '%s' "$fallback" | tr '[:upper:]' '[:lower:]')"
  if [[ "$fallback" =~ ^[0-9a-f]{8}$ ]]; then
    printf '%s' "$fallback"
    return 0
  fi
  printf '%08x' "$RANDOM"
}

resolve_packet_id() {
  local fallback="${1:-}"
  local packet_id="${STELA_PACKET_ID:-}"
  if [[ -n "$packet_id" ]]; then
    printf '%s' "$packet_id"
    return 0
  fi
  if [[ -n "$fallback" ]]; then
    printf '%s' "$fallback"
    return 0
  fi
  die "Missing packet ID. Set STELA_PACKET_ID or provide fallback."
}

build_definition_leaf_path() {
  local stem="$1"
  local trace_suffix="$2"
  printf 'archives/definitions/%s-%s-%s.md' "$stem" "$(date -u +%Y-%m-%d)" "$trace_suffix"
}

read_factory_head_value() {
  local key="$1"
  local head_file="${FACTORY_HEAD_FILE:-${AGENTS_LEDGER:-${SKILL_FILE:-}}}"
  [[ -n "$head_file" ]] || die "FACTORY_HEAD_FILE is not set."
  local value
  value="$(awk -F':' -v key="$key" '
    $1 == key {
      entry=$0
      sub(/^[^:]+:[[:space:]]*/, "", entry)
      print entry
      exit
    }
  ' "$head_file")"
  value="$(trim "$value")"
  if [[ -z "$value" ]]; then
    die "Missing ${key}: pointer in ${head_file}"
  fi
  printf '%s' "$value"
}

normalize_previous_head_value() {
  local value="$1"
  if [[ "$value" == *"-(origin)" ]]; then
    printf '(none)'
    return 0
  fi
  printf '%s' "$value"
}

update_factory_head_value() {
  local key="$1"
  local value="$2"
  local head_file="${FACTORY_HEAD_FILE:-${AGENTS_LEDGER:-${SKILL_FILE:-}}}"
  [[ -n "$head_file" ]] || die "FACTORY_HEAD_FILE is not set."
  local tmp
  tmp="$(mktemp)"

  if ! awk -v key="$key" -v value="$value" '
    BEGIN { updated=0 }
    $0 ~ ("^" key ":[[:space:]]*") {
      print key ": " value
      updated=1
      next
    }
    { print }
    END { if (updated == 0) exit 2 }
  ' "$head_file" > "$tmp"; then
    status=$?
    rm -f "$tmp"
    if [[ "$status" -eq 2 ]]; then
      die "Failed to locate ${key}: pointer in ${head_file}"
    fi
    die "Failed to rewrite ${key}: pointer in ${head_file}"
  fi

  mv "$tmp" "$head_file"
}

strip_leading_frontmatter() {
  local path="$1"
  awk '
    NR == 1 && $0 == "---" { in_fm=1; next }
    in_fm == 1 {
      if ($0 == "---") {
        in_fm=0
        next
      }
      next
    }
    { print }
  ' "$path"
}

emit_head_leaf_from_source() {
  local key="$1"
  local stem="$2"
  local source_path="$3"
  local packet_id="$4"
  local current_head
  current_head="$(read_factory_head_value "$key")"
  local previous
  previous="$(normalize_previous_head_value "$current_head")"

  local trace_id
  trace_id="$(resolve_trace_id)"
  local trace_suffix
  trace_suffix="$(trace_suffix_from_id "$trace_id")"
  local leaf_rel
  leaf_rel="$(build_definition_leaf_path "$stem" "$trace_suffix")"
  local leaf_abs="${REPO_ROOT}/${leaf_rel}"
  if [[ -e "$leaf_abs" ]]; then
    die "Leaf already exists: ${leaf_rel}"
  fi

  local created_at
  created_at="$(iso_utc_now)"

  local tmp
  tmp="$(mktemp)"
  {
    printf '%s\n' '---'
    printf 'trace_id: %s\n' "$trace_id"
    printf 'packet_id: %s\n' "$packet_id"
    printf 'created_at: %s\n' "$created_at"
    printf 'previous: %s\n' "$previous"
    printf '%s\n' '---'
    strip_leading_frontmatter "$source_path"
  } > "$tmp"

  redact_stream < "$tmp" > "$leaf_abs"
  rm -f "$tmp"

  update_factory_head_value "$key" "$leaf_rel"
  printf '%s' "$leaf_abs"
}

slugify() {
  local value="$1"
  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  value="$(printf '%s' "$value" | tr -cs 'a-z0-9' '-')"
  value="${value#-}"
  value="${value%-}"
  if [[ -z "$value" ]]; then
    value="${FACTORY_SLUG_FALLBACK:-item}"
  fi
  printf '%s' "$value"
}

is_placeholder_value() {
  local value="$1"
  if [[ -z "$value" ]]; then
    return 0
  fi
  case "$value" in
    *"["*|*"]"*|*"TBD"*|*"TODO"*|*"ENTER_"*|*"REPLACE_"*|*"Not provided"*)
      return 0
      ;;
  esac
  return 1
}

read_task_field() {
  local label="$1"
  local value
  value="$(awk -v label="$label" '
    $0 ~ "\\*\\*" label "\\*\\*" {
      sub(/.*\\*\\*[^*]+\\*\\*:[[:space:]]*/, "", $0);
      print $0;
      exit
    }
  ' "$TASK_FILE")"
  value="$(trim "$value")"
  if is_placeholder_value "$value"; then
    echo "Not provided"
  else
    echo "$value"
  fi
}

render_definition_template() {
  local template_path="$1"
  local output_path="$2"
  shift 2

  if (( $# % 2 != 0 )); then
    die "render_definition_template requires TOKEN value pairs."
  fi

  require_file "$template_path"
  [[ -x "$TEMPLATE_BIN" ]] || die "template binary missing or not executable: ${TEMPLATE_BIN}"

  local render_key=""
  if [[ -n "${AGENT_TEMPLATE_PATH:-}" && "$template_path" == "$AGENT_TEMPLATE_PATH" ]]; then
    render_key="agent"
  elif [[ -n "${TASK_TEMPLATE_PATH:-}" && "$template_path" == "$TASK_TEMPLATE_PATH" ]]; then
    render_key="task"
  elif [[ -n "${SKILL_TEMPLATE_PATH:-}" && "$template_path" == "$SKILL_TEMPLATE_PATH" ]]; then
    render_key="skill"
  else
    die "unsupported definition template path: ${template_path}"
  fi

  local slots_tmp
  slots_tmp="$(mktemp)"

  while (( $# > 0 )); do
    local token="$1"
    local value="$2"
    shift 2
    printf '[%s]\n%s\n\n' "$token" "$value" >> "$slots_tmp"
  done

  if ! "$TEMPLATE_BIN" render "$render_key" --slots-file="$slots_tmp" --out="$output_path"; then
    rm -f "$slots_tmp" "$output_path"
    die "Draft rendering failed for ${template_path}."
  fi

  rm -f "$slots_tmp"
}
