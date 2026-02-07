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
  local legacy_headings=(
    "## 0. Freshness Gate (Must Pass Before Work)"
    "## I) Required Context Load (Read Before Doing Anything)"
    "## II) Scope & Safety"
    "## III. Execution Plan (A-E Canon)"
    "## 3) Closeout (Mandatory)"
  )

  local legacy_patterns=(
    '^##[[:space:]]*0[.)]?[[:space:]]*FRESHNESS GATE'
    '^##[[:space:]]*I[.)]?[[:space:]]*REQUIRED CONTEXT LOAD'
    '^##[[:space:]]*II[.)]?[[:space:]]*SCOPE'
    '^##[[:space:]]*III[.)]?[[:space:]]*EXECUTION PLAN'
    '^##[[:space:]]*3[.)]?[[:space:]]*CLOSEOUT'
  )

  local legacy_thread_label="## 3.1) Thread Transition (Reset / Archive Rule)"
  local legacy_thread_pattern='^##[[:space:]]*(3\\.1|5)[.)]?[[:space:]]*THREAD TRANSITION'
  local legacy_work_label="## 4) Work Log (Timestamped Continuity)"
  local legacy_work_pattern='^##[[:space:]]*4[.)]?[[:space:]]*WORK LOG'

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

  local legacy_errors
  local decimal_errors

  if legacy_errors="$(heading_errors_for_scheme "$path" "legacy" legacy_headings legacy_patterns "$legacy_thread_label" "$legacy_thread_pattern" "$legacy_work_label" "$legacy_work_pattern")"; then
    :
  else
    decimal_errors="$(heading_errors_for_scheme "$path" "decimal" decimal_headings decimal_patterns "$decimal_thread_label" "$decimal_thread_pattern" "$decimal_work_label" "$decimal_work_pattern" || true)"
    if [[ -z "$decimal_errors" ]]; then
      :
    else
      if [[ -n "$legacy_errors" ]]; then
        while IFS= read -r line; do
          [[ -n "$line" ]] && fail "$line"
        done <<< "$legacy_errors"
      fi
      if [[ -n "$decimal_errors" ]]; then
        while IFS= read -r line; do
          [[ -n "$line" ]] && fail "$line"
        done <<< "$decimal_errors"
      fi
      fail "heading scheme not recognized. Accepted heading schemes: legacy (0/I/II/III/3 + 3.1 + 4) or decimal (3.1/3.2/3.3/3.4/4/4.1/5)."
    fi
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

  if (( ${#allowlist[@]} == 0 )); then
    fail "Target Files allowlist missing or empty"
  else
    local entry
    for entry in "${allowlist[@]}"; do
      entry="$(trim "$entry")"
      entry="$(strip_backticks "$entry")"
      if [[ -z "$entry" ]]; then
        fail "Target Files allowlist has empty entry"
        continue
      fi

      if [[ "$entry" =~ ^\(new\)[[:space:]]* ]]; then
        entry="${entry#(new)}"
        entry="$(trim "$entry")"
        if [[ -z "$entry" ]]; then
          fail "Target Files allowlist '(new)' entry missing path"
        fi
        continue
      fi

      if [[ ! -e "$entry" ]]; then
        fail "Target Files allowlist path missing: $entry (use '(new)' prefix if new)"
      fi
    done
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

run_test() {
  local tmp_valid
  local tmp_invalid
  local tmp_order

  tmp_valid="$(mktemp)"
  cat <<'EOF' > "$tmp_valid"
# DP-OPS-0001: Lint Test
## 0. FRESHNESS GATE (MUST PASS BEFORE WORK)
* **Base Branch:** work/boot_files_update
* **Work Branch:** work/boot_files_update
* **Base HEAD:** 13a2074d
## I) REQUIRED CONTEXT LOAD (READ BEFORE DOING ANYTHING)
* **Loaded:** OPEN, TRUTH, AGENTS, SoP
## II) SCOPE & SAFETY
* **Objective:** Validate lint headings and required fields.
### Target Files allowlist (hard gate)
- tools/lint/dp.sh
## III) EXECUTION PLAN (A–E CANON)
### A) STATE / CONTEXT
Test state.
### B) REQUEST
1) Test request.
### C) CHANGELOG NOTES
- Test changelog.
### D) PATCH / DIFF OUTPUT
- Test diff.
### E) RECEIPT (REQUIRED)
- Test receipt.
## 3. CLOSEOUT (MANDATORY)
- Closeout notes.
## 3.1) THREAD TRANSITION (RESET / ARCHIVE RULE)
- Transition notes.
## 4) WORK LOG (TIMESTAMPED CONTINUITY)
- 2026-01-27 14:05 — DP-OPS-0001: Lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review.
EOF

  lint_file "$tmp_valid" >/dev/null

  tmp_invalid="$(mktemp)"
  cat <<'EOF' > "$tmp_invalid"
# DP-OPS-0001: Lint Test
## 0. FRESHNESS GATE (MUST PASS BEFORE WORK)
* **Base Branch:** work/boot_files_update
* **Work Branch:** work/boot_files_update
* **Base HEAD:** 13a2074d
## I) REQUIRED CONTEXT LOAD (READ BEFORE DOING ANYTHING)
* **Loaded:** OPEN, TRUTH, AGENTS, SoP
## II) SCOPE & SAFETY
* **Objective:** TBD
### Target Files allowlist (hard gate)
- tools/lint/dp.sh
## III) EXECUTION PLAN (A–E CANON)
### A) STATE
Test state.
### B) REQUEST
1) Test request.
### C) CHANGELOG
- Test changelog.
### D) PATCH / DIFF
- Test diff.
### E) RECEIPT (REQUIRED)
- Test receipt.
## 3) CLOSEOUT (MANDATORY)
- Closeout notes.
## 3.1) THREAD TRANSITION (RESET / ARCHIVE RULE)
- Transition notes.
## 4) WORK LOG (TIMESTAMPED CONTINUITY)
- 2026-01-27 14:05 — DP-OPS-0001: Lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review.
EOF

  if lint_file "$tmp_invalid" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid"
    echo "FAIL: --test expected placeholder detection to fail" >&2
    exit 1
  fi

  tmp_order="$(mktemp)"
  cat <<'EOF' > "$tmp_order"
# DP-OPS-0001: Lint Test
## 0. FRESHNESS GATE (MUST PASS BEFORE WORK)
* **Base Branch:** work/boot_files_update
* **Work Branch:** work/boot_files_update
* **Base HEAD:** 13a2074d
## III) EXECUTION PLAN (A–E CANON)
## II) SCOPE & SAFETY
* **Objective:** Validate lint headings and required fields.
### Target Files allowlist (hard gate)
- tools/lint/dp.sh
## I) REQUIRED CONTEXT LOAD (READ BEFORE DOING ANYTHING)
* **Loaded:** OPEN, TRUTH, AGENTS, SoP
### A) STATE
Test state.
### B) REQUEST
1) Test request.
### C) CHANGELOG
- Test changelog.
### D) PATCH / DIFF
- Test diff.
### E) RECEIPT (REQUIRED)
- Test receipt.
## 3) CLOSEOUT (MANDATORY)
- Closeout notes.
## 3.1) THREAD TRANSITION (RESET / ARCHIVE RULE)
- Transition notes.
## 4) WORK LOG (TIMESTAMPED CONTINUITY)
- 2026-01-27 14:05 — DP-OPS-0001: Lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review.
EOF

  if lint_file "$tmp_order" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid" "$tmp_order"
    echo "FAIL: --test expected heading order detection to fail" >&2
    exit 1
  fi

  tmp_decimal_valid="$(mktemp)"
  cat <<'EOF' > "$tmp_decimal_valid"
# DP-OPS-0002: Decimal Lint Test
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/decimal-lint-test
Base HEAD: 13a2074d
## 3.2 Required Context Load (Read Before Doing Anything)
- Loaded: PoT, SoP, CONTEXT, MAP
## 3.3 Scope and Safety
- Objective: Validate decimal headings.
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
- 2026-01-27 14:05 — DP-OPS-0002: Lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review.
EOF

  lint_file "$tmp_decimal_valid" >/dev/null

  tmp_decimal_invalid="$(mktemp)"
  cat <<'EOF' > "$tmp_decimal_invalid"
# DP-OPS-0003: Decimal Lint Test Invalid
## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/decimal-lint-test
Base HEAD: 13a2074d
## 3.3 Scope and Safety
- Objective: Validate decimal heading failures.
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
- 2026-01-27 14:05 — DP-OPS-0003: Lint test entry. Verification: NOT RUN. Blockers: none. NEXT: review.
EOF

  if lint_file "$tmp_decimal_invalid" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid" "$tmp_order" "$tmp_decimal_valid" "$tmp_decimal_invalid"
    echo "FAIL: --test expected decimal heading detection to fail" >&2
    exit 1
  fi

  rm -f "$tmp_valid" "$tmp_invalid" "$tmp_order" "$tmp_decimal_valid" "$tmp_decimal_invalid"
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
    lint_file "$tmp_stdin"
    rm -f "$tmp_stdin"
    ;;
  -)
    tmp_stdin="$(mktemp)"
    cat > "$tmp_stdin"
    lint_file "$tmp_stdin"
    rm -f "$tmp_stdin"
    ;;
  *)
    lint_file "$1"
    ;;
esac
