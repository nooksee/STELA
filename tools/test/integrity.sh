#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(git rev-parse --show-toplevel)"
TEST_ROOT="${SOURCE_ROOT}/var/tmp/_smoke/integrity-$$"
PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
  rm -rf -- "$TEST_ROOT"
  emit_binary_leaf "test-integrity" "finish"
}

# shellcheck source=/dev/null
source "${SOURCE_ROOT}/ops/lib/scripts/common.sh"
trap cleanup EXIT
emit_binary_leaf "test-integrity" "start"

record_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
}

record_fail() {
  echo "FAIL: $*" >&2
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

write_task() {
  local repo="$1"
  local routing_state="$2"
  local packet_state="$3"
  shift 3
  {
    printf 'Routing State: %s\n' "$routing_state"
    printf 'Packet State: %s\n' "$packet_state"
    printf 'Packet ID: DP-OPS-9000\n\n'
    printf 'In scope:\n'
    for path in "$@"; do
      printf -- '- %s\n' "$path"
    done
    printf '\nOut of scope:\n- everything else\n\n'
    printf 'Target Files allowlist (hard gate):\n'
    printf -- '- storage/dp/active/allowlist.txt\n\n'
    printf '### 3.4.3 Changelog\n'
    printf 'UPDATE:\n'
    for path in "$@"; do
      printf -- '- %s\n' "$path"
    done
    printf '### 3.4.4 Validation\n\n'
    printf '### CbC Design Discipline Preflight\n'
    printf 'Required when the DP objective changes a live tool.\n'
    printf 'For non-tooling DPs:\n'
    printf 'Not applicable. Synthetic scope fixture.\n'
  } > "${repo}/TASK.md"
}

make_case() {
  local name="$1"
  local routing_state="$2"
  local packet_state="$3"
  local policy_text="$4"
  shift 4
  local repo="${TEST_ROOT}/${name}"

  mkdir -p "${repo}/ops/lib/scripts" "${repo}/tools/lint" \
    "${repo}/storage/dp/active" "${repo}/storage/dp/intake" "${repo}/data"
  cp "${SOURCE_ROOT}/ops/lib/scripts/common.sh" "${repo}/ops/lib/scripts/common.sh"
  cp "${SOURCE_ROOT}/tools/lint/integrity.sh" "${repo}/tools/lint/integrity.sh"
  chmod +x "${repo}/tools/lint/integrity.sh"
  printf 'logs/\nstorage/dp/intake/\n' > "${repo}/.gitignore"
  printf '%s\n' "$policy_text" > "${repo}/storage/dp/active/allowlist.txt"
  printf 'declared\n' > "${repo}/data/declared.txt"
  printf 'historical\n' > "${repo}/data/historical.txt"
  printf 'delete\n' > "${repo}/data/delete.txt"
  write_task "$repo" "$routing_state" "$packet_state" "$@"

  git -C "$repo" init -q
  git -C "$repo" config user.name "STELA Fixture"
  git -C "$repo" config user.email "stela-fixture@example.invalid"
  git -C "$repo" add .
  git -C "$repo" commit -qm "fixture baseline"
  printf '%s' "$repo"
}

expect_pass() {
  local label="$1"
  local repo="$2"
  local expected="$3"
  local output=""
  if ! output="$(cd "$repo" && bash tools/lint/integrity.sh 2>&1)"; then
    record_fail "${label}: expected pass"
    printf '%s\n' "$output" >&2
    return
  fi
  if [[ "$output" != *"$expected"* ]]; then
    record_fail "${label}: missing expected output '${expected}'"
    return
  fi
  record_pass
}

expect_fail() {
  local label="$1"
  local repo="$2"
  local expected="$3"
  local output=""
  if output="$(cd "$repo" && bash tools/lint/integrity.sh 2>&1)"; then
    record_fail "${label}: expected failure"
    return
  fi
  if [[ "$output" != *"$expected"* ]]; then
    record_fail "${label}: missing expected output '${expected}'"
    printf '%s\n' "$output" >&2
    return
  fi
  record_pass
}

mkdir -p "$TEST_ROOT"

repo="$(make_case declared-pass ACTIVE ACTIVE $'data/declared.txt\nstorage/dp/active/allowlist.txt' data/declared.txt)"
printf 'change\n' >> "${repo}/data/declared.txt"
expect_pass "declared path with persistent coverage" "$repo" "Integrity scope mode: packet-exact"

repo="$(make_case wildcard-ceiling ACTIVE ACTIVE $'data/*.txt\nstorage/dp/active/allowlist.txt' data/declared.txt)"
printf 'change\n' >> "${repo}/data/historical.txt"
expect_fail "persistent wildcard cannot widen packet scope" "$repo" "absent from the active packet exact mutation scope"

repo="$(make_case packet-only ACTIVE ACTIVE $'data/declared.txt\nstorage/dp/active/allowlist.txt' data/new.txt)"
printf 'new\n' > "${repo}/data/new.txt"
expect_fail "packet declaration cannot bypass persistent policy" "$repo" "absent from persistent path policy"

repo="$(make_case undeclared-delete ACTIVE ACTIVE $'data/delete.txt\nstorage/dp/active/allowlist.txt' data/declared.txt)"
rm "${repo}/data/delete.txt"
expect_fail "undeclared deletion remains packet-gated" "$repo" "absent from the active packet exact mutation scope"

repo="$(make_case declared-delete ACTIVE ACTIVE $'data/delete.txt\nstorage/dp/active/allowlist.txt' data/delete.txt storage/dp/active/allowlist.txt)"
rm "${repo}/data/delete.txt"
printf 'storage/dp/active/allowlist.txt\n' > "${repo}/storage/dp/active/allowlist.txt"
expect_pass "declared deletion may retire its prior persistent entry" "$repo" "OK: integrity lint passed"

repo="$(make_case addendum-pass ACTIVE ACTIVE $'data/addendum.txt\nstorage/dp/active/allowlist.txt' data/declared.txt)"
printf 'new\n' > "${repo}/data/addendum.txt"
{
  printf 'Base Packet: DP-OPS-9000\n\n'
  printf 'Exact paths added by this addendum (one per line; no globs; no brace expansion):\n'
  printf -- '- data/addendum.txt\n'
  printf '## A.3 Verification\n'
} > "${repo}/storage/dp/intake/ADDENDUM.md"
expect_pass "matching addendum extends exact scope" "$repo" "Addendum scope paths: 1"

repo="$(make_case addendum-mismatch ACTIVE ACTIVE $'data/addendum.txt\nstorage/dp/active/allowlist.txt' data/declared.txt)"
printf 'new\n' > "${repo}/data/addendum.txt"
{
  printf 'Base Packet: DP-OPS-9001\n\n'
  printf 'Exact paths added by this addendum (one per line; no globs; no brace expansion):\n'
  printf -- '- data/addendum.txt\n'
  printf '## A.3 Verification\n'
} > "${repo}/storage/dp/intake/ADDENDUM.md"
expect_fail "mismatched addendum fails closed" "$repo" "active addendum does not provide a valid exact scope delta"

repo="$(make_case idle-maintenance IDLE COMPLETED $'data/historical.txt\nstorage/dp/active/allowlist.txt' data/declared.txt)"
printf 'change\n' >> "${repo}/data/historical.txt"
expect_pass "idle maintenance uses persistent policy transparently" "$repo" "Integrity scope mode: maintenance-idle"

repo="$(make_case idle-addendum IDLE COMPLETED $'data/historical.txt\nstorage/dp/active/allowlist.txt' data/declared.txt)"
{
  printf 'Base Packet: DP-OPS-9000\n\n'
  printf 'Exact paths added by this addendum (one per line; no globs; no brace expansion):\n'
  printf -- '- data/historical.txt\n'
  printf '## A.3 Verification\n'
} > "${repo}/storage/dp/intake/ADDENDUM.md"
expect_fail "idle routing rejects active addendum scope" "$repo" "addendum scope exists while TASK routing is IDLE"

if (( FAIL_COUNT > 0 )); then
  echo "Integrity scope fixture summary: pass=${PASS_COUNT} fail=${FAIL_COUNT}"
  exit 1
fi

echo "Integrity scope fixture summary: pass=${PASS_COUNT} fail=0"
