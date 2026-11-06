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

repo="$(make_case compile-leaf-current ACTIVE ACTIVE $'data/declared.txt\nstorage/dp/active/allowlist.txt' data/declared.txt)"
mkdir -p "${repo}/archives/manifests"
fixture_head="$(git -C "$repo" rev-parse --short HEAD)"
printf 'snapshot\n' > "${repo}/archives/manifests/compile-2026-01-01T000000-${fixture_head}.md"
expect_pass "untracked compile leaf stamped with HEAD is current-run output" "$repo" "Current-run compile leaves: 1"

repo="$(make_case compile-leaf-foreign ACTIVE ACTIVE $'data/declared.txt\nstorage/dp/active/allowlist.txt' data/declared.txt)"
mkdir -p "${repo}/archives/manifests"
printf 'snapshot\n' > "${repo}/archives/manifests/compile-2026-01-01T000000-0badc0de.md"
expect_fail "compile leaf stamped with another hash stays packet-gated" "$repo" "absent from the active packet exact mutation scope"

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

# Certify dry-run fixture (DP-OPS-0271): a synthetic packet, DP-OPS-9000, in a
# copy of the working tree, so the closeout preflight path (packet, work branch,
# OPEN anchor, closing sidecar, artifact paths, authored heads, integrity gate,
# narrative) and the postflight dual-scope check run without a live packet. The
# replay stays live-only: a dry run emits no leaf and rewrites no head.
make_certify_dry_run_fixture() {
  local repo="${TEST_ROOT}/certify-dry-run"
  local stamp
  stamp="$(date -u +%Y-%m-%d)"
  mkdir -p "$repo"
  (cd "$SOURCE_ROOT" && { git ls-files -z; git ls-files -z --others --exclude-standard; } | tar --null -T - -cf -) \
    | tar -C "$repo" -xf -
  git -C "$repo" init -q -b main
  git -C "$repo" config user.name "STELA Fixture"
  git -C "$repo" config user.email "stela-fixture@example.invalid"
  git -C "$repo" add -A . >/dev/null
  git -C "$repo" commit -qm "fixture baseline"
  local base
  base="$(git -C "$repo" rev-parse --short HEAD)"
  git -C "$repo" checkout -q -b "agent/dp-ops-9000-${stamp}"
  (cd "$repo" && ./ops/bin/open --out=auto >/dev/null)
  cat > "${repo}/var-dry-slots.txt" <<'SLOTS'
[DP_SCOPED_LOAD_ORDER]
- docs/INDEX.md

[OBJECTIVE]
- Synthetic packet for the certify dry-run fixture.

[IN_SCOPE]
- `docs/fixture-dry-run.md`: one synthetic file.

[OUT_OF_SCOPE]
- Everything else.

[SAFETY_INVARIANTS]
- No leaf is emitted by a dry run.

[PLAN_STATE]
- No synthetic file exists.

[PLAN_REQUEST]
- Create the synthetic file.

[PLAN_CHANGELOG]
- NEW docs/fixture-dry-run.md
- UPDATE storage/dp/active/allowlist.txt
- UPDATE SoP.md
- UPDATE PoW.md

[PLAN_PATCH]
1. Create the file.

[RECEIPT_EXTRA]
- bash tools/lint/truth.sh

[CBC_PREFLIGHT]
Not applicable. Synthetic fixture.
SLOTS
  mv "${repo}/var-dry-slots.txt" "${repo}/var/tmp/dry-slots.txt" 2>/dev/null || { mkdir -p "${repo}/var/tmp"; mv "${repo}/var-dry-slots.txt" "${repo}/var/tmp/dry-slots.txt"; }
  (cd "$repo" && ./ops/bin/draft --id=DP-OPS-9000 --title="Certify dry-run fixture" \
    --work-branch="agent/dp-ops-9000-${stamp}" --base-head="$base" --slots-file=var/tmp/dry-slots.txt >/dev/null)
  (cd "$repo" && ./ops/bin/llms >/dev/null)
  git -C "$repo" add -A . >/dev/null
  git -C "$repo" commit -qm "DP-OPS-9000: open packet"
  printf '<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->\n# Fixture\n\nSynthetic.\n' > "${repo}/docs/fixture-dry-run.md"
  printf 'docs/fixture-dry-run.md\n' >> "${repo}/storage/dp/active/allowlist.txt"
  git -C "$repo" add docs/fixture-dry-run.md
  local ts
  ts="$(date -u '+%Y-%m-%d %H:%M:%S')"
  printf '# STELA STATE OF PLAY\n\n- Current objective: Fixture.\n- Accepted baseline: Fixture.\n- Provisional work: None.\n- Unresolved tensions: None.\n- Rejected directions: None.\n- Exact next action: None.\n\n## %s UTC — DP-OPS-9000 Certify dry-run fixture\n\n- Latest certified shipment: DP-OPS-9000.\n' "$ts" > "${repo}/SoP.md"
  printf '# Current proof entry only\n## %s UTC — DP-OPS-9000 Certify dry-run fixture\n\n- Packet ID: DP-OPS-9000\n- Timestamp: %s\n- Work Branch: agent/dp-ops-9000-%s\n- Base HEAD: %s\n- Scope:\n  - docs/fixture-dry-run.md\n- Target Files allowlist: `storage/dp/active/allowlist.txt`\n- Receipt pointers:\n  - RESULTS: generated by certify\n  - PACKET: generated by certify\n- Notes:\n  - Fixture.\n' "$ts" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$stamp" "$base" > "${repo}/PoW.md"
  cat > "${repo}/storage/handoff/CLOSING.md" <<'CLOSE'
# Closing Block Sidecar — DP-OPS-9000

## Section 1: Current Closeout Labels
Commit Message
Add the dry-run fixture file

Create Pull Request (Title)
FIXTURE DP-OPS-9000 TEST: certify dry-run fixture

Create Pull Request (Description)
## What changed
- One synthetic file for the certify dry-run fixture.

Confirm Merge (Commit Message)
Merge pull request: fixture (DP-OPS-9000)

Confirm Merge (Extended Description)
docs/fixture-dry-run.md

Confirm Merge (Add a Comment)
Does the fixture exercise the preflight path it claims to?
CLOSE
  cat > "${repo}/var/tmp/dry-narrative.md" <<'NARR'
### Preflight State
git rev-parse --abbrev-ref HEAD
agent/dp-ops-9000
git rev-parse --short HEAD
fixture
git status --porcelain
(no output)
Preflight lint status: fixture.

### Implemented Changes
- docs/fixture-dry-run.md created.

### Closeout Notes
None.

### Decision Leaf
Decision Required: No
Decision Leaf: None
NARR
  printf '%s' "$repo"
}

expect_dry_run() {
  local label="$1"
  local repo="$2"
  local want="$3"
  local expected="$4"
  local output="" rc=0
  output="$(cd "$repo" && ./ops/bin/certify --dp=DP-OPS-9000 --dry-run --narrative-file=var/tmp/dry-narrative.md --out=auto 2>&1)" || rc=$?
  if [[ "$want" == "pass" && $rc -ne 0 ]]; then
    record_fail "${label}: expected dry run to pass (exit ${rc})"
    printf '%s\n' "$output" >&2
    return
  fi
  if [[ "$want" == "fail" && $rc -eq 0 ]]; then
    record_fail "${label}: expected dry run to fail"
    return
  fi
  if [[ "$output" != *"$expected"* ]]; then
    record_fail "${label}: missing expected output '${expected}'"
    printf '%s\n' "$output" >&2
    return
  fi
  local leaves
  leaves="$(ls "${repo}/archives/surfaces" 2>/dev/null | grep -c 'DP-OPS-9000' || true)"
  if [[ "$leaves" != "0" ]]; then
    record_fail "${label}: dry run emitted ${leaves} leaf file(s)"
    return
  fi
  record_pass
}

repo="$(make_certify_dry_run_fixture)"
expect_dry_run "certify dry run passes preflight and dual scope on a synthetic packet" "$repo" pass "CERTIFY-DRY-RUN: PASS dp=DP-OPS-9000"
printf 'undeclared\n' > "${repo}/docs/fixture-undeclared.md"
expect_dry_run "certify dry run fails closed at the integrity gate on an undeclared path" "$repo" fail "integrity gate failed"

if (( FAIL_COUNT > 0 )); then
  echo "Integrity scope fixture summary: pass=${PASS_COUNT} fail=${FAIL_COUNT}"
  exit 1
fi

echo "Integrity scope fixture summary: pass=${PASS_COUNT} fail=0"
