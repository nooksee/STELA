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

FAILURES=0
RUN_OUTPUT=""
RUN_STATUS=0
DIRTY_FILE=""
OPEN_TEST_ROOT="var/tmp/_smoke/open-$$"
OPEN_TEST_ROOT_ABS="${REPO_ROOT}/${OPEN_TEST_ROOT}"
declare -a CLEANUP_PATHS=()
declare -A CLEANUP_SEEN=()

cleanup_generated() {
  local rel_path
  if [[ -n "$DIRTY_FILE" && -e "$DIRTY_FILE" ]]; then
    rm -f -- "$DIRTY_FILE"
  fi

  rm -rf -- "$OPEN_TEST_ROOT_ABS"

  for rel_path in "${CLEANUP_PATHS[@]}"; do
    [[ -n "$rel_path" ]] || continue
    if [[ -e "${REPO_ROOT}/${rel_path}" ]]; then
      rm -f -- "${REPO_ROOT}/${rel_path}"
    fi
  done
}

trap 'cleanup_generated; emit_binary_leaf "test-open" "finish"' EXIT
emit_binary_leaf "test-open" "start"

fail() {
  echo "FAIL: $*" >&2
  FAILURES=$((FAILURES + 1))
}

normalize_rel_path() {
  local value="$1"
  value="$(trim "$value")"
  value="${value#./}"
  if [[ "$value" == "${REPO_ROOT}/"* ]]; then
    value="${value#${REPO_ROOT}/}"
  fi
  printf '%s' "$value"
}

queue_cleanup_path() {
  local rel_path
  rel_path="$(normalize_rel_path "$1")"
  [[ -n "$rel_path" ]] || return 0

  case "$rel_path" in
    storage/handoff/*)
      ;;
    var/tmp/_smoke/*)
      ;;
    *)
      fail "refusing to queue cleanup path outside storage/handoff/ or var/tmp/_smoke/: ${rel_path}"
      return 1
      ;;
  esac

  if [[ -z "${CLEANUP_SEEN[$rel_path]+x}" ]]; then
    CLEANUP_SEEN["$rel_path"]=1
    CLEANUP_PATHS+=("$rel_path")
  fi
}

run_capture() {
  RUN_OUTPUT=""
  RUN_STATUS=0
  set +e
  RUN_OUTPUT="$($@ 2>&1)"
  RUN_STATUS=$?
  set -e
}

parse_output_path() {
  local label="$1"
  printf '%s\n' "$RUN_OUTPUT" | sed -n "s/^${label}:[[:space:]]*//p" | tail -n 1
}

assert_file_exists() {
  local rel_path="$1"
  [[ -f "${REPO_ROOT}/${rel_path}" ]] || fail "expected file missing: ${rel_path}"
}

assert_file_not_empty() {
  local rel_path="$1"
  [[ -s "${REPO_ROOT}/${rel_path}" ]] || fail "expected non-empty file: ${rel_path}"
}

assert_contains() {
  local rel_path="$1"
  local needle="$2"
  if ! grep -Fq -- "$needle" "${REPO_ROOT}/${rel_path}"; then
    fail "expected '${needle}' in ${rel_path}"
  fi
}

assert_absent() {
  local rel_path="$1"
  local needle="$2"
  if grep -Fq -- "$needle" "${REPO_ROOT}/${rel_path}"; then
    fail "unexpected '${needle}' in ${rel_path}"
  fi
}

DIRTY_FILE="open-test-dirty-${RANDOM}${RANDOM}.tmp"
printf 'open-test-dirty\n' > "$DIRTY_FILE"
mkdir -p "$OPEN_TEST_ROOT_ABS"

run_capture env OPEN_HANDOFF_BASE="$OPEN_TEST_ROOT_ABS" ./ops/bin/open --out=auto --tag=open-test
if [[ "$RUN_STATUS" -ne 0 ]]; then
  fail "ops/bin/open failed during de-dup test"
  printf '%s\n' "$RUN_OUTPUT" >&2
fi

open_path="$(parse_output_path "OPEN saved")"
if [[ -z "$open_path" ]]; then
  fail "open output missing OPEN saved path"
fi

open_path="$(normalize_rel_path "$open_path")"
if [[ -n "$open_path" ]]; then
  assert_file_exists "$open_path"
  queue_cleanup_path "$open_path"

  assert_contains "$open_path" "- Porcelain entries:"
  assert_contains "$open_path" "- Porcelain artifact: emitted"
  assert_contains "$open_path" "- Porcelain saved: ${OPEN_TEST_ROOT}/OPEN-PORCELAIN-open-test-"
  assert_absent "$open_path" "- Porcelain (git status --porcelain):"
  assert_absent "$open_path" "- Porcelain preview (truncated to 50 lines):"

  porcelain_ref="$(sed -n 's/^- Porcelain saved:[[:space:]]*//p' "${REPO_ROOT}/${open_path}" | head -n 1)"
  porcelain_ref="$(normalize_rel_path "$porcelain_ref")"

  if [[ -z "$porcelain_ref" || "$porcelain_ref" == "(suppressed: clean working tree)" ]]; then
    fail "open de-dup test expected porcelain artifact pointer in OPEN"
  else
    assert_file_exists "$porcelain_ref"
    assert_file_not_empty "$porcelain_ref"
    queue_cleanup_path "$porcelain_ref"
  fi
fi

if (( FAILURES > 0 )); then
  exit 1
fi

echo "PASS: open de-dup test"
