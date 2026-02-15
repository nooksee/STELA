#!/usr/bin/env bash
set -euo pipefail

SYNTH_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNTH_REPO_ROOT="${PROJECT_REPO_ROOT:-$(cd "${SYNTH_SCRIPT_DIR}/../../.." && pwd)}"

SYNTH_DEFAULT_MANIFEST="ops/lib/manifests/OPS.md"
SYNTH_HAZARD_BLACKLIST=(
  "docs//agents"
  "docs//tasks"
  "docs//skills"
  "opt/_factory/agents"
  "opt/_factory/tasks"
  "opt/_factory/skills"
)
declare -a SYNTH_RESOLVED_PATHS=()
declare -A SYNTH_SEEN_FILES=()
declare -A SYNTH_SEEN_MANIFESTS=()

synth_usage() {
  cat <<'USAGE'
Usage: ops/lib/scripts/synthesize.sh [--manifest=PATH] [--mode=stream|list]

Modes:
- stream: emit synthesized bundle stream with canonical file headers (default).
- list: emit resolved file list only.
USAGE
}

synth_die() {
  if declare -F project_die >/dev/null 2>&1; then
    project_die "$*"
  fi
  echo "ERROR: $*" >&2
  exit 1
}

synth_trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

synth_manifest_abs() {
  local manifest_rel="$1"
  local manifest_clean
  manifest_clean="$(synth_trim "$manifest_rel")"
  manifest_clean="${manifest_clean#./}"
  if [[ -z "$manifest_clean" ]]; then
    synth_die "manifest path is required"
  fi

  local manifest_abs="${SYNTH_REPO_ROOT}/${manifest_clean}"
  if [[ ! -f "$manifest_abs" ]]; then
    synth_die "manifest not found: ${manifest_clean}"
  fi
  printf '%s' "$manifest_abs"
}

synth_has_glob() {
  local value="$1"
  [[ "$value" == *"*"* || "$value" == *"?"* || "$value" == *"["* ]]
}

resolve_manifest_entry() {
  local entry_raw="$1"
  local entry
  entry="$(synth_trim "$entry_raw")"
  entry="${entry#./}"

  if [[ -z "$entry" ]]; then
    return 0
  fi

  if synth_has_glob "$entry"; then
    synth_die "manifest glob not allowed at runtime: ${entry}. Run ops/bin/compile."
  fi

  if [[ ! -f "${SYNTH_REPO_ROOT}/${entry}" ]]; then
    synth_die "manifest entry not found: ${entry}"
  fi
  printf '%s\n' "$entry"
}

resolve_manifest_recursive() {
  local manifest_abs="$1"

  local manifest_rel="${manifest_abs#"${SYNTH_REPO_ROOT}/"}"
  if [[ -n "${SYNTH_SEEN_MANIFESTS[$manifest_rel]:-}" ]]; then
    return 0
  fi
  SYNTH_SEEN_MANIFESTS["$manifest_rel"]=1

  local -a entries=()
  mapfile -t entries < <(awk -F'`' 'NF >= 3 { for (i = 2; i <= NF; i += 2) print $i }' "$manifest_abs")

  local entry
  for entry in "${entries[@]}"; do
    entry="$(synth_trim "$entry")"
    [[ -z "$entry" ]] && continue

    if [[ "$entry" == @manifest:* ]]; then
      local include_rel="${entry#@manifest:}"
      include_rel="${include_rel#./}"
      local include_abs
      include_abs="$(synth_manifest_abs "$include_rel")"
      resolve_manifest_recursive "$include_abs"
      continue
    fi

    local expanded
    while IFS= read -r expanded; do
      [[ -z "$expanded" ]] && continue
      if [[ -z "${SYNTH_SEEN_FILES[$expanded]:-}" ]]; then
        SYNTH_SEEN_FILES["$expanded"]=1
        SYNTH_RESOLVED_PATHS+=("$expanded")
      fi
    done < <(resolve_manifest_entry "$entry")
  done
}

resolve_manifest() {
  local manifest_rel="$1"
  local manifest_abs
  manifest_abs="$(synth_manifest_abs "$manifest_rel")"

  SYNTH_RESOLVED_PATHS=()
  unset SYNTH_SEEN_FILES SYNTH_SEEN_MANIFESTS
  declare -gA SYNTH_SEEN_FILES=()
  declare -gA SYNTH_SEEN_MANIFESTS=()

  resolve_manifest_recursive "$manifest_abs"

  if (( ${#SYNTH_RESOLVED_PATHS[@]} == 0 )); then
    synth_die "manifest resolved to no files: ${manifest_rel}"
  fi

  printf '%s\n' "${SYNTH_RESOLVED_PATHS[@]}"
}

enforce_hazards() {
  local file_path
  local hazard
  for file_path in "$@"; do
    for hazard in "${SYNTH_HAZARD_BLACKLIST[@]}"; do
      if [[ "$file_path" == "$hazard" || "$file_path" == "$hazard/"* ]]; then
        synth_die "context hazard detected: ${file_path}"
      fi
    done
  done
}

synth_strip_toc() {
  awk '
    BEGIN { skip=0 }
    /^## (Table of Contents|Contents|TOC)$/ { skip=1; next }
    skip && /^# / { skip=0 }
    skip && /^## / { skip=0 }
    !skip { print }
  '
}

synth_redact_stream() {
  sed -E \
    -e 's/AKIA[0-9A-Z]{16}/[REDACTED]/g' \
    -e 's/ASIA[0-9A-Z]{16}/[REDACTED]/g' \
    -e 's/AIza[0-9A-Za-z_-]{35}/[REDACTED]/g' \
    -e 's/xox[baprs]-[0-9A-Za-z-]{10,48}/[REDACTED]/g' \
    -e 's/ghp_[0-9A-Za-z]{36}/[REDACTED]/g' \
    -e 's/ghs_[0-9A-Za-z]{36}/[REDACTED]/g' \
    -e 's/-----BEGIN [A-Z ]+ PRIVATE KEY-----/[REDACTED PRIVATE KEY]/g'
}

synth_emit_sop_head() {
  local file="$1"
  local limit="${SYNTHESIZE_SOP_LIMIT:-10}"
  awk -v limit="$limit" '
    BEGIN { count=0 }
    /^## [0-9]{4}-[0-9]{2}-[0-9]{2} / {
      count++
      if (count > limit) {
        exit
      }
    }
    { print }
  ' "$file"
}

emit_stream() {
  local file_path
  local abs_path

  for file_path in "$@"; do
    abs_path="${SYNTH_REPO_ROOT}/${file_path}"
    if [[ ! -f "$abs_path" ]]; then
      synth_die "missing synthesized file: ${file_path}"
    fi

    printf '## %s\n' "$file_path"
    if [[ "$file_path" == "SoP.md" ]]; then
      synth_emit_sop_head "$abs_path" | synth_strip_toc | synth_redact_stream
    else
      synth_strip_toc < "$abs_path" | synth_redact_stream
    fi
    printf '\n\n'
  done
}

synthesize_manifest_list() {
  local manifest_rel="$1"
  local -a paths=()

  mapfile -t paths < <(resolve_manifest "$manifest_rel")
  enforce_hazards "${paths[@]}"
  printf '%s\n' "${paths[@]}"
}

synthesize_manifest_stream() {
  local manifest_rel="$1"
  local -a paths=()

  mapfile -t paths < <(resolve_manifest "$manifest_rel")
  enforce_hazards "${paths[@]}"
  emit_stream "${paths[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  manifest_rel="$SYNTH_DEFAULT_MANIFEST"
  mode="stream"

  for arg in "$@"; do
    case "$arg" in
      --manifest=*)
        manifest_rel="${arg#--manifest=}"
        ;;
      --mode=list|--list)
        mode="list"
        ;;
      --mode=stream)
        mode="stream"
        ;;
      -h|--help)
        synth_usage
        exit 0
        ;;
      *)
        synth_die "Unknown arg: ${arg}"
        ;;
    esac
  done

  if [[ "$mode" == "list" ]]; then
    synthesize_manifest_list "$manifest_rel"
  else
    synthesize_manifest_stream "$manifest_rel"
  fi
fi
