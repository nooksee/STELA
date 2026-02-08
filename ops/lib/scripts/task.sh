#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TASKS_DIR="${REPO_ROOT}/docs/library/tasks"
TASKS_REGISTRY="${REPO_ROOT}/docs/ops/registry/TASKS.md"
TASKS_LEDGER="${REPO_ROOT}/docs/library/TASKS.md"
TASK_FILE="${REPO_ROOT}/TASK.md"
CONTEXT_MANIFEST="${REPO_ROOT}/ops/lib/manifests/CONTEXT.md"
HANDOFF_DIR="${REPO_ROOT}/storage/handoff"
HEURISTICS_LIB="${SCRIPT_DIR}/heuristics.sh"

if [[ -f "$HEURISTICS_LIB" ]]; then
  # shellcheck source=/dev/null
  source "$HEURISTICS_LIB"
else
  generate_provenance_block() { echo "## Provenance"; }
fi

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
}

require_tasks_ledger_sections() {
  if ! grep -q "^## Candidate Log" "$TASKS_LEDGER"; then
    die "Task ledger missing Candidate Log section."
  fi
  if ! grep -q "^## Promotion Log" "$TASKS_LEDGER"; then
    die "Task ledger missing Promotion Log section."
  fi
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

  if ! grep -q 'PoT.md' "$path"; then
    die "Draft missing PoT.md pointer in Pointers section."
  fi
  if ! grep -q 'docs/GOVERNANCE.md' "$path"; then
    die "Draft missing docs/GOVERNANCE.md pointer in Pointers section."
  fi
  if ! grep -q 'TASK.md' "$path"; then
    die "Draft missing TASK.md pointer in Pointers section."
  fi
}

append_candidate_log() {
  local task_id="$1"
  local name="$2"
  local dp_id="$3"
  local draft_path="$4"
  local timestamp
  timestamp="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  require_tasks_ledger_sections

  local entry_file
  entry_file="$(mktemp)"
  cat <<ENTRY_LOG > "$entry_file"

- ${timestamp}
  - Task ID: ${task_id}
  - Name: ${name}
  - DP provenance: ${dp_id}
  - Draft path: ${draft_path}
ENTRY_LOG

  local tmp
  tmp="$(mktemp)"

  if ! awk -v entry_file="$entry_file" '
    BEGIN { in_section=0; inserted=0 }
    function emit_entry() {
      while ((getline line < entry_file) > 0) { print line }
      close(entry_file)
    }
    /^## Candidate Log/ { in_section=1 }
    /^## Promotion Log/ {
      if (in_section && inserted == 0) { emit_entry(); inserted=1 }
      in_section=0
    }
    {
      if (in_section && $0 ~ /^- No entries recorded yet\./) next
      print
    }
    END { if (inserted == 0) exit 2 }
  ' "$TASKS_LEDGER" > "$tmp"; then
    status=$?
    rm -f "$tmp" "$entry_file"
    if [[ "$status" -eq 2 ]]; then
      die "Task ledger missing Promotion Log section."
    fi
    die "Failed to update docs/library/TASKS.md candidate log."
  fi

  mv "$tmp" "$TASKS_LEDGER"
  rm -f "$entry_file"
}

append_promotion_log() {
  local task_id="$1"
  local name="$2"
  local dp_id="$3"
  local task_path="$4"
  local timestamp
  timestamp="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  require_tasks_ledger_sections

  local entry_file
  entry_file="$(mktemp)"
  cat <<PROMO_LOG > "$entry_file"

- ${timestamp}
  - Task ID: ${task_id}
  - Name: ${name}
  - DP provenance: ${dp_id}
  - Promoted file: ${task_path}
PROMO_LOG

  local tmp
  tmp="$(mktemp)"

  if ! awk '
    BEGIN { in_section=0; seen=0 }
    /^## Promotion Log/ { in_section=1; seen=1 }
    {
      if (in_section && $0 ~ /^- No entries recorded yet\./) next
      print
    }
    END { if (seen == 0) exit 2 }
  ' "$TASKS_LEDGER" > "$tmp"; then
    status=$?
    rm -f "$tmp" "$entry_file"
    if [[ "$status" -eq 2 ]]; then
      die "Task ledger missing Promotion Log section."
    fi
    die "Failed to update docs/library/TASKS.md promotion log."
  fi

  cat "$entry_file" >> "$tmp"
  mv "$tmp" "$TASKS_LEDGER"
  rm -f "$entry_file"
}

select_latest_draft() {
  local draft_path=""
  mapfile -t drafts < <(find "$HANDOFF_DIR" -maxdepth 1 -type f -name 'task-draft-*.md' | sort)
  if (( ${#drafts[@]} == 0 )); then
    die "No draft found in storage/handoff"
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
      die "Task registry table not found in docs/ops/registry/TASKS.md"
    fi
    die "Failed to update docs/ops/registry/TASKS.md"
  fi

  mv "$tmp" "$TASKS_REGISTRY"
}

update_registry_entry() {
  local task_id="$1"
  local name="$2"
  local path="$3"
  local tmp
  tmp="$(mktemp)"

  if ! awk -v task_id="$task_id" -v name="$name" -v path="$path" '
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
    status=$?
    rm -f "$tmp"
    if [[ "$status" -eq 2 ]]; then
      return 1
    fi
    die "Failed to update docs/ops/registry/TASKS.md"
  fi

  mv "$tmp" "$TASKS_REGISTRY"
  return 0
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

  local base_ref="main"
  local head_ref="HEAD"

  local provenance_block
  provenance_block="$(generate_provenance_block "$dp_id" "$objective" "$base_ref" "$head_ref" "$REPO_ROOT")"

  local slug
  slug="$(slugify "$name")"
  local draft_path
  local counter=0

  while :; do
    if [[ $counter -eq 0 ]]; then
      draft_path="${HANDOFF_DIR}/task-draft-${task_id}-$(date -u '+%Y%m%d')-${slug}.md"
    else
      draft_path="${HANDOFF_DIR}/task-draft-${task_id}-$(date -u '+%Y%m%d')-${slug}-${counter}.md"
    fi
    if [[ ! -e "$draft_path" ]]; then
      break
    fi
    counter=$((counter + 1))
  done

  local tmp
  tmp="$(mktemp)"

  {
    cat <<DRAFT
# Task Draft: ${name}

${provenance_block}

## Orchestration
- **Primary Agent:** Not provided
- **Supporting Agents:** Not provided

## Pointers
- **Constitution:** \`PoT.md\`
- **Governance:** \`docs/GOVERNANCE.md\`
- **Contract:** \`TASK.md\`
- **Registry:** \`docs/ops/registry/TASKS.md\`
- **Toolchain:** Not provided
- **JIT Skills:** (none)
- **Reference Docs:** Not provided

## Execution Logic
1. Pre-flight: Not provided.
2. Execution: Not provided.
3. Verification: Not provided.
4. Correction: Not provided.

## Scope Boundary
- **Allowed:** Not provided.
- **Forbidden:** Not provided.
- **Stop Conditions:** Not provided.
DRAFT
  } > "$tmp"

  redact_stream < "$tmp" > "$draft_path"
  rm -f "$tmp"

  append_candidate_log "$task_id" "$name" "$dp_id" "$draft_path"

  echo "$draft_path"
}

cmd_promote() {
  require_repo_root
  ensure_handoff_dir
  ensure_tasks_dir
  require_tasks_ledger_sections

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
  task_rel_path="docs/library/tasks/${task_id}.md"
  local task_path
  task_path="${TASKS_DIR}/${task_id}.md"

  local tmp_task
  tmp_task="$(mktemp)"
  awk -v header="# Task: ${name}" '
    BEGIN { replaced=0 }
    /^# Task Draft: / {
      if (!replaced) { print header; replaced=1; next }
    }
    { print }
    END { if (!replaced) exit 1 }
  ' "$draft_path" > "$tmp_task" || die "Failed to rewrite draft header"

  mv "$tmp_task" "$task_path"

  local registry_row
  registry_row="| ${task_id} | ${name} | ${task_rel_path} | |"

  if ! update_registry_entry "$task_id" "$name" "$task_rel_path"; then
    insert_registry_entry "$registry_row"
  fi

  append_promotion_log "$task_id" "$name" "$dp_id" "$task_rel_path"

  if (( delete_draft == 1 )); then
    rm -f "$draft_path"
  fi

  echo "$task_path"
}

cmd_check() {
  require_repo_root

  if grep -nE 'docs/library/tasks|B-TASK-' "$CONTEXT_MANIFEST" >/dev/null; then
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
