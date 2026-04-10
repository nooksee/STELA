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
DP_TEST_ROOT="var/tmp/_smoke/dp-$$"
DP_TEST_ROOT_ABS="${REPO_ROOT}/${DP_TEST_ROOT}"

cleanup_generated() {
  rm -rf -- "$DP_TEST_ROOT_ABS"
}

trap 'cleanup_generated; emit_binary_leaf "test-dp" "finish"' EXIT
emit_binary_leaf "test-dp" "start"

fail() {
  echo "FAIL: $*" >&2
  FAILURES=$((FAILURES + 1))
}

assert_output_contains() {
  local output="$1"
  local needle="$2"
  local label="$3"
  if [[ "$output" != *"$needle"* ]]; then
    fail "${label}: expected output to contain '${needle}'"
  fi
}

write_valid_dp_fixture() {
  local path="$1"
  local template_source
  local dp_scoped_load_order
  local objective
  local in_scope
  local out_scope
  local safety
  local plan_state
  local plan_request
  local plan_changelog
  local plan_patch
  local receipt_extra
  local cbc_preflight

  dp_scoped_load_order='- tools/test/dp.sh
- tools/lint/dp.sh
- docs/ops/specs/tools/lint/dp.md'
  objective='Add deterministic explicit-path regression coverage for dp lint delete/load-order contradictions without changing live lint semantics.'
  in_scope='- tools/test/dp.sh
- docs/ops/specs/tools/lint/dp.md'
  out_scope='- tools/lint/dp.sh semantic changes
- unrelated repo refactors'
  safety='- Keep the harness deterministic and fixture-first.
- Call bash tools/lint/dp.sh on synthetic fixtures directly.'
  plan_state='- tools/lint/dp.sh already catches delete/load-order contradictions inside bash tools/lint/dp.sh --test.'
  plan_request='- Add an external explicit-path PASS fixture and a deterministic delete/load-order contradiction FAIL fixture.'
  plan_changelog='- ADD tools/test/dp.sh
- UPDATE docs/ops/specs/tools/lint/dp.md'
  plan_patch='- Added a canonical PASS fixture for explicit-path dp lint coverage.
- Added a deterministic FAIL fixture for a DELETE path still present in 3.2.2 DP-scoped load order.'
  receipt_extra='- bash tools/lint/truth.sh
- bash tools/lint/style.sh
- bash tools/lint/integrity.sh
- bash -n tools/test/dp.sh
- bash tools/test/dp.sh
- git diff --exit-code -- tools/lint/dp.sh ops/src/surfaces/dp.md.tpl tools/lint/task.sh ops/bin/certify tools/test/results.sh
- git diff --check'
  cbc_preflight='Not applicable. This packet adds synthetic regression coverage and directly coupled spec text; it does not change a live enforcement surface.'

  template_source="$(mktemp)"
  ./ops/bin/template render dp --non-strict --out="$template_source"

  : > "$path"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//'{{DP_ID}}'/DP-OPS-0000}"
    line="${line//'{{DP_TITLE}}'/Fixture explicit-path delete-load-order coverage}"
    line="${line//'{{BASE_BRANCH}}'/main}"
    line="${line//'{{PROPOSED_WORK_BRANCH}}'/work/dp-ops-0000-2026-04-10}"
    line="${line//'{{BASE_HEAD}}'/ba4f936c}"
    line="${line//'{{FRESHNESS_STAMP}}'/2026-04-10}"
    line="${line//'{{OPEN_ANCHOR_PATH}}'/storage/handoff/OPEN-main-ba4f936c.txt}"
    line="${line//'{{OPEN_TRACE_ID}}'/stela-20260410T000000Z-fixture0001}"
    line="${line//'{{OPEN_WORKING_TREE}}'/clean}"

    case "$line" in
      "{{DP_SCOPED_LOAD_ORDER}}")
        printf '%s\n' "$dp_scoped_load_order" >> "$path"
        ;;
      "{{OBJECTIVE}}")
        printf '%s\n' "$objective" >> "$path"
        ;;
      "{{IN_SCOPE}}")
        printf '%s\n' "$in_scope" >> "$path"
        ;;
      "{{OUT_OF_SCOPE}}")
        printf '%s\n' "$out_scope" >> "$path"
        ;;
      "{{SAFETY_INVARIANTS}}")
        printf '%s\n' "$safety" >> "$path"
        ;;
      "{{PLAN_STATE}}")
        printf '%s\n' "$plan_state" >> "$path"
        ;;
      "{{PLAN_REQUEST}}")
        printf '%s\n' "$plan_request" >> "$path"
        ;;
      "{{PLAN_CHANGELOG}}")
        printf '%s\n' "$plan_changelog" >> "$path"
        ;;
      "{{PLAN_PATCH}}")
        printf '%s\n' "$plan_patch" >> "$path"
        ;;
      "{{RECEIPT_EXTRA}}")
        printf '%s\n' "$receipt_extra" >> "$path"
        ;;
      "{{CBC_PREFLIGHT}}")
        printf '%s\n' "$cbc_preflight" >> "$path"
        ;;
      *)
        printf '%s\n' "$line" >> "$path"
        ;;
    esac
  done < "$template_source"

  rm -f "$template_source"
}

run_expect_pass() {
  local label="$1"
  local path="$2"
  local output=""

  if ! output="$(bash tools/lint/dp.sh "$path" 2>&1)"; then
    fail "${label}: expected pass"
    printf '%s\n' "$output" >&2
    return
  fi

  assert_output_contains "$output" "OK: DP lint passed" "$label"
}

run_expect_fail() {
  local label="$1"
  local path="$2"
  local expected="$3"
  local output=""

  if output="$(bash tools/lint/dp.sh "$path" 2>&1)"; then
    fail "${label}: expected failure"
    printf '%s\n' "$output" >&2
    return
  fi

  assert_output_contains "$output" "$expected" "$label"
}

mkdir -p "$DP_TEST_ROOT_ABS"

valid_fixture="${DP_TEST_ROOT_ABS}/valid-DP.md"
write_valid_dp_fixture "$valid_fixture"
run_expect_pass "valid explicit-path fixture" "$valid_fixture"

delete_load_order_fixture="${DP_TEST_ROOT_ABS}/delete-load-order-DP.md"
cp "$valid_fixture" "$delete_load_order_fixture"
python3 - "$delete_load_order_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
lines = path.read_text().splitlines()
patched = []
inserted = False
for line in lines:
    patched.append(line)
    if line == "### 3.4.3 Changelog" and not inserted:
        patched.append("- DELETE docs/ops/specs/tools/lint/dp.md")
        inserted = True
path.write_text("\n".join(patched) + "\n")
PY
run_expect_fail \
  "delete/load-order contradiction fixture" \
  "$delete_load_order_fixture" \
  "§3.4.3 declares DELETE path still present in §3.2.2 DP-scoped load order: docs/ops/specs/tools/lint/dp.md"

work_branch_fixture="${DP_TEST_ROOT_ABS}/work-branch-DP.md"
cp "$valid_fixture" "$work_branch_fixture"
python3 - "$work_branch_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("Work Branch: work/dp-ops-0000-2026-04-10", "Work Branch: work/no-date-fragment", 1)
path.write_text(text)
PY
run_expect_fail \
  "invalid work branch fixture" \
  "$work_branch_fixture" \
  "Work Branch must follow 'work/<DP-ID>-YYYY-MM-DD' form (PoT.md §6.2.1): work/no-date-fragment"

sidecar_fixture="${DP_TEST_ROOT_ABS}/sidecar-coherence-DP.md"
cp "$valid_fixture" "$sidecar_fixture"
python3 - "$sidecar_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("storage/handoff/CLOSING.md", "storage/handoff/CLOSING-DP-OPS-9999.md", 1)
path.write_text(text)
PY
run_expect_fail \
  "closing sidecar coherence fixture" \
  "$sidecar_fixture" \
  "closing-sidecar DP id mismatch: heading uses 'DP-OPS-0000' but §3.5.1 uses 'DP-OPS-9999'"

drafting_marker_fixture="${DP_TEST_ROOT_ABS}/drafting-marker-DP.md"
cp "$valid_fixture" "$drafting_marker_fixture"
python3 - "$drafting_marker_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("Work Branch: work/dp-ops-0000-2026-04-10", "Work Branch: PROPOSED-work/dp-ops-0000-2026-04-10", 1)
path.write_text(text)
PY
run_expect_fail \
  "drafting-marker residue fixture" \
  "$drafting_marker_fixture" \
  "PROPOSED is a drafting marker and must not appear in a finalized DP"

contamination_fixture="${DP_TEST_ROOT_ABS}/contamination-DP.md"
cp "$valid_fixture" "$contamination_fixture"
printf '%s\n' ':contentReference[oaicite:0]{index=0}' >> "$contamination_fixture"
run_expect_fail \
  "foreign citation contamination fixture" \
  "$contamination_fixture" \
  "dp: contamination: line"

metadata_leak_fixture="${DP_TEST_ROOT_ABS}/metadata-leak-DP.md"
cp "$valid_fixture" "$metadata_leak_fixture"
printf '%s\n' '<!-- CCD: ff_target="test" ff_band="10-20" -->' >> "$metadata_leak_fixture"
run_expect_fail \
  "include metadata leakage fixture" \
  "$metadata_leak_fixture" \
  "dp: include metadata leakage: line"

if (( FAILURES > 0 )); then
  exit 1
fi

echo "PASS: dp lint synthetic-fixture tests"
