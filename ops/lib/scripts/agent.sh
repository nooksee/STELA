#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
AGENTS_DIR="${REPO_ROOT}/docs/library/agents"
AGENTS_REGISTRY="${REPO_ROOT}/docs/ops/registry/AGENTS.md"
AGENTS_LEDGER="${REPO_ROOT}/docs/library/AGENTS.md"
SOP_FILE="${REPO_ROOT}/SoP.md"
TASK_FILE="${REPO_ROOT}/TASK.md"
CONTEXT_MANIFEST="${REPO_ROOT}/ops/lib/manifests/CONTEXT.md"
HANDOFF_DIR="${REPO_ROOT}/storage/handoff"
DUMPS_DIR="${REPO_ROOT}/storage/dumps"
HEURISTICS_LIB="${SCRIPT_DIR}/heuristics.sh"

if [[ -f "$HEURISTICS_LIB" ]]; then
  # shellcheck source=/dev/null
  source "$HEURISTICS_LIB"
else
  detect_hot_zone() { echo "None"; }
  detect_high_churn() { echo "None"; }
  generate_provenance_block() { echo "## Provenance"; }
fi

usage() {
  cat <<'USAGE'
Usage:
  ops/lib/scripts/agent.sh harvest --name "..." --dp "DP-OPS-XXXX" [--specialization "..."] [--summary "..."] [--skill S-LEARN-01] [--skills S-LEARN-01,S-LEARN-02] [--open PATH] [--dump PATH] [--objective "..."]
  ops/lib/scripts/agent.sh promote <draft_path> [--delete-draft]
  ops/lib/scripts/agent.sh check|--check

Notes:
- harvest auto-detects OPEN and dump artifacts when omitted; use --open/--dump to override.
- promote enforces pointer-first gates and PoT duplication linting.
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
  require_file "$SOP_FILE"
  require_file "$TASK_FILE"
  require_file "$CONTEXT_MANIFEST"
}

require_registry() {
  require_file "$AGENTS_REGISTRY"
}

require_agents_ledger() {
  require_file "$AGENTS_LEDGER"
}

require_agents_ledger_sections() {
  if ! grep -q "^## Candidate Log" "$AGENTS_LEDGER"; then
    die "Agent ledger missing Candidate Log section."
  fi
  if ! grep -q "^## Promotion Log" "$AGENTS_LEDGER"; then
    die "Agent ledger missing Promotion Log section."
  fi
}

ensure_handoff_dir() {
  mkdir -p "$HANDOFF_DIR"
}

ensure_agents_dir() {
  mkdir -p "$AGENTS_DIR"
}

cmd_check_guardrail() {
  require_repo_root

  local failed=0

  # 1. Check for Scope Boundary
  local agent
  local missing_boundary=0
  if compgen -G "${AGENTS_DIR}/*.md" > /dev/null; then
    for agent in "${AGENTS_DIR}"/*.md; do
      if ! grep -q "^## Scope Boundary" "$agent"; then
        echo "FAIL: Missing '## Scope Boundary' in $(basename "$agent")"
        failed=1
        missing_boundary=1
      fi
    done
  fi
  if [[ $missing_boundary -eq 0 ]]; then
    echo "PASS: All agents define Scope Boundaries."
  fi

  # 2. Context Hazard Check
  # Agents cannot load the agent library. This prevents recursive definition loops.
  local hazard_pattern="docs/library/agents"
  local hazards=""
  if compgen -G "${AGENTS_DIR}/*.md" > /dev/null; then
    hazards="$(grep -l "$hazard_pattern" "${AGENTS_DIR}"/*.md 2>/dev/null || true)"
  fi
  if [[ -n "$hazards" ]]; then
    echo "FAIL: Context hazard detected (reference to agents dir) in:"
    echo "$hazards"
    failed=1
  else
    echo "PASS: No context hazard references to agents directory."
  fi

  if [[ $failed -eq 1 ]]; then
    echo "FAILED."
    exit 1
  fi
  echo "PASSED."
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
    value="agent"
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

select_latest_open() {
  mapfile -t opens < <(find "$HANDOFF_DIR" -maxdepth 1 -type f -name 'OPEN-*.txt' | grep -v 'OPEN-PORCELAIN-' | sort)
  if (( ${#opens[@]} == 0 )); then
    die "No OPEN artifacts found in storage/handoff"
  fi

  local open_path
  open_path="$(ls -t "${opens[@]}" | head -n 1)"
  local newest_time
  newest_time="$(stat -c %Y "$open_path")"

  local same_time=0
  local path
  for path in "${opens[@]}"; do
    if [[ "$(stat -c %Y "$path")" == "$newest_time" ]]; then
      same_time=$((same_time + 1))
    fi
  done

  if (( same_time > 1 )); then
    die "Multiple OPEN artifacts share the same timestamp. Provide --open explicitly."
  fi

  echo "$open_path"
}

select_latest_dump() {
  mapfile -t dumps < <(find "$DUMPS_DIR" -maxdepth 1 -type f -name 'dump-*.txt' | grep -v '\.manifest\.txt$' | sort)
  if (( ${#dumps[@]} == 0 )); then
    die "No dump artifacts found in storage/dumps"
  fi

  local dump_path
  dump_path="$(ls -t "${dumps[@]}" | head -n 1)"
  local newest_time
  newest_time="$(stat -c %Y "$dump_path")"

  local same_time=0
  local path
  for path in "${dumps[@]}"; do
    if [[ "$(stat -c %Y "$path")" == "$newest_time" ]]; then
      same_time=$((same_time + 1))
    fi
  done

  if (( same_time > 1 )); then
    die "Multiple dump artifacts share the same timestamp. Provide --dump explicitly."
  fi

  echo "$dump_path"
}

collect_manifest_paths() {
  awk -F'`' 'NF >= 3 { for (i = 2; i <= NF; i += 2) print $i }' "$CONTEXT_MANIFEST" | \
    awk 'NF' | awk '!seen[$0]++'
}

normalize_skill() {
  local skill="$1"
  skill="$(trim "$skill")"
  if [[ -z "$skill" ]]; then
    return 0
  fi
  if [[ "$skill" =~ ^S-LEARN-[0-9]+$ ]]; then
    printf 'docs/library/skills/%s.md' "$skill"
    return 0
  fi
  if [[ "$skill" =~ ^docs/library/skills/S-LEARN-[0-9]+\.md$ ]]; then
    printf '%s' "$skill"
    return 0
  fi
  printf '%s' "$skill"
}

context_hazard_check() {
  local path="$1"
  local max_items=8
  local run=0
  local section=""
  local line
  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]+ ]]; then
      section="${line##"## "}"
      run=0
      continue
    fi

    case "$section" in
      "Provenance"|"Pointers"|"Context Sources")
        run=0
        continue
        ;;
    esac

    if [[ "$line" =~ ^[[:space:]]*([-*]|[0-9]+\.)[[:space:]] ]]; then
      run=$((run + 1))
      if (( run > max_items )); then
        echo "FAIL: Context hazard detected. Long knowledge list exceeds ${max_items} items." >&2
        return 1
      fi
    else
      run=0
    fi
  done < "$path"
  return 0
}

pot_duplication_linter() {
  local path="$1"
  local -a forbidden=(
    "No contractions"
    "Policy of Truth"
    "Do not edit main"
    "Linguistic Precision"
  )

  local hit=0
  local phrase
  for phrase in "${forbidden[@]}"; do
    if grep -n -i -F "$phrase" "$path" >/dev/null; then
      echo "FAIL: PoT duplication detected (${phrase}). Remove and replace with pointers to PoT.md." >&2
      grep -n -i -F "$phrase" "$path" >&2 || true
      hit=1
    fi
  done

  if (( hit == 1 )); then
    return 1
  fi
  return 0
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

read_section_first_line() {
  local section="$1"
  local path="$2"
  awk -v section="$section" '
    BEGIN { in_section=0 }
    $0 == section { in_section=1; next }
    in_section {
      if ($0 ~ /^## /) { exit }
      if ($0 ~ /[^[:space:]]/) { print $0; exit }
    }
  ' "$path"
}

validate_candidate() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    die "Draft not found: $path"
  fi

  if grep -nE '\bTODO\b|\bTBD\b|ENTER_|REPLACE_|\[ID\]|\[TITLE\]' "$path" >/dev/null; then
    die "Draft contains placeholder markers. Clean the draft before promotion."
  fi

  if ! grep -nE '^# Agent Draft: .+' "$path" >/dev/null; then
    die "Draft header missing or invalid. Expected '# Agent Draft: <name>'."
  fi

  section_has_content "## Provenance" "$path"
  section_has_content "## Role" "$path"
  section_has_content "## Specialization" "$path"
  section_has_content "## Pointers" "$path"
  section_has_content "## Scope Boundary" "$path"

  if ! grep -q 'PoT.md' "$path"; then
    die "Draft missing PoT.md pointer in Pointers section."
  fi
  if ! grep -q 'docs/GOVERNANCE.md' "$path"; then
    die "Draft missing docs/GOVERNANCE.md pointer in Pointers section."
  fi
  if ! grep -q 'TASK.md' "$path"; then
    die "Draft missing TASK.md pointer in Pointers section."
  fi
  if ! grep -q 'docs/library/skills/S-LEARN-' "$path"; then
    die "Draft missing JIT skill pointers (docs/library/skills/S-LEARN-XX.md)."
  fi

  local specialization
  specialization="$(read_section_first_line "## Specialization" "$path")"
  specialization="$(trim "$specialization")"
  if is_placeholder_value "$specialization"; then
    die "Draft specialization is missing or placeholder."
  fi
}

next_agent_id() {
  local max_id=0

  if [[ -d "$AGENTS_DIR" ]]; then
    while IFS= read -r file; do
      local base
      base="$(basename "$file")"
      if [[ "$base" =~ R-AGENT-([0-9]+)\.md ]]; then
        local num="${BASH_REMATCH[1]}"
        if ((10#$num > max_id)); then
          max_id=$((10#$num))
        fi
      fi
    done < <(find "$AGENTS_DIR" -maxdepth 1 -type f -name 'R-AGENT-*.md')
  fi

  if [[ -f "$AGENTS_REGISTRY" ]]; then
    while IFS= read -r match; do
      if [[ "$match" =~ R-AGENT-([0-9]+) ]]; then
        local num="${BASH_REMATCH[1]}"
        if ((10#$num > max_id)); then
          max_id=$((10#$num))
        fi
      fi
    done < <(grep -oE 'R-AGENT-[0-9]+' "$AGENTS_REGISTRY" 2>/dev/null || true)
  fi

  local next_id=$((max_id + 1))
  local next_id_fmt
  next_id_fmt="$(printf '%02d' "$next_id")"
  printf 'R-AGENT-%s' "$next_id_fmt"
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
  ' "$AGENTS_REGISTRY" > "$tmp"; then
    status=$?
    rm -f "$tmp"
    if [[ "$status" -eq 2 ]]; then
      die "Agents registry table not found in docs/ops/registry/AGENTS.md"
    fi
    die "Failed to update docs/ops/registry/AGENTS.md"
  fi

  mv "$tmp" "$AGENTS_REGISTRY"
}

append_candidate_log() {
  local name="$1"
  local dp_id="$2"
  local draft_path="$3"
  local timestamp
  timestamp="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  require_agents_ledger
  require_agents_ledger_sections

  local entry_file
  entry_file="$(mktemp)"
  cat <<EOF > "$entry_file"

- ${timestamp}
  - Candidate name: ${name}
  - DP provenance: ${dp_id}
  - Draft path: ${draft_path}
EOF

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
  ' "$AGENTS_LEDGER" > "$tmp"; then
    status=$?
    rm -f "$tmp" "$entry_file"
    if [[ "$status" -eq 2 ]]; then
      die "Agent ledger missing Promotion Log section."
    fi
    die "Failed to update docs/library/AGENTS.md candidate log."
  fi

  mv "$tmp" "$AGENTS_LEDGER"
  rm -f "$entry_file"
}

append_promotion_log() {
  local agent_id="$1"
  local name="$2"
  local specialization="$3"
  local dp_id="$4"
  local agent_path="$5"
  local timestamp
  timestamp="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  require_agents_ledger
  require_agents_ledger_sections

  local entry_file
  entry_file="$(mktemp)"
  cat <<EOF > "$entry_file"

- ${timestamp}
  - Agent ID: ${agent_id}
  - Name: ${name}
  - Specialization: ${specialization}
  - DP provenance: ${dp_id}
  - Promoted file: ${agent_path}
EOF

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
  ' "$AGENTS_LEDGER" > "$tmp"; then
    status=$?
    rm -f "$tmp" "$entry_file"
    if [[ "$status" -eq 2 ]]; then
      die "Agent ledger missing Promotion Log section."
    fi
    die "Failed to update docs/library/AGENTS.md promotion log."
  fi

  cat "$entry_file" >> "$tmp"
  mv "$tmp" "$AGENTS_LEDGER"
  rm -f "$entry_file"
}

cmd_harvest() {
  require_repo_root
  require_agents_ledger
  ensure_handoff_dir

  local name=""
  local dp_id=""
  local specialization=""
  local summary=""
  local objective=""
  local open_path=""
  local dump_path=""
  local skills=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name)
        name="$2"
        shift 2
        ;;
      --dp)
        dp_id="$2"
        shift 2
        ;;
      --specialization)
        specialization="$2"
        shift 2
        ;;
      --summary|--description)
        summary="$2"
        shift 2
        ;;
      --objective)
        objective="$2"
        shift 2
        ;;
      --skill)
        skills+=("$2")
        shift 2
        ;;
      --skills)
        IFS=',' read -r -a skill_list <<< "$2"
        for item in "${skill_list[@]}"; do
          skills+=("$item")
        done
        shift 2
        ;;
      --open)
        open_path="$2"
        shift 2
        ;;
      --dump)
        dump_path="$2"
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

  if [[ -z "$name" ]]; then
    die "--name is required"
  fi

  if [[ -z "$dp_id" ]]; then
    die "--dp is required"
  fi

  if [[ -z "$open_path" ]]; then
    open_path="$(select_latest_open)"
  fi

  if [[ -z "$dump_path" ]]; then
    dump_path="$(select_latest_dump)"
  fi

  if [[ -z "$objective" ]]; then
    objective="$(read_task_field "Goal")"
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
      draft_path="${HANDOFF_DIR}/agent-draft-$(date -u '+%Y%m%d')-${slug}.md"
    else
      draft_path="${HANDOFF_DIR}/agent-draft-$(date -u '+%Y%m%d')-${slug}-${counter}.md"
    fi
    if [[ ! -e "$draft_path" ]]; then
      break
    fi
    counter=$((counter + 1))
  done

  if [[ -z "$specialization" ]]; then
    specialization="Not provided"
  fi
  if [[ -z "$summary" ]]; then
    summary="$specialization"
  fi

  local skill_lines=()
  local skill
  for skill in "${skills[@]}"; do
    local normalized
    normalized="$(normalize_skill "$skill")"
    if [[ -n "$normalized" ]]; then
      skill_lines+=("- \`${normalized}\`")
    fi
  done
  if (( ${#skill_lines[@]} == 0 )); then
    skill_lines+=("- (none provided)")
  fi

  local tmp
  tmp="$(mktemp)"

  {
    cat <<EOF
# Agent Draft: ${name}

${provenance_block}

## Role
${summary}

## Specialization
${specialization}

## Pointers
- Constitution: \`PoT.md\`
- Governance/Jurisdiction: \`docs/GOVERNANCE.md\`
- Output contract: \`TASK.md\`
- Authorized toolchain: \`ops/bin/open\`, \`ops/bin/dump\`, \`ops/bin/llms\`, \`tools/lint/context.sh\`, \`tools/lint/truth.sh\`, \`tools/lint/library.sh\`, \`tools/verify.sh\`
- JIT skills:
EOF
    printf '%s\n' "${skill_lines[@]}"
    cat <<EOF

## Scope Boundary
Operate only within the active DP and defer to canon surfaces for governance and behavioral rules.

## Context Sources
- OPEN prompt: ${open_path}
- Dump artifact: ${dump_path}
- Context manifest: \`ops/lib/manifests/CONTEXT.md\`
- Loaded context (from manifest):
EOF
    collect_manifest_paths | awk '{ print "- `" $0 "`" }'
    echo
  } > "$tmp"

  redact_stream < "$tmp" > "$draft_path"
  rm -f "$tmp"

  append_candidate_log "$name" "$dp_id" "$draft_path"

  echo "$draft_path"
}

select_latest_draft() {
  local draft_path=""
  mapfile -t drafts < <(find "$HANDOFF_DIR" -maxdepth 1 -type f -name 'agent-draft-*.md' | sort)
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

cmd_promote() {
  require_repo_root
  require_registry
  require_agents_ledger
  ensure_handoff_dir
  ensure_agents_dir

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

  if ! context_hazard_check "$draft_path"; then
    exit 1
  fi

  if ! pot_duplication_linter "$draft_path"; then
    exit 1
  fi

  local name
  name="$(grep -m1 -E '^# Agent Draft: ' "$draft_path" | sed -E 's/^# Agent Draft: //')"
  name="$(trim "$name")"
  if [[ -z "$name" ]]; then
    die "Draft name is empty"
  fi

  local specialization
  specialization="$(read_section_first_line "## Specialization" "$draft_path")"
  specialization="$(trim "$specialization")"
  if is_placeholder_value "$specialization"; then
    die "Draft specialization is missing or placeholder"
  fi

  local dp_id
  dp_id="$(awk '/\*\*DP-ID\*\*/ { sub(/.*\*\*DP-ID\*\*:[[:space:]]*/, "", $0); print $0; exit }' "$draft_path")"
  dp_id="$(trim "$dp_id")"
  if is_placeholder_value "$dp_id"; then
    die "Draft DP-ID is missing or placeholder"
  fi

  local agent_id
  agent_id="$(next_agent_id)"
  local agent_path
  agent_path="${AGENTS_DIR}/${agent_id}.md"

  if [[ -e "$agent_path" ]]; then
    die "Agent file already exists: $agent_path"
  fi

  local tmp_agent
  tmp_agent="$(mktemp)"
  awk -v header="# Agent: ${name}" '
    BEGIN { replaced=0 }
    /^# Agent Draft: / {
      if (!replaced) { print header; replaced=1; next }
    }
    { print }
    END { if (!replaced) exit 1 }
  ' "$draft_path" > "$tmp_agent" || die "Failed to rewrite draft header"

  mv "$tmp_agent" "$agent_path"

  if grep -Fq "| ${agent_id} |" "$AGENTS_REGISTRY"; then
    die "docs/ops/registry/AGENTS.md already contains ${agent_id}"
  fi

  local registry_row
  registry_row="| ${agent_id} | ${name} | ${dp_id} | ${specialization} |"
  insert_registry_entry "$registry_row"
  append_promotion_log "$agent_id" "$name" "$specialization" "$dp_id" "$agent_path"

  if (( delete_draft == 1 )); then
    rm -f "$draft_path"
  fi

  echo "$agent_path"
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
      cmd_check_guardrail "$@"
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
