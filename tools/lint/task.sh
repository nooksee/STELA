#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1
trap 'emit_binary_leaf "lint-task" "finish"' EXIT
emit_binary_leaf "lint-task" "start"

TASKS_DIR="opt/_factory/tasks"
TASKS_REGISTRY="docs/ops/registry/tasks.md"

failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "CRITICAL: Required file missing at ${REPO_ROOT}/${path}" >&2
    exit 2
  fi
}

normalize_token() {
  local value="$1"
  if [[ "$value" == ./* ]]; then
    value="${value#./}"
  fi
  printf '%s' "$value"
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

resolve_task_surface_path() {
  local source_path="$1"
  if [[ "$(basename "$source_path")" != "TASK.md" ]]; then
    printf '%s' "$source_path"
    return 0
  fi

  local line_count
  line_count="$(awk 'END { print NR }' "$source_path")"
  if [[ "$line_count" != "1" ]]; then
    printf '%s' "$source_path"
    return 0
  fi

  local pointer_path
  pointer_path="$(trim "$(cat "$source_path")")"
  pointer_path="${pointer_path#./}"
  if [[ "$pointer_path" == "${REPO_ROOT}/"* ]]; then
    pointer_path="${pointer_path#${REPO_ROOT}/}"
  fi

  if [[ ! "$pointer_path" =~ ^archives/surfaces/[A-Za-z0-9._/-]+\.md$ ]]; then
    fail "TASK is single-line but not a valid archives/surfaces pointer"
    return 1
  fi

  local target_path="${REPO_ROOT}/${pointer_path}"
  if [[ ! -f "$target_path" ]]; then
    fail "TASK pointer target missing: ${pointer_path}"
    return 1
  fi

  printf '%s' "$target_path"
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

extract_section() {
  local section="$1"
  local path="$2"
  awk -v section="$section" '
    BEGIN { in_section=0 }
    $0 == section { in_section=1; next }
    /^## / { if (in_section) exit }
    in_section { print }
  ' "$path"
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

first_heading_line() {
  local path="$1"
  local pattern="$2"
  awk -v regex="$pattern" 'BEGIN { IGNORECASE=1 } $0 ~ regex { print NR; exit }' "$path"
}

extract_block() {
  local path="$1"
  local start_pattern="$2"
  local stop_pattern="$3"
  awk -v start_regex="$start_pattern" -v stop_regex="$stop_pattern" '
    BEGIN { in_block=0 }
    $0 ~ start_regex { in_block=1; next }
    in_block && $0 ~ stop_regex { exit }
    in_block { print }
  ' "$path"
}

check_forbidden_task_versioning() {
  local path="$1"
  local issue
  if issue="$(awk '
    /^(#|##|###|####|#####|######|Status:|Owner:|Last Updated:)/ {
      if ($0 ~ /(^|[^[:alnum:]])[Vv]2([^[:alnum:]]|$)/) {
        print $0
        exit 1
      }
    }
  ' "$path")"; then
    :
  else
    fail "TASK contains a forbidden versioning token in header/status content: ${issue}"
  fi
}

check_task_dashboard() {
  local path="$1"
  require_file "$path"
  check_forbidden_task_versioning "$path"

  local -a labels=(
    "## 1. Session State (The Anchor)"
    "## 2. Logic Pointers (The Law)"
    "## 3. Current Dispatch Packet (DP)"
    "## 3.1 Freshness Gate (Must Pass Before Work)"
    "## 3.1.1 DP Preflight Gate (Run Before Any Edits)"
    "## 3.2 Required Context Load (Read Before Doing Anything)"
    "### 3.2.1 Canon load order (always)"
    "### 3.2.2 DP-scoped load order (per DP)"
    "## 3.3 Scope and Safety"
    "## 3.4 Execution Plan (A-E Canon)"
    "### 3.4.1 State (What is true now)"
    "### 3.4.2 Request (What we are changing)"
    "### 3.4.3 Changelog (Planned edits)"
    "### 3.4.4 Patch / Diff (Implementation details)"
    "### 3.4.5 Receipt (Proofs to collect) — MUST RUN"
    "## 3.5 Closeout (Mandatory Routing)"
    "### 3.5.1 Mandatory Closing Block"
  )

  local -a patterns=(
    '^##[[:space:]]*1\\.[[:space:]]*SESSION STATE'
    '^##[[:space:]]*2\\.[[:space:]]*LOGIC POINTERS'
    '^##[[:space:]]*3\\.[[:space:]]*CURRENT DISPATCH PACKET'
    '^##[[:space:]]*3\\.1[.)]?[[:space:]]*FRESHNESS GATE'
    '^##[[:space:]]*3\\.1\\.1[.)]?[[:space:]]*DP PREFLIGHT GATE'
    '^##[[:space:]]*3\\.2[.)]?[[:space:]]*REQUIRED CONTEXT LOAD'
    '^###[[:space:]]*3\\.2\\.1[.)]?[[:space:]]*CANON LOAD ORDER'
    '^###[[:space:]]*3\\.2\\.2[.)]?[[:space:]]*DP-SCOPED LOAD ORDER'
    '^##[[:space:]]*3\\.3[.)]?[[:space:]]*SCOPE AND SAFETY'
    '^##[[:space:]]*3\\.4[.)]?[[:space:]]*EXECUTION PLAN'
    '^###[[:space:]]*3\\.4\\.1[.)]?[[:space:]]*STATE'
    '^###[[:space:]]*3\\.4\\.2[.)]?[[:space:]]*REQUEST'
    '^###[[:space:]]*3\\.4\\.3[.)]?[[:space:]]*CHANGELOG'
    '^###[[:space:]]*3\\.4\\.4[.)]?[[:space:]]*PATCH'
    '^###[[:space:]]*3\\.4\\.5[.)]?[[:space:]]*RECEIPT'
    '^##[[:space:]]*3\\.5[.)]?[[:space:]]*CLOSEOUT'
    '^###[[:space:]]*3\\.5\\.1[.)]?[[:space:]]*MANDATORY CLOSING BLOCK'
  )

  local -a heading_lines=()
  local i
  local line
  local missing=0
  for ((i=0; i<${#labels[@]}; i++)); do
    line="$(first_heading_line "$path" "${patterns[i]}")"
    if [[ -z "$line" ]]; then
      fail "TASK missing heading '${labels[i]}'"
      missing=1
      heading_lines+=("")
    else
      heading_lines+=("$line")
    fi
  done

  if (( !missing )); then
    for ((i=0; i<${#heading_lines[@]}-1; i++)); do
      if (( heading_lines[i] >= heading_lines[i+1] )); then
        fail "TASK headings out of order: '${labels[i]}' should appear before '${labels[i+1]}'"
        break
      fi
    done
  fi

  if grep -nEiq '^##[[:space:]]*4\.1[.)]?[[:space:]]*Thread[[:space:]]+Transition([[:space:]]*[(].*[)])?[[:space:]]*$' "$path"; then
    fail "TASK contains forbidden legacy heading '## 4.1 Thread Transition'"
  fi
  if grep -nEiq '^##[[:space:]]*5\.[[:space:]]*Work[[:space:]]+Log([[:space:]]*[(].*[)])?[[:space:]]*$' "$path"; then
    fail "TASK contains forbidden legacy heading '## 5. Work Log'"
  fi

  if ! grep -Eq '^Pointer:[[:space:]]*storage/handoff/OPEN-<branch>-<short-hash>[.]txt([[:space:]]*[(].*[)])?$' "$path" \
    && ! grep -Fxq "Pointer: Session context output (generated by ops/bin/open)" "$path"; then
    fail "TASK Session State pointer must be pointer-first and exact"
  fi
  if ! grep -nE '^Context Manifest:[[:space:]]*ops/lib/manifests/CONTEXT\.md' "$path" >/dev/null; then
    fail "TASK missing Session State Context Manifest pointer"
  fi

  local session_block
  session_block="$(extract_block "$path" '^## 1[.] Session State' '^## 2[.]')"
  if grep -nE '^[[:space:]]*(Active Branch|Branch|Base HEAD):' <<< "$session_block" >/dev/null; then
    fail "TASK Session State must not mirror inline branch/hash fields"
  fi
  if grep -nE 'work/[[:alnum:]_.-]+' <<< "$session_block" >/dev/null; then
    fail "TASK Session State must not include work branch mirrors"
  fi
  if grep -nE '[0-9a-f]{7,}' <<< "$session_block" >/dev/null; then
    fail "TASK Session State must not include hash mirrors"
  fi

  local freeze_rule_count
  local freeze_discipline_count
  freeze_rule_count="$(grep -c '^Freeze Rule:$' "$path" || true)"
  freeze_discipline_count="$(grep -c '^Freeze discipline (single rule):$' "$path" || true)"
  if (( freeze_rule_count + freeze_discipline_count != 1 )); then
    fail "TASK requires exactly one Freeze Rule block"
  fi
  if ! grep -Fq 'AMENDMENT:' "$path" && ! grep -Eq '^AMENDMENT[[:space:]]*[(]' "$path"; then
    fail "TASK Freeze Rule must require AMENDMENT entries for post-dispatch changes"
  fi

  local canon_block
  canon_block="$(extract_block "$path" '^### 3[.]2[.]1' '^### 3[.]2[.]2')"
  local -a canon_expected=(
    "1. PoT.md"
    "2. SoP.md"
    "3. PoW.md"
    "4. TASK.md"
    "5. docs/MAP.md"
    "6. docs/MANUAL.md"
    "7. ops/lib/manifests/CONTEXT.md"
  )
  local expected
  for expected in "${canon_expected[@]}"; do
    if ! grep -Fxq "$expected" <<< "$canon_block"; then
      fail "TASK canon load order missing '${expected}'"
    fi
  done

  local canon_count
  local canon_numbered
  canon_numbered="$(grep -E '^[[:space:]]*[0-9]+\.[[:space:]]' <<< "$canon_block" || true)"
  canon_count="$(grep -cE '^[[:space:]]*[0-9]+\.[[:space:]]' <<< "$canon_numbered" || true)"
  if [[ "$canon_count" != "7" ]]; then
    fail "TASK canon load order must contain exactly seven numbered items"
  fi
  if grep -nE '(tools/|ops/bin/|docs/ops/specs/)' <<< "$canon_numbered" >/dev/null; then
    fail "TASK canon load order is bloated; tools/binaries belong in DP-scoped load order"
  fi

  if ! grep -Fq 'Worker does not read OPEN.' "$path"; then
    fail "TASK must state that workers do not read OPEN"
  fi

  local open_read_issue
  if open_read_issue="$(awk '
    BEGIN { IGNORECASE=1 }
    {
      line_lower=tolower($0)
      if (line_lower ~ /read[[:space:]]+open/ || line_lower ~ /open[[:space:]]+is[[:space:]]+required[[:space:]]+reading/) {
        if (line_lower ~ /does not read open/) { next }
        if (line_lower ~ /not required reading/) { next }
        print $0
        exit 1
      }
    }
  ' "$path")"; then
    :
  else
    fail "TASK contains forbidden OPEN-reading instruction: ${open_read_issue}"
  fi

  local receipt_block
  receipt_block="$(extract_block "$path" '^### 3[.]4[.]5' '^## 3[.]5([.]|[[:space:]])')"
  if ! grep -Fq 'bash tools/lint/dp.sh TASK.md' <<< "$receipt_block"; then
    fail "TASK receipt contract missing dp lint command"
  fi
  if ! grep -Fq 'bash tools/lint/task.sh' <<< "$receipt_block"; then
    fail "TASK receipt contract missing task lint command"
  fi
  if ! grep -Fq 'bash tools/lint/integrity.sh' <<< "$receipt_block"; then
    fail "TASK receipt contract missing integrity lint command"
  fi
  if ! grep -Fq 'bash tools/lint/style.sh' <<< "$receipt_block"; then
    fail "TASK receipt contract missing style lint command"
  fi
  if ! grep -Fq './ops/bin/open' <<< "$receipt_block"; then
    fail "TASK receipt contract missing executable OPEN command"
  fi
  if ! grep -Fq 'git diff --name-only' <<< "$receipt_block"; then
    fail "TASK receipt contract missing git diff --name-only proof"
  fi
  if ! grep -Fq 'git diff --stat' <<< "$receipt_block"; then
    fail "TASK receipt contract missing git diff --stat proof"
  fi
  if ! grep -Fq 'comm -23 <(git diff --name-only | sort) <(sort storage/dp/active/allowlist.txt) || true' <<< "$receipt_block"; then
    fail "TASK receipt contract missing allowlist diff subset proof"
  fi
  if ! grep -Fq 'comm -23 <(git ls-files --others --exclude-standard | sort) <(sort storage/dp/active/allowlist.txt) || true' <<< "$receipt_block"; then
    fail "TASK receipt contract missing untracked allowlist subset proof"
  fi

  if ! grep -nE '^###[[:space:]]*3\.5\.1[.)]?[[:space:]]*Mandatory[[:space:]]+Closing[[:space:]]+Block[[:space:]]*$' "$path" >/dev/null; then
    fail "TASK closeout block missing heading '### 3.5.1 Mandatory Closing Block'"
  fi

  local -a closing_labels=(
    "Primary Commit Header (plaintext)"
    "Pull Request Title (plaintext)"
    "Pull Request Description (markdown)"
    "Final Squash Stub (plaintext) (Must differ from #1)"
    "Extended Technical Manifest (plaintext)"
    "Review Conversation Starter (markdown)"
  )
  # Certify-routed format: active packets generated from ops/src/surfaces/dp.md.tpl
  # carry the list-item form of the §3.5.1 Mandatory Closing Block. This path is the
  # standard acceptance path for live current-packet TASK heads.
  local -a closing_list_items=(
    "- Primary Commit Header"
    "- Pull Request Title"
    "- Pull Request Description"
    "- Final Squash Stub"
    "- Extended Technical Manifest"
    "- Review Conversation Starter"
  )
  # Receipt proof token: certify-routed format
  local list_format_present=1
  local item
  for item in "${closing_list_items[@]}"; do
    if ! grep -Fxq -- "$item" "$path"; then
      list_format_present=0
      break
    fi
  done

  if (( list_format_present )); then
    return
  fi

  # Legacy label format: historical TASK leaves authored before the certify-routed
  # list-item format was introduced carry the plaintext-label form. This path is the
  # grandfathered acceptance path for historical TASK heads only.
  local label
  for label in "${closing_labels[@]}"; do
    if [[ "$label" == "Final Squash Stub (plaintext) (Must differ from #1)" ]]; then
      if ! grep -Fxq "$label" "$path" \
        && ! grep -Fxq "Final Squash Stub (plaintext) (must differ from Primary Commit Header)" "$path"; then
        fail "TASK closeout block missing label '${label}'"
      fi
      continue
    fi
    if ! grep -Fxq "$label" "$path"; then
      fail "TASK closeout block missing label '${label}'"
    fi
  done
}

require_file "$TASKS_REGISTRY"

if [[ ! -d "$TASKS_DIR" ]]; then
  fail "Tasks directory missing at ${TASKS_DIR}"
fi

contraction_pattern="\\b(don\\x27t|can\\x27t|won\\x27t|it\\x27s|shouldn\\x27t|didn\\x27t|doesn\\x27t|isn\\x27t|aren\\x27t|wasn\\x27t|weren\\x27t|haven\\x27t|hasn\\x27t|hadn\\x27t|wouldn\\x27t|couldn\\x27t|mustn\\x27t|shan\\x27t|let\\x27s|they\\x27re|we\\x27re|you\\x27re|i\\x27m|i\\x27ve|i\\x27ll|i\\x27d)\\b"
contraction_hits="$(rg -n -i "$contraction_pattern" "$TASKS_DIR" 2>/dev/null || true)"
if [[ -n "$contraction_hits" ]]; then
  fail "Contractions found in task files."
  echo "$contraction_hits" >&2
fi

legacy_task_state_hits="$(rg -n -e 'Active Branch:' -e 'Base HEAD: .*Must match session context output' -e 'Gate Artifacts \\(Must Match\\)' -e 'Gate Commands \\(Must Pass\\)' -e 'update TASK\\.md gate artifacts' "$TASKS_DIR" 2>/dev/null || true)"
if [[ -n "$legacy_task_state_hits" ]]; then
  fail "Legacy TASK inline state mutation language found in task files."
  echo "$legacy_task_state_hits" >&2
fi

mapfile -t registry_rows < <(awk -F'|' '
  $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*---/ {
    id=$2; name=$3; path=$4
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    gsub(/^[[:space:]]+/, "", name)
    gsub(/[[:space:]]+$/, "", name)
    gsub(/^[[:space:]]+/, "", path)
    gsub(/[[:space:]]+$/, "", path)
    if (id != "" && id != "ID") print id "|" name "|" path
  }
' "$TASKS_REGISTRY")

declare -A registry_ids

declare -A registry_paths

declare -A registry_names

for row in "${registry_rows[@]}"; do
  id="${row%%|*}"
  rest="${row#*|}"
  name="${rest%%|*}"
  path="${rest#*|}"

  if [[ -n "${registry_ids[$id]+set}" ]]; then
    fail "Registry duplicate task ID '${id}'"
  else
    registry_ids["$id"]=1
  fi

  if [[ -n "$path" ]]; then
    if [[ -n "${registry_paths[$path]+set}" ]]; then
      fail "Registry duplicate task path '${path}'"
    else
      registry_paths["$path"]=1
    fi
  fi

  registry_names["$id"]="$name"

  if [[ -n "$path" && ! -f "$path" ]]; then
    fail "Registry references missing task file '${path}'"
  fi

done

if compgen -G "${TASKS_DIR}/*.md" > /dev/null; then
  while IFS= read -r file; do
    rel_path="${file#${REPO_ROOT}/}"
    if [[ -z "${registry_paths[$rel_path]+set}" ]]; then
      fail "Ghost task file '${rel_path}' is not registered"
    fi
  done < <(find "${TASKS_DIR}" -maxdepth 1 -type f -name '*.md')
fi

if compgen -G "${TASKS_DIR}/*.md" > /dev/null; then
  for task in "${TASKS_DIR}"/*.md; do
    task_name="$(basename "$task")"
    header_line="$(head -n 1 "$task" | tr -d '\r')"
    if [[ ! "$header_line" =~ ^#\ Task:\  ]]; then
      fail "${task_name} missing required '# Task: <name>' header"
    fi

    task_id="$(basename "$task" .md)"
    registry_name="${registry_names[$task_id]:-}"
    if [[ -n "$registry_name" ]]; then
      header_name="${header_line#\# }"
      if [[ "$header_name" != "$registry_name" ]]; then
        fail "${task_name} header name '${header_name}' does not match registry name '${registry_name}'"
      fi
    fi

    for section in "## Provenance" "## Orchestration" "## Pointers" "## Execution Logic" "## Scope Boundary"; do
      section_count="$(grep -c "^${section}$" "$task" || true)"
      if [[ "$section_count" -eq 0 ]]; then
        fail "${task_name} missing required section '${section}'"
      elif [[ "$section_count" -gt 1 ]]; then
        fail "${task_name} has duplicate section '${section}'"
      fi
    done

    for label in "Captured" "DP-ID" "Branch" "HEAD" "Objective"; do
      value="$(field_value "$label" "$task")"
      value="$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      if is_placeholder_value "$value"; then
        fail "${task_name} missing or placeholder value for '${label}'"
      fi
    done

    for label in "Primary Agent" "Supporting Agents"; do
      value="$(field_value "$label" "$task")"
      value="$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      if is_placeholder_value "$value"; then
        fail "${task_name} missing or placeholder value for '${label}'"
      fi
    done

    for label in "Allowed" "Forbidden" "Stop Conditions"; do
      value="$(field_value "$label" "$task")"
      value="$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      if is_placeholder_value "$value"; then
        fail "${task_name} missing or placeholder value for '${label}'"
      fi
    done

    pointers_section="$(extract_section "## Pointers" "$task")"

    if ! grep -q 'PoT.md' <<< "$pointers_section"; then
      fail "${task_name} missing PoT.md pointer in Pointers section"
    fi
    if ! grep -q 'docs/GOVERNANCE.md' <<< "$pointers_section"; then
      fail "${task_name} missing docs/GOVERNANCE.md pointer in Pointers section"
    fi
    if ! grep -q 'TASK.md' <<< "$pointers_section"; then
      fail "${task_name} missing TASK.md pointer in Pointers section"
    fi

    mapfile -t pointer_tokens < <(printf '%s\n' "$pointers_section" | grep -oE '`[^`]+`' | sed -e 's/`//g' || true)
    for token in "${pointer_tokens[@]}"; do
      normalized="$(normalize_token "$token")"
      if [[ "$normalized" == *" "* ]]; then
        continue
      fi
      if [[ "$normalized" == /* || "$normalized" == ~* ]]; then
        fail "${task_name} pointer token uses absolute or home path '${token}'"
        continue
      fi
      case "$normalized" in
        PoT.md|TASK.md|docs/*|ops/*|tools/*|*.md|*.sh)
          if [[ ! -e "$REPO_ROOT/$normalized" ]]; then
            fail "${task_name} pointer token '${token}' does not exist"
          fi
          ;;
      esac
    done

    mapfile -t agent_refs < <(rg -o "R-AGENT-[0-9]{2,}" "$task" | sort -u)
    for ref in "${agent_refs[@]}"; do
      ref_slug="${ref,,}"
      if [[ ! -f "$REPO_ROOT/opt/_factory/agents/${ref_slug}.md" ]]; then
        fail "${task_name} references missing agent ${ref}"
      fi
    done

    mapfile -t skill_refs < <(rg -o "S-LEARN-[0-9]{2,}" "$task" | sort -u)
    for ref in "${skill_refs[@]}"; do
      ref_slug="${ref,,}"
      if [[ ! -f "$REPO_ROOT/opt/_factory/skills/${ref_slug}.md" ]]; then
        fail "${task_name} references missing skill ${ref}"
      fi
    done

    execution_section="$(extract_section "## Execution Logic" "$task")"
    ambiguous_pattern='(^|[^[:alpha:]])(check|review|ensure|confirm|validate|verify|audit|analyze|assess|inspect)($|[^[:alpha:]])'
    while IFS= read -r line; do
      if [[ "$line" =~ ^[[:space:]]*[0-9]+\.[[:space:]] ]]; then
        if echo "$line" | grep -Eqi "$ambiguous_pattern" && [[ "$line" != *'`'* ]]; then
          fail "${task_name} contains narrative execution language without pointers: ${line}"
        fi
      fi
    done <<< "$execution_section"

    last_step="$(printf '%s\n' "$execution_section" | awk '/^[[:space:]]*[0-9]+\.[[:space:]]/ {line=$0} END {print line}')"
    if [[ -z "$last_step" ]]; then
      fail "${task_name} has no numbered steps in Execution Logic"
    else
      if ! grep -q "Closeout" <<< "$last_step" || ! grep -q "TASK.md" <<< "$last_step" || ! grep -qi "Section 3.5" <<< "$last_step"; then
        fail "${task_name} missing final Closeout pointer in Execution Logic (TASK.md Section 3.5)"
      fi
    fi
  done
fi

task_dashboard_path="TASK.md"
if (( $# > 1 )); then
  echo "ERROR: Usage: tools/lint/task.sh [TASK_PATH]" >&2
  exit 1
fi
if (( $# == 1 )); then
  task_dashboard_path="$1"
fi

if resolved_task_dashboard_path="$(resolve_task_surface_path "$task_dashboard_path")"; then
  check_task_dashboard "$resolved_task_dashboard_path"
fi

if (( failures > 0 )); then
  echo "FAILED: ${failures} error(s) detected." >&2
  exit 1
fi

echo "OK: Task lint checks passed."
