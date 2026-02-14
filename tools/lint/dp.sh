#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/lint/dp.sh [--test] [path|-]
USAGE
}

failures=0
declare -a normalized_allowlist=()

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
    value="${value#\`}"
  fi
  if [[ "$value" == *\` ]]; then
    value="${value%\`}"
  fi
  printf '%s' "$value"
}

extract_hash() {
  local value="$1"
  local match
  match="$(printf '%s' "$value" | grep -oE '[0-9a-f]{7,}' | head -n1 || true)"
  printf '%s' "$match"
}

has_standalone_ellipsis() {
  local path="$1"
  if grep -nE '(^|[[:space:]])\.\.\.([[:space:]]|$)' "$path" >/dev/null; then
    return 0
  fi
  return 1
}

contains_placeholder() {
  local value="$1"
  local lowered

  lowered="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  if [[ -z "$lowered" ]]; then
    return 0
  fi

  case "$lowered" in
    *"tbd"*|*"todo"*|*"["*|*"]"*|*"<fill"*|*"enter_"*|*"replace_"*|*"dp-xxxx"*|*"xxxx"*|*"0000000"*|*"populate during execution"*|*"do not pre-fill"*)
      return 0
      ;;
  esac

  return 1
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

results_label_regex='^(Primary Commit Header [(]plaintext[)]|Pull Request Title [(]plaintext[)]|Pull Request Description [(]markdown[)]|Final Squash Stub [(]plaintext[)]( [(]Must differ from #1[)]| [(]must differ from Primary Commit Header[)])?|Extended Technical Manifest [(]plaintext[)]|Review Conversation Starter [(]markdown[)])$'

extract_results_closing_block() {
  local path="$1"
  awk '
    BEGIN { in_block=0 }
    /^##[[:space:]]*Mandatory Closing Block[[:space:]]*$/ { in_block=1; next }
    in_block { print }
  ' "$path"
}

extract_results_field_block() {
  local path="$1"
  local start_pattern="$2"
  awk -v start_regex="$start_pattern" -v label_regex="$results_label_regex" '
    BEGIN { in_block=0 }
    $0 ~ start_regex { in_block=1; next }
    in_block && $0 ~ label_regex { exit }
    in_block { print }
  ' "$path"
}

field_block_nonempty() {
  local value="$1"
  if [[ -z "$(printf '%s\n' "$value" | sed '/^[[:space:]]*$/d')" ]]; then
    return 1
  fi
  return 0
}

field_value() {
  local label="$1"
  local path="$2"
  awk -v label="$label" '
    {
      if ($0 ~ "^[[:space:]]*" label ":[[:space:]]*") {
        text = $0
        sub("^[[:space:]]*" label ":[[:space:]]*", "", text)
        print text
        exit
      }
    }
  ' "$path"
}

check_required_field() {
  local label="$1"
  local path="$2"
  local value

  value="$(field_value "$label" "$path")"
  value="$(trim "$value")"
  value="$(strip_backticks "$value")"

  if [[ -z "$value" ]]; then
    fail "missing or empty value for '$label'"
    return 1
  fi

  return 0
}

is_task_surface() {
  local path="$1"
  if grep -nE '^#[[:space:]]*STELA TASK DASHBOARD' "$path" >/dev/null; then
    return 0
  fi
  if grep -nE '^##[[:space:]]*3[.][[:space:]]*Current Dispatch Packet \(DP\)' "$path" >/dev/null; then
    return 0
  fi
  return 1
}

extract_dp_payload() {
  local source_path="$1"
  local payload_path="$2"

  if is_task_surface "$source_path"; then
    if grep -nE '^##[[:space:]]*4([.]|[[:space:]])' "$source_path" >/dev/null; then
      fail "TASK.md must not contain legacy Section 4 Closeout heading; use Section 3.5"
      return 1
    fi
    if ! grep -nE '^##[[:space:]]*3[.]5([.]|[[:space:]])' "$source_path" >/dev/null; then
      fail "TASK.md missing required Section 3.5 Closeout heading"
      return 1
    fi

    awk '
      BEGIN { in_dp=0 }
      /^## 3[.] Current Dispatch Packet \(DP\)/ { in_dp=1; next }
      /^## 3[.]5([.]|[[:space:]])/ && in_dp { exit }
      in_dp { print }
    ' "$source_path" > "$payload_path"

    if [[ ! -s "$payload_path" ]]; then
      fail "TASK.md missing extractable DP payload between Section 3 and Section 3.5"
      return 1
    fi
    return 0
  fi

  cp "$source_path" "$payload_path"
}

payload_is_template() {
  local path="$1"
  if grep -nE '^#{1,6}[[:space:]]*DP-XXXX\b' "$path" >/dev/null; then
    return 0
  fi
  return 1
}

has_llms_invocation() {
  local path="$1"
  if grep -nE '(^|[[:space:]`])(\./ops/bin/llms|ops/bin/llms)([[:space:]`]|$)' "$path" >/dev/null; then
    return 0
  fi
  return 1
}

check_heading_order() {
  local path="$1"

  local -a labels=(
    "3.1 Freshness Gate"
    "3.1.1 DP Preflight Gate"
    "3.2 Required Context Load"
    "3.2.1 Canon load order"
    "3.2.2 DP-scoped load order"
    "3.3 Scope and Safety"
    "3.4 Execution Plan"
    "3.4.1 State"
    "3.4.2 Request"
    "3.4.3 Changelog"
    "3.4.4 Patch / Diff"
    "3.4.5 Receipt"
  )

  local -a patterns=(
    '^#{2,6}[[:space:]]*3[.]1[.)]?[[:space:]]*FRESHNESS GATE'
    '^#{2,6}[[:space:]]*3[.]1[.]1[.)]?[[:space:]]*DP PREFLIGHT GATE'
    '^#{2,6}[[:space:]]*3[.]2[.)]?[[:space:]]*REQUIRED CONTEXT LOAD'
    '^#{3,6}[[:space:]]*3[.]2[.]1[.)]?[[:space:]]*CANON LOAD ORDER'
    '^#{3,6}[[:space:]]*3[.]2[.]2[.)]?[[:space:]]*DP-SCOPED LOAD ORDER'
    '^#{2,6}[[:space:]]*3[.]3[.)]?[[:space:]]*SCOPE AND SAFETY'
    '^#{2,6}[[:space:]]*3[.]4[.)]?[[:space:]]*EXECUTION PLAN'
    '^#{3,6}[[:space:]]*3[.]4[.]1[.)]?[[:space:]]*STATE'
    '^#{3,6}[[:space:]]*3[.]4[.]2[.)]?[[:space:]]*REQUEST'
    '^#{3,6}[[:space:]]*3[.]4[.]3[.)]?[[:space:]]*CHANGELOG'
    '^#{3,6}[[:space:]]*3[.]4[.]4[.)]?[[:space:]]*PATCH'
    '^#{3,6}[[:space:]]*3[.]4[.]5[.)]?[[:space:]]*RECEIPT'
  )

  local -a heading_lines=()
  local missing=0
  local i
  local line

  for ((i=0; i<${#labels[@]}; i++)); do
    line="$(first_heading_line "$path" "${patterns[i]}")"
    if [[ -z "$line" ]]; then
      fail "missing heading '${labels[i]}'"
      heading_lines+=("")
      missing=1
    else
      heading_lines+=("$line")
    fi
  done

  if (( !missing )); then
    for ((i=0; i<${#heading_lines[@]}-1; i++)); do
      if (( heading_lines[i] >= heading_lines[i+1] )); then
        fail "headings out of order: '${labels[i]}' should appear before '${labels[i+1]}'"
        break
      fi
    done
  fi
}

check_dp_id_heading() {
  local path="$1"
  if ! grep -nE '^#{1,6}[[:space:]]*DP-[A-Z]+-[0-9]{4,}([_-]v[0-9]+)?(:[[:space:]].+)?$' "$path" >/dev/null \
    && ! grep -nE '^#{1,6}[[:space:]]*DP-XXXX\b' "$path" >/dev/null; then
    fail "missing DP id heading (expected 'DP-<AREA>-<####>' or template marker 'DP-XXXX')"
  fi
}

check_required_fields() {
  local path="$1"
  local template_mode="$2"

  local base_branch
  local work_branch
  local base_head_raw
  local base_head

  check_required_field "Base Branch" "$path" || true
  check_required_field "Required Work Branch" "$path" || true
  check_required_field "Base HEAD" "$path" || true

  base_branch="$(field_value "Base Branch" "$path")"
  work_branch="$(field_value "Required Work Branch" "$path")"
  base_head_raw="$(field_value "Base HEAD" "$path")"

  base_branch="$(trim "$(strip_backticks "$base_branch")")"
  work_branch="$(trim "$(strip_backticks "$work_branch")")"
  base_head_raw="$(trim "$(strip_backticks "$base_head_raw")")"

  if (( template_mode )); then
    return
  fi

  if contains_placeholder "$base_branch"; then
    fail "placeholder value for 'Base Branch'"
  fi
  if contains_placeholder "$work_branch"; then
    fail "placeholder value for 'Required Work Branch'"
  fi
  if contains_placeholder "$base_head_raw"; then
    fail "placeholder value for 'Base HEAD'"
  fi

  base_head="$(extract_hash "$base_head_raw")"
  if [[ -z "$base_head" ]]; then
    fail "missing or invalid Base HEAD hash"
  fi
  if [[ "$base_head" == "0000000" ]]; then
    fail "placeholder value for 'Base HEAD'"
  fi
}

check_preflight_gate() {
  local path="$1"
  local preflight_block

  preflight_block="$(extract_block "$path" '^#{2,6}[[:space:]]*3[.]1[.]1' '^#{2,6}[[:space:]]*3[.]2')"
  if [[ -z "$preflight_block" ]]; then
    fail "missing DP Preflight Gate block"
    return
  fi

  local -a required_lines=(
    "bash tools/lint/dp.sh --test"
    "bash tools/lint/dp.sh TASK.md"
    "bash tools/lint/task.sh"
  )

  local req
  for req in "${required_lines[@]}"; do
    if ! grep -Fq -- "$req" <<< "$preflight_block"; then
      fail "DP Preflight Gate missing command: ${req}"
    fi
  done
}

check_canon_load_order() {
  local path="$1"
  local canon_block

  canon_block="$(extract_block "$path" '^#{3,6}[[:space:]]*3[.]2[.]1' '^#{3,6}[[:space:]]*3[.]2[.]2|^#{2,6}[[:space:]]*3[.]3')"
  if [[ -z "$canon_block" ]]; then
    fail "missing Canon load order block (3.2.1)"
    return
  fi

  local -a expected=(
    "1. PoT.md"
    "2. SoP.md"
    "3. TASK.md"
    "4. docs/MAP.md"
    "5. docs/MANUAL.md"
    "6. ops/lib/manifests/CONTEXT.md"
  )

  local item
  for item in "${expected[@]}"; do
    if ! grep -Fxq -- "$item" <<< "$canon_block"; then
      fail "canon load order missing '${item}'"
    fi
  done

  local count
  count="$(grep -cE '^[[:space:]]*[0-9]+\.[[:space:]]' <<< "$canon_block" || true)"
  if [[ "$count" != "6" ]]; then
    fail "canon load order must contain exactly six numbered items"
  fi
}

check_context_load_llms_rules() {
  local path="$1"
  local context_block
  local core_line

  context_block="$(extract_block "$path" '^#{2,6}[[:space:]]*3[.]2' '^#{2,6}[[:space:]]*3[.]3')"
  if [[ -z "$context_block" ]]; then
    fail "missing context load block (3.2)"
    return
  fi

  if grep -Eq '(^|[^[:alnum:]_-])llms-full[.]txt([^[:alnum:]_-]|$)' <<< "$context_block"; then
    fail "context load must not reference llms-full.txt"
  fi

  while IFS= read -r core_line; do
    core_line="$(trim "$core_line")"
    if [[ -z "$core_line" ]]; then
      continue
    fi
    if ! grep -Eiq '(explicit|lightweight|alignment)' <<< "$core_line"; then
      fail "llms-core.txt is allowed only when explicitly marked as lightweight alignment usage"
    fi
  done < <(grep -Ei '(^|[^[:alnum:]_-])llms-core[.]txt([^[:alnum:]_-]|$)' <<< "$context_block" || true)
}

extract_allowlist_entries() {
  local path="$1"
  awk '
    BEGIN { in_allow=0 }
    {
      if (!in_allow && $0 ~ /Target Files allowlist \(hard gate\):/) {
        in_allow=1
        next
      }
      if (in_allow) {
        if ($0 ~ /^[[:space:]]*llms allowlist rule:/) { exit }
        if ($0 ~ /^#{1,6}[[:space:]]/) { exit }
        if ($0 ~ /^[[:space:]]*$/) { next }
        if ($0 ~ /^[[:space:]]*[-*][[:space:]]+/) {
          line=$0
          sub(/^[[:space:]]*[-*][[:space:]]+/, "", line)
          sub(/[[:space:]]+#.*/, "", line)
          sub(/[[:space:]]+[(].*/, "", line)
          print line
        }
      }
    }
  ' "$path"
}

allowlist_contains() {
  local needle="$1"
  local listed

  for listed in "${normalized_allowlist[@]}"; do
    listed="$(trim "$(strip_backticks "$listed")")"
    if [[ "$listed" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

check_allowlist() {
  local path="$1"
  local template_mode="$2"
  mapfile -t normalized_allowlist < <(extract_allowlist_entries "$path")

  if (( ${#normalized_allowlist[@]} == 0 )); then
    fail "Target Files allowlist missing or empty"
    return
  fi

  local concrete=0
  local entry
  for entry in "${normalized_allowlist[@]}"; do
    entry="$(trim "$entry")"
    entry="$(strip_backticks "$entry")"
    if [[ -z "$entry" ]]; then
      fail "Target Files allowlist has empty entry"
      continue
    fi

    if contains_placeholder "$entry"; then
      continue
    fi

    concrete=$((concrete + 1))
  done

  if (( concrete == 0 )); then
    if (( !template_mode )); then
      fail "Target Files allowlist must contain at least one concrete path"
    fi
  fi

  if (( template_mode )); then
    return
  fi

  if has_llms_invocation "$path"; then
    if ! allowlist_contains "ops/bin/llms" && ! allowlist_contains "./ops/bin/llms"; then
      echo "WARN: llms invocation detected but allowlist does not include ops/bin/llms" >&2
    fi
  fi
}

check_receipt_contract() {
  local path="$1"
  local receipt_block

  receipt_block="$(extract_block "$path" '^#{3,6}[[:space:]]*3[.]4[.]5' '^#{1,6}[[:space:]]*3[.]5([.]|[[:space:]])')"
  if [[ -z "$receipt_block" ]]; then
    fail "missing receipt block (3.4.5)"
    return
  fi

  if ! grep -Eq '\./ops/bin/open[[:space:]]+--out=auto[[:space:]]+--dp=' <<< "$receipt_block"; then
    fail "receipt block missing executable OPEN command"
  fi
  if ! grep -Eq '\./ops/bin/dump[[:space:]]+--scope=platform[[:space:]]+--format=chatgpt[[:space:]]+--out=auto[[:space:]]+--bundle' <<< "$receipt_block"; then
    fail "receipt block missing executable DUMP command"
  fi
  if ! grep -Fq 'test -s' <<< "$receipt_block"; then
    fail "receipt block missing non-empty dump payload check (test -s ...)"
  fi

  local -a gate_commands=(
    "bash tools/lint/context.sh"
    "bash tools/lint/style.sh"
    "bash tools/lint/truth.sh"
    "bash tools/lint/dp.sh --test"
    "bash tools/lint/dp.sh TASK.md"
    "bash tools/lint/task.sh"
    "bash tools/lint/llms.sh"
    "./tools/verify.sh"
  )

  local cmd
  for cmd in "${gate_commands[@]}"; do
    if ! grep -Fq "$cmd" <<< "$receipt_block"; then
      fail "receipt block missing verification command: ${cmd}"
    fi
  done

  if ! grep -Fq 'git diff --name-only' <<< "$receipt_block"; then
    fail "receipt block missing git diff --name-only proof"
  fi
  if ! grep -Fq 'git diff --stat' <<< "$receipt_block"; then
    fail "receipt block missing git diff --stat proof"
  fi
  if ! grep -Fq 'Verify Section 3.5 Closing Block is populated in RESULTS' <<< "$receipt_block"; then
    fail "receipt block missing Section 3.5 Closing Block verification line"
  fi

  if ! grep -Eiq 'required pasted outputs|paste outputs' <<< "$receipt_block"; then
    fail "receipt block missing required pasted outputs clause"
  fi
  if ! grep -Fq 'Mandatory Closing Block required in RESULTS' <<< "$receipt_block" \
    && ! grep -Fq 'Mandatory Closing Block' <<< "$receipt_block"; then
    fail "receipt block missing Mandatory Closing Block requirement"
  fi
}

check_disposable_input_hazards() {
  local path="$1"
  local issue

  if issue="$(awk '
    BEGIN { IGNORECASE=1 }
    {
      line=tolower($0)
      if (line ~ /storage\/_scratch\// || line ~ /storage\/tmp\// || line ~ /chat log/ || line ~ /conversation dump/ || line ~ /throwaway notes/ || line ~ /scratch draft/) {
        if (line ~ /do not/ || line ~ /must not/ || line ~ /not required/ || line ~ /forbidden/) {
          next
        }
        print $0
        exit 1
      }
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
        if (line ~ /do not/ || line ~ /must not/ || line ~ /does not/ || line ~ /not required/) {
          next
        }
        print $0
        exit 1
      }
    }
  ' "$path")"; then
    :
  else
    fail "DP requests OPEN/DUMP as attachments instead of receipt pointers: ${issue}"
  fi

  if issue="$(awk '
    BEGIN { IGNORECASE=1 }
    {
      line=tolower($0)
      if (line ~ /begin[[:space:]]+open|end[[:space:]]+open|begin[[:space:]]+dump|end[[:space:]]+dump|pasted[[:space:]]+bundle|raw[[:space:]]+open[[:space:]]+payload|raw[[:space:]]+dump[[:space:]]+payload/) {
        if (line ~ /do not/ || line ~ /must not/ || line ~ /does not/ || line ~ /not required/) {
          next
        }
        print $0
        exit 1
      }
    }
  ' "$path")"; then
    :
  else
    fail "DP embeds OPEN/DUMP payload markers instead of pointer references: ${issue}"
  fi
}

lint_results_path() {
  local path="$1"
  failures=0

  local closing_tmp
  closing_tmp="$(mktemp)"
  extract_results_closing_block "$path" > "$closing_tmp"

  if [[ ! -s "$closing_tmp" ]]; then
    rm -f "$closing_tmp"
    fail "RESULTS file missing Mandatory Closing Block"
    return 1
  fi

  local -a required_label_patterns=(
    '^Primary Commit Header [(]plaintext[)][[:space:]]*$'
    '^Pull Request Title [(]plaintext[)][[:space:]]*$'
    '^Pull Request Description [(]markdown[)][[:space:]]*$'
    '^Final Squash Stub [(]plaintext[)]( [(]Must differ from #1[)]| [(]must differ from Primary Commit Header[)])?[[:space:]]*$'
    '^Extended Technical Manifest [(]plaintext[)][[:space:]]*$'
    '^Review Conversation Starter [(]markdown[)][[:space:]]*$'
  )

  local pattern
  for pattern in "${required_label_patterns[@]}"; do
    if ! grep -Eq "$pattern" "$closing_tmp"; then
      fail "RESULTS missing required Mandatory Closing Block label matching pattern: ${pattern}"
    fi
  done

  local primary_header
  local pr_title
  local final_stub
  local extended_manifest
  local pr_description
  local review_starter

  primary_header="$(extract_results_field_block "$closing_tmp" '^Primary Commit Header [(]plaintext[)][[:space:]]*$')"
  pr_title="$(extract_results_field_block "$closing_tmp" '^Pull Request Title [(]plaintext[)][[:space:]]*$')"
  final_stub="$(extract_results_field_block "$closing_tmp" '^Final Squash Stub [(]plaintext[)]( [(]Must differ from #1[)]| [(]must differ from Primary Commit Header[)])?[[:space:]]*$')"
  extended_manifest="$(extract_results_field_block "$closing_tmp" '^Extended Technical Manifest [(]plaintext[)][[:space:]]*$')"
  pr_description="$(extract_results_field_block "$closing_tmp" '^Pull Request Description [(]markdown[)][[:space:]]*$')"
  review_starter="$(extract_results_field_block "$closing_tmp" '^Review Conversation Starter [(]markdown[)][[:space:]]*$')"

  local -a strict_labels=(
    "Primary Commit Header (plaintext)"
    "Pull Request Title (plaintext)"
    "Final Squash Stub (plaintext)"
    "Extended Technical Manifest (plaintext)"
  )
  local -a strict_values=(
    "$primary_header"
    "$pr_title"
    "$final_stub"
    "$extended_manifest"
  )

  local i
  for ((i=0; i<${#strict_labels[@]}; i++)); do
    if ! field_block_nonempty "${strict_values[i]}"; then
      fail "RESULTS strict field empty: ${strict_labels[i]}"
      continue
    fi
    if grep -Eq '\*|`|\[|\]' <<< "${strict_values[i]}"; then
      fail "RESULTS strict field contains forbidden markdown tokens (* \` [ ]): ${strict_labels[i]}"
    fi
  done

  if ! field_block_nonempty "$pr_description"; then
    fail "RESULTS permissive field empty: Pull Request Description (markdown)"
  fi
  if ! field_block_nonempty "$review_starter"; then
    fail "RESULTS permissive field empty: Review Conversation Starter (markdown)"
  fi

  if grep -Eiq 'ENTER[[:space:]_-]*DESCRIPTION[[:space:]_-]*HERE|PLACEHOLDER' <<< "$pr_description"; then
    fail "RESULTS permissive field contains placeholder text: Pull Request Description (markdown)"
  fi
  if grep -Eiq 'ENTER[[:space:]_-]*DESCRIPTION[[:space:]_-]*HERE|PLACEHOLDER' <<< "$review_starter"; then
    fail "RESULTS permissive field contains placeholder text: Review Conversation Starter (markdown)"
  fi

  local primary_first
  local final_first
  primary_first="$(printf '%s\n' "$primary_header" | sed -n '/[^[:space:]]/ { s/^[[:space:]]*//; s/[[:space:]]*$//; p; q; }')"
  final_first="$(printf '%s\n' "$final_stub" | sed -n '/[^[:space:]]/ { s/^[[:space:]]*//; s/[[:space:]]*$//; p; q; }')"
  if [[ -n "$primary_first" && -n "$final_first" && "$primary_first" == "$final_first" ]]; then
    fail "RESULTS Final Squash Stub must differ from Primary Commit Header"
  fi

  rm -f "$closing_tmp"

  if (( failures )); then
    return 1
  fi

  echo "OK: DP RESULTS lint passed"
}

lint_payload() {
  local path="$1"
  failures=0

  if has_standalone_ellipsis "$path"; then
    fail "placeholder token found: ..."
  fi

  check_dp_id_heading "$path"
  check_heading_order "$path"

  local template_mode=0
  if payload_is_template "$path"; then
    template_mode=1
  fi

  check_required_fields "$path" "$template_mode"
  check_preflight_gate "$path"
  check_canon_load_order "$path"
  check_context_load_llms_rules "$path"
  check_allowlist "$path" "$template_mode"
  check_receipt_contract "$path"
  check_disposable_input_hazards "$path"

  if (( failures )); then
    return 1
  fi

  echo "OK: DP lint passed"
}

lint_path() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    fail "Missing file: $path"
    return 1
  fi

  if [[ "$path" == *-RESULTS.md ]]; then
    lint_results_path "$path"
    return $?
  fi

  local payload_tmp
  payload_tmp="$(mktemp)"

  if ! extract_dp_payload "$path" "$payload_tmp"; then
    rm -f "$payload_tmp"
    return 1
  fi

  if ! lint_payload "$payload_tmp"; then
    rm -f "$payload_tmp"
    return 1
  fi

  rm -f "$payload_tmp"
}

run_test() {
  local tmp_valid
  local tmp_invalid_placeholder
  local tmp_missing_preflight
  local tmp_disposable
  local tmp_llms_full_context
  local tmp_llms_core_lightweight
  local tmp_llms_core_nonexplicit
  local tmp_task_wrapper
  local tmp_task_invalid
  local tmp_results_valid
  local tmp_results_invalid_strict
  local tmp_results_invalid_permissive

  tmp_valid="$(mktemp)"
  cat <<'TESTDP' > "$tmp_valid"
# DP-OPS-0001: DP Lint Test
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0001-lint
Base HEAD: fdc5d080

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

## 3.2 Required Context Load (Read Before Doing Anything)

### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md

### 3.2.2 DP-scoped load order (per DP)
- tools/lint/task.sh
- tools/lint/dp.sh

## 3.3 Scope and Safety
Objective: Validate DP lint behavior.
In scope: DP lint only.
Out of scope: TASK surface container rules.
Safety and invariants: Keep lint deterministic.

Target Files allowlist (hard gate):
- tools/lint/dp.sh

## 3.4 Execution Plan (A-E)

### 3.4.1 State
State text.

### 3.4.2 Request
Request text.

### 3.4.3 Changelog
Changelog text.

### 3.4.4 Patch / Diff
Patch text.

### 3.4.5 Receipt (Proofs to collect) — MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0001"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- Zero-byte check: test -s <dump_payload_path>
- bash tools/lint/context.sh
- bash tools/lint/style.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/llms.sh
- ./tools/verify.sh
- git diff --name-only
- git diff --stat
- Verify Section 3.5 Closing Block is populated in RESULTS.
- Required pasted outputs: receipts, verification outcomes, and diff output.
- Mandatory Closing Block required in RESULTS.
TESTDP

  lint_path "$tmp_valid" >/dev/null

  tmp_invalid_placeholder="$(mktemp)"
  cat <<'TESTDP' > "$tmp_invalid_placeholder"
# DP-OPS-0002: Placeholder Detection
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0002-lint
Base HEAD: 0000000

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

## 3.2 Required Context Load (Read Before Doing Anything)

### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md

### 3.2.2 DP-scoped load order (per DP)
- tools/lint/task.sh
- tools/lint/dp.sh

## 3.3 Scope and Safety
Objective: Validate placeholder failure.
In scope: DP lint only.
Out of scope: none.
Safety and invariants: none.

Target Files allowlist (hard gate):
- Populate during execution; do not pre-fill in TASK.md.

## 3.4 Execution Plan (A-E)
### 3.4.1 State
State.
### 3.4.2 Request
Request.
### 3.4.3 Changelog
Changelog.
### 3.4.4 Patch / Diff
Patch.
### 3.4.5 Receipt (Proofs to collect) — MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0002"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- Zero-byte check: test -s <dump_payload_path>
- bash tools/lint/context.sh
- bash tools/lint/style.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/llms.sh
- ./tools/verify.sh
- git diff --name-only
- git diff --stat
- Verify Section 3.5 Closing Block is populated in RESULTS.
- Required pasted outputs: receipts, verification outcomes, and diff output.
- Mandatory Closing Block required in RESULTS.
TESTDP

  if lint_path "$tmp_invalid_placeholder" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid_placeholder" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_llms_full_context" "$tmp_llms_core_lightweight" "$tmp_llms_core_nonexplicit" "$tmp_results_valid" "$tmp_results_invalid_strict" "$tmp_results_invalid_permissive" "$tmp_task_wrapper" "$tmp_task_invalid"
    echo "FAIL: --test expected placeholder detection to fail" >&2
    exit 1
  fi

  tmp_missing_preflight="$(mktemp)"
  cat <<'TESTDP' > "$tmp_missing_preflight"
# DP-OPS-0003: Preflight Missing
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0003-lint
Base HEAD: fdc5d080

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/task.sh

## 3.2 Required Context Load (Read Before Doing Anything)

### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md

### 3.2.2 DP-scoped load order (per DP)
- tools/lint/task.sh
- tools/lint/dp.sh

## 3.3 Scope and Safety
Objective: Validate preflight checks.
In scope: DP lint only.
Out of scope: none.
Safety and invariants: none.

Target Files allowlist (hard gate):
- tools/lint/dp.sh

## 3.4 Execution Plan (A-E)
### 3.4.1 State
State.
### 3.4.2 Request
Request.
### 3.4.3 Changelog
Changelog.
### 3.4.4 Patch / Diff
Patch.
### 3.4.5 Receipt (Proofs to collect) — MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0003"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- Zero-byte check: test -s <dump_payload_path>
- bash tools/lint/context.sh
- bash tools/lint/style.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/llms.sh
- ./tools/verify.sh
- git diff --name-only
- git diff --stat
- Verify Section 3.5 Closing Block is populated in RESULTS.
- Required pasted outputs: receipts, verification outcomes, and diff output.
- Mandatory Closing Block required in RESULTS.
TESTDP

  if lint_path "$tmp_missing_preflight" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid_placeholder" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_llms_full_context" "$tmp_llms_core_lightweight" "$tmp_llms_core_nonexplicit" "$tmp_results_valid" "$tmp_results_invalid_strict" "$tmp_results_invalid_permissive" "$tmp_task_wrapper" "$tmp_task_invalid"
    echo "FAIL: --test expected preflight command detection to fail" >&2
    exit 1
  fi

  tmp_disposable="$(mktemp)"
  cat <<'TESTDP' > "$tmp_disposable"
# DP-OPS-0004: Disposable Input
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0004-lint
Base HEAD: fdc5d080

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

## 3.2 Required Context Load (Read Before Doing Anything)

### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md

### 3.2.2 DP-scoped load order (per DP)
- tools/lint/task.sh
- tools/lint/dp.sh
- Required input: storage/_scratch/notes.md

## 3.3 Scope and Safety
Objective: Validate disposable hazard detection.
In scope: DP lint only.
Out of scope: none.
Safety and invariants: none.

Target Files allowlist (hard gate):
- tools/lint/dp.sh

## 3.4 Execution Plan (A-E)
### 3.4.1 State
State.
### 3.4.2 Request
Request.
### 3.4.3 Changelog
Changelog.
### 3.4.4 Patch / Diff
Patch.
### 3.4.5 Receipt (Proofs to collect) — MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0004"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- Zero-byte check: test -s <dump_payload_path>
- bash tools/lint/context.sh
- bash tools/lint/style.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/llms.sh
- ./tools/verify.sh
- git diff --name-only
- git diff --stat
- Verify Section 3.5 Closing Block is populated in RESULTS.
- Required pasted outputs: receipts, verification outcomes, and diff output.
- Mandatory Closing Block required in RESULTS.
TESTDP

  if lint_path "$tmp_disposable" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid_placeholder" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_llms_full_context" "$tmp_llms_core_lightweight" "$tmp_llms_core_nonexplicit" "$tmp_results_valid" "$tmp_results_invalid_strict" "$tmp_results_invalid_permissive" "$tmp_task_wrapper" "$tmp_task_invalid"
    echo "FAIL: --test expected disposable input detection to fail" >&2
    exit 1
  fi

  tmp_llms_full_context="$(mktemp)"
  cat <<'TESTDP' > "$tmp_llms_full_context"
# DP-OPS-0007: llms-full Context Ban
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0007-lint
Base HEAD: fdc5d080

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

## 3.2 Required Context Load (Read Before Doing Anything)

### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md

### 3.2.2 DP-scoped load order (per DP)
- tools/lint/task.sh
- tools/lint/dp.sh
- llms-full.txt

## 3.3 Scope and Safety
Objective: Validate llms-full context ban.
In scope: DP lint only.
Out of scope: none.
Safety and invariants: none.

Target Files allowlist (hard gate):
- tools/lint/dp.sh

## 3.4 Execution Plan (A-E)
### 3.4.1 State
State.
### 3.4.2 Request
Request.
### 3.4.3 Changelog
Changelog.
### 3.4.4 Patch / Diff
Patch.
### 3.4.5 Receipt (Proofs to collect) — MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0007"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- Zero-byte check: test -s <dump_payload_path>
- bash tools/lint/context.sh
- bash tools/lint/style.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/llms.sh
- ./tools/verify.sh
- git diff --name-only
- git diff --stat
- Verify Section 3.5 Closing Block is populated in RESULTS.
- Required pasted outputs: receipts, verification outcomes, and diff output.
- Mandatory Closing Block required in RESULTS.
TESTDP

  if lint_path "$tmp_llms_full_context" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid_placeholder" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_llms_full_context" "$tmp_llms_core_lightweight" "$tmp_llms_core_nonexplicit" "$tmp_results_valid" "$tmp_results_invalid_strict" "$tmp_results_invalid_permissive" "$tmp_task_wrapper" "$tmp_task_invalid"
    echo "FAIL: --test expected llms-full context detection to fail" >&2
    exit 1
  fi

  tmp_llms_core_lightweight="$(mktemp)"
  cat <<'TESTDP' > "$tmp_llms_core_lightweight"
# DP-OPS-0008: llms-core Lightweight
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0008-lint
Base HEAD: fdc5d080

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

## 3.2 Required Context Load (Read Before Doing Anything)

### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md

### 3.2.2 DP-scoped load order (per DP)
- tools/lint/task.sh
- tools/lint/dp.sh
- llms-core.txt (explicit lightweight alignment check)

## 3.3 Scope and Safety
Objective: Validate llms-core lightweight allowance.
In scope: DP lint only.
Out of scope: none.
Safety and invariants: none.

Target Files allowlist (hard gate):
- tools/lint/dp.sh

## 3.4 Execution Plan (A-E)
### 3.4.1 State
State.
### 3.4.2 Request
Request.
### 3.4.3 Changelog
Changelog.
### 3.4.4 Patch / Diff
Patch.
### 3.4.5 Receipt (Proofs to collect) — MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0008"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- Zero-byte check: test -s <dump_payload_path>
- bash tools/lint/context.sh
- bash tools/lint/style.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/llms.sh
- ./tools/verify.sh
- git diff --name-only
- git diff --stat
- Verify Section 3.5 Closing Block is populated in RESULTS.
- Required pasted outputs: receipts, verification outcomes, and diff output.
- Mandatory Closing Block required in RESULTS.
TESTDP

  lint_path "$tmp_llms_core_lightweight" >/dev/null

  tmp_llms_core_nonexplicit="$(mktemp)"
  cat <<'TESTDP' > "$tmp_llms_core_nonexplicit"
# DP-OPS-0009: llms-core Non-Explicit
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0009-lint
Base HEAD: fdc5d080

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

## 3.2 Required Context Load (Read Before Doing Anything)

### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md

### 3.2.2 DP-scoped load order (per DP)
- tools/lint/task.sh
- tools/lint/dp.sh
- llms-core.txt

## 3.3 Scope and Safety
Objective: Validate llms-core non-explicit failure.
In scope: DP lint only.
Out of scope: none.
Safety and invariants: none.

Target Files allowlist (hard gate):
- tools/lint/dp.sh

## 3.4 Execution Plan (A-E)
### 3.4.1 State
State.
### 3.4.2 Request
Request.
### 3.4.3 Changelog
Changelog.
### 3.4.4 Patch / Diff
Patch.
### 3.4.5 Receipt (Proofs to collect) — MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0009"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- Zero-byte check: test -s <dump_payload_path>
- bash tools/lint/context.sh
- bash tools/lint/style.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/llms.sh
- ./tools/verify.sh
- git diff --name-only
- git diff --stat
- Verify Section 3.5 Closing Block is populated in RESULTS.
- Required pasted outputs: receipts, verification outcomes, and diff output.
- Mandatory Closing Block required in RESULTS.
TESTDP

  if lint_path "$tmp_llms_core_nonexplicit" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid_placeholder" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_llms_full_context" "$tmp_llms_core_lightweight" "$tmp_llms_core_nonexplicit" "$tmp_results_valid" "$tmp_results_invalid_strict" "$tmp_results_invalid_permissive" "$tmp_task_wrapper" "$tmp_task_invalid"
    echo "FAIL: --test expected llms-core explicitness detection to fail" >&2
    exit 1
  fi

  tmp_results_valid="$(mktemp --suffix=-RESULTS.md)"
  cat <<'TESTRESULTS' > "$tmp_results_valid"
# DP-OPS-0099 RESULTS

## Mandatory Closing Block
Primary Commit Header (plaintext)
DP-OPS-0099 validate results lint path

Pull Request Title (plaintext)
DP-OPS-0099 Validate RESULTS lint path

Pull Request Description (markdown)
### Summary
- Added RESULTS mandatory closing block checks.

Final Squash Stub (plaintext) (Must differ from #1)
Validate RESULTS mandatory closing block rules

Extended Technical Manifest (plaintext)
tools/lint/dp.sh

Review Conversation Starter (markdown)
Does this validator enforce strict plaintext versus permissive markdown fields correctly?
TESTRESULTS

  lint_path "$tmp_results_valid" >/dev/null

  tmp_results_invalid_strict="$(mktemp --suffix=-RESULTS.md)"
  cat <<'TESTRESULTS' > "$tmp_results_invalid_strict"
# DP-OPS-0099 RESULTS

## Mandatory Closing Block
Primary Commit Header (plaintext)
*invalid markdown token*

Pull Request Title (plaintext)
DP-OPS-0099 Validate RESULTS lint path

Pull Request Description (markdown)
### Summary
- Added RESULTS mandatory closing block checks.

Final Squash Stub (plaintext) (Must differ from #1)
Validate RESULTS mandatory closing block rules

Extended Technical Manifest (plaintext)
tools/lint/dp.sh

Review Conversation Starter (markdown)
Does this validator enforce strict plaintext versus permissive markdown fields correctly?
TESTRESULTS

  if lint_path "$tmp_results_invalid_strict" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid_placeholder" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_llms_full_context" "$tmp_llms_core_lightweight" "$tmp_llms_core_nonexplicit" "$tmp_results_valid" "$tmp_results_invalid_strict"
    echo "FAIL: --test expected strict RESULTS field markdown token detection to fail" >&2
    exit 1
  fi

  tmp_results_invalid_permissive="$(mktemp --suffix=-RESULTS.md)"
  cat <<'TESTRESULTS' > "$tmp_results_invalid_permissive"
# DP-OPS-0099 RESULTS

## Mandatory Closing Block
Primary Commit Header (plaintext)
DP-OPS-0099 validate results lint path

Pull Request Title (plaintext)
DP-OPS-0099 Validate RESULTS lint path

Pull Request Description (markdown)
ENTER DESCRIPTION HERE

Final Squash Stub (plaintext) (Must differ from #1)
Validate RESULTS mandatory closing block rules

Extended Technical Manifest (plaintext)
tools/lint/dp.sh

Review Conversation Starter (markdown)
Does this validator enforce strict plaintext versus permissive markdown fields correctly?
TESTRESULTS

  if lint_path "$tmp_results_invalid_permissive" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid_placeholder" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_llms_full_context" "$tmp_llms_core_lightweight" "$tmp_llms_core_nonexplicit" "$tmp_results_valid" "$tmp_results_invalid_strict" "$tmp_results_invalid_permissive"
    echo "FAIL: --test expected permissive RESULTS placeholder detection to fail" >&2
    exit 1
  fi

  tmp_task_wrapper="$(mktemp)"
  cat <<'TESTTASK' > "$tmp_task_wrapper"
# STELA TASK DASHBOARD
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-12

## 1. Session State
Pointer: storage/handoff/OPEN-<branch>-<short-hash>.txt
Context Manifest: ops/lib/manifests/CONTEXT.md

## 2. Logic Pointers
Primary Constraint: PoT.md

## 3. Current Dispatch Packet (DP)
### DP-OPS-0005: TASK Extraction Check
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0005-lint
Base HEAD: fdc5d080

## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh

## 3.2 Required Context Load (Read Before Doing Anything)
### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md
### 3.2.2 DP-scoped load order (per DP)
- tools/lint/task.sh
- tools/lint/dp.sh

## 3.3 Scope and Safety
Objective: Validate TASK payload extraction.
In scope: DP lint.
Out of scope: TASK container lint.
Safety and invariants: deterministic checks.
Target Files allowlist (hard gate):
- tools/lint/dp.sh

## 3.4 Execution Plan (A-E)
### 3.4.1 State
State.
### 3.4.2 Request
Request.
### 3.4.3 Changelog
Changelog.
### 3.4.4 Patch / Diff
Patch.
### 3.4.5 Receipt (Proofs to collect) — MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0005"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- Zero-byte check: test -s <dump_payload_path>
- bash tools/lint/context.sh
- bash tools/lint/style.sh
- bash tools/lint/truth.sh
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
- bash tools/lint/llms.sh
- ./tools/verify.sh
- git diff --name-only
- git diff --stat
- Verify Section 3.5 Closing Block is populated in RESULTS.
- Required pasted outputs: receipts, verification outcomes, and diff output.
- Mandatory Closing Block required in RESULTS.

## 3.5 Closeout (Mandatory Routing)
- closeout text.
TESTTASK

  lint_path "$tmp_task_wrapper" >/dev/null

  tmp_task_invalid="$(mktemp)"
  cat <<'TESTTASK' > "$tmp_task_invalid"
# STELA TASK DASHBOARD
Status: ACTIVE
Owner: Integrator
Last Updated: 2026-02-12

## 3. Current Dispatch Packet (DP)
### DP-OPS-0006: TASK Extraction Invalid
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-0006-lint
Base HEAD: fdc5d080
## 3.1.1 DP Preflight Gate (Run Before Any Edits)
- bash tools/lint/dp.sh --test
- bash tools/lint/dp.sh TASK.md
- bash tools/lint/task.sh
## 3.2 Required Context Load (Read Before Doing Anything)
### 3.2.1 Canon load order (always)
1. PoT.md
2. SoP.md
3. TASK.md
4. docs/MAP.md
5. docs/MANUAL.md
6. ops/lib/manifests/CONTEXT.md
### 3.2.2 DP-scoped load order (per DP)
- tools/lint/task.sh
- tools/lint/dp.sh
## 3.3 Scope and Safety
Objective: Validate extraction failure.
In scope: DP lint.
Out of scope: TASK container lint.
Safety and invariants: deterministic checks.
Target Files allowlist (hard gate):
- tools/lint/dp.sh
## 3.4 Execution Plan (A-E)
### 3.4.1 State
State.
### 3.4.2 Request
Request.
### 3.4.3 Changelog
Changelog.
### 3.4.4 Patch / Diff
Patch.
### 3.4.5 Receipt (Proofs to collect) — MUST RUN
- ./ops/bin/open --out=auto --dp="DP-OPS-0006"
- ./ops/bin/dump --scope=platform --format=chatgpt --out=auto --bundle
- git diff --name-only
- git diff --stat
TESTTASK

  if lint_path "$tmp_task_invalid" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid_placeholder" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_llms_full_context" "$tmp_llms_core_lightweight" "$tmp_llms_core_nonexplicit" "$tmp_results_valid" "$tmp_results_invalid_strict" "$tmp_results_invalid_permissive" "$tmp_task_wrapper" "$tmp_task_invalid"
    echo "FAIL: --test expected receipt requirement detection to fail" >&2
    exit 1
  fi

  rm -f "$tmp_valid" "$tmp_invalid_placeholder" "$tmp_missing_preflight" "$tmp_disposable" "$tmp_llms_full_context" "$tmp_llms_core_lightweight" "$tmp_llms_core_nonexplicit" "$tmp_results_valid" "$tmp_results_invalid_strict" "$tmp_results_invalid_permissive" "$tmp_task_wrapper" "$tmp_task_invalid"
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
