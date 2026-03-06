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
Usage: bash tools/lint/response.sh [--mode=dp|audit] [--test] [path|-]
Default input: stdin
Example: bash tools/lint/response.sh --mode=audit var/tmp/response-audit-valid.md
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

  if [[ ! "$first_content_line" =~ ^\*\*AUDIT[[:space:]]+- ]]; then
    response_fail "audit body must start with marker '**AUDIT -'"
    return 1
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

lint_response_file() {
  local input_path="$1"
  local body_tmp
  body_tmp="$(mktemp)"
  failures=0

  if [[ ! -f "$input_path" ]]; then
    response_fail "response file not found: $input_path"
    rm -f "$body_tmp"
    return 1
  fi

  if [[ "$response_mode" == "dp" ]]; then
    extract_single_fenced_block "$input_path" "$body_tmp"
    check_dp_body_start "$body_tmp"
  elif [[ "$response_mode" == "audit" ]]; then
    extract_single_fenced_block "$input_path" "$body_tmp"
    check_audit_body_start "$body_tmp"
  else
    response_fail "unsupported lint mode: ${response_mode}"
  fi
  check_drift_tokens "$body_tmp"

  if (( failures )); then
    rm -f "$body_tmp"
    return 1
  fi

  if [[ "$response_mode" == "dp" && "$response_skip_dp_delegate" != "1" ]]; then
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
  local response_audit_marker_with_inner_fence
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
  response_audit_marker_with_inner_fence="${test_dir}/response-audit-marker-inner-fence.md"

  response_mode="dp"
  response_skip_dp_delegate=1

  if ! bash tools/lint/dp.sh --test >/dev/null 2>&1; then
    echo "FAIL: --test expected dp lint self-test to pass" >&2
    failures_local=1
  fi

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
    echo "FAIL: --test expected plain audit response without fence to fail" >&2
    failures_local=1
  fi

  {
    echo '**AUDIT - DP-OPS-9999**'
    echo
    echo '## Step 0'
    echo
    echo '```'
    echo 'internal snippet'
    echo '```'
  } > "$response_audit_marker_with_inner_fence"
  if lint_response_file "$response_audit_marker_with_inner_fence" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response with nested fence to fail" >&2
    failures_local=1
  fi

  {
    echo 'To: Operator'
    echo 'From: Foreman'
    echo
    cat "$response_audit_valid"
  } > "$response_audit_preface"
  if lint_response_file "$response_audit_preface" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response with preface text outside fence to fail" >&2
    failures_local=1
  fi

  {
    echo '## Audit Verdict'
    echo 'PASS'
  } > "$response_audit_not_marker"
  if lint_response_file "$response_audit_not_marker" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response without marker to fail" >&2
    failures_local=1
  fi

  {
    echo '**AUDIT - DP-OPS-9999**'
    echo 'The user prompt is empty'
  } > "$response_audit_meta"
  if lint_response_file "$response_audit_meta" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response with meta chatter to fail" >&2
    failures_local=1
  fi

  {
    echo '```markdown'
    echo '**AUDIT - DP-OPS-9999**'
    echo
    echo '[cite_start]This is contaminated[cite: 1]'
    echo '```'
  } > "$response_audit_cite"
  if lint_response_file "$response_audit_cite" >/dev/null 2>&1; then
    echo "FAIL: --test expected audit response with citation token to fail" >&2
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
        response_fail "--mode requires one of: dp audit"
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
  dp|audit) ;;
  *)
    usage >&2
    response_fail "invalid mode: ${response_mode}. Use dp or audit."
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
