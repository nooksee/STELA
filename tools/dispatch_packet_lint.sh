#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/dispatch_packet_lint.sh [--test] [path|-]
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
  "..."
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

check_required_field() {
  local label="$1"
  local value

  value="$(awk -v label="$label" '
    {
      match($0, label ":[[:space:]]*")
      if (RSTART) {
        text = substr($0, RSTART + RLENGTH)
        gsub(/^[[:space:]]+/, "", text)
        print text
        exit
      }
    }
  ' "$path")"

  value="$(trim "$value")"
  value="$(strip_backticks "$value")"

  if [[ -z "$value" ]]; then
    fail "missing or empty value for '$label'"
    return
  fi

  if contains_placeholder "$value"; then
    fail "placeholder value for '$label'"
  fi
}

lint_file() {
  local path="$1"
  failures=0

  if [[ ! -f "$path" ]]; then
    fail "Missing file: $path"
    return 1
  fi

  local headings=(
    "## 0. FRESHNESS GATE (STOP IF FAILED)"
    "## I. SCOPE & SAFETY"
    "## II. EXECUTION PLAN (A-E CANON)"
    "### A) STATE"
    "### B) REQUEST"
    "### C) CHANGELOG"
    "### D) PATCH / DIFF"
    "### E) RECEIPT (REQUIRED)"
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

  if ! grep -nE '^#\s*DP-[A-Z]+-[0-9]{4,}:' "$path" >/dev/null; then
    fail "missing DP id heading (expected '# DP-<AREA>-<####>: <title>')"
  fi

  local token
  for token in "${PLACEHOLDER_TOKENS[@]}"; do
    if grep -Fq -- "$token" "$path"; then
      fail "placeholder token found: $token"
    fi
  done

  check_required_field "Base Branch"
  check_required_field "Required Work Branch"
  check_required_field "Base HEAD"
  check_required_field "Objective"

  mapfile -t allowlist < <(
    awk '
      BEGIN { found = 0 }
      /Target Files \(Allowlist\)/ { found = 1; next }
      found {
        if ($0 ~ /^\s*$/) { exit }
        if ($0 ~ /^\s*#{1,6} /) { exit }
        if ($0 ~ /^\s*[-*] /) {
          line = $0
          sub(/^\s*[-*]\s+/, "", line)
          print line
          next
        }
        if ($0 ~ /^\s*\*\*/) { exit }
      }
    ' "$path"
  )

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
## 0. FRESHNESS GATE (STOP IF FAILED)
* **Base Branch:** work/boot_files_update
* **Required Work Branch:** work/boot_files_update
* **Base HEAD:** 13a2074d
## I. SCOPE & SAFETY
* **Objective:** Validate lint headings and required fields.
* **Target Files (Allowlist):**
  * tools/dispatch_packet_lint.sh
## II. EXECUTION PLAN (A-E CANON)
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
EOF

  lint_file "$tmp_valid" >/dev/null

  tmp_invalid="$(mktemp)"
  cat <<'EOF' > "$tmp_invalid"
# DP-OPS-0001: Lint Test
## 0. FRESHNESS GATE (STOP IF FAILED)
* **Base Branch:** work/boot_files_update
* **Required Work Branch:** work/boot_files_update
* **Base HEAD:** 13a2074d
## I. SCOPE & SAFETY
* **Objective:** TBD
* **Target Files (Allowlist):**
  * tools/dispatch_packet_lint.sh
## II. EXECUTION PLAN (A-E CANON)
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
EOF

  if lint_file "$tmp_invalid" >/dev/null 2>&1; then
    rm -f "$tmp_valid" "$tmp_invalid"
    echo "FAIL: --test expected placeholder detection to fail" >&2
    exit 1
  fi

  tmp_order="$(mktemp)"
  cat <<'EOF' > "$tmp_order"
# DP-OPS-0001: Lint Test
## 0. FRESHNESS GATE (STOP IF FAILED)
* **Base Branch:** work/boot_files_update
* **Required Work Branch:** work/boot_files_update
* **Base HEAD:** 13a2074d
## II. EXECUTION PLAN (A-E CANON)
## I. SCOPE & SAFETY
* **Objective:** Validate lint headings and required fields.
* **Target Files (Allowlist):**
  * tools/dispatch_packet_lint.sh
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
