#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
SKILL_FILE="${REPO_ROOT}/opt/_factory/SKILLS.md"
SKILLS_REGISTRY="${REPO_ROOT}/docs/ops/registry/SKILLS.md"
TASK_FILE="${REPO_ROOT}/TASK.md"
CONTEXT_MANIFEST="${REPO_ROOT}/ops/lib/manifests/CONTEXT.md"
SKILLS_DIR="${REPO_ROOT}/opt/_factory/skills"
HANDOFF_DIR="${REPO_ROOT}/archives/definitions"
SKILL_TEMPLATE_PATH="${REPO_ROOT}/ops/src/definitions/skill.md.tpl"
TEMPLATE_BIN="${REPO_ROOT}/ops/bin/template"
HEURISTICS_LIB="${SCRIPT_DIR}/heuristics.sh"

if [[ -f "$HEURISTICS_LIB" ]]; then
  # shellcheck source=/dev/null
  source "$HEURISTICS_LIB"
else
  detect_hot_zone() { echo "None"; }
  detect_high_churn() { echo "None"; }
  generate_provenance_block() { echo "## Provenance"; }
  check_semantic_collision() { return 0; }
fi

usage() {
  cat <<'USAGE'
Usage:
  ops/lib/scripts/skill.sh harvest|--harvest [--name "..."] [--context "..."] [--solution "..."] [--context-stdin | --solution-stdin] [--force]
  ops/lib/scripts/skill.sh promote|--promote <draft_path> [--delete-draft]
  ops/lib/scripts/skill.sh check|--check

Legacy positional alias:
  ops/lib/scripts/skill.sh "name" "context" "solution"

Notes:
- Use --context-stdin or --solution-stdin to read multi-line content from stdin (heredoc-safe). Only one stdin field is allowed per invocation.
- Harvest auto-detects provenance and can suggest name or context when omitted.
- Promote without a draft path uses the most recent draft when unambiguous.
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    die "Required file missing: $path"
  fi
}

require_repo_root() {
  require_file "$SKILL_FILE"
  require_file "$SKILLS_REGISTRY"
  require_file "$TASK_FILE"
  require_file "$CONTEXT_MANIFEST"
  require_file "$SKILL_TEMPLATE_PATH"
}

ensure_handoff_dir() {
  mkdir -p "$HANDOFF_DIR"
}

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
  case "$template_path" in
    "$SKILL_TEMPLATE_PATH")
      render_key="skill"
      ;;
    *)
      die "unsupported definition template path: ${template_path}"
      ;;
  esac

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

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
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

select_latest_path_by_mtime() {
  local latest_path=""
  local latest_mtime=-1
  local path=""
  local mtime=0

  for path in "$@"; do
    [[ -f "$path" ]] || continue
    mtime="$(stat -c %Y "$path")"
    if (( mtime > latest_mtime )); then
      latest_mtime="$mtime"
      latest_path="$path"
      continue
    fi
    if (( mtime == latest_mtime )) && [[ "$path" > "$latest_path" ]]; then
      latest_path="$path"
    fi
  done

  [[ -n "$latest_path" ]] || return 1
  printf '%s' "$latest_path"
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
  die "Missing packet ID. Set STELA_PACKET_ID or update TASK.md Current DP."
}

build_definition_leaf_path() {
  local stem="$1"
  local trace_suffix="$2"
  printf 'archives/definitions/%s-%s-%s.md' "$stem" "$(date -u +%Y-%m-%d)" "$trace_suffix"
}

read_factory_head_value() {
  local key="$1"
  local value
  value="$(awk -F':' -v key="$key" '
    $1 == key {
      entry=$0
      sub(/^[^:]+:[[:space:]]*/, "", entry)
      print entry
      exit
    }
  ' "$SKILL_FILE")"
  value="$(trim "$value")"
  if [[ -z "$value" ]]; then
    die "Missing ${key}: pointer in ${SKILL_FILE}"
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
  ' "$SKILL_FILE" > "$tmp"; then
    status=$?
    rm -f "$tmp"
    if [[ "$status" -eq 2 ]]; then
      die "Failed to locate ${key}: pointer in ${SKILL_FILE}"
    fi
    die "Failed to rewrite ${key}: pointer in ${SKILL_FILE}"
  fi

  mv "$tmp" "$SKILL_FILE"
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

is_placeholder_value() {
  local value="$1"
  if [[ -z "$value" ]]; then
    return 0
  fi
  case "$value" in
    *"["*|*"]"*|*"TBD"*|*"TODO"*|*"ENTER_"*|*"REPLACE_"*)
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

slugify() {
  local value="$1"
  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  value="$(printf '%s' "$value" | tr -cs 'a-z0-9' '-')"
  value="${value#-}"
  value="${value%-}"
  if [[ -z "$value" ]]; then
    value="skill"
  fi
  printf '%s' "$value"
}

read_multiline_from_tty() {
  local lines=()
  local line
  while IFS= read -r line; do
    if [[ "$line" == "EOF" ]]; then
      break
    fi
    lines+=("$line")
  done
  printf '%s\n' "${lines[@]}"
}

collect_harvest_inputs() {
  local -n out_name=$1
  local -n out_context=$2
  local -n out_solution=$3
  local -n out_force=$4
  local allow_empty="${5:-0}"
  shift 5

  local context_from_stdin=0
  local solution_from_stdin=0
  out_force=0
  local positional=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name)
        out_name="$2"
        shift 2
        ;;
      --context)
        out_context="$2"
        shift 2
        ;;
      --solution)
        out_solution="$2"
        shift 2
        ;;
      --context-stdin)
        context_from_stdin=1
        shift
        ;;
      --solution-stdin)
        solution_from_stdin=1
        shift
        ;;
      --force)
        out_force=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        while [[ $# -gt 0 ]]; do
          positional+=("$1")
          shift
        done
        ;;
      -*)
        die "Unknown option: $1"
        ;;
      *)
        positional+=("$1")
        shift
        ;;
    esac
  done

  if (( context_from_stdin + solution_from_stdin > 1 )); then
    die "Only one of --context-stdin or --solution-stdin is allowed"
  fi

  if (( ${#positional[@]} > 0 )); then
    if [[ -z "$out_name" ]]; then
      out_name="${positional[0]:-}"
    fi
    if [[ -z "$out_context" ]]; then
      out_context="${positional[1]:-}"
    fi
    if [[ -z "$out_solution" ]]; then
      out_solution="${positional[2]:-}"
    fi
    if (( ${#positional[@]} > 3 )); then
      die "Too many positional arguments"
    fi
  fi

  if [[ $context_from_stdin -eq 1 ]]; then
    out_context="$(cat)"
  elif [[ $solution_from_stdin -eq 1 ]]; then
    out_solution="$(cat)"
  fi

  if [[ -z "$out_name" && "$allow_empty" -eq 0 ]]; then
    if [[ -t 0 ]]; then
      read -r -p "Name: " out_name
    else
      die "Name is required (use --name)"
    fi
  fi

  if [[ -z "$out_context" && "$allow_empty" -eq 0 ]]; then
    if [[ -t 0 ]]; then
      echo "Enter context. End with a single line containing EOF."
      out_context="$(read_multiline_from_tty)"
    else
      die "Context is required (use --context or --context-stdin)"
    fi
  fi

  if [[ -z "$out_solution" && "$allow_empty" -eq 0 ]]; then
    if [[ -t 0 ]]; then
      echo "Enter solution. End with a single line containing EOF."
      out_solution="$(read_multiline_from_tty)"
    else
      die "Solution is required (use --solution or --solution-stdin)"
    fi
  fi
}

context_hazard_check() {
  if grep -nE '(docs/|opt/_factory)/skills/|S-LEARN-' "$CONTEXT_MANIFEST" >/dev/null; then
    echo "FAIL: Skills are referenced in ops/lib/manifests/CONTEXT.md. Remove skills from the context manifest." >&2
    return 1
  fi
  return 0
}

next_skill_id() {
  local max_id=0

  if [[ -d "$SKILLS_DIR" ]]; then
    while IFS= read -r file; do
      local base
      base="$(basename "$file")"
      if [[ "$base" =~ S-LEARN-([0-9]+)\.md ]]; then
        local num="${BASH_REMATCH[1]}"
        if ((10#$num > max_id)); then
          max_id=$((10#$num))
        fi
      fi
    done < <(find "$SKILLS_DIR" -maxdepth 1 -type f -name 'S-LEARN-*.md')
  fi

  while IFS= read -r match; do
    if [[ "$match" =~ S-LEARN-([0-9]+) ]]; then
      local num="${BASH_REMATCH[1]}"
      if ((10#$num > max_id)); then
        max_id=$((10#$num))
      fi
    fi
  done < <(grep -oE 'S-LEARN-[0-9]+' "$SKILLS_REGISTRY" 2>/dev/null || true)

  local next_id=$((max_id + 1))
  local next_id_fmt
  next_id_fmt="$(printf '%02d' "$next_id")"
  printf 'S-LEARN-%s' "$next_id_fmt"
}

insert_skill_registry_entry() {
  local row="$1"
  local tmp
  tmp="$(mktemp)"

  if ! awk -v row="$row" '
    BEGIN { inserted=0 }
    {
      print
      if (!inserted && $0 ~ /^\|[[:space:]]*---/) {
        print row
        inserted=1
      }
    }
    END { if (!inserted) exit 2 }
  ' "$SKILLS_REGISTRY" > "$tmp"; then
    status=$?
    rm -f "$tmp"
    if [[ "$status" -eq 2 ]]; then
      die "Skills registry table not found in docs/ops/registry/SKILLS.md"
    fi
    die "Failed to update docs/ops/registry/SKILLS.md"
  fi

  mv "$tmp" "$SKILLS_REGISTRY"
}

validate_candidate() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    die "Draft not found: $path"
  fi

  if grep -nE '\bTODO\b|\bTBD\b|ENTER_|REPLACE_|\[ID\]|\[TITLE\]' "$path" >/dev/null; then
    die "Draft contains placeholder markers. Clean the draft before promotion."
  fi

  local required_sections=(
    "## Provenance"
    "## Scope"
    "## Invocation guidance"
    "## Drift preventers"
  )

  local section
  for section in "${required_sections[@]}"; do
    if ! awk -v section="$section" '
      BEGIN { in_section=0; found=0; has_content=0 }
      $0 == section { in_section=1; found=1; next }
      in_section {
        if ($0 ~ /^## /) { exit }
        if ($0 ~ /[^[:space:]]/) { has_content=1; exit }
      }
      END { if (!found || !has_content) exit 1 }
    ' "$path"; then
      die "Draft section missing or empty: $section"
    fi
  done

  if ! grep -nE '^# Skill Draft: .+' "$path" >/dev/null; then
    die "Draft header missing or invalid. Expected '# Skill Draft: <title>'."
  fi
}

cmd_check() {
  require_repo_root
  if context_hazard_check; then
    echo "PASS: Skills Context Hazard check clean."
  else
    echo "FAIL: Skills Context Hazard check failed."
    exit 1
  fi
}

cmd_harvest() {
  require_repo_root
  ensure_handoff_dir

  local name=""
  local context=""
  local solution=""
  local force=0

  collect_harvest_inputs name context solution force 1 "$@"

  local base_ref="main"
  local head_ref="HEAD"

  local hot_zone
  hot_zone="$(detect_hot_zone "$base_ref" "$head_ref" "$REPO_ROOT")"
  if [[ -z "$hot_zone" ]]; then
    hot_zone="None"
  fi

  local high_churn
  high_churn="$(detect_high_churn "$base_ref" "$head_ref" "$REPO_ROOT")"
  if [[ -z "$high_churn" ]]; then
    high_churn="None"
  fi

  if [[ -z "$name" ]]; then
    if [[ "$hot_zone" != "None" ]]; then
      name="Hot Zone: ${hot_zone}"
    else
      name="Skill Draft"
    fi
  fi

  if [[ -z "$context" ]]; then
    if [[ "$hot_zone" != "None" ]]; then
      context="the hot zone ${hot_zone}"
    else
      context="capturing a reusable lesson from recent work"
    fi
    if [[ "$high_churn" != "None" ]]; then
      local churn_inline
      churn_inline="$(printf '%s\n' "$high_churn" | awk 'NF {printf "%s%s", sep, $0; sep="; "}')"
      context="${context}; high churn: ${churn_inline}"
    fi
  fi

  local solution_placeholder=0
  if [[ -z "$solution" ]]; then
    solution="REPLACE_SOLUTION"
    solution_placeholder=1
  fi

  if ! check_semantic_collision "$name" "$SKILLS_DIR" "$HANDOFF_DIR"; then
    if [[ $force -eq 0 ]]; then
      die "Semantic collision detected. Use --force to override."
    else
      echo "WARN: Semantic collision override enabled." >&2
    fi
  fi

  local dp_id
  local objective
  dp_id="$(read_task_field "Current DP")"
  objective="$(read_task_field "Goal")"
  local packet_id
  packet_id="$(resolve_packet_id "$dp_id")"

  local trace_id
  trace_id="$(resolve_trace_id)"
  local trace_suffix
  trace_suffix="$(trace_suffix_from_id "$trace_id")"
  local created_at
  created_at="$(iso_utc_now)"
  local current_candidate
  current_candidate="$(read_factory_head_value "candidate")"
  local previous
  previous="$(normalize_previous_head_value "$current_candidate")"
  local draft_rel_path
  draft_rel_path="$(build_definition_leaf_path "skill-candidate" "$trace_suffix")"
  local draft_path
  draft_path="${REPO_ROOT}/${draft_rel_path}"
  if [[ -e "$draft_path" ]]; then
    die "Leaf already exists: ${draft_rel_path}"
  fi

  local tmp
  tmp="$(mktemp)"

  local provenance_block
  provenance_block="$(generate_provenance_block "$packet_id" "$objective" "$base_ref" "$head_ref" "$REPO_ROOT")"

  render_definition_template "$SKILL_TEMPLATE_PATH" "$tmp" \
    "TRACE_ID" "$trace_id" \
    "PACKET_ID" "$packet_id" \
    "CREATED_AT" "$created_at" \
    "PREVIOUS" "$previous" \
    "SKILL_NAME" "$name" \
    "PROVENANCE_BLOCK" "$provenance_block" \
    "CONTEXT" "$context" \
    "SOLUTION" "$solution"

  redact_stream < "$tmp" > "$draft_path"
  rm -f "$tmp"
  update_factory_head_value "candidate" "$draft_rel_path"

  if [[ $solution_placeholder -eq 1 ]]; then
    echo "WARN: Solution placeholder present. Refine the draft before promotion." >&2
  fi

  echo "$draft_path"
}

select_latest_draft() {
  local draft_path=""
  mapfile -t drafts < <(find "$HANDOFF_DIR" -maxdepth 1 -type f -name 'skill-candidate-*.md' | sort)
  if (( ${#drafts[@]} == 0 )); then
    die "No draft found in archives/definitions"
  fi
  if (( ${#drafts[@]} == 1 )); then
    echo "${drafts[0]}"
    return 0
  fi

  draft_path="$(ls -t "${drafts[@]}" | head -n 1)"
  local newest_time
  newest_time="$(stat -c %Y "$draft_path")"

  local same_time=0
  local path
  for path in "${drafts[@]}"; do
    if [[ "$(stat -c %Y "$path")" == "$newest_time" ]]; then
      same_time=$((same_time + 1))
    fi
  done

  if (( same_time > 1 )); then
    die "Multiple drafts share the same timestamp. Provide an explicit draft path."
  fi

  echo "$draft_path"
}

materialize_promoted_skill() {
  local draft_path="$1"
  local skill_id="$2"
  local title="$3"
  local output_path="$4"

  awk -v header="# ${skill_id}: ${title}" '
    BEGIN { has_pointers=0; inserted=0 }
    /^## Pointers$/ {
      has_pointers=1
    }
    NR == 1 {
      print header
      next
    }
    $0 == "## Invocation guidance" {
      print "## Invocation Guidance"
      next
    }
    $0 == "## Drift preventers" {
      if (!has_pointers && !inserted) {
        print "## Pointers"
        print "- Constitution: `PoT.md`"
        print "- Governance: `docs/GOVERNANCE.md`"
        print "- Contract: `TASK.md`"
        print "- Registry: `docs/ops/registry/SKILLS.md`"
        print ""
        inserted=1
      }
      print
      next
    }
    {
      print
    }
    END {
      if (!has_pointers && !inserted) {
        print ""
        print "## Pointers"
        print "- Constitution: `PoT.md`"
        print "- Governance: `docs/GOVERNANCE.md`"
        print "- Contract: `TASK.md`"
        print "- Registry: `docs/ops/registry/SKILLS.md`"
      }
    }
  ' "$draft_path" > "$output_path"
}

cmd_promote() {
  require_repo_root
  ensure_handoff_dir

  local delete_draft=0
  local draft_path=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --delete-draft)
        delete_draft=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --*)
        die "Unknown option: $1"
        ;;
      *)
        if [[ -z "$draft_path" ]]; then
          draft_path="$1"
          shift
        else
          die "Unexpected extra argument: $1"
        fi
        ;;
    esac
  done

  if [[ -z "$draft_path" ]]; then
    draft_path="$(select_latest_draft)"
  fi

  validate_candidate "$draft_path"

  if ! context_hazard_check; then
    exit 1
  fi

  local title
  title="$(grep -m1 -E '^# Skill Draft: ' "$draft_path" | sed -E 's/^# Skill Draft: //')"
  title="$(trim "$title")"
  if [[ -z "$title" ]]; then
    die "Draft title is empty"
  fi

  local skill_id
  skill_id="$(next_skill_id)"
  local skill_path
  skill_path="${SKILLS_DIR}/${skill_id}.md"

  if [[ -e "$skill_path" ]]; then
    die "Skill file already exists: $skill_path"
  fi

  mkdir -p "$SKILLS_DIR"

  local tmp_skill
  tmp_skill="$(mktemp)"
  materialize_promoted_skill "$draft_path" "$skill_id" "$title" "$tmp_skill"
  mv "$tmp_skill" "$skill_path"

  if grep -Fq "| ${skill_id} |" "$SKILLS_REGISTRY"; then
    die "docs/ops/registry/SKILLS.md already contains ${skill_id}"
  fi

  local registry_row
  registry_row="| ${skill_id} | Skill: ${title} | opt/_factory/skills/${skill_id}.md | |"
  insert_skill_registry_entry "$registry_row"

  local packet_seed
  packet_seed="$(awk '
    /^packet_id:[[:space:]]*/ {
      line=$0
      sub(/^packet_id:[[:space:]]*/, "", line)
      print line
      exit
    }
  ' "$draft_path")"
  packet_seed="$(trim "$packet_seed")"
  if [[ -z "$packet_seed" ]]; then
    packet_seed="$(read_task_field "Current DP")"
  fi

  local packet_id
  packet_id="$(resolve_packet_id "$packet_seed")"
  emit_head_leaf_from_source "promotion" "skill-promotion" "$skill_path" "$packet_id" >/dev/null

  if (( delete_draft == 1 )); then
    rm -f "$draft_path"
  fi

  echo "${skill_path}"
}

cmd_legacy() {
  if [[ "$#" -ne 3 ]]; then
    usage >&2
    exit 1
  fi
  cmd_harvest --name "$1" --context "$2" --solution "$3"
}

main() {
  if [[ "$#" -eq 0 ]]; then
    usage >&2
    exit 1
  fi

  case "$1" in
    harvest|--harvest)
      shift
      cmd_harvest "$@"
      ;;
    promote|--promote)
      shift
      cmd_promote "$@"
      ;;
    check|--check)
      shift
      cmd_check "$@"
      ;;
    -h|--help)
      usage
      ;;
    *)
      cmd_legacy "$@"
      ;;
  esac
}

main "$@"
