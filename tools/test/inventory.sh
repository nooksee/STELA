#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(git rev-parse --show-toplevel)"
TEST_ROOT="${SOURCE_ROOT}/var/tmp/_smoke/inventory-$$"
PASS_COUNT=0
FAIL_COUNT=0

# shellcheck source=/dev/null
source "${SOURCE_ROOT}/ops/lib/scripts/common.sh"

cleanup() {
  rm -rf -- "$TEST_ROOT"
  emit_binary_leaf "test-inventory" "finish"
}

trap cleanup EXIT
emit_binary_leaf "test-inventory" "start"
mkdir -p "$TEST_ROOT"

record_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
}

record_fail() {
  echo "FAIL: $*" >&2
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

assert_contains() {
  local label="$1"
  local output="$2"
  local expected="$3"
  if [[ "$output" == *"$expected"* ]]; then
    record_pass
  else
    record_fail "${label}: missing expected output '${expected}'"
  fi
}

first_output=""
second_output=""
first_status=0
second_status=0
decision_template="ops/src/decisions/"'dec.md.tpl'
documentation_template="ops/src/docs/"'readme.md.tpl'
closing_template="ops/src/surfaces/"'closing.md.tpl'
planning_template="ops/src/stances/"'planning.md.tpl'

if first_output="$(cd "$SOURCE_ROOT" && bash tools/verify.sh --inventory 2>&1)"; then
  first_status=0
else
  first_status=$?
fi
if second_output="$(cd "$SOURCE_ROOT" && bash tools/verify.sh --inventory 2>&1)"; then
  second_status=0
else
  second_status=$?
fi

if (( first_status == 0 )); then
  record_pass
else
  record_fail "first inventory run exited ${first_status}"
fi

if (( second_status == 0 )); then
  record_pass
else
  record_fail "second inventory run exited ${second_status}"
fi

if [[ "$first_output" == "$second_output" ]]; then
  record_pass
else
  record_fail "inventory output is not deterministic"
fi

assert_contains "contract" "$first_output" \
  "INVENTORY-CONTRACT version=1 mode=report-only lifecycle_inference=0"
assert_contains "binary summary" "$first_output" \
  "INVENTORY-SUMMARY kind=binary present=23 registered=23 present_registered=23 present_unregistered=0 registered_missing=0 spec_missing=0 metadata_missing=0"
assert_contains "test summary" "$first_output" \
  "INVENTORY-SUMMARY kind=test present=9 registered=7 present_registered=7 present_unregistered=2 registered_missing=0 spec_missing=2 metadata_missing=0"
assert_contains "template summary" "$first_output" \
  "INVENTORY-SUMMARY kind=template present=27 registered=26 present_registered=26 present_unregistered=1 registered_missing=0 spec_missing=0 metadata_missing=0"
assert_contains "total summary" "$first_output" \
  "INVENTORY-TOTAL kinds=8 present=95 registered=92 present_registered=92 present_unregistered=3 registered_missing=0 spec_missing=2 metadata_missing=0"
assert_contains "report-only status" "$first_output" \
  "INVENTORY-STATUS mismatches=report-only lifecycle_decisions=0 repository_mutations=0"
assert_contains "registered hygiene binary" "$first_output" \
  "INVENTORY-ITEM kind=binary path=ops/bin/hygiene present=1 registered=1"
assert_contains "registered trace binary" "$first_output" \
  "INVENTORY-ITEM kind=binary path=ops/bin/trace present=1 registered=1"
assert_contains "unregistered test" "$first_output" \
  "INVENTORY-ITEM kind=test path=tools/test/dp.sh present=1 registered=0"
assert_contains "registered closing template" "$first_output" \
  "INVENTORY-ITEM kind=template path=${closing_template} present=1 registered=1 executable=na spec=na spec_path=none policy_refs=0 declared_router=manifest literal_consumers=1 metadata_complete=1"
assert_contains "registered planning stance" "$first_output" \
  "INVENTORY-ITEM kind=template path=${planning_template} present=1 registered=1"
assert_contains "registered unused documentation template" "$first_output" \
  "INVENTORY-ITEM kind=template path=${documentation_template} present=1 registered=1"
assert_contains "unregistered decision template" "$first_output" \
  "INVENTORY-ITEM kind=template path=${decision_template} present=1 registered=0"

summary_count="$(printf '%s\n' "$first_output" | grep -c '^INVENTORY-SUMMARY ' || true)"
if [[ "$summary_count" == "8" ]]; then
  record_pass
else
  record_fail "expected 8 inventory family summaries, found ${summary_count}"
fi

if (( FAIL_COUNT > 0 )); then
  echo "Runtime inventory report contract: pass=${PASS_COUNT} fail=${FAIL_COUNT}"
  exit 1
fi

echo "Runtime inventory report contract: pass=${PASS_COUNT} fail=0"
