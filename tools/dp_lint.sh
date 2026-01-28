#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/dp_lint.sh [--test] [path|-]
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
        if ($0 ~ /^\\s*$/) { exit }
        if ($0 ~ /^\\s*#{1,6} /) { exit }
        if ($0 ~ /^\\s*[-*] /) { ok = 1; exit }
        if ($0 ~ /^\\s*\\*\\*/) { exit }
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
        if ($0 ~ /^\\s*$/) { exit }
        if ($0 ~ /^\\s*#{1,6} /) { exit }
        if ($0 ~ /^\\s*[-*] /) {
          line = $0
          sub(/^\\s*[-*]\\s+/, "", line)
          print line
          next
        }
        if ($0 ~ /^\\s*\\*\\*/) { exit }
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
        if ($0 ~ /^\\s*$/) { exit }
        if ($0 ~ /^\\s*#{1,6} /) { exit }
        if ($0 ~ /^\\s*[-*] /) {
          line = $0
          while (match(line, /`[^`]+`/)) {
            token = substr(line, RSTART + 1, RLENGTH - 2)
            print token
            line = substr(line, RSTART + RLENGTH)
          }
          next
        }
        if ($0 ~ /^\\s*\\*\\*/) { exit }
      }
    }
  ' "$path"
}

lint_file() {
  local path="$1"
  failures=0

  if [[ ! -f "$path" ]]; then
    fail "Missing file: $path"
    return 1
  fi

  # If TASK DP headings change, update this list in the same PR.
  local headings=(
    "## 0. FRESHNESS GATE (MUST PASS BEFORE WORK)"
    "## I. REQUIRED CONTEXT LOAD (DP-SCOPED)"
    "## II. SCOPE & SAFETY"
    "## III. EXECUTION PLAN (A–E CANON)"
    "### A) STATE"
    "### B) REQUEST"
    "### C) CHANGELOG"
    "### D) PATCH / DIFF"
    "### E) RECEIPT (REQUIRED)"
    "## 3) CLOSEOUT (MANDATORY)"
    "## 3.1) THREAD TRANSITION (RESET / ARCHIVE RULE)"
    "## 4) WORK LOG (TIMESTAMPED CONTINUITY)"
  )

  local heading_lines=()
  local missing=0
  local heading
  local line

  for heading in "${headings[@]}"; do
    line="$(awk -v h="$heading" '$0 == h { print NR; exit }' "$path")"
    if [[ -z "$line" ]]; then
      fail "missing heading '$heading'"
      missing=1
      heading_lines+=("")
    else
      heading_lines+=("$line")
    fi
  done

  if (( !missing )); then
    local i
    for ((i=0; i<${#heading_lines[@]}-1; i++)); do
      if (( heading_lines[i] >= heading_lines[i+1] )); then
        fail "headings out of order: '${headings[i]}' should appear before '${headings[i+1]}'"
        break
      fi
    done
  fi

  if ! grep -nE '^#\s*DP-[A-Z]+-[0-9]{4,}([_-]v[0-9]+)?:' "$path" >/dev/null; then
    fail "missing DP id heading (expected '# DP-<AREA>-<####>: <title>')"
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
  check_required_field "Required Work Branch"
  check_required_field "Base HEAD"

  if ! field_value_valid "Objective"; then
    if ! grep -Fq "In scope" "$path"; then
      fail "missing scope summary (Objective or In scope section)"
    fi
  fi

  local allowlist_from_in_scope=0

  mapfile -t allowlist < <(extract_allowlist_paths "$path" "Target Files (Allowlist)")
  if (( ${#allowlist[@]} == 0 )); then
    mapfile -t allowlist < <(extract_allowlist_paths "$path" "Allowed Scope")
  fi
  if (( ${#allowlist[@]} == 0 )); then
    if grep -Fq "In scope" "$path"; then
      allowlist_from_in_scope=1
    fi
  fi

  if (( ${#allowlist[@]} == 0 )) && (( allowlist_from_in_scope == 0 )); then
    fail "Target Files allowlist missing or empty"
  elif (( allowlist_from_in_scope == 0 )); then
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
* **Required Work Branch:** work/boot_files_update
* **Base HEAD:** 13a2074d
## I. REQUIRED CONTEXT LOAD (DP-SCOPED)
* **Loaded:** OPEN, TRUTH, AGENTS, SoP
## II. SCOPE & SAFETY
* **Objective:** Validate lint headings and required fields.
* **Target Files (Allowlist):**
  * tools/dp_lint.sh
## III. EXECUTION PLAN (A–E CANON)
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

  lint_file "$tmp_valid" >/dev/null

  tmp_invalid="$(mktemp)"
  cat <<'EOF' > "$tmp_invalid"
# DP-OPS-0001: Lint Test
## 0. FRESHNESS GATE (MUST PASS BEFORE WORK)
* **Base Branch:** work/boot_files_update
* **Required Work Branch:** work/boot_files_update
* **Base HEAD:** 13a2074d
## I. REQUIRED CONTEXT LOAD (DP-SCOPED)
* **Loaded:** OPEN, TRUTH, AGENTS, SoP
## II. SCOPE & SAFETY
* **Objective:** TBD
* **Target Files (Allowlist):**
  * tools/dp_lint.sh
## III. EXECUTION PLAN (A–E CANON)
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
* **Required Work Branch:** work/boot_files_update
* **Base HEAD:** 13a2074d
## III. EXECUTION PLAN (A–E CANON)
## II. SCOPE & SAFETY
* **Objective:** Validate lint headings and required fields.
* **Target Files (Allowlist):**
  * tools/dp_lint.sh
## I. REQUIRED CONTEXT LOAD (DP-SCOPED)
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

  rm -f "$tmp_valid" "$tmp_invalid" "$tmp_order"
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
