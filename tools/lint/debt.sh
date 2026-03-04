#!/usr/bin/env bash
set -euo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${REPO_ROOT}/ops/lib/scripts/common.sh"

cd "$REPO_ROOT"
trap 'emit_binary_leaf "lint-debt" "finish"' EXIT
emit_binary_leaf "lint-debt" "start"

usage() {
  cat <<'USAGE'
Usage: bash tools/lint/debt.sh [--test] [--list-stale] [--current-dp=DP-OPS-####] [path]
Default path: ops/lib/manifests/DEBT.md
USAGE
}

debt_fail() {
  echo "FAIL: $*" >&2
  return 1
}

trim_inline() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

dp_to_num() {
  local dp_id="$1"
  local raw=""
  if [[ "$dp_id" =~ ^DP-OPS-([0-9]{4})$ ]]; then
    raw="${BASH_REMATCH[1]}"
    printf '%s' "$((10#${raw}))"
    return 0
  fi
  return 1
}

resolve_task_source_path() {
  local source_path="TASK.md"
  local line_count
  line_count="$(awk 'END { print NR }' "$source_path")"
  if [[ "$line_count" != "1" ]]; then
    printf '%s' "$source_path"
    return 0
  fi

  local pointer_path
  pointer_path="$(trim_inline "$(cat "$source_path")")"
  pointer_path="${pointer_path#\`}"; pointer_path="${pointer_path%\`}"
  pointer_path="${pointer_path#./}"
  if [[ -f "${REPO_ROOT}/${pointer_path}" ]]; then
    printf '%s' "${REPO_ROOT}/${pointer_path}"
    return 0
  fi

  printf '%s' "$source_path"
}

resolve_current_dp_num() {
  local override="$1"
  local branch
  local source_path
  local dp_id

  if [[ -n "$override" ]]; then
    dp_to_num "$override" || die "invalid --current-dp value: ${override}"
    return 0
  fi

  branch="$(git rev-parse --abbrev-ref HEAD)"
  if [[ "$branch" =~ dp-ops-([0-9]{4}) ]]; then
    printf '%s' "$((10#${BASH_REMATCH[1]}))"
    return 0
  fi

  source_path="$(resolve_task_source_path)"
  dp_id="$(grep -E '^### DP-OPS-[0-9]{4}:' "$source_path" | head -n 1 | sed -E 's/^### (DP-OPS-[0-9]{4}):.*/\1/')"
  [[ -n "$dp_id" ]] || die "unable to resolve current DP id from branch or TASK"
  dp_to_num "$dp_id" || die "invalid current DP id resolved from TASK: ${dp_id}"
}

lint_debt_file() {
  local debt_path="$1"
  local list_stale="$2"
  local current_dp_num="$3"

  [[ -f "$debt_path" ]] || die "debt registry not found: ${debt_path}"
  [[ -s "$debt_path" ]] || die "debt registry is empty: ${debt_path}"

  if ! grep -Eq '^##[[:space:]]+Entries[[:space:]]*$' "$debt_path"; then
    debt_fail "missing '## Entries' section: ${debt_path}"
    return 1
  fi

  local failures=0
  local rows=0
  local stale_count=0
  local line_num=0
  local line=""
  local entries_started=0
  local guard_id=""
  local added_in=""
  local owner=""
  local remove_by_dp=""
  local reason=""
  local status=""
  local remove_by_num=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))

    if (( entries_started == 0 )); then
      if [[ "$line" =~ ^##[[:space:]]+Entries[[:space:]]*$ ]]; then
        entries_started=1
      fi
      continue
    fi

    if [[ "$line" =~ ^##[[:space:]]+ ]]; then
      break
    fi

    line="$(trim_inline "$line")"
    [[ -n "$line" ]] || continue
    [[ "$line" =~ ^# ]] && continue

    if [[ "$line" != *"|"* ]]; then
      debt_fail "line ${line_num}: invalid entry format (expected pipe-delimited fields)"
      failures=1
      continue
    fi

    IFS='|' read -r guard_id added_in owner remove_by_dp reason status extra <<< "$line"
    guard_id="$(trim_inline "$guard_id")"
    added_in="$(trim_inline "$added_in")"
    owner="$(trim_inline "$owner")"
    remove_by_dp="$(trim_inline "$remove_by_dp")"
    reason="$(trim_inline "$reason")"
    status="$(trim_inline "$status")"

    if [[ -n "${extra:-}" ]]; then
      debt_fail "line ${line_num}: invalid field count (expected 6)"
      failures=1
      continue
    fi

    rows=$((rows + 1))

    if [[ "$guard_id" == "NONE" && "$status" == "resolved" ]]; then
      continue
    fi

    if [[ -z "$guard_id" || -z "$added_in" || -z "$owner" || -z "$remove_by_dp" || -z "$reason" || -z "$status" ]]; then
      debt_fail "line ${line_num}: all fields are required"
      failures=1
      continue
    fi

    if ! [[ "$status" == "active" || "$status" == "resolved" ]]; then
      debt_fail "line ${line_num}: invalid status '${status}' (expected active or resolved)"
      failures=1
      continue
    fi

    if ! [[ "$added_in" =~ ^DP-OPS-[0-9]{4}$ ]]; then
      debt_fail "line ${line_num}: invalid added_in '${added_in}'"
      failures=1
      continue
    fi

    if ! [[ "$remove_by_dp" =~ ^DP-OPS-[0-9]{4}$ ]]; then
      debt_fail "line ${line_num}: invalid remove_by_dp '${remove_by_dp}'"
      failures=1
      continue
    fi

    remove_by_num="$(dp_to_num "$remove_by_dp")"

    if [[ "$status" == "active" && "$current_dp_num" -gt "$remove_by_num" ]]; then
      stale_count=$((stale_count + 1))
      if (( list_stale )); then
        printf '%s|%s|%s|%s\n' "$guard_id" "$remove_by_dp" "$owner" "$reason"
      fi
    fi
  done < "$debt_path"

  if (( rows == 0 )); then
    debt_fail "no entry rows found in debt registry"
    failures=1
  fi

  if (( failures != 0 )); then
    return 1
  fi

  if (( list_stale )); then
    return 0
  fi

  if (( stale_count > 0 )); then
    debt_fail "stale active guard debt entries detected: ${stale_count}"
    return 1
  fi

  echo "OK: debt lint passed (${debt_path#${REPO_ROOT}/})"
  return 0
}

run_tests() {
  local test_dir
  test_dir="$(mktemp -d)"
  trap 'rm -rf "$test_dir"' RETURN

  cat > "${test_dir}/valid.md" <<'EOF_VALID'
# Guard Debt Registry

## Entries
NONE|DP-OPS-0149|system|DP-OPS-0149|registry initialized|resolved
GUARD-001|DP-OPS-0149|ops|DP-OPS-0150|temporary lint check|active
EOF_VALID

  cat > "${test_dir}/malformed.md" <<'EOF_BAD'
# Guard Debt Registry

## Entries
GUARD-001|DP-OPS-0149|ops|DP-OPS-0150|missing status
EOF_BAD

  cat > "${test_dir}/stale.md" <<'EOF_STALE'
# Guard Debt Registry

## Entries
GUARD-001|DP-OPS-0148|ops|DP-OPS-0148|temporary lint check|active
EOF_STALE

  if ! lint_debt_file "${test_dir}/valid.md" 0 149 >/dev/null 2>&1; then
    echo "FAIL: --test expected valid debt file to pass" >&2
    return 1
  fi

  if lint_debt_file "${test_dir}/malformed.md" 0 149 >/dev/null 2>&1; then
    echo "FAIL: --test expected malformed debt file to fail" >&2
    return 1
  fi

  if lint_debt_file "${test_dir}/stale.md" 0 149 >/dev/null 2>&1; then
    echo "FAIL: --test expected stale debt file to fail" >&2
    return 1
  fi

  if ! lint_debt_file "${test_dir}/stale.md" 1 149 >/dev/null 2>&1; then
    echo "FAIL: --test expected --list-stale mode to succeed" >&2
    return 1
  fi

  echo "OK: --test passed"
  return 0
}

run_test_mode=0
list_stale_mode=0
current_dp_override=""
debt_path="ops/lib/manifests/DEBT.md"

while (($# > 0)); do
  case "$1" in
    --test)
      run_test_mode=1
      shift
      ;;
    --list-stale)
      list_stale_mode=1
      shift
      ;;
    --current-dp=*)
      current_dp_override="${1#--current-dp=}"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ "$debt_path" != "ops/lib/manifests/DEBT.md" ]]; then
        debt_fail "unexpected argument: $1"
        exit 1
      fi
      debt_path="$1"
      shift
      ;;
  esac
done

if (( run_test_mode )); then
  run_tests
  exit $?
fi

[[ "$debt_path" != /* ]] || die "debt registry path must be repo-relative"

current_dp_num="$(resolve_current_dp_num "$current_dp_override")"
lint_debt_file "$debt_path" "$list_stale_mode" "$current_dp_num"
