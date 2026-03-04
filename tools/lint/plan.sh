#!/usr/bin/env bash
set -euo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${REPO_ROOT}/ops/lib/scripts/common.sh"

cd "$REPO_ROOT"
trap 'emit_binary_leaf "lint-plan" "finish"' EXIT
emit_binary_leaf "lint-plan" "start"

usage() {
  cat <<'USAGE'
Usage: bash tools/lint/plan.sh [--test] [path]
Default path: storage/handoff/PLAN.md
USAGE
}

trim_inline() {
  local value="$1"
  value="${value#./}"
  if [[ "$value" == "${REPO_ROOT}/"* ]]; then
    value="${value#${REPO_ROOT}/}"
  fi
  printf '%s' "$value"
}

plan_fail() {
  echo "FAIL: $*" >&2
  return 1
}

plan_require_pattern() {
  local abs_path="$1"
  local pattern="$2"
  local message="$3"
  if ! grep -Eq "$pattern" "$abs_path"; then
    plan_fail "$message"
    return 1
  fi
  return 0
}

lint_plan_file() {
  local input_path="$1"
  local rel_path
  rel_path="$(trim_inline "$input_path")"
  local abs_path="${REPO_ROOT}/${rel_path}"

  if [[ ! -f "$abs_path" ]]; then
    plan_fail "PLAN file not found: ${rel_path}"
    return 1
  fi

  if [[ ! -s "$abs_path" ]]; then
    plan_fail "PLAN file is empty: ${rel_path}"
    return 1
  fi

  if ! grep -Eq '^#{1,6}[[:space:]]+[^[:space:]]' "$abs_path"; then
    plan_fail "PLAN file requires at least one markdown heading: ${rel_path}"
    return 1
  fi

  if ! awk '
    /^[[:space:]]*$/ { next }
    /^#{1,6}[[:space:]]+/ { next }
    { found=1; exit }
    END { exit found ? 0 : 1 }
  ' "$abs_path"; then
    plan_fail "PLAN file requires non-heading content: ${rel_path}"
    return 1
  fi

  if grep -Eq '\{\{[A-Z0-9_]+\}\}' "$abs_path"; then
    plan_fail "PLAN file contains unresolved template tokens: ${rel_path}"
    return 1
  fi

  local has_architect_handoff=0
  if grep -Eq '^##+[[:space:]]+Architect Handoff([[:space:]]*)$' "$abs_path"; then
    has_architect_handoff=1
  fi

  if (( has_architect_handoff )); then
    plan_require_pattern "$abs_path" 'Selected Option:[[:space:]]+[^[:space:]]+' "Architect Handoff requires 'Selected Option:' value (${rel_path})" || return 1
    plan_require_pattern "$abs_path" 'Slice Mode:[[:space:]]+(single|multi)' "Architect Handoff requires 'Slice Mode: single|multi' (${rel_path})" || return 1
    plan_require_pattern "$abs_path" 'Selected Slices:[[:space:]]+[^[:space:]]+' "Architect Handoff requires 'Selected Slices:' value (${rel_path})" || return 1

    if grep -Eq 'Slice Mode:[[:space:]]+multi([[:space:]]|$)' "$abs_path"; then
      plan_require_pattern "$abs_path" 'Execution Order:[[:space:]]+[^[:space:]]+' "Architect Handoff requires 'Execution Order:' when Slice Mode is multi (${rel_path})" || return 1
    fi
  fi

  echo "PLAN lint: PASS (${rel_path})"
  return 0
}

run_tests() {
  local test_dir="var/tmp/lint-plan-test-$RANDOM$RANDOM"
  local failures=0

  mkdir -p "$test_dir"
  trap 'rm -rf "${test_dir}"' RETURN

  cat > "${test_dir}/valid.md" <<'EOF_VALID'
# PLAN

## Objective
Ship bundle routing.
EOF_VALID

  cat > "${test_dir}/no-heading.md" <<'EOF_NO_HEADING'
Ship bundle routing without headings.
EOF_NO_HEADING

  cat > "${test_dir}/heading-only.md" <<'EOF_HEADING_ONLY'
# PLAN
## Objective
EOF_HEADING_ONLY

  cat > "${test_dir}/token.md" <<'EOF_TOKEN'
# PLAN

{{PLACEHOLDER}}
EOF_TOKEN

  cat > "${test_dir}/architect-valid.md" <<'EOF_ARCH_OK'
# PLAN

## Architect Handoff
- Selected Option: RECOMMENDED
- Slice Mode: single
- Selected Slices: S1
EOF_ARCH_OK

  cat > "${test_dir}/architect-missing-slices.md" <<'EOF_ARCH_MISSING_SLICES'
# PLAN

## Architect Handoff
- Selected Option: RECOMMENDED
- Slice Mode: single
EOF_ARCH_MISSING_SLICES

  cat > "${test_dir}/architect-multi-missing-order.md" <<'EOF_ARCH_MULTI_NO_ORDER'
# PLAN

## Architect Handoff
- Selected Option: RECOMMENDED
- Slice Mode: multi
- Selected Slices: S1,S2
EOF_ARCH_MULTI_NO_ORDER

  if ! lint_plan_file "${test_dir}/valid.md" >/dev/null 2>&1; then
    echo "FAIL: --test expected valid plan to pass" >&2
    failures=1
  fi

  if lint_plan_file "${test_dir}/no-heading.md" >/dev/null 2>&1; then
    echo "FAIL: --test expected missing heading to fail" >&2
    failures=1
  fi

  if lint_plan_file "${test_dir}/heading-only.md" >/dev/null 2>&1; then
    echo "FAIL: --test expected heading-only plan to fail" >&2
    failures=1
  fi

  if lint_plan_file "${test_dir}/token.md" >/dev/null 2>&1; then
    echo "FAIL: --test expected unresolved token to fail" >&2
    failures=1
  fi

  if lint_plan_file "${test_dir}/missing.md" >/dev/null 2>&1; then
    echo "FAIL: --test expected missing file to fail" >&2
    failures=1
  fi

  if ! lint_plan_file "${test_dir}/architect-valid.md" >/dev/null 2>&1; then
    echo "FAIL: --test expected architect-valid plan to pass" >&2
    failures=1
  fi

  if lint_plan_file "${test_dir}/architect-missing-slices.md" >/dev/null 2>&1; then
    echo "FAIL: --test expected architect plan missing selected slices to fail" >&2
    failures=1
  fi

  if lint_plan_file "${test_dir}/architect-multi-missing-order.md" >/dev/null 2>&1; then
    echo "FAIL: --test expected architect multi plan missing execution order to fail" >&2
    failures=1
  fi

  if (( failures != 0 )); then
    return 1
  fi

  echo "OK: --test passed"
}

run_test=0
plan_path="storage/handoff/PLAN.md"

while (($# > 0)); do
  case "$1" in
    --test)
      run_test=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      if [[ "$plan_path" != "storage/handoff/PLAN.md" ]]; then
        plan_fail "unexpected argument: $1"
        exit 1
      fi
      plan_path="$1"
      ;;
  esac
  shift
done

if (( run_test == 1 )); then
  run_tests
  exit $?
fi

lint_plan_file "$plan_path"
