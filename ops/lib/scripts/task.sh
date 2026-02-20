#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TASKS_DIR="${REPO_ROOT}/opt/_factory/tasks"
TASKS_REGISTRY="${REPO_ROOT}/docs/ops/registry/tasks.md"
TASKS_LEDGER="${REPO_ROOT}/opt/_factory/TASKS.md"
TASK_FILE="${REPO_ROOT}/TASK.md"
CONTEXT_MANIFEST="${REPO_ROOT}/ops/lib/manifests/CONTEXT.md"
HANDOFF_DIR="${REPO_ROOT}/archives/definitions"
TASK_TEMPLATE_PATH="${REPO_ROOT}/ops/src/definitions/task.md.tpl"
TEMPLATE_BIN="${REPO_ROOT}/ops/bin/template"
HEURISTICS_LIB="${SCRIPT_DIR}/heuristics.sh"

if [[ -f "$HEURISTICS_LIB" ]]; then
  # shellcheck source=/dev/null
  source "$HEURISTICS_LIB"
else
  generate_provenance_block() { echo "## Provenance"; }
fi

FACTORY_HEAD_FILE="${TASKS_LEDGER}"
FACTORY_SLUG_FALLBACK="task"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/factory.sh"

usage() {
  cat <<'USAGE'
Usage:
  ops/lib/scripts/task.sh harvest --id B-TASK-XX --name "..." --objective "..." [--dp "DP-OPS-XXXX"]
  ops/lib/scripts/task.sh promote <draft_path> [--delete-draft]
  ops/lib/scripts/task.sh check|--check
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
  require_file "$TASKS_LEDGER"
  require_file "$TASKS_REGISTRY"
  require_file "$TASK_FILE"
  require_file "$CONTEXT_MANIFEST"
  require_file "$TASK_TEMPLATE_PATH"
}

task_id_exists() {
  local task_id="$1"
  if [[ -z "$task_id" ]]; then
    return 1
  fi
  if awk -v task_id="$task_id" -F'|' '
    $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*---/ {
      id=$2
      gsub(/^[[:space:]]+/, "", id)
      gsub(/[[:space:]]+$/, "", id)
      if (id == task_id) { found=1; exit }
    }
    END { exit found ? 0 : 1 }
  ' "$TASKS_REGISTRY"; then
    return 0
  fi
  return 1
}

ensure_handoff_dir() {
  mkdir -p "$HANDOFF_DIR"
}

ensure_tasks_dir() {
  mkdir -p "$TASKS_DIR"
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
  die "Missing packet ID. Provide STELA_PACKET_ID or --dp."
}

build_definition_leaf_path() {
  local stem="$1"
  local trace_suffix="$2"
  local suffix="${3:-}"
  local path
  path="$(printf 'archives/definitions/%s-%s-%s' "$stem" "$(date -u +%Y-%m-%d)" "$trace_suffix")"
  if [[ -n "$suffix" ]]; then
    path="${path}-${suffix}"
  fi
  printf '%s.md' "$path"
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
  ' "$TASKS_LEDGER")"
  value="$(trim "$value")"
  if [[ -z "$value" ]]; then
    die "Missing ${key}: pointer in ${TASKS_LEDGER}"
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

hydrate_task_draft_defaults() {
  local path="$1"
  local tmp
  tmp="$(mktemp)"

  awk '
    {
      if ($0 == "- **Primary Agent:** Not provided") {
        print "- **Primary Agent:** R-AGENT-01"
        next
      }
      if ($0 == "- **Supporting Agents:** Not provided") {
        print "- **Supporting Agents:** (none)"
        next
      }
      if ($0 == "5. Closeout: Complete Closeout per `TASK.md` Section 4.") {
        print "5. Closeout: Complete Closeout per `TASK.md` Section 3.5."
        next
      }
      if ($0 ~ /^- \*\*Allowed:\*\* Not provided\.?$/) {
        print "- **Allowed:** Execute only allowlisted DP changes and complete Closeout per `TASK.md` Section 3.5."
        next
      }
      if ($0 ~ /^- \*\*Forbidden:\*\* Not provided\.?$/) {
        print "- **Forbidden:** Do not modify out-of-scope files or skip required verification."
        next
      }
      if ($0 ~ /^- \*\*Stop Conditions:\*\* Not provided\.?$/) {
        print "- **Stop Conditions:** Stop on missing required inputs, lint failures, or scope expansion."
        next
      }
      print
    }
  ' "$path" > "$tmp"

  mv "$tmp" "$path"
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
  ' "$TASKS_LEDGER" > "$tmp"; then
    status=$?
    rm -f "$tmp"
    if [[ "$status" -eq 2 ]]; then
      die "Failed to locate ${key}: pointer in ${TASKS_LEDGER}"
    fi
    die "Failed to rewrite ${key}: pointer in ${TASKS_LEDGER}"
  fi

  mv "$tmp" "$TASKS_LEDGER"
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
  local suffix="${5:-}"

  local current_head
  current_head="$(read_factory_head_value "$key")"
  local previous
  previous="$(normalize_previous_head_value "$current_head")"

  local trace_id
  trace_id="$(resolve_trace_id)"
  local trace_suffix
  trace_suffix="$(trace_suffix_from_id "$trace_id")"
  local leaf_rel
  leaf_rel="$(build_definition_leaf_path "$stem" "$trace_suffix" "$suffix")"
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
    value="task"
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

read_current_dp() {
  local raw
  raw="$(awk -F':' '/\\*\\*Current DP\\*\\*/ {print $2; exit}' "$TASK_FILE")"
  raw="$(trim "$raw")"
  if [[ -n "$raw" ]]; then
    raw="$(printf '%s' "$raw" | awk '{print $1}')"
  fi
  if is_placeholder_value "$raw"; then
    echo "Not provided"
  else
    echo "$raw"
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
  case "$template_path" in
    "$TASK_TEMPLATE_PATH")
      render_key="task"
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

section_has_content() {
  local section="$1"
  local path="$2"
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
}

field_value() {
  local label="$1"
  local path="$2"
  awk -v label="$label" '
    {
      needle = "**" label ":**"
      pos = index($0, needle)
      if (pos) {
        text = substr($0, pos + length(needle))
        gsub(/^[[:space:]]+/, "", text)
        print text
        exit
      }
    }
  ' "$path"
}

require_field_value() {
  local label="$1"
  local path="$2"
  local value
  value="$(field_value "$label" "$path")"
  value="$(trim "$value")"
  if is_placeholder_value "$value"; then
    die "Draft field missing or placeholder: $label"
  fi
}

validate_candidate() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    die "Draft not found: $path"
  fi

  if grep -nE '\bTODO\b|\bTBD\b|ENTER_|REPLACE_|\[ID\]|\[TITLE\]' "$path" >/dev/null; then
    die "Draft contains placeholder markers. Clean the draft before promotion."
  fi

  if ! grep -nE '^# Task Draft: .+' "$path" >/dev/null; then
    die "Draft header missing or invalid. Expected '# Task Draft: <name>'."
  fi

  section_has_content "## Provenance" "$path"
  section_has_content "## Orchestration" "$path"
  section_has_content "## Pointers" "$path"
  section_has_content "## Execution Logic" "$path"
  section_has_content "## Scope Boundary" "$path"

  require_field_value "Captured" "$path"
  require_field_value "DP-ID" "$path"
  require_field_value "Branch" "$path"
  require_field_value "HEAD" "$path"
  require_field_value "Objective" "$path"
  require_field_value "Primary Agent" "$path"
  require_field_value "Supporting Agents" "$path"
  require_field_value "Allowed" "$path"
  require_field_value "Forbidden" "$path"
  require_field_value "Stop Conditions" "$path"

  if ! grep -q 'PoT.md' "$path"; then
    die "Draft missing PoT.md pointer in Pointers section."
  fi
  if ! grep -q 'docs/GOVERNANCE.md' "$path"; then
    die "Draft missing docs/GOVERNANCE.md pointer in Pointers section."
  fi
  if ! grep -q 'TASK.md' "$path"; then
    die "Draft missing TASK.md pointer in Pointers section."
  fi

  local execution_section
  execution_section="$(awk -v section="## Execution Logic" '
    BEGIN { in_section=0 }
    $0 == section { in_section=1; next }
    /^## / { if (in_section) exit }
    in_section { print }
  ' "$path")"

  local last_step
  last_step="$(printf '%s\n' "$execution_section" | awk '/^[[:space:]]*[0-9]+\.[[:space:]]/ {line=$0} END {print line}')"
  if [[ -z "$last_step" ]]; then
    die "Draft Execution Logic missing numbered steps."
  fi
  if ! grep -q "Closeout" <<< "$last_step" || ! grep -q "TASK.md" <<< "$last_step" || ! grep -qi "Section 3.5" <<< "$last_step"; then
    die "Draft Execution Logic missing final Closeout pointer to TASK.md Section 3.5."
  fi
}

select_latest_draft() {
  local draft_path=""
  mapfile -t drafts < <(find "$HANDOFF_DIR" -maxdepth 1 -type f -name 'task-candidate-*.md' | sort)
  if (( ${#drafts[@]} == 0 )); then
    die "No draft found in ${HANDOFF_DIR}"
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

insert_registry_entry() {
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
  ' "$TASKS_REGISTRY" > "$tmp"; then
    status=$?
    rm -f "$tmp"
    if [[ "$status" -eq 2 ]]; then
      die "Task registry table not found in docs/ops/registry/tasks.md"
    fi
    die "Failed to update docs/ops/registry/tasks.md"
  fi

  mv "$tmp" "$TASKS_REGISTRY"
}

update_registry_entry() {
  local task_id="$1"
  local name="$2"
  local path="$3"
  local tmp
  tmp="$(mktemp)"

  local status=0
  if awk -v task_id="$task_id" -v name="$name" -v path="$path" '
    BEGIN { updated=0 }
    {
      if ($0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*---/) {
        id=$2
        gsub(/^[[:space:]]+/, "", id)
        gsub(/[[:space:]]+$/, "", id)
        if (id == task_id) {
          printf "| %s | %s | %s | |\n", task_id, name, path
          updated=1
          next
        }
      }
      print
    }
    END { if (updated == 0) exit 2 }
  ' "$TASKS_REGISTRY" > "$tmp"; then
    mv "$tmp" "$TASKS_REGISTRY"
    return 0
  else
    status=$?
  fi

  rm -f "$tmp"
  if [[ "$status" -eq 2 ]]; then
    return 1
  fi
  die "Failed to update docs/ops/registry/tasks.md"
}

cmd_harvest() {
  require_repo_root
  ensure_handoff_dir

  local task_id=""
  local name=""
  local dp_id=""
  local objective=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --id)
        task_id="$2"
        shift 2
        ;;
      --name)
        name="$2"
        shift 2
        ;;
      --objective)
        objective="$2"
        shift 2
        ;;
      --dp)
        dp_id="$2"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        die "Unknown option: $1"
        ;;
    esac
  done

  if [[ -z "$task_id" ]]; then
    die "--id is required"
  fi

  if [[ -z "$name" ]]; then
    die "--name is required"
  fi

  if [[ -z "$objective" ]]; then
    objective="$(read_task_field "Goal")"
  fi

  if is_placeholder_value "$objective"; then
    die "Objective is required and cannot be placeholder"
  fi

  if [[ -z "$dp_id" ]]; then
    dp_id="$(read_current_dp)"
  fi

  if is_placeholder_value "$dp_id"; then
    die "DP-ID is required and cannot be placeholder"
  fi

  if [[ ! "$task_id" =~ ^B-TASK-[0-9]{2,}$ ]]; then
    die "Task ID must match B-TASK-XX"
  fi
  if task_id_exists "$task_id"; then
    die "Task ID ${task_id} already exists in docs/ops/registry/tasks.md. Review the registry or run ops/lib/scripts/task.sh check before harvesting."
  fi

  local packet_id
  packet_id="$(resolve_packet_id "$dp_id")"
  local base_ref="main"
  local head_ref="HEAD"

  local provenance_block
  provenance_block="$(generate_provenance_block "$packet_id" "$objective" "$base_ref" "$head_ref" "$REPO_ROOT")"

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
  draft_rel_path="$(build_definition_leaf_path "task-candidate" "$trace_suffix" "$task_id")"
  local draft_path
  draft_path="${REPO_ROOT}/${draft_rel_path}"
  if [[ -e "$draft_path" ]]; then
    die "Leaf already exists: ${draft_rel_path}"
  fi

  local tmp
  tmp="$(mktemp)"

  render_definition_template "$TASK_TEMPLATE_PATH" "$tmp" \
    "TRACE_ID" "$trace_id" \
    "PACKET_ID" "$packet_id" \
    "CREATED_AT" "$created_at" \
    "PREVIOUS" "$previous" \
    "TASK_NAME" "$name" \
    "PROVENANCE_BLOCK" "$provenance_block"

  hydrate_task_draft_defaults "$tmp"

  redact_stream < "$tmp" > "$draft_path"
  rm -f "$tmp"

  update_factory_head_value "candidate" "$draft_rel_path"

  echo "$draft_path"
}

cmd_promote() {
  require_repo_root
  ensure_handoff_dir
  ensure_tasks_dir

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

  local name
  name="$(grep -m1 -E '^# Task Draft: ' "$draft_path" | sed -E 's/^# Task Draft: //')"
  name="$(trim "$name")"
  if [[ -z "$name" ]]; then
    die "Draft name is empty"
  fi
  local header_name="$name"
  if [[ "$header_name" != Task:\ * ]]; then
    header_name="Task: ${header_name}"
  fi

  local dp_id
  dp_id="$(field_value "DP-ID" "$draft_path")"
  dp_id="$(trim "$dp_id")"
  if is_placeholder_value "$dp_id"; then
    die "Draft DP-ID is missing or placeholder"
  fi

  local task_id=""
  if [[ "$draft_path" =~ (B-TASK-[0-9]{2,}) ]]; then
    task_id="${BASH_REMATCH[1]}"
  fi

  if [[ -z "$task_id" ]]; then
    die "Task ID not found in draft path. Expected B-TASK-XX in filename."
  fi

  local task_rel_path
  task_rel_path="opt/_factory/tasks/${task_id}.md"
  local task_path
  task_path="${TASKS_DIR}/${task_id}.md"

  local tmp_task
  tmp_task="$(mktemp)"
  strip_leading_frontmatter "$draft_path" | \
    awk -v header="# ${header_name}" '
      BEGIN { replaced=0 }
      /^# Task Draft: / {
        if (!replaced) { print header; replaced=1; next }
      }
      { print }
      END { if (!replaced) exit 1 }
    ' > "$tmp_task" || die "Failed to rewrite draft header"

  mv "$tmp_task" "$task_path"

  local registry_row
  registry_row="| ${task_id} | ${name} | ${task_rel_path} | |"

  if ! update_registry_entry "$task_id" "$name" "$task_rel_path"; then
    insert_registry_entry "$registry_row"
  fi

  local packet_id
  packet_id="$(resolve_packet_id "$dp_id")"
  emit_head_leaf_from_source "promotion" "task-promotion" "$task_path" "$packet_id" "$task_id" >/dev/null

  if (( delete_draft == 1 )); then
    rm -f "$draft_path"
  fi

  echo "$task_path"
}

cmd_check() {
  require_repo_root

  if grep -nE '(docs/|opt/_factory)/tasks|B-TASK-' "$CONTEXT_MANIFEST" >/dev/null; then
    echo "FAIL: Tasks are referenced in ops/lib/manifests/CONTEXT.md. Remove tasks from the context manifest." >&2
    exit 1
  fi

  if ! bash "$REPO_ROOT/tools/lint/task.sh"; then
    exit 1
  fi

  echo "OK: Task context hazard checks passed."
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
      die "Unknown command: $1"
      ;;
  esac
}

main "$@"
