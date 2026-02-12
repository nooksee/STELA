#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/lint/dp.sh [--test] [path|-]
USAGE
}

failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

strip_backticks() {
  local value="$1"
  if [[ "$value" == \`* ]]; then
    value="${value#\`}";
  fi
  if [[ "$value" == *\` ]]; then
    value="${value%\`}";
  fi
  printf '%s' "$value"
}

extract_hash() {
  local value="$1"
  local match
  match="$(printf '%s' "$value" | grep -oE '[0-9a-f]{7,}' | head -n1 || true)"
  printf '%s' "$match"
}

PLACEHOLDER_TOKENS=(
  "TBD"
  "<fill"
  "[ID]"
  "[TITLE]"
  "[id]"
  "[slug]"
  "[date]"
  "[hash]"
  "[branch]"
  "[One sentence goal]"
  "[List exact files to touch]"
)

TASK_PROMPT="Populate during execution; do not pre-fill in TASK.md."
CLOSEOUT_INSTRUCTION="(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)"

contains_placeholder() {
  local text="$1"
  local token
  for token in "${PLACEHOLDER_TOKENS[@]}"; do
    if [[ "$text" == *"$token"* ]]; then
      return 0
    fi
  done
  return 1
}

has_standalone_ellipsis() {
  local path="$1"
  if grep -nE '(^|[[:space:]])\\.\\.\\.([[:space:]]|$)' "$path" >/dev/null; then
    return 0
  fi
  return 1
}

has_llms_invocation() {
  local path="$1"
  if grep -nE '`(\./ops/bin/llms|ops/bin/llms)`' "$path" >/dev/null; then
    return 0
  fi
  awk '
    BEGIN { in_block = 0; found = 0 }
    /^[[:space:]]*```/ || /^[[:space:]]*~~~/ { in_block = !in_block; next }
    in_block {
      if ($0 ~ /(^|[[:space:]])(\.\/ops\/bin\/llms|ops\/bin\/llms)([[:space:]]|$)/) {
        found = 1
        exit
      }
    }
    END { exit found ? 0 : 1 }
  ' "$path"
}

field_value() {
  local label="$1"
  awk -v label="$label" '
    {
      pos = index($0, label)
      if (pos) {
        rest = substr($0, pos)
        colon = index(rest, ":")
        if (colon) {
          text = substr(rest, colon + 1)
          gsub(/^[[:space:]]+/, "", text)
          print text
          exit
        }
      }
    }
  ' "$path"
}

check_required_field() {
  local label="$1"
  local value

  value="$(field_value "$label")"
  value="$(trim "$value")"
  value="$(strip_backticks "$value")"

  if [[ -z "$value" ]]; then
    fail "missing or empty value for '$label'"
    return 1
  fi

  if contains_placeholder "$value"; then
    fail "placeholder value for '$label'"
    return 1
  fi
  return 0
}

check_required_field_any() {
  local primary="$1"
  local secondary="$2"
  local value

  value="$(field_value "$primary")"
  value="$(trim "$value")"
  value="$(strip_backticks "$value")"
  if [[ -n "$value" ]] && ! contains_placeholder "$value"; then
    return 0
  fi

  value="$(field_value "$secondary")"
  value="$(trim "$value")"
  value="$(strip_backticks "$value")"
  if [[ -n "$value" ]] && ! contains_placeholder "$value"; then
    return 0
  fi

  fail "missing or empty value for '$primary' or '$secondary'"
  return 1
}

field_value_valid() {
  local label="$1"
  local value

  value="$(field_value "$label")"
  value="$(trim "$value")"
  value="$(strip_backticks "$value")"

  if [[ -z "$value" ]]; then
    return 1
  fi

  if contains_placeholder "$value"; then
    return 1
  fi
  return 0
}

scope_list_exists() {
  local path="$1"
  local section="$2"
  awk -v section="$section" '
    BEGIN { found = 0; ok = 0 }
    {
      if (!found && index($0, section)) { found = 1; next }
      if (found) {
        if ($0 ~ /^[[:space:]]*$/) { exit }
        if ($0 ~ /^[[:space:]]*#{1,6} /) { exit }
        if ($0 ~ /^[[:space:]]*[-*] /) { ok = 1; exit }
        if ($0 ~ /^[[:space:]]*\\*\\*/) { exit }
      }
    }
    END { exit ok ? 0 : 1 }
  ' "$path"
}

extract_allowlist_paths() {
  local path="$1"
  local section="$2"
  awk -v section="$section" '
    BEGIN { found = 0 }
    {
      if (!found && index($0, section)) { found = 1; next }
      if (found) {
        if ($0 ~ /^[[:space:]]*$/) { next }
        if ($0 ~ /^[[:space:]]*<!--/) { next }
        if ($0 ~ /^[[:space:]]*#{1,6} /) { exit }
        if ($0 ~ /^[[:space:]]*[-*] /) {
          line = $0
          sub(/^[[:space:]]*[-*][[:space:]]+/, "", line)
          sub(/[[:space:]]+#.*/, "", line)
          sub(/[[:space:]]+[(].*/, "", line)
          print line
          next
        }
        if ($0 ~ /^[[:space:]]*\\*\\*/) { exit }
      }
    }
  ' "$path"
}

extract_allowlist_backticks() {
  local path="$1"
  local section="$2"
  awk -v section="$section" '
    BEGIN { found = 0 }
    {
      if (!found && index($0, section)) { found = 1; next }
      if (found) {
        if ($0 ~ /^[[:space:]]*$/) { next }
        if ($0 ~ /^[[:space:]]*<!--/) { next }
        if ($0 ~ /^[[:space:]]*#{1,6} /) { exit }
        if ($0 ~ /^[[:space:]]*[-*] /) {
          line = $0
          while (match(line, /`[^`]+`/)) {
            token = substr(line, RSTART + 1, RLENGTH - 2)
            print token
            line = substr(line, RSTART + RLENGTH)
          }
          next
        }
        if ($0 ~ /^[[:space:]]*\\*\\*/) { exit }
      }
    }
  ' "$path"
}

first_heading_line() {
  local path="$1"
  local pattern="$2"
  awk -v r="$pattern" 'BEGIN { IGNORECASE = 1 } $0 ~ r { print NR; exit }' "$path"
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

check_task_subsections() {
  local path="$1"
  local -a labels=(
    "### 3.1 Freshness Gate (Must Pass Before Work)"
    "### 3.1.1 DP Preflight Gate (Run Before Any Edits)"
    "### 3.2 Required Context Load (Read Before Doing Anything)"
    "### 3.3 Scope and Safety"
    "### 3.4 Execution Plan (A-E Canon)"
  )
  local -a patterns=(
    '^###[[:space:]]*3\\.1[.)]?[[:space:]]*FRESHNESS GATE'
    '^###[[:space:]]*3\\.1\\.1[.)]?[[:space:]]*DP PREFLIGHT GATE'
    '^###[[:space:]]*3\\.2[.)]?[[:space:]]*REQUIRED CONTEXT LOAD'
    '^###[[:space:]]*3\\.3[.)]?[[:space:]]*SCOPE'
    '^###[[:space:]]*3\\.4[.)]?[[:space:]]*EXECUTION PLAN'
  )

  local -a heading_lines=()
  local missing=0
  local line
  local i

  for ((i=0; i<${#labels[@]}; i++)); do
    line="$(first_heading_line "$path" "${patterns[i]}")"
    if [[ -z "$line" ]]; then
      fail "missing heading '${labels[i]}' (task dp substructure)"
      missing=1
      heading_lines+=("")
    else
      heading_lines+=("$line")
    fi
  done

  if (( !missing )); then
    for ((i=0; i<${#heading_lines[@]}-1; i++)); do
      if (( heading_lines[i] >= heading_lines[i+1] )); then
        fail "headings out of order: '${labels[i]}' should appear before '${labels[i+1]}' (task dp substructure)"
        break
      fi
    done
  fi

  if ! grep -nE '^###[[:space:]]*DP-' "$path" >/dev/null; then
    fail "missing DP header line (expected '### DP-...')"
  fi
}

check_task_plan_headings() {
  local path="$1"
  local -a labels=(
    "#### 3.4.1 State (What is true now)"
    "#### 3.4.2 Request (What we are changing)"
    "#### 3.4.3 Changelog (Planned edits)"
    "#### 3.4.4 Patch / Diff (Implementation details)"
    "#### 3.4.5 Receipt (Proofs to collect)"
  )
  local -a patterns=(
    '^####[[:space:]]*3\\.4\\.1[.)]?[[:space:]]*STATE'
    '^####[[:space:]]*3\\.4\\.2[.)]?[[:space:]]*REQUEST'
    '^####[[:space:]]*3\\.4\\.3[.)]?[[:space:]]*CHANGELOG'
    '^####[[:space:]]*3\\.4\\.4[.)]?[[:space:]]*PATCH'
    '^####[[:space:]]*3\\.4\\.5[.)]?[[:space:]]*RECEIPT'
  )

  local -a heading_lines=()
  local missing=0
  local line
  local i

  for ((i=0; i<${#labels[@]}; i++)); do
    line="$(first_heading_line "$path" "${patterns[i]}")"
    if [[ -z "$line" ]]; then
      fail "missing heading '${labels[i]}' (task execution plan)"
      missing=1
      heading_lines+=("")
    else
      heading_lines+=("$line")
    fi
  done

  if (( !missing )); then
    for ((i=0; i<${#heading_lines[@]}-1; i++)); do
      if (( heading_lines[i] >= heading_lines[i+1] )); then
        fail "headings out of order: '${labels[i]}' should appear before '${labels[i+1]}' (task execution plan)"
        break
      fi
    done
  fi
}

check_task_freeze_rule() {
  local path="$1"
  local freeze_count
  freeze_count="$(grep -c '^Freeze Rule:$' "$path" || true)"
  if [[ "$freeze_count" != "1" ]]; then
    fail "TASK v2 requires exactly one Freeze Rule block"
  fi
  if ! grep -Fq 'AMENDMENT:' "$path"; then
    fail "TASK v2 Freeze Rule must require AMENDMENT entries"
  fi
}

check_task_preflight_gate_contract() {
  local path="$1"
  local preflight_block
  preflight_block="$(extract_block "$path" '^### 3[.]1[.]1' '^### 3[.]2')"

  if [[ -z "$preflight_block" ]]; then
    fail "TASK v2 missing DP Preflight Gate block"
    return
  fi

  local -a required_lines=(
    "bash tools/lint/dp.sh --test"
    "bash tools/lint/dp.sh TASK.md"
    "bash tools/lint/task.sh"
    "STOP if any preflight check fails."
  )
  local req
  for req in "${required_lines[@]}"; do
    if ! grep -Fq -- "$req" <<< "$preflight_block"; then
      fail "TASK v2 preflight block missing line: ${req}"
    fi
  done
}

check_task_context_load_contract() {
  local path="$1"
  local canon_block
  canon_block="$(extract_block "$path" '^#### 3[.]2[.]1' '^#### 3[.]2[.]2')"
  if [[ -z "$canon_block" ]]; then
    fail "TASK v2 missing canon load order block (3.2.1)"
    return
  fi

  local -a canon_expected=(
    "1. PoT.md"
    "2. SoP.md"
    "3. TASK.md"
    "4. docs/MAP.md"
    "5. docs/MANUAL.md"
    "6. ops/lib/manifests/CONTEXT.md"
  )
  local expected
  for expected in "${canon_expected[@]}"; do
    if ! grep -Fxq -- "$expected" <<< "$canon_block"; then
      fail "TASK v2 canon load order missing '${expected}'"
    fi
  done

  local canon_count
  canon_count="$(grep -cE '^[[:space:]]*[0-9]+\.[[:space:]]' <<< "$canon_block" || true)"
  if [[ "$canon_count" != "6" ]]; then
    fail "TASK v2 canon load order must include exactly six numbered items"
  fi

  if grep -nE '(tools/|ops/bin/|docs/ops/specs/)' <<< "$canon_block" >/dev/null; then
    fail "TASK v2 canon load order is bloated; tools and binaries belong under 3.2.2"
  fi

  local scoped_block
  scoped_block="$(extract_block "$path" '^#### 3[.]2[.]2' '^### 3[.]3')"
  local -a scoped_expected=(
    "tools/lint/dp.sh"
    "tools/lint/task.sh"
    "docs/ops/specs/binaries/open.md"
  )
  for expected in "${scoped_expected[@]}"; do
    if ! grep -Fq -- "$expected" <<< "$scoped_block"; then
      fail "TASK v2 DP-scoped load order missing '${expected}'"
    fi
  done

  if ! grep -Fq 'Worker does not read OPEN.' <<< "$canon_block"; then
    fail "TASK v2 context notes must state that worker does not read OPEN"
  fi
  if ! grep -Fq 'Worker input is the DP text only.' <<< "$canon_block"; then
    fail "TASK v2 context notes must state DP text-only worker input"
  fi
  if ! grep -Fq 'DP writer must not attach or cite disposable artifacts.' <<< "$canon_block"; then
    fail "TASK v2 context notes must forbid disposable artifact citations"
  fi
  if ! grep -Fq 'DP writer must not embed pasted bundles.' <<< "$canon_block"; then
    fail "TASK v2 context notes must forbid pasted bundles"
  fi
}

check_task_open_read_policy() {
  local path="$1"
  local open_issue
  if open_issue="$(awk '
    BEGIN { IGNORECASE=1 }
    {
      line=tolower($0)
      if (line ~ /read[[:space:]]+open/ || line ~ /open[[:space:]]+is[[:space:]]+required[[:space:]]+reading/) {
        if (line ~ /does not read open/) { next }
        if (line ~ /not required reading/) { next }
        print $0
        exit 1
      }
    }
  ' "$path")"; then
    :
  else
    fail "TASK contains forbidden OPEN-reading directive: ${open_issue}"
  fi
}

check_task_receipt_contract() {
  local path="$1"
  local receipt_block
  receipt_block="$(extract_block "$path" '^#### 3[.]4[.]5' '^## 4[.]')"
  if [[ -z "$receipt_block" ]]; then
    fail "TASK v2 missing receipt block"
    return
  fi

  if ! grep -Eq '\./ops/bin/open[[:space:]]+--out=auto[[:space:]]+--dp=' <<< "$receipt_block"; then
    fail "TASK v2 receipt contract missing executable OPEN command"
  fi
  if ! grep -Eq '\./ops/bin/dump[[:space:]]+--scope=platform[[:space:]]+--format=chatgpt[[:space:]]+--out=auto[[:space:]]+--bundle' <<< "$receipt_block"; then
    fail "TASK v2 receipt contract missing executable DUMP command"
  fi
  if ! grep -Fq 'git diff --name-only' <<< "$receipt_block"; then
    fail "TASK v2 receipt contract missing git diff --name-only proof command"
  fi
  if ! grep -Fq 'git diff --stat' <<< "$receipt_block"; then
    fail "TASK v2 receipt contract missing git diff --stat proof command"
  fi
  if ! grep -iq 'required pasted outputs' <<< "$receipt_block"; then
    fail "TASK v2 receipt contract missing required pasted outputs language"
  fi
  if ! grep -Fq 'Mandatory Closing Block required in RESULTS' <<< "$receipt_block"; then
    fail "TASK v2 receipt contract missing Mandatory Closing Block requirement"
  fi
}

check_task_scope_baseline() {
  local path="$1"
  local issue
  if issue="$(awk '
    BEGIN { in_scope=0; obj=0; ins=0; outs=0; saf=0; allow=0; allow_item=0 }
    /^### 3\.3 / { in_scope=1; next }
    /^### 3\.4 / { in_scope=0 }
    in_scope {
      if ($0 ~ /^Objective:/) {
        obj=1
        sub(/^Objective:[[:space:]]*/, "", $0)
        if ($0 ~ /^[[:space:]]*$/) { print "Objective missing value"; exit 1 }
        next
      }
      if ($0 ~ /^In scope:/) {
        ins=1
        sub(/^In scope:[[:space:]]*/, "", $0)
        if ($0 ~ /^[[:space:]]*$/) { print "In scope missing value"; exit 1 }
        next
      }
      if ($0 ~ /^Out of scope:/) {
        outs=1
        sub(/^Out of scope:[[:space:]]*/, "", $0)
        if ($0 ~ /^[[:space:]]*$/) { print "Out of scope missing value"; exit 1 }
        next
      }
      if ($0 ~ /^Safety and invariants:/) {
        saf=1
        sub(/^Safety and invariants:[[:space:]]*/, "", $0)
        if ($0 ~ /^[[:space:]]*$/) { print "Safety and invariants missing value"; exit 1 }
        next
      }
      if ($0 ~ /^Target Files allowlist \(hard gate\):/) {
        allow=1
        next
      }
      if (allow && $0 ~ /^[[:space:]]*[-*][[:space:]]+/) {
        allow_item=1
        next
      }
    }
    END {
      if (!obj) { print "missing Objective line"; exit 1 }
      if (!ins) { print "missing In scope line"; exit 1 }
      if (!outs) { print "missing Out of scope line"; exit 1 }
      if (!saf) { print "missing Safety and invariants line"; exit 1 }
      if (!allow) { print "missing Target Files allowlist heading"; exit 1 }
      if (!allow_item) { print "Target Files allowlist missing entries"; exit 1 }
    }
  ' "$path")"; then
    :
  else
    fail "scope section invalid: $issue"
  fi
}

check_task_plan_baseline() {
  local path="$1"
  local prompt="$TASK_PROMPT"
  local issue

  if issue="$(awk -v prompt="$prompt" '
    BEGIN { in_plan=0; heading=""; content=0; in_receipt=0 }
    /^### 3\.4 / { in_plan=1; next }
    /^## 4[.)]/ {
      if (in_plan && heading != "" && content == 0) {
        print "missing execution plan content after heading: " heading
        exit 1
      }
      exit
    }
    in_plan {
      if ($0 ~ /^#### 3\.4\.[1-5] /) {
        if (heading != "" && content == 0) {
          print "missing execution plan content after heading: " heading
          exit 1
        }
        heading=$0
        content=0
        if ($0 ~ /^#### 3\.4\.5 /) {
          in_receipt=1
        } else {
          in_receipt=0
        }
        next
      }
      if ($0 ~ /^[[:space:]]*$/) { next }
      if (in_receipt && $0 == prompt) {
        print "receipt section still uses template prompt"
        exit 1
      }
      content=1
    }
    END {
      if (in_plan && heading != "" && content == 0) {
        print "missing execution plan content after heading: " heading
        exit 1
      }
    }
  ' "$path")"; then
    :
  else
    fail "$issue"
  fi
}

check_task_closeout_baseline() {
  local path="$1"
  local instruction="$CLOSEOUT_INSTRUCTION"
  local -a labels=(
    "Primary Commit Header (plaintext)"
    "Pull Request Title (plaintext)"
    "Pull Request Description (markdown)"
    "Final Squash Stub (plaintext) (Must differ from #1)"
    "Extended Technical Manifest (plaintext)"
    "Review Conversation Starter (markdown)"
  )
  local label

  if ! grep -nF "Mandatory Closing Block" "$path" >/dev/null; then
    fail "missing Mandatory Closing Block"
    return
  fi

  for label in "${labels[@]}"; do
    if ! grep -Fx -- "$label" "$path" >/dev/null; then
      fail "missing closeout label: $label"
    fi
  done

  local instruction_count
  instruction_count="$(awk -v instr="$instruction" '
    BEGIN { in_block=0; count=0 }
    /^[[:space:]]*Mandatory Closing Block/ { in_block=1; next }
    /^## 4\.1 / { in_block=0 }
    in_block && $0 == instr { count++ }
    END { print count }
  ' "$path")"

  if [[ "$instruction_count" != "6" ]]; then
    fail "closeout instruction placeholder count mismatch (expected 6, got ${instruction_count})"
  fi

  local issue
  if issue="$(awk -v instr="$instruction" '
    BEGIN { in_block=0 }
    /^[[:space:]]*Mandatory Closing Block/ { in_block=1; next }
    /^## 4\.1 / { in_block=0 }
    in_block {
      if ($0 ~ /^[[:space:]]*$/) { next }
      if ($0 == instr) { next }
      if ($0 == "Varied Wording provision: Each entry must use meaningfully distinct wording; copy or minor tense changes are not acceptable. Entry 4 must differ from Entry 1.") { next }
      if ($0 ~ /^[[:space:]]*Primary Commit Header/) { next }
      if ($0 ~ /^[[:space:]]*Pull Request Title/) { next }
      if ($0 ~ /^[[:space:]]*Pull Request Description/) { next }
      if ($0 ~ /^[[:space:]]*Final Squash Stub/) { next }
      if ($0 ~ /^[[:space:]]*Extended Technical Manifest/) { next }
      if ($0 ~ /^[[:space:]]*Review Conversation Starter/) { next }
      print $0
      exit 1
    }
  ' "$path")"; then
    :
  else
    fail "closeout block contains non-template content: $issue"
  fi
}

check_task_thread_transition() {
  local path="$1"
  if ! grep -nE '^##[[:space:]]*4\.1[.)]?[[:space:]]*Thread Transition' "$path" >/dev/null; then
    fail "missing heading '## 4.1 Thread Transition (Reset / Archive Rule)' (task scheme)"
  fi
}

check_task_work_log_baseline() {
  local path="$1"
  local marker="(No active thread)"
  local issue
  local rc

  if issue="$(awk -v marker="$marker" '
    BEGIN { in_log=0; found=0 }
    /^## 5\. Work Log/ { in_log=1; next }
    {
      if (!in_log) { next }
      if ($0 ~ /^[[:space:]]*$/) { next }
      if (!found && $0 == marker) { found=1; next }
      print $0
      exit 1
    }
    END {
      if (!in_log) { exit 2 }
      if (!found) { exit 3 }
    }
  ' "$path")"; then
    rc=0
  else
    rc=$?
  fi

  case "$rc" in
    0)
      ;;
    1)
      fail "Work Log contains non-template content: $issue"
      ;;
    2)
      fail "missing Work Log section"
      ;;
    3)
      fail "Work Log missing baseline marker: ${marker}"
      ;;
    *)
      fail "Work Log validation failed"
      ;;
  esac
}

has_in_scope_section() {
  local path="$1"
  if grep -nE '^[[:space:]]*(###\s+)?In scope\b' "$path" >/dev/null; then
    return 0
  fi
  if grep -nE '^[[:space:]]*\\*\\*In scope\\*\\*' "$path" >/dev/null; then
    return 0
  fi
  return 1
}

has_objective_section() {
  local path="$1"
  if grep -nE '^[[:space:]]*(###\s+)?Objective\b' "$path" >/dev/null; then
    return 0
  fi
  if grep -nE '^[[:space:]]*\\*\\*Objective\\*\\*' "$path" >/dev/null; then
    return 0
  fi
  return 1
}

check_dp_preflight_gate() {
  local path="$1"
  if ! grep -nEi '^##[[:space:]]*3\.1\.1[.)]?[[:space:]]*DP PREFLIGHT GATE' "$path" >/dev/null; then
    fail "missing heading '## 3.1.1 DP Preflight Gate (Run Before Any Edits)'"
    return
  fi

  local preflight_block
  preflight_block="$(extract_block "$path" '^##[[:space:]]*3[.]1[.]1' '^##[[:space:]]*3[.]2')"
  local -a required_preflight=(
    "bash tools/lint/dp.sh --test"
    "bash tools/lint/dp.sh TASK.md"
    "bash tools/lint/task.sh"
  )
  local req
  for req in "${required_preflight[@]}"; do
    if ! grep -Fq -- "$req" <<< "$preflight_block"; then
      fail "DP preflight gate missing command: ${req}"
    fi
  done
}

check_dp_disposable_input_hazards() {
  local path="$1"
  local issue

  if issue="$(awk '
    BEGIN { IGNORECASE=1 }
    /storage\/_scratch\/|storage\/tmp\/|scratch draft|throwaway notes|throwaway memo/ {
      print $0
      exit 1
    }
  ' "$path")"; then
    :
  else
    fail "DP references disposable artifact input: ${issue}"
  fi

  if issue="$(awk '
    BEGIN { IGNORECASE=1 }
    {
      line=tolower($0)
      if ((line ~ /attach/ || line ~ /attachment/) && (line ~ /open/ || line ~ /dump/)) {
        if (line ~ /do not/ || line ~ /must not/ || line ~ /not required/) { next }
        print $0
        exit 1
      }
    }
  ' "$path")"; then
    :
  else
    fail "DP requests OPEN/DUMP as attachments instead of executable receipts: ${issue}"
  fi

  if issue="$(awk '
    BEGIN { IGNORECASE=1 }
    /BEGIN[[:space:]]+OPEN|END[[:space:]]+OPEN|BEGIN[[:space:]]+DUMP|END[[:space:]]+DUMP|pasted[[:space:]]+bundle|raw[[:space:]]+open[[:space:]]+payload|raw[[:space:]]+dump[[:space:]]+payload/ {
      print $0
      exit 1
    }
  ' "$path")"; then
    :
  else
    fail "DP embeds OPEN/DUMP payload markers instead of pointer references: ${issue}"
  fi
}

is_task_file() {
  local path="$1"
  if grep -nE '^#[[:space:]]*STELA TASK DASHBOARD' "$path" >/dev/null; then
    return 0
  fi
  if grep -nE '^##[[:space:]]*1\\.[[:space:]]*Session State' "$path" >/dev/null; then
    return 0
  fi
  return 1
}

lint_task() {
  local path="$1"
  failures=0

  local task_headings=(
    "## 1. Session State (The Anchor)"
    "## 2. Logic Pointers (The Law)"
    "## 3. Current Dispatch Packet (DP)"
    "## 4. Closeout (Mandatory)"
    "## 5. Work Log (Timestamped Continuity)"
  )

  local task_patterns=(
    '^##[[:space:]]*1\\.[[:space:]]*SESSION STATE'
    '^##[[:space:]]*2\\.[[:space:]]*LOGIC POINTERS'
    '^##[[:space:]]*3\\.[[:space:]]*CURRENT DISPATCH PACKET'
    '^##[[:space:]]*4\\.[[:space:]]*CLOSEOUT'
    '^##[[:space:]]*5\\.[[:space:]]*WORK LOG'
  )

  local -a heading_lines=()
  local missing=0
  local line
  local i

  for ((i=0; i<${#task_headings[@]}; i++)); do
    line="$(first_heading_line "$path" "${task_patterns[i]}")"
    if [[ -z "$line" ]]; then
      fail "missing heading '${task_headings[i]}' (task scheme)"
      missing=1
      heading_lines+=("")
    else
      heading_lines+=("$line")
    fi
  done

  if (( !missing )); then
    for ((i=0; i<${#heading_lines[@]}-1; i++)); do
      if (( heading_lines[i] >= heading_lines[i+1] )); then
        fail "headings out of order: '${task_headings[i]}' should appear before '${task_headings[i+1]}' (task scheme)"
        break
      fi
    done
  fi

  check_required_field "Pointer"
  check_required_field "Base HEAD"
  check_required_field "Context Manifest"

  local pointer_raw
  pointer_raw="$(field_value "Pointer")"
  pointer_raw="$(trim "$pointer_raw")"
  pointer_raw="$(strip_backticks "$pointer_raw")"
  local v2_pointer_pattern='^storage/handoff/OPEN-<branch>-<short-hash>[.]txt([[:space:]]*[(].*[)])?$'
  if [[ "$pointer_raw" != "Session context output (generated by ops/bin/open)" ]] && [[ ! "$pointer_raw" =~ $v2_pointer_pattern ]]; then
    fail "Pointer must equal 'Session context output (generated by ops/bin/open)'"
  fi

  local session_issue
  if session_issue="$(awk '
    BEGIN { in_session=0 }
    /^## 1\. Session State/ { in_session=1; next }
    /^## 2\./ { in_session=0 }
    in_session {
      if ($0 ~ /^[[:space:]]*Active Branch:/) { print "Active Branch"; exit 1 }
      if ($0 ~ /^[[:space:]]*Branch:/) { print "Branch"; exit 1 }
      if ($0 ~ /^[[:space:]]*Base HEAD:/) { print "Base HEAD"; exit 1 }
      if ($0 ~ /work\/[[:alnum:]_.-]+/) { print "work branch mirror"; exit 1 }
      if ($0 ~ /[0-9a-f]{7,}/) { print "hash mirror"; exit 1 }
    }
  ' "$path")"; then
    :
  else
    fail "legacy volatile session state field detected in Session State: $session_issue"
  fi

  local base_head_raw
  local base_head
  base_head_raw="$(field_value "Base HEAD")"
  base_head_raw="$(trim "$base_head_raw")"
  base_head_raw="$(strip_backticks "$base_head_raw")"
  base_head="$(extract_hash "$base_head_raw")"
  if [[ -z "$base_head" ]]; then
    fail "missing or invalid Base HEAD hash"
  fi

  local -a required_pointers=(
    "PoT.md"
    "docs/MANUAL.md"
    "docs/ops/specs/surfaces/task.md"
    "tools/lint/context.sh"
    "tools/verify.sh"
    "tools/lint/dp.sh"
    "tools/lint/task.sh"
    "ops/bin/open"
    "ops/bin/dump"
    "ops/bin/prune"
  )
  local pointer
  for pointer in "${required_pointers[@]}"; do
    if ! grep -Fq -- "$pointer" "$path"; then
      fail "missing pointer-first canon reference: ${pointer}"
    fi
  done

  if grep -nE '^[[:space:]]*Gate Artifacts \(Must Match\):' "$path" >/dev/null; then
    fail "legacy static gate artifact block is forbidden in TASK.md"
  fi
  if grep -nE '^[[:space:]]*Gate Commands \(Must Pass\):' "$path" >/dev/null; then
    fail "legacy static gate command block is forbidden in TASK.md"
  fi
  if grep -nE 'Mandatory artifacts \(every execution, no exceptions\)' "$path" >/dev/null; then
    fail "legacy mandatory artifacts line is forbidden in TASK.md"
  fi

  local -a static_gate_filename_patterns=(
    '^[[:space:]]*[-*][[:space:]]*OPEN:[[:space:]]*storage/handoff/OPEN-'
    '^[[:space:]]*[-*][[:space:]]*OPEN-PORCELAIN:[[:space:]]*storage/handoff/OPEN-PORCELAIN-'
    '^[[:space:]]*[-*][[:space:]]*Dump:[[:space:]]*storage/dumps/dump-full-'
    '^[[:space:]]*[-*][[:space:]]*Dump Manifest:[[:space:]]*storage/dumps/dump-full-'
  )
  local static_pattern
  for static_pattern in "${static_gate_filename_patterns[@]}"; do
    if grep -nE -- "$static_pattern" "$path" >/dev/null; then
      fail "legacy static artifact filename list detected in TASK.md"
      break
    fi
  done

  local token
  for token in "${PLACEHOLDER_TOKENS[@]}"; do
    if grep -Fq -- "$token" "$path"; then
      fail "placeholder token found: $token"
    fi
  done

  if has_standalone_ellipsis "$path"; then
    fail "placeholder token found: ..."
  fi

  check_task_subsections "$path"
  check_task_freeze_rule "$path"
  check_task_preflight_gate_contract "$path"
  check_task_context_load_contract "$path"
  check_task_open_read_policy "$path"
  check_task_plan_headings "$path"
  check_task_scope_baseline "$path"
  check_task_plan_baseline "$path"
  check_task_receipt_contract "$path"
  check_task_closeout_baseline "$path"
  check_task_thread_transition "$path"
  check_task_work_log_baseline "$path"

  if (( failures )); then
    return 1
  fi

  echo "OK: TASK lint passed"
}

heading_errors_for_scheme() {
  local path="$1"
  local scheme="$2"
  local -n labels="$3"
  local -n patterns="$4"
  local thread_label="$5"
  local thread_pattern="$6"
  local work_label="$7"
  local work_pattern="$8"

  local -a errors=()
  local -a heading_lines=()
  local missing=0
  local line
  local i

  for ((i=0; i<${#labels[@]}; i++)); do
    line="$(first_heading_line "$path" "${patterns[i]}")"
    if [[ -z "$line" ]]; then
      errors+=("missing heading '${labels[i]}' (${scheme} scheme)")
      missing=1
      heading_lines+=("")
    else
      heading_lines+=("$line")
    fi
  done

  if (( !missing )); then
    for ((i=0; i<${#heading_lines[@]}-1; i++)); do
      if (( heading_lines[i] >= heading_lines[i+1] )); then
        errors+=("headings out of order: '${labels[i]}' should appear before '${labels[i+1]}' (${scheme} scheme)")
        break
      fi
    done
  fi

  local closeout_line="${heading_lines[${#heading_lines[@]}-1]}"
  local work_log_line
  local thread_line

  work_log_line="$(first_heading_line "$path" "$work_pattern")"
  if [[ -z "$work_log_line" ]]; then
    errors+=("missing heading '$work_label' (${scheme} scheme)")
  fi

  thread_line="$(first_heading_line "$path" "$thread_pattern")"
  if [[ -z "$thread_line" ]]; then
    errors+=("missing heading '$thread_label' (${scheme} scheme)")
  fi

  if [[ -n "$closeout_line" && -n "$work_log_line" ]]; then
    if (( work_log_line <= closeout_line )); then
      errors+=("headings out of order: '$work_label' should appear after '${labels[${#labels[@]}-1]}' (${scheme} scheme)")
    fi
  fi

  if [[ -n "$closeout_line" && -n "$thread_line" ]]; then
    if (( thread_line <= closeout_line )); then
      errors+=("headings out of order: '$thread_label' should appear after '${labels[${#labels[@]}-1]}' (${scheme} scheme)")
    fi
  fi

  if (( ${#errors[@]} )); then
    printf '%s\n' "${errors[@]}"
    return 1
  fi

  return 0
}

lint_file() {
  local path="$1"
  failures=0

  if [[ ! -f "$path" ]]; then
    fail "Missing file: $path"
    return 1
  fi

  # If TASK DP headings change, update these lists and the --test fixtures.
  # Decimal scheme only (3.1/3.2/3.3/3.4/4/4.1/5).
  local decimal_headings=(
    "## 3.1 Freshness Gate (Must Pass Before Work)"
    "## 3.2 Required Context Load (Read Before Doing Anything)"
    "## 3.3 Scope and Safety"
    "## 3.4 Execution Plan (A-E Canon)"
    "## 4 Closeout (Mandatory)"
  )

  local decimal_patterns=(
    '^##[[:space:]]*3\\.1[.)]?[[:space:]]*FRESHNESS GATE'
    '^##[[:space:]]*3\\.2[.)]?[[:space:]]*REQUIRED CONTEXT LOAD'
    '^##[[:space:]]*3\\.3[.)]?[[:space:]]*SCOPE'
    '^##[[:space:]]*3\\.4[.)]?[[:space:]]*EXECUTION PLAN'
    '^##[[:space:]]*4[.)]?[[:space:]]*CLOSEOUT'
  )

  local decimal_thread_label="## 4.1 Thread Transition (Reset / Archive Rule)"
  local decimal_thread_pattern='^##[[:space:]]*4\\.1[.)]?[[:space:]]*THREAD TRANSITION'
  local decimal_work_label="## 5 Work Log (Timestamped Continuity)"
  local decimal_work_pattern='^##[[:space:]]*5[.)]?[[:space:]]*WORK LOG'

  local decimal_errors

  if decimal_errors="$(heading_errors_for_scheme "$path" "decimal" decimal_headings decimal_patterns "$decimal_thread_label" "$decimal_thread_pattern" "$decimal_work_label" "$decimal_work_pattern")"; then
    :
  else
    while IFS= read -r line; do
      [[ -n "$line" ]] && fail "$line"
    done <<< "$decimal_errors"
    fail "heading scheme not recognized. Accepted heading scheme: decimal (3.1/3.2/3.3/3.4/4/4.1/5)."
  fi

  if ! grep -nE '^#\s*DP-[A-Z]+-[0-9]{4,}([_-]v[0-9]+)?(: .+)?$' "$path" >/dev/null; then
    fail "missing DP id heading (expected '# DP-<AREA>-<####>' with optional ': <title>')"
  fi

  local token
  for token in "${PLACEHOLDER_TOKENS[@]}"; do
    if grep -Fq -- "$token" "$path"; then
      fail "placeholder token found: $token"
    fi
  done

  if has_standalone_ellipsis "$path"; then
    fail "placeholder token found: ..."
  fi

  check_required_field "Base Branch"
  check_required_field_any "Required Work Branch" "Work Branch"
  check_required_field "Base HEAD"
  check_dp_preflight_gate "$path"
  check_dp_disposable_input_hazards "$path"

  local has_ae=1
  local letter
  for letter in A B C D E; do
    if ! grep -nE "^###\\s*${letter}[.)]" "$path" >/dev/null; then
      has_ae=0
      break
    fi
  done

  local has_decimal=1
  local idx
  for idx in 1 2 3 4 5; do
    if ! grep -nE "^###\\s*3\\.4\\.${idx}\\b" "$path" >/dev/null; then
      has_decimal=0
      break
    fi
  done

  if (( !has_ae && !has_decimal )); then
    fail "missing execution plan subheadings (accepts '### A)' through '### E)' or '### 3.4.1' through '### 3.4.5')"
  fi

  if ! field_value_valid "Objective"; then
    if ! has_objective_section "$path" && ! has_in_scope_section "$path"; then
      fail "missing scope summary (Objective or In scope section)"
    fi
  fi

  mapfile -t allowlist < <(extract_allowlist_backticks "$path" "Target Files allowlist (hard gate)")
  if (( ${#allowlist[@]} == 0 )); then
    mapfile -t allowlist < <(extract_allowlist_paths "$path" "Target Files allowlist (hard gate)")
  fi
  if (( ${#allowlist[@]} == 0 )); then
    mapfile -t allowlist < <(extract_allowlist_backticks "$path" "Target Files (Allowlist)")
    if (( ${#allowlist[@]} == 0 )); then
      mapfile -t allowlist < <(extract_allowlist_paths "$path" "Target Files (Allowlist)")
    fi
  fi
  if (( ${#allowlist[@]} == 0 )); then
    mapfile -t allowlist < <(extract_allowlist_backticks "$path" "Allowed Scope")
    if (( ${#allowlist[@]} == 0 )); then
      mapfile -t allowlist < <(extract_allowlist_paths "$path" "Allowed Scope")
    fi
  fi

  local -a normalized_allowlist=()
  if (( ${#allowlist[@]} == 0 )); then
    fail "Target Files allowlist missing or empty"
  else
    local entry
    local normalized
    for entry in "${allowlist[@]}"; do
      entry="$(trim "$entry")"
      entry="$(strip_backticks "$entry")"
      if [[ -z "$entry" ]]; then
        fail "Target Files allowlist has empty entry"
        continue
      fi

      normalized="$entry"
      if [[ "$normalized" =~ ^\(new\)[[:space:]]* ]]; then
        normalized="${normalized#(new)}"
        normalized="$(trim "$normalized")"
        if [[ -z "$normalized" ]]; then
          fail "Target Files allowlist '(new)' entry missing path"
        else
          normalized_allowlist+=("${normalized#./}")
        fi
        continue
      fi

      normalized_allowlist+=("${normalized#./}")
      if [[ ! -e "$entry" ]]; then
        fail "Target Files allowlist path missing: $entry (use '(new)' prefix if new)"
      fi
    done
  fi

  if (( ${#normalized_allowlist[@]} )) && has_llms_invocation "$path"; then
    local -a required_llms=(
      "llms.txt"
      "llms-small.txt"
      "llms-full.txt"
      "llms-ops.txt"
      "llms-governance.txt"
    )
    local -a missing_llms=()
    local required
    local entry
    local found

    for required in "${required_llms[@]}"; do
      found=0
      for entry in "${normalized_allowlist[@]}"; do
        if [[ "$entry" == "$required" ]]; then
          found=1
          break
        fi
      done
      if (( !found )); then
        missing_llms+=("$required")
      fi
    done

    if (( ${#missing_llms[@]} )); then
      echo "WARN: llms allowlist missing required root outputs: ${missing_llms[*]}" >&2
    fi
  fi

  local fallback='Fallback: ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle'
  if grep -Fq -- '--include-dir' "$path" || grep -Fq -- '--exclude-dir' "$path" || grep -Fq -- '--ignore-file' "$path"; then
    if ! grep -Fq -- "$fallback" "$path"; then
      fail "missing dump-refiner fallback line: $fallback"
    fi
  fi

  if (( failures )); then
    return 1
  fi

  echo "OK: DP lint passed"
}

lint_path() {
  local path="$1"
  if is_task_file "$path"; then
    lint_task "$path"
  else
    lint_file "$path"
  fi
}

run_test() {
  local tmp_valid
  local tmp_invalid
  local tmp_missing_preflight
  local tmp_disposable
  local tmp_task_valid
  local tmp_task_invalid
  local tmp_task_dirty

  tmp_valid="$(mktemp)"
  cat <<'EOF' > "$tmp_valid"
# DP-OPS-0001: Lint Test
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0001-lint
Base HEAD: 13a2074d
## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
## 3.2 Required Context Load (Read Before Doing Anything)
- Loaded: PoT.md, SoP.md, TASK.md, docs/MAP.md, docs/MANUAL.md, ops/lib/manifests/CONTEXT.md.
## 3.3 Scope and Safety
- Objective: Validate V2 lint headings and required fields.
### Target Files allowlist (hard gate)
- tools/lint/dp.sh
## 3.4 Execution Plan (A-E Canon)
### 3.4.1 State
Test state.
### 3.4.2 Request
1) Test request.
### 3.4.3 Changelog
- Test changelog.
### 3.4.4 Patch / Diff
- Test diff.
### 3.4.5 Receipt (Required)
- Test receipt.
## 4 Closeout (Mandatory)
- Closeout notes.
## 4.1 Thread Transition (Reset / Archive Rule)
- Transition notes.
## 5 Work Log (Timestamped Continuity)
- 2026-01-27 14:05 — DP-OPS-0001: Lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review.
EOF

  lint_path "$tmp_valid" >/dev/null

  tmp_invalid="$(mktemp)"
  cat <<'EOF' > "$tmp_invalid"
# DP-OPS-0002: Lint Placeholder Test
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0002-lint
Base HEAD: 13a2074d
## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
## 3.2 Required Context Load (Read Before Doing Anything)
- Loaded: PoT.md, SoP.md, TASK.md.
## 3.3 Scope and Safety
Objective: TBD
### Target Files allowlist (hard gate)
- tools/lint/dp.sh
## 3.4 Execution Plan (A-E Canon)
### 3.4.1 State
State text.
### 3.4.2 Request
Request text.
### 3.4.3 Changelog
Changelog text.
### 3.4.4 Patch / Diff
Patch text.
### 3.4.5 Receipt (Required)
Receipt text.
## 4 Closeout (Mandatory)
Closeout text.
## 4.1 Thread Transition (Reset / Archive Rule)
Thread text.
## 5 Work Log (Timestamped Continuity)
- 2026-01-27 14:05 — DP-OPS-0002: Lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review.
EOF

  if lint_path "$tmp_invalid" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid"
    echo "FAIL: --test expected placeholder detection to fail" >&2
    exit 1
  fi

  tmp_missing_preflight="$(mktemp)"
  cat <<'EOF' > "$tmp_missing_preflight"
# DP-OPS-0003: Missing Preflight
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0003-lint
Base HEAD: 13a2074d
## 3.2 Required Context Load (Read Before Doing Anything)
- Loaded: PoT.md, SoP.md, TASK.md.
## 3.3 Scope and Safety
Objective: Validate preflight requirement.
### Target Files allowlist (hard gate)
- tools/lint/dp.sh
## 3.4 Execution Plan (A-E Canon)
### 3.4.1 State
State text.
### 3.4.2 Request
Request text.
### 3.4.3 Changelog
Changelog text.
### 3.4.4 Patch / Diff
Patch text.
### 3.4.5 Receipt (Required)
Receipt text.
## 4 Closeout (Mandatory)
Closeout text.
## 4.1 Thread Transition (Reset / Archive Rule)
Thread text.
## 5 Work Log (Timestamped Continuity)
- 2026-01-27 14:05 — DP-OPS-0003: Lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review.
EOF

  if lint_path "$tmp_missing_preflight" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid" "$tmp_missing_preflight"
    echo "FAIL: --test expected preflight heading detection to fail" >&2
    exit 1
  fi

  tmp_disposable="$(mktemp)"
  cat <<'EOF' > "$tmp_disposable"
# DP-OPS-0004: Disposable Input Test
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0004-lint
Base HEAD: 13a2074d
## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
## 3.2 Required Context Load (Read Before Doing Anything)
- Required input: storage/_scratch/notes.md
## 3.3 Scope and Safety
Objective: Validate disposable input rejection.
### Target Files allowlist (hard gate)
- tools/lint/dp.sh
## 3.4 Execution Plan (A-E Canon)
### 3.4.1 State
State text.
### 3.4.2 Request
Request text.
### 3.4.3 Changelog
Changelog text.
### 3.4.4 Patch / Diff
Patch text.
### 3.4.5 Receipt (Required)
Receipt text.
## 4 Closeout (Mandatory)
Closeout text.
## 4.1 Thread Transition (Reset / Archive Rule)
Thread text.
## 5 Work Log (Timestamped Continuity)
- 2026-01-27 14:05 — DP-OPS-0004: Lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review.
EOF

  if lint_path "$tmp_disposable" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid" "$tmp_missing_preflight" "$tmp_disposable"
    echo "FAIL: --test expected disposable input detection to fail" >&2
    exit 1
  fi

  tmp_task_valid="$(mktemp)"
  cat <<'EOF' > "$tmp_task_valid"
# STELA TASK DASHBOARD
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-12

## 1. Session State (The Anchor)
Pointer: Session context output (generated by ops/bin/open)
Context Manifest: ops/lib/manifests/CONTEXT.md (Checked by tools/lint/context.sh)

## 2. Logic Pointers (The Law)
Primary Constraint: PoT.md (Policy of Truth).
Surface Contract Spec: docs/ops/specs/surfaces/task.md.
Lint Enforcement: tools/lint/dp.sh and tools/lint/task.sh.

Freeze Rule:
- After dispatch, the active DP is frozen.
- Any change to scope, allowlist, gates, or receipt requirements must be recorded as `AMENDMENT:` lines inside Section 3 before execution continues.

## 3. Current Dispatch Packet (DP)
### DP-XXXX: (Template)

### 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-XXXX-task-surface-contract-lock
Base HEAD: 13a2074d

Required local re-check (worker runs; paste results in RESULTS):
- git rev-parse --abbrev-ref HEAD
- git rev-parse --short HEAD
- git status --porcelain

STOP if any mismatch.
STOP if Required Work Branch is missing.
STOP if told to create or switch branches.
STOP if working tree is dirty before execution begins.

### 3.1.1 DP Preflight Gate (Run Before Any Edits)
Purpose:
- Catch malformed DP or TASK schema before work begins.

Worker runs (paste outcome in RESULTS):
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

STOP if any preflight check fails.

### 3.2 Required Context Load (Read Before Doing Anything)

#### 3.2.1 Canon load order (always)
Worker must confirm loaded before edits begin:
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md

Notes:
- Worker does not read OPEN. OPEN is for Integrator state refresh and for receipts.
- Disposable artifacts must not be referenced or included.
- Worker input is the DP text only.
- DP writer must not attach or cite disposable artifacts.
- DP writer must not embed pasted bundles.

#### 3.2.2 DP-scoped load order (per DP)
- tools/lint/dp.sh
- tools/lint/task.sh
- docs/ops/specs/binaries/open.md (pointer reference only; OPEN behavior is not modified in this DP)

### 3.3 Scope and Safety
Objective: Populate during execution; do not pre-fill in TASK.md.
In scope: Populate during execution; do not pre-fill in TASK.md.
Out of scope: Populate during execution; do not pre-fill in TASK.md.
Safety and invariants: Populate during execution; do not pre-fill in TASK.md.

Target Files allowlist (hard gate):
- Populate during execution; do not pre-fill in TASK.md.

### 3.4 Execution Plan (A-E Canon)
DP Authoring Protocol (section-by-section):
- 3.4.1 State: facts only.
- 3.4.2 Request: numbered change requests.
- 3.4.3 Changelog: planned file deltas.
- 3.4.4 Patch / Diff: implementation details.
- 3.4.5 Receipt: executable proofs and required pasted outputs.

#### 3.4.1 State (What is true now)
Populate during execution; do not pre-fill in TASK.md.

#### 3.4.2 Request (What we are changing)
Populate during execution; do not pre-fill in TASK.md.

#### 3.4.3 Changelog (Planned edits)
Populate during execution; do not pre-fill in TASK.md.

#### 3.4.4 Patch / Diff (Implementation details)
Populate during execution; do not pre-fill in TASK.md.

#### 3.4.5 Receipt (Proofs to collect) — MUST RUN
Rule:
- If any required proof is missing, DP is FAIL.
- Proofs must match the allowlist.

A) Capture session artifacts (record printed paths in RESULTS)
- ./ops/bin/open --out=auto --dp="DP-OPS-XXXX"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- Zero-byte check: test -s <dump_payload_path>

B) Gates (record PASS/FAIL in RESULTS; if NOT RUN, include reason + risk)
- bash tools/lint/context.sh
- bash tools/lint/style.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/llms.sh
- ./tools/verify.sh

C) Diff proof (paste outputs in RESULTS)
- git diff --name-only
- git diff --stat

D) RESULTS file (required)
- storage/handoff/DP-OPS-XXXX-RESULTS.md must include:
  - Status block (Scope summary, Tracked change, Verification)
  - Receipt pointers (OPEN, OPEN-PORCELAIN or none + reason, dump payload, dump manifest, dump bundle if any)
  - Verification outcomes (RUN/NOT RUN + reason + risk)
  - required pasted outputs (paths, diffs, verification outcomes)
  - NEXT: one single action
  - Mandatory Closing Block required in RESULTS

## 4. Closeout (Mandatory)
- Follow docs/MANUAL.md Closeout Cycle (Verify, Harvest, Refresh, Log, Prune).
- Run: ./ops/bin/prune --dp=DP-OPS-XXXX --scrub (after receipts and SoP logging).

Mandatory Closing Block
Varied Wording provision: Each entry must use meaningfully distinct wording; copy or minor tense changes are not acceptable. Entry 4 must differ from Entry 1.

Primary Commit Header (plaintext)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)

Pull Request Title (plaintext)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)

Pull Request Description (markdown)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)

Final Squash Stub (plaintext) (Must differ from #1)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)

Extended Technical Manifest (plaintext)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)

Review Conversation Starter (markdown)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)

## 4.1 Thread Transition (Reset / Archive Rule)
- Append a THREAD END entry to the TASK.md Work Log at completion.

## 5. Work Log (Timestamped Continuity)
(No active thread)
EOF

  lint_path "$tmp_task_valid" >/dev/null

  tmp_task_invalid="$(mktemp)"
  cat <<'EOF' > "$tmp_task_invalid"
# STELA TASK DASHBOARD
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-12

## 1. Session State (The Anchor)
Pointer: Session context output (generated by ops/bin/open)
Context Manifest: ops/lib/manifests/CONTEXT.md (Checked by tools/lint/context.sh)

## 2. Logic Pointers (The Law)
Primary Constraint: PoT.md (Policy of Truth).

Freeze Rule:
- After dispatch, the active DP is frozen.
- Any change to scope must be recorded as `AMENDMENT:` lines.

## 3. Current Dispatch Packet (DP)
### DP-XXXX: (Template)
### 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-XXXX-task-surface-contract-lock
Base HEAD: 13a2074d
### 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
### 3.2 Required Context Load (Read Before Doing Anything)
#### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md
Notes:
- Worker must read OPEN before edits.
#### 3.2.2 DP-scoped load order (per DP)
- tools/lint/dp.sh
- tools/lint/task.sh
- docs/ops/specs/binaries/open.md
### 3.3 Scope and Safety
Objective: Test invalid OPEN read policy.
In scope: None.
Out of scope: None.
Safety and invariants: None.
Target Files allowlist (hard gate):
- TASK.md
### 3.4 Execution Plan (A-E Canon)
#### 3.4.1 State (What is true now)
State.
#### 3.4.2 Request (What we are changing)
Request.
#### 3.4.3 Changelog (Planned edits)
Changelog.
#### 3.4.4 Patch / Diff (Implementation details)
Patch.
#### 3.4.5 Receipt (Proofs to collect)
- git diff --name-only
- git diff --stat
## 4. Closeout (Mandatory)
Mandatory Closing Block
Primary Commit Header (plaintext)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)
Pull Request Title (plaintext)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)
Pull Request Description (markdown)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)
Final Squash Stub (plaintext) (Must differ from #1)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)
Extended Technical Manifest (plaintext)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)
Review Conversation Starter (markdown)
(Write to DP-OPS-XXXX-RESULTS.md; do not pre-fill in TASK.md)
## 4.1 Thread Transition (Reset / Archive Rule)
- Transition.
## 5. Work Log (Timestamped Continuity)
(No active thread)
EOF

  if lint_path "$tmp_task_invalid" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_task_valid" "$tmp_task_invalid"
    echo "FAIL: --test expected OPEN-reading detection to fail" >&2
    exit 1
  fi

  tmp_task_dirty="$(mktemp)"
  awk '{ gsub(/\(No active thread\)/, "2026-01-27 14:05 — DP-OPS-0005: Task lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review."); print }' "$tmp_task_valid" > "$tmp_task_dirty"

  if lint_path "$tmp_task_dirty" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_task_valid" "$tmp_task_invalid" "$tmp_task_dirty"
    echo "FAIL: --test expected task Work Log baseline detection to fail" >&2
    exit 1
  fi

  rm -f "$tmp_valid" "$tmp_invalid" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_task_valid" "$tmp_task_invalid" "$tmp_task_dirty"
  echo "OK: --test passed"
}

if (( $# > 1 )); then
  usage >&2
  fail "Too many arguments"
  exit 1
fi

case "${1:-}" in
  --test)
    run_test
    exit 0
    ;;
  "")
    if [[ -t 0 ]]; then
      usage >&2
      fail "No input provided"
      exit 1
    fi
    tmp_stdin="$(mktemp)"
    cat > "$tmp_stdin"
    lint_path "$tmp_stdin"
    rm -f "$tmp_stdin"
    ;;
  -)
    tmp_stdin="$(mktemp)"
    cat > "$tmp_stdin"
    lint_path "$tmp_stdin"
    rm -f "$tmp_stdin"
    ;;
  *)
    lint_path "$1"
    ;;
esac
