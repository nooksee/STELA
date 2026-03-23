#!/usr/bin/env bash
set -euo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${REPO_ROOT}/ops/lib/scripts/common.sh"

cd "$REPO_ROOT"
trap 'emit_binary_leaf "lint-response" "finish"' EXIT
emit_binary_leaf "lint-response" "start"

usage() {
  cat <<'USAGE'
Usage: bash tools/lint/response.sh [--mode=dp|audit|architect|planning|foreman|conformist|execution-decision] [--test] [path|-]
Default input: stdin
Example: bash tools/lint/response.sh --mode=audit var/tmp/response-audit-valid.md
Mode matrix freeze: architect|planning|foreman|conformist remain explicit machine-ingest modes.
USAGE
}

failures=0
response_mode="dp"
response_skip_dp_delegate=0

response_fail() {
  echo "FAIL: $*" >&2
  failures=1
}

trim_inline() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

normalize_field_value() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

resolve_task_surface_source() {
  local source_path="TASK.md"
  local line_count
  local pointer_path

  line_count="$(awk 'END { print NR }' "$source_path")"
  if [[ "$line_count" != "1" ]]; then
    printf '%s' "$source_path"
    return 0
  fi

  pointer_path="$(trim_inline "$(cat "$source_path")")"
  pointer_path="${pointer_path#\`}"
  pointer_path="${pointer_path%\`}"
  pointer_path="${pointer_path#./}"
  if [[ "$pointer_path" == "${REPO_ROOT}/"* ]]; then
    pointer_path="${pointer_path#${REPO_ROOT}/}"
  fi

  if [[ -f "${REPO_ROOT}/${pointer_path}" ]]; then
    printf '%s' "${REPO_ROOT}/${pointer_path}"
    return 0
  fi

  printf '%s' "$source_path"
}

extract_active_dp_payload() {
  local out_path="$1"
  local source_path
  source_path="$(resolve_task_surface_source)"

  if grep -Eq '^##[[:space:]]*3[.][[:space:]]*Current Dispatch Packet \(DP\)' "$source_path"; then
    awk '
      BEGIN { in_section=0; in_block=0 }
      /^##[[:space:]]*3[.][[:space:]]*Current Dispatch Packet [(]DP[)][[:space:]]*$/ { in_section=1; next }
      in_section && /^##[[:space:]]*[0-9]+[.]/ && $0 !~ /^##[[:space:]]*3[.]/ { exit }
      in_section && /^### DP-/ { in_block=1 }
      in_block { print }
    ' "$source_path" > "$out_path"
    return 0
  fi

  cp "$source_path" "$out_path"
}

extract_single_fenced_block() {
  local input_path="$1"
  local body_path="$2"
  local in_block=0
  local open_count=0
  local close_count=0
  local line=""
  local trimmed=""

  : > "$body_path"

  while IFS= read -r line || [[ -n "$line" ]]; do
    if (( in_block == 0 )); then
      if [[ "$line" =~ ^\`\`\`[[:alnum:]_-]*[[:space:]]*$ ]]; then
        open_count=$(( open_count + 1 ))
        if (( open_count > 1 )); then
          response_fail "response envelope must contain exactly one fenced markdown code block"
        fi
        in_block=1
        continue
      fi

      trimmed="$(trim_inline "$line")"
      if [[ -n "$trimmed" ]]; then
        response_fail "non-whitespace text detected outside fenced code block: ${line}"
      fi
      continue
    fi

    if [[ "$line" =~ ^\`\`\`[[:space:]]*$ ]]; then
      close_count=$(( close_count + 1 ))
      in_block=0
      continue
    fi

    printf '%s\n' "$line" >> "$body_path"
  done < "$input_path"

  if (( in_block == 1 )); then
    response_fail "fenced markdown code block is not closed"
  fi

  if (( open_count != 1 || close_count != 1 )); then
    response_fail "response envelope must contain exactly one fenced markdown code block"
  fi
}

extract_audit_body() {
  local input_path="$1"
  local body_path="$2"
  extract_single_fenced_block "$input_path" "$body_path"
}

check_dp_body_start() {
  local body_path="$1"
  local first_content_line
  first_content_line="$(awk 'NF { print; exit }' "$body_path")"

  if [[ -z "$first_content_line" ]]; then
    response_fail "fenced markdown code block is empty"
    return 1
  fi

  if [[ ! "$first_content_line" =~ ^###[[:space:]]+DP- ]]; then
    response_fail "DP body must start with heading format '### DP-...'"
    return 1
  fi
}

check_audit_body_start() {
  local body_path="$1"
  local first_content_line
  first_content_line="$(awk 'NF { print; exit }' "$body_path")"

  if [[ -z "$first_content_line" ]]; then
    response_fail "audit body is empty"
    return 1
  fi

  if [[ ! "$first_content_line" =~ ^\*\*AUDIT[[:space:]]+[-—] ]]; then
    response_fail "audit body must start with marker '**AUDIT -'"
    return 1
  fi
}

check_architect_body_scope() {
  local body_path="$1"
  local hit=""
  local line_number=""
  local line_text=""

  hit="$(awk '
    $0 ~ /^\*\*AUDIT[[:space:]]+[-—]/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "architect body must not contain audit verdict marker at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+Contractor Execution Narrative$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "architect body must not contain contractor narrative section at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    $0 ~ /^###[[:space:]]+(Preflight State|Implemented Changes|Closeout Notes|Decision Leaf)$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "architect body must not contain receipt narrative subheading at line ${line_number}: ${line_text}"
  fi
}

check_planning_body_scope() {
  local body_path="$1"
  local first_content_line
  local hit=""
  local line_number=""
  local line_text=""
  local plan_lint_output=""
  local conversational_mode=0

  first_content_line="$(awk 'NF { print; exit }' "$body_path")"
  if [[ -z "$first_content_line" ]]; then
    response_fail "planning body is empty"
    return 1
  fi

  if [[ "$first_content_line" =~ ^1[.][[:space:]]+Analysis[[:space:]]+and[[:space:]]+Discussion$ ]]; then
    conversational_mode=1
  fi

  hit="$(awk '
    $0 ~ /^\*\*AUDIT[[:space:]]+[-—]/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "planning body must not contain audit verdict marker at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+Contractor Execution Narrative$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "planning body must not contain contractor narrative section at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    $0 ~ /^###[[:space:]]+(Preflight State|Implemented Changes|Closeout Notes|Decision Leaf)$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "planning body must not contain receipt narrative subheading at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    tolower($0) ~ /decision[[:space:]]+required:/ || tolower($0) ~ /decision[[:space:]]+leaf:/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "planning body must not contain audit/foreman decision fields at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    index(tolower($0), "section 3.4.5") || index(tolower($0), "receipt_extra") || index(tolower($0), "ops/src/surfaces/dp.md.tpl") || index(tolower($0), "emit exactly one fenced markdown code block") || index(tolower($0), "do not output option menus") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "planning body must not contain role-policy overcompensation prose at line ${line_number}: ${line_text}"
  fi

  if (( conversational_mode )); then
    if ! grep -Eq '^Questions / Conversation:[[:space:]]*$' "$body_path"; then
      response_fail "conversational planning body must include 'Questions / Conversation:'"
      return 1
    fi
    local q_count
    q_count="$(grep -cE '^Q[0-9][.][[:space:]]' "$body_path" || true)"
    if (( q_count > 3 )); then
      response_fail "planning conversational body must contain at most 3 questions"
      return 1
    fi
    if (( q_count > 0 )); then
      local q_num
      for q_num in 1 2 3; do
        if ! grep -qE "^Q${q_num}[.][[:space:]]" "$body_path"; then
          continue
        fi
        local opt_count rec_count
        opt_count="$(awk -v q="$q_num" '
          $0 ~ "^Q" q "[.][[:space:]]" { f=1; next }
          f && /^Q[0-9][.][[:space:]]/ { exit }
          f && /^Questions / { exit }
          f && /^- [ABC][.][[:space:]]/ { c++ }
          END { print c+0 }
        ' "$body_path")"
        if [[ "$opt_count" != "3" ]]; then
          response_fail "each planning question must have exactly 3 options (Q${q_num} has ${opt_count})"
          return 1
        fi
        rec_count="$(awk -v q="$q_num" '
          $0 ~ "^Q" q "[.][[:space:]]" { f=1; next }
          f && /^Q[0-9][.][[:space:]]/ { exit }
          f && /^Questions / { exit }
          f && /\(Recommended\)/ { c++ }
          END { print c+0 }
        ' "$body_path")"
        if [[ "$rec_count" != "1" ]]; then
          response_fail "each planning question must have exactly one (Recommended) option (Q${q_num} has ${rec_count})"
          return 1
        fi
      done
    fi
    return 0
  fi

  if ! plan_lint_output="$(bash tools/lint/plan.sh "$body_path" 2>&1)"; then
    response_fail "planning body must be either conversational planning or a valid final PLAN: $(printf '%s\n' "$plan_lint_output" | tail -n 1)"
    return 1
  fi
}

check_foreman_body_scope() {
  local body_path="$1"
  local first_content_line
  local hit=""
  local line_number=""
  local line_text=""
  local decision_required_line=""
  local decision_leaf_line=""
  local decision_required_value=""
  local decision_leaf_value=""

  first_content_line="$(awk 'NF { print; exit }' "$body_path")"
  if [[ -z "$first_content_line" ]]; then
    response_fail "foreman body is empty"
    return 1
  fi

  if [[ ! "$first_content_line" =~ ^###[[:space:]]+Addendum ]]; then
    response_fail "foreman body must start with heading format '### Addendum...'"
    return 1
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+A[.]1[[:space:]]+Authorization$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -z "$hit" ]]; then
    response_fail "foreman body must include section '## A.1 Authorization'"
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+A[.]2[[:space:]]+Scope[[:space:]]+Delta$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -z "$hit" ]]; then
    response_fail "foreman body must include section '## A.2 Scope Delta'"
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+A[.]3[[:space:]]+Addendum[[:space:]]+Objective$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -z "$hit" ]]; then
    response_fail "foreman body must include section '## A.3 Addendum Objective'"
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+A[.]4[[:space:]]+Context[[:space:]]+Load$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -z "$hit" ]]; then
    response_fail "foreman body must include section '## A.4 Context Load'"
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+A[.]5[[:space:]]+Addendum[[:space:]]+Receipt[[:space:]]+[(]Proofs[[:space:]]+to[[:space:]]+collect[)][[:space:]]+-[[:space:]]+MUST[[:space:]]+RUN$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -z "$hit" ]]; then
    response_fail "foreman body must include section '## A.5 Addendum Receipt (Proofs to collect) - MUST RUN'"
  fi

  hit="$(awk '
    $0 ~ /^\*\*AUDIT[[:space:]]+[-—]/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "foreman body must not contain audit verdict marker at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+Contractor Execution Narrative$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "foreman body must not contain contractor narrative section at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+Verdict$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "foreman body must not contain audit verdict section at line ${line_number}: ${line_text}"
  fi

  decision_required_line="$(grep -E '^Decision Required:' "$body_path" | head -n 1 || true)"
  decision_leaf_line="$(grep -E '^Decision Leaf:' "$body_path" | head -n 1 || true)"
  if [[ -n "$decision_required_line" || -n "$decision_leaf_line" ]]; then
    if [[ -z "$decision_required_line" || -z "$decision_leaf_line" ]]; then
      response_fail "foreman body decision fields must include both 'Decision Required:' and 'Decision Leaf:'"
      return 1
    fi

    decision_required_value="$(normalize_field_value "${decision_required_line#Decision Required:}")"
    decision_leaf_value="$(normalize_field_value "${decision_leaf_line#Decision Leaf:}")"
    case "$decision_required_value" in
      Yes)
        if [[ ! "$decision_leaf_value" =~ ^archives/decisions/RoR-[^[:space:]]+\.md$ ]]; then
          response_fail "foreman decision coherence failed: Decision Required='Yes' requires Decision Leaf='archives/decisions/RoR-*.md'"
          return 1
        fi
        ;;
      No)
        if [[ "$decision_leaf_value" != "None" ]]; then
          response_fail "foreman decision coherence failed: Decision Required='No' requires Decision Leaf='None'"
          return 1
        fi
        ;;
      *)
        response_fail "foreman decision coherence failed: Decision Required must be exactly 'Yes' or 'No'"
        return 1
        ;;
    esac
  fi
}


check_conformist_body_scope() {
  local body_path="$1"
  local first_content_line
  local hit=""
  local line_number=""
  local line_text=""

  first_content_line="$(awk 'NF { print; exit }' "$body_path")"
  if [[ -z "$first_content_line" ]]; then
    response_fail "conformist body is empty"
    return 1
  fi

  if [[ ! "$first_content_line" =~ ^###[[:space:]]+DP- ]]; then
    response_fail "conformist body must start with heading format '### DP-...'"
    return 1
  fi

  hit="$(awk '
    $0 ~ /^\*\*AUDIT[[:space:]]+[-—]/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "conformist body must not contain audit verdict marker at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    $0 ~ /^##[[:space:]]+Contractor Execution Narrative$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "conformist body must not contain contractor narrative section at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    $0 ~ /^###[[:space:]]+(Preflight State|Implemented Changes|Closeout Notes|Decision Leaf)$/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "conformist body must not contain receipt narrative subheading at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    $0 ~ /^###[[:space:]]+Addendum/ || $0 ~ /^##[[:space:]]+A[.][1-5][[:space:]]/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "conformist body must not contain addendum authorization sections at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    tolower($0) ~ /decision[[:space:]]+required:/ || tolower($0) ~ /decision[[:space:]]+leaf:/ { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "conformist body must not contain decision fields at line ${line_number}: ${line_text}"
  fi
}

check_drift_tokens() {
  local body_path="$1"
  local hit=""
  local line_number=""
  local line_text=""

  hit="$(awk '
    index($0, ":contentReference[") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "forbidden token ':contentReference[' at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    index($0, "oaicite") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "forbidden token 'oaicite' at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    index($0, "Show more") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "forbidden token 'Show more' at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    index(tolower($0), "[cite_start]") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "forbidden token '[cite_start]' at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    index(tolower($0), "[cite:") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "forbidden token '[cite:' at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    index(tolower($0), "[/cite]") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "forbidden token '[/cite]' at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    index(tolower($0), "user prompt is empty") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "forbidden meta-chatter token 'user prompt is empty' at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    index(tolower($0), "reading documents") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "forbidden meta-chatter token 'reading documents' at line ${line_number}: ${line_text}"
  fi

  hit="$(awk '
    index(tolower($0), "running command") { printf "%d\t%s\n", NR, $0; exit }
  ' "$body_path")"
  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    response_fail "forbidden meta-chatter token 'running command' at line ${line_number}: ${line_text}"
  fi
}

check_execution_decision_schema() {
  local body_path="$1"
  local required_constraint_labels=(
    "Active task constraints used:"
    "Observable evidence used:"
    "Evidence gaps or unknowns:"
    "Confidence level:"
  )
  local required_step_labels=(
    "Trigger:"
    "Decision:"
    "Rationale:"
    "Tools considered or used:"
    "Actions taken:"
    "Actions not taken:"
    "Key evidence:"
  )
  local label complete_block_found in_block block_text ok line
  for label in "${required_constraint_labels[@]}"; do
    if ! grep -qE "^${label}" "$body_path"; then
      response_fail "execution-decision body missing required constraint label at line start: ${label}"
    fi
  done
  for label in "${required_step_labels[@]}"; do
    if ! grep -qE "^${label}" "$body_path"; then
      response_fail "execution-decision body missing required step label at line start: ${label}"
    fi
  done
  # Verify at least one complete step block: all seven step labels must appear
  # within the same Trigger-to-Trigger (or Trigger-to-end) region. Split-block
  # distributions — where labels are spread across multiple incomplete blocks so
  # each individual block is missing one or more labels — are rejected.
  complete_block_found=0
  in_block=0
  block_text=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == *"Trigger:"* ]]; then
      if (( in_block )); then
        ok=1
        for label in "${required_step_labels[@]:1}"; do
          if ! grep -qE "^${label}" <<< "$block_text"; then ok=0; break; fi
        done
        if (( ok )); then complete_block_found=1; break; fi
      fi
      in_block=1
      block_text="$line"$'\n'
    elif (( in_block )); then
      block_text+="$line"$'\n'
    fi
  done < "$body_path"
  if (( in_block && ! complete_block_found )); then
    ok=1
    for label in "${required_step_labels[@]:1}"; do
      if [[ "$block_text" != *"$label"* ]]; then ok=0; break; fi
    done
    if (( ok )); then complete_block_found=1; fi
  fi
  if (( ! complete_block_found )); then
    response_fail "execution-decision body has no complete step block — all seven step labels must appear together within a single Trigger-to-Trigger (or Trigger-to-end) block"
  fi
  return 0
}

lint_response_file() {
  local input_path="$1"
  local body_tmp
  mkdir -p "${REPO_ROOT}/var/tmp"
  body_tmp="$(mktemp "${REPO_ROOT}/var/tmp/lint-response-body.XXXXXX")"
  failures=0

  if [[ ! -f "$input_path" ]]; then
    response_fail "response file not found: $input_path"
    rm -f "$body_tmp"
    return 1
  fi

  if [[ "$response_mode" == "dp" ]]; then
    extract_single_fenced_block "$input_path" "$body_tmp"
    check_dp_body_start "$body_tmp"
  elif [[ "$response_mode" == "architect" ]]; then
    extract_single_fenced_block "$input_path" "$body_tmp"
    check_dp_body_start "$body_tmp"
    check_architect_body_scope "$body_tmp"
  elif [[ "$response_mode" == "planning" ]]; then
    extract_single_fenced_block "$input_path" "$body_tmp"
    check_planning_body_scope "$body_tmp"
  elif [[ "$response_mode" == "foreman" ]]; then
    extract_single_fenced_block "$input_path" "$body_tmp"
    check_foreman_body_scope "$body_tmp"
  elif [[ "$response_mode" == "conformist" ]]; then
    extract_single_fenced_block "$input_path" "$body_tmp"
    check_conformist_body_scope "$body_tmp"
  elif [[ "$response_mode" == "audit" ]]; then
    extract_single_fenced_block "$input_path" "$body_tmp"
    check_audit_body_start "$body_tmp"
  elif [[ "$response_mode" == "execution-decision" ]]; then
    extract_single_fenced_block "$input_path" "$body_tmp"
    check_execution_decision_schema "$body_tmp"
  else
    response_fail "unsupported lint mode: ${response_mode}"
  fi
  check_drift_tokens "$body_tmp"

  if (( failures )); then
    rm -f "$body_tmp"
    return 1
  fi

  if [[ ( "$response_mode" == "dp" || "$response_mode" == "architect" || "$response_mode" == "conformist" ) && "$response_skip_dp_delegate" != "1" ]]; then
    if ! bash tools/lint/dp.sh "$body_tmp"; then
      rm -f "$body_tmp"
      return 1
    fi
  fi

  rm -f "$body_tmp"
  echo "OK: response lint passed (mode=${response_mode})"
}

run_test() {
  local test_dir
  local response_valid
  local response_outside
  local response_multiple
  local response_token
  local response_not_dp
  local response_trailing
  local response_audit_valid
  local response_audit_plain
  local response_audit_preface
  local response_audit_not_marker
  local response_audit_meta
  local response_audit_cite
  local response_architect_valid
  local response_architect_audit_marker
  local response_architect_narrative
  local response_planning_valid
  local response_planning_conversation_valid
  local response_planning_audit_marker
  local response_planning_narrative
  local response_planning_policy
  local response_planning_missing_plan
  local response_planning_structured_valid
  local response_planning_few_options
  local response_planning_no_recommended
  local response_planning_too_many_questions
  local response_foreman_valid
  local response_foreman_audit_marker
  local response_foreman_missing_sections
  local response_foreman_decision_incoherent
  local response_conformist_valid
  local response_conformist_audit_marker
  local response_conformist_addendum_marker
  local response_conformist_decision_fields
  local response_exec_decision_valid
  local response_exec_decision_missing_constraint
  local response_exec_decision_missing_step
  local response_exec_decision_split_block
  local response_exec_decision_label_in_prose
  local failures_local=0
  local saved_mode="$response_mode"

  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN

  response_valid="${test_dir}/response-valid.md"
  response_outside="${test_dir}/response-outside.md"
  response_multiple="${test_dir}/response-multiple.md"
  response_token="${test_dir}/response-token.md"
  response_not_dp="${test_dir}/response-not-dp.md"
  response_trailing="${test_dir}/response-trailing.md"
  response_audit_valid="${test_dir}/response-audit-valid.md"
  response_audit_plain="${test_dir}/response-audit-plain.md"
  response_audit_preface="${test_dir}/response-audit-preface.md"
  response_audit_not_marker="${test_dir}/response-audit-not-marker.md"
  response_audit_meta="${test_dir}/response-audit-meta.md"
  response_audit_cite="${test_dir}/response-audit-cite.md"
  response_architect_valid="${test_dir}/response-architect-valid.md"
  response_architect_audit_marker="${test_dir}/response-architect-audit-marker.md"
  response_architect_narrative="${test_dir}/response-architect-narrative.md"
  response_planning_valid="${test_dir}/response-planning-valid.md"
  response_planning_conversation_valid="${test_dir}/response-planning-conversation-valid.md"
  response_planning_audit_marker="${test_dir}/response-planning-audit-marker.md"
  response_planning_narrative="${test_dir}/response-planning-narrative.md"
  response_planning_policy="${test_dir}/response-planning-policy.md"
  response_planning_missing_plan="${test_dir}/response-planning-missing-plan.md"
  response_planning_structured_valid="${test_dir}/response-planning-structured-valid.md"
  response_planning_few_options="${test_dir}/response-planning-few-options.md"
  response_planning_no_recommended="${test_dir}/response-planning-no-recommended.md"
  response_planning_too_many_questions="${test_dir}/response-planning-too-many-questions.md"
  response_foreman_valid="${test_dir}/response-foreman-valid.md"
  response_foreman_audit_marker="${test_dir}/response-foreman-audit-marker.md"
  response_foreman_missing_sections="${test_dir}/response-foreman-missing-sections.md"
  response_foreman_decision_incoherent="${test_dir}/response-foreman-decision-incoherent.md"
  response_conformist_valid="${test_dir}/response-conformist-valid.md"
  response_conformist_audit_marker="${test_dir}/response-conformist-audit-marker.md"
  response_conformist_addendum_marker="${test_dir}/response-conformist-addendum-marker.md"
  response_conformist_decision_fields="${test_dir}/response-conformist-decision-fields.md"

  response_mode="dp"
  response_skip_dp_delegate=1

  cat > "$response_valid" <<'EOF_VALID'
```markdown
### DP-OPS-9999: Response Envelope Self-Test

## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-9999-response-envelope-self-test-2026-03-04
Base HEAD: 00000000
Freshness Stamp: 2026-03-04
```
EOF_VALID

  if ! lint_response_file "$response_valid" >/dev/null 2>&1; then
    echo "FAIL: --test expected valid single-block response to pass" >&2
    failures_local=1
  fi

  {
    echo "analysis header"
    cat "$response_valid"
  } > "$response_outside"
  if lint_response_file "$response_outside" >/dev/null 2>&1; then
    echo "FAIL: --test expected outside-text response to fail" >&2
    failures_local=1
  fi

  {
    cat "$response_valid"
    echo
    echo '```markdown'
    echo '### DP-OPS-9999: extra block'
    echo '```'
  } > "$response_multiple"
  if lint_response_file "$response_multiple" >/dev/null 2>&1; then
    echo "FAIL: --test expected multiple-block response to fail" >&2
    failures_local=1
  fi

  {
    echo '```markdown'
    echo '### DP-OPS-9999: token test'
    echo ':contentReference[oaicite:0]{index=0}'
    echo '```'
  } > "$response_token"
  if lint_response_file "$response_token" >/dev/null 2>&1; then
    echo "FAIL: --test expected drift-token response to fail" >&2
    failures_local=1
  fi

  {
    echo '```markdown'
    echo '# Not a DP heading'
    echo '```'
  } > "$response_not_dp"
  if lint_response_file "$response_not_dp" >/dev/null 2>&1; then
    echo "FAIL: --test expected non-DP body start to fail" >&2
    failures_local=1
  fi

  {
    cat "$response_valid"
    echo "trailing note"
  } > "$response_trailing"
  if lint_response_file "$response_trailing" >/dev/null 2>&1; then
    echo "FAIL: --test expected trailing-text response to fail" >&2
    failures_local=1
  fi

  response_mode="audit"

  {
    echo '```markdown'
    echo '**AUDIT - DP-OPS-9999**'
    echo
    echo '## Step 0 — Preconditions'
    echo 'PASS'
    echo '```'
  } > "$response_audit_valid"
  if ! lint_response_file "$response_audit_valid" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response with marker to pass" >&2
    failures_local=1
  fi

  {
    echo '**AUDIT - DP-OPS-9999**'
    echo
    echo '## Step 0 — Preconditions'
    echo 'PASS'
  } > "$response_audit_plain"
  if lint_response_file "$response_audit_plain" >/dev/null 2>&1; then
    echo "FAIL: --test expected plain audit response without fenced block to fail" >&2
    failures_local=1
  fi

  {
    echo 'To: Operator'
    echo 'From: Foreman'
    echo
    cat "$response_audit_valid"
  } > "$response_audit_preface"
  if lint_response_file "$response_audit_preface" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response with preface text to fail" >&2
    failures_local=1
  fi

  {
    echo '```markdown'
    echo '## Audit Verdict'
    echo 'PASS'
    echo '```'
  } > "$response_audit_not_marker"
  if lint_response_file "$response_audit_not_marker" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response without marker to fail" >&2
    failures_local=1
  fi

  {
    echo '```markdown'
    echo '**AUDIT - DP-OPS-9999**'
    echo 'The user prompt is empty'
    echo '```'
  } > "$response_audit_meta"
  if lint_response_file "$response_audit_meta" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response with meta chatter to fail" >&2
    failures_local=1
  fi

  {
    echo '```markdown'
    echo '**AUDIT - DP-OPS-9999**'
    echo '[cite_start]token[cite: 1]'
    echo '```'
  } > "$response_audit_cite"
  if lint_response_file "$response_audit_cite" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response with citation tokens to fail" >&2
    failures_local=1
  fi

  response_mode="architect"

  cp "$response_valid" "$response_architect_valid"
  if ! lint_response_file "$response_architect_valid" >/dev/null 2>&1; then
    echo "FAIL: --test expected architect response with DP body to pass" >&2
    failures_local=1
  fi

  cat > "$response_architect_audit_marker" <<'EOF_ARCH_AUDIT'
```markdown
### DP-OPS-9999: Architect Drift Fixture

**AUDIT - DP-OPS-9999**
```
EOF_ARCH_AUDIT
  if lint_response_file "$response_architect_audit_marker" >/dev/null 2>&1; then
    echo "FAIL: --test expected architect response with audit marker to fail" >&2
    failures_local=1
  fi

  cat > "$response_architect_narrative" <<'EOF_ARCH_NARRATIVE'
```markdown
### DP-OPS-9999: Architect Drift Fixture

## Contractor Execution Narrative
### Preflight State
```
EOF_ARCH_NARRATIVE
  if lint_response_file "$response_architect_narrative" >/dev/null 2>&1; then
    echo "FAIL: --test expected architect response with contractor narrative to fail" >&2
    failures_local=1
  fi

  response_mode="planning"

  cat > "$response_planning_valid" <<'EOF_PLANNING_VALID'
```markdown
# Reset Generated Planning

## Summary
Planning output is rendered as a plan surface.

## Key Changes
- Produce a deterministic plan draft from the attached topic.

## Test Plan
- bash tools/lint/response.sh --test

## Assumptions
- Keep the output plan-shaped and machine-ingestible.
```
EOF_PLANNING_VALID
  if ! lint_response_file "$response_planning_valid" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning plan-shaped response to pass" >&2
    failures_local=1
  fi

  cat > "$response_planning_conversation_valid" <<'EOF_PLANNING_CONVERSATION'
```markdown
1. Analysis and Discussion
The topic leaves scope ambiguity around the exact runtime reset surface.

2. Decision Questions

Q1. Should the reset remove generated slice handling from editor assist as well as bundle/runtime?
- A. Reset bundle/runtime only; leave editor assist unchanged.
- B. Reset bundle/runtime and editor assist together. (Recommended)
- C. Reset editor assist only and defer bundle/runtime.

Questions / Conversation:
Q1:B — or: Use recommended options
```
EOF_PLANNING_CONVERSATION
  if ! lint_response_file "$response_planning_conversation_valid" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning conversational response to pass" >&2
    failures_local=1
  fi

  cat > "$response_planning_audit_marker" <<'EOF_PLANNING_AUDIT'
```markdown
# Reset Generated Planning
**AUDIT - DP-OPS-9999**
```
EOF_PLANNING_AUDIT
  if lint_response_file "$response_planning_audit_marker" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning response with audit marker to fail" >&2
    failures_local=1
  fi

  cat > "$response_planning_narrative" <<'EOF_PLANNING_NARRATIVE'
```markdown
# Reset Generated Planning
## Contractor Execution Narrative
```
EOF_PLANNING_NARRATIVE
  if lint_response_file "$response_planning_narrative" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning response with contractor narrative to fail" >&2
    failures_local=1
  fi

  cat > "$response_planning_policy" <<'EOF_PLANNING_POLICY'
```markdown
1. Analysis and Discussion
Section 3.4.5 requires RECEIPT_EXTRA policy wording.

Questions / Conversation:
- confirm
```
EOF_PLANNING_POLICY
  if lint_response_file "$response_planning_policy" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning response with policy-overcompensation prose to fail" >&2
    failures_local=1
  fi

  cat > "$response_planning_missing_plan" <<'EOF_PLANNING_MISSING'
```markdown
1. Analysis and Discussion
```
EOF_PLANNING_MISSING
  if lint_response_file "$response_planning_missing_plan" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning response missing both final PLAN structure and conversation footer to fail" >&2
    failures_local=1
  fi

  cat > "$response_planning_structured_valid" <<'EOF_PLANNING_STRUCTURED'
```markdown
1. Analysis and Discussion
The scope leaves two material gaps that affect implementation direction.

2. Decision Questions

Q1. Which reset surface should be targeted first?
- A. Bundle/runtime reset only; defer editor assist.
- B. Bundle/runtime and editor assist together. (Recommended)
- C. Editor assist only; leave bundle/runtime for a follow-on packet.

Q2. Should the new validation path be gated behind a feature flag?
- A. No feature flag; ship validation as default behavior.
- B. Feature flag for gradual rollout. (Recommended)
- C. Validation disabled by default; operator opt-in required.

Questions / Conversation:
Q1:B, Q2:B — or: Use recommended options
```
EOF_PLANNING_STRUCTURED
  if ! lint_response_file "$response_planning_structured_valid" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning structured question-mode response to pass" >&2
    failures_local=1
  fi

  cat > "$response_planning_few_options" <<'EOF_PLANNING_FEW_OPTIONS'
```markdown
1. Analysis and Discussion
Ambiguity remains around the target surface.

2. Decision Questions

Q1. Which surface should be reset?
- A. Bundle/runtime only. (Recommended)
- B. Editor assist only.

Questions / Conversation:
Q1:A — or: Use recommended options
```
EOF_PLANNING_FEW_OPTIONS
  if lint_response_file "$response_planning_few_options" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning question with fewer than 3 options to fail" >&2
    failures_local=1
  fi

  cat > "$response_planning_no_recommended" <<'EOF_PLANNING_NO_REC'
```markdown
1. Analysis and Discussion
Ambiguity remains around the target surface.

2. Decision Questions

Q1. Which surface should be reset?
- A. Bundle/runtime only.
- B. Editor assist only.
- C. Both together.

Questions / Conversation:
Q1:A
```
EOF_PLANNING_NO_REC
  if lint_response_file "$response_planning_no_recommended" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning question with no (Recommended) option to fail" >&2
    failures_local=1
  fi

  cat > "$response_planning_too_many_questions" <<'EOF_PLANNING_TOO_MANY'
```markdown
1. Analysis and Discussion
Four gaps remain.

2. Decision Questions

Q1. First question?
- A. Option one. (Recommended)
- B. Option two.
- C. Option three.

Q2. Second question?
- A. Option one.
- B. Option two. (Recommended)
- C. Option three.

Q3. Third question?
- A. Option one.
- B. Option two.
- C. Option three. (Recommended)

Q4. Fourth question?
- A. Option one. (Recommended)
- B. Option two.
- C. Option three.

Questions / Conversation:
Use recommended options
```
EOF_PLANNING_TOO_MANY
  if lint_response_file "$response_planning_too_many_questions" >/dev/null 2>&1; then
    echo "FAIL: --test expected planning response with 4 questions to fail" >&2
    failures_local=1
  fi

  response_mode="foreman"

  cat > "$response_foreman_valid" <<'EOF_FOREMAN_VALID'
```markdown
### Addendum A to DP-OPS-9999
Decision Required: Yes
Decision Leaf: archives/decisions/RoR-2026-03-07-foreman-fixture.md

## A.1 Authorization
Operator Authorization:
> Authorized for addendum generation.

## A.2 Scope Delta
Exact paths added by this addendum (one per line; no globs; no brace expansion):
- docs/example.md

## A.3 Addendum Objective
Add addendum-only scope boundary.

## A.4 Context Load
- PoT.md

## A.5 Addendum Receipt (Proofs to collect) - MUST RUN
**Mandatory receipt commands (always run; do not omit):**
- bash tools/lint/dp.sh TASK.md
```
EOF_FOREMAN_VALID
  if ! lint_response_file "$response_foreman_valid" >/dev/null 2>&1; then
    echo "FAIL: --test expected foreman response with addendum body to pass" >&2
    failures_local=1
  fi

  cat > "$response_foreman_audit_marker" <<'EOF_FOREMAN_AUDIT'
```markdown
### Addendum A to DP-OPS-9999
**AUDIT - DP-OPS-9999**

## A.1 Authorization
Operator Authorization:
> Authorized.

## A.2 Scope Delta
- docs/example.md

## A.3 Addendum Objective
Objective text.

## A.4 Context Load
- PoT.md

## A.5 Addendum Receipt (Proofs to collect) - MUST RUN
```
EOF_FOREMAN_AUDIT
  if lint_response_file "$response_foreman_audit_marker" >/dev/null 2>&1; then
    echo "FAIL: --test expected foreman response with audit marker to fail" >&2
    failures_local=1
  fi

  cat > "$response_foreman_missing_sections" <<'EOF_FOREMAN_MISSING'
```markdown
### Addendum A to DP-OPS-9999
## A.1 Authorization
Operator Authorization:
> Authorized.
```
EOF_FOREMAN_MISSING
  if lint_response_file "$response_foreman_missing_sections" >/dev/null 2>&1; then
    echo "FAIL: --test expected foreman response missing required addendum sections to fail" >&2
    failures_local=1
  fi

  cat > "$response_foreman_decision_incoherent" <<'EOF_FOREMAN_DECISION'
```markdown
### Addendum A to DP-OPS-9999
Decision Required: No
Decision Leaf: archives/decisions/RoR-2026-03-07-invalid.md

## A.1 Authorization
Operator Authorization:
> Authorized.

## A.2 Scope Delta
- docs/example.md

## A.3 Addendum Objective
Objective text.

## A.4 Context Load
- PoT.md

## A.5 Addendum Receipt (Proofs to collect) - MUST RUN
```
EOF_FOREMAN_DECISION
  if lint_response_file "$response_foreman_decision_incoherent" >/dev/null 2>&1; then
    echo "FAIL: --test expected foreman response with incoherent decision fields to fail" >&2
    failures_local=1
  fi


  response_mode="conformist"

  cp "$response_valid" "$response_conformist_valid"
  if ! lint_response_file "$response_conformist_valid" >/dev/null 2>&1; then
    echo "FAIL: --test expected conformist response with DP body to pass" >&2
    failures_local=1
  fi

  cat > "$response_conformist_audit_marker" <<'EOF_CONFORMIST_AUDIT'
```markdown
### DP-OPS-9999: Conformist Drift Fixture
**AUDIT - DP-OPS-9999**
```
EOF_CONFORMIST_AUDIT
  if lint_response_file "$response_conformist_audit_marker" >/dev/null 2>&1; then
    echo "FAIL: --test expected conformist response with audit marker to fail" >&2
    failures_local=1
  fi

  cat > "$response_conformist_addendum_marker" <<'EOF_CONFORMIST_ADDENDUM'
```markdown
### DP-OPS-9999: Conformist Drift Fixture
## A.1 Authorization
```
EOF_CONFORMIST_ADDENDUM
  if lint_response_file "$response_conformist_addendum_marker" >/dev/null 2>&1; then
    echo "FAIL: --test expected conformist response with addendum heading to fail" >&2
    failures_local=1
  fi

  cat > "$response_conformist_decision_fields" <<'EOF_CONFORMIST_DECISION'
```markdown
### DP-OPS-9999: Conformist Drift Fixture
Decision Required: Yes
Decision Leaf: archives/decisions/RoR-2026-03-07-test.md
```
EOF_CONFORMIST_DECISION
  if lint_response_file "$response_conformist_decision_fields" >/dev/null 2>&1; then
    echo "FAIL: --test expected conformist response with decision fields to fail" >&2
    failures_local=1
  fi

  response_exec_decision_valid="${test_dir}/response-exec-decision-valid.md"
  response_exec_decision_missing_constraint="${test_dir}/response-exec-decision-missing-constraint.md"
  response_exec_decision_missing_step="${test_dir}/response-exec-decision-missing-step.md"

  cat > "$response_exec_decision_valid" <<'EOF_EXEC_DECISION_VALID'
```
Active task constraints used:
PoT.md, TASK.md, allowlist.

Observable evidence used:
Diff output and integrity lint results.

Evidence gaps or unknowns:
None.

Confidence level:
High.

Trigger:
Worker received DP-OPS-0221.
Decision:
Proceed with execution.
Rationale:
Preflight passed.
Tools considered or used:
bash tools/lint/dp.sh
Actions taken:
Read all required context.
Actions not taken:
Did not modify out-of-scope files.
Key evidence:
dp.sh PASS, task.sh PASS.
```
EOF_EXEC_DECISION_VALID
  response_mode="execution-decision"
  failures=0
  if ! lint_response_file "$response_exec_decision_valid" >/dev/null 2>&1; then
    echo "FAIL: --test expected valid execution-decision response to pass" >&2
    failures_local=1
  fi

  cat > "$response_exec_decision_missing_constraint" <<'EOF_EXEC_DECISION_MISSING_CONSTRAINT'
```
Observable evidence used:
Diff output.

Evidence gaps or unknowns:
None.

Confidence level:
High.

Trigger:
Worker received DP.
Decision:
Proceed.
Rationale:
Preflight passed.
Tools considered or used:
bash tools/lint/dp.sh
Actions taken:
Read context.
Actions not taken:
None.
Key evidence:
dp.sh PASS.
```
EOF_EXEC_DECISION_MISSING_CONSTRAINT
  failures=0
  if lint_response_file "$response_exec_decision_missing_constraint" >/dev/null 2>&1; then
    echo "FAIL: --test expected execution-decision missing constraint label to fail" >&2
    failures_local=1
  fi

  cat > "$response_exec_decision_missing_step" <<'EOF_EXEC_DECISION_MISSING_STEP'
```
Active task constraints used:
PoT.md.

Observable evidence used:
Diff output.

Evidence gaps or unknowns:
None.

Confidence level:
High.

Trigger:
Worker received DP.
Decision:
Proceed.
Rationale:
Preflight passed.
Tools considered or used:
bash tools/lint/dp.sh
Actions taken:
Read context.
Actions not taken:
None.
```
EOF_EXEC_DECISION_MISSING_STEP
  failures=0
  if lint_response_file "$response_exec_decision_missing_step" >/dev/null 2>&1; then
    echo "FAIL: --test expected execution-decision missing step label to fail" >&2
    failures_local=1
  fi

  response_exec_decision_split_block="${test_dir}/response-exec-decision-split-block.md"
  cat > "$response_exec_decision_split_block" <<'EOF_EXEC_DECISION_SPLIT_BLOCK'
```
Active task constraints used:
PoT.md.

Observable evidence used:
Diff output.

Evidence gaps or unknowns:
None.

Confidence level:
High.

Trigger:
First step.
Decision:
Proceed.
Rationale:
Good reason.
Tools considered or used:
Tool A.

Trigger:
Second step.
Actions taken:
Done.
Actions not taken:
Nothing.
Key evidence:
Test passed.
```
EOF_EXEC_DECISION_SPLIT_BLOCK
  failures=0
  if lint_response_file "$response_exec_decision_split_block" >/dev/null 2>&1; then
    echo "FAIL: --test expected execution-decision split-block response to fail" >&2
    failures_local=1
  fi

  response_exec_decision_label_in_prose="${test_dir}/response-exec-decision-label-in-prose.md"
  cat > "$response_exec_decision_label_in_prose" <<'EOF_EXEC_DECISION_LABEL_IN_PROSE'
```
Observable evidence used:
Diff output confirming "Active task constraints used: PoT.md" was noted inline.

Evidence gaps or unknowns:
None.

Confidence level:
High.

Trigger:
Worker received DP.
Decision:
Proceed.
Rationale:
Preflight passed.
Tools considered or used:
bash tools/lint/dp.sh
Actions taken:
Read context.
Actions not taken:
None.
Key evidence:
dp.sh PASS.
```
EOF_EXEC_DECISION_LABEL_IN_PROSE
  failures=0
  if lint_response_file "$response_exec_decision_label_in_prose" >/dev/null 2>&1; then
    echo "FAIL: --test expected execution-decision with constraint label only in prose to fail" >&2
    failures_local=1
  fi

  response_mode="$saved_mode"
  response_skip_dp_delegate=0

  if (( failures_local != 0 )); then
    return 1
  fi

  echo "OK: --test passed"
}

run_test_mode=0
input_path=""

while (($# > 0)); do
  case "$1" in
    --mode)
      shift
      if (($# == 0)); then
        usage >&2
        response_fail "--mode requires one of: dp audit architect planning foreman conformist"
        exit 1
      fi
      response_mode="$1"
      shift
      ;;
    --mode=*)
      response_mode="${1#--mode=}"
      shift
      ;;
    --test)
      run_test_mode=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ -n "$input_path" ]]; then
        usage >&2
        response_fail "too many arguments"
        exit 1
      fi
      input_path="$1"
      shift
      ;;
  esac
done

case "$response_mode" in
  dp|audit|architect|planning|foreman|conformist|execution-decision) ;;
  *)
    usage >&2
    response_fail "invalid mode: ${response_mode}. Use dp, audit, architect, planning, foreman, conformist, or execution-decision."
    exit 1
    ;;
esac

if (( run_test_mode )); then
  run_test
  exit $?
fi

if [[ -z "$input_path" ]]; then
  input_path="$(mktemp)"
  cat > "$input_path"
  if [[ ! -s "$input_path" ]]; then
    rm -f "$input_path"
    usage >&2
    response_fail "no input provided"
    exit 1
  fi
  lint_response_file "$input_path"
  status=$?
  rm -f "$input_path"
  exit $status
fi

if [[ "$input_path" == "-" ]]; then
  stdin_tmp="$(mktemp)"
  cat > "$stdin_tmp"
  lint_response_file "$stdin_tmp"
  status=$?
  rm -f "$stdin_tmp"
  exit $status
fi

lint_response_file "$input_path"
