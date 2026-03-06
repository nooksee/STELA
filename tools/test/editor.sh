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
declare -a CLEANUP_PATHS=()
declare -A CLEANUP_SEEN=()
TASK_BASELINE_BACKUP_REL=""
TASK_POINTER_BACKUP_REL=""
TASK_POINTER_REL=""
TASK_RESTORE_NEEDED=0
TASK_POINTER_RESTORE_NEEDED=0
DRAFT_INTAKE_FIXTURE_REL=""
DRAFT_INTAKE_FIXTURE_PREEXISTED=0

cleanup_generated() {
  if [[ "$TASK_RESTORE_NEEDED" == "1" && -n "$TASK_BASELINE_BACKUP_REL" ]]; then
    if [[ -f "${REPO_ROOT}/${TASK_BASELINE_BACKUP_REL}" ]]; then
      cp -- "${REPO_ROOT}/${TASK_BASELINE_BACKUP_REL}" "${REPO_ROOT}/TASK.md"
    fi
  fi

  if [[ "$TASK_POINTER_RESTORE_NEEDED" == "1" && -n "$TASK_POINTER_REL" && -n "$TASK_POINTER_BACKUP_REL" ]]; then
    if [[ -f "${REPO_ROOT}/${TASK_POINTER_BACKUP_REL}" ]]; then
      cp -- "${REPO_ROOT}/${TASK_POINTER_BACKUP_REL}" "${REPO_ROOT}/${TASK_POINTER_REL}"
    fi
  fi

  if [[ -n "$DRAFT_INTAKE_FIXTURE_REL" && "$DRAFT_INTAKE_FIXTURE_PREEXISTED" != "1" ]]; then
    if [[ -e "${REPO_ROOT}/${DRAFT_INTAKE_FIXTURE_REL}" ]]; then
      rm -f -- "${REPO_ROOT}/${DRAFT_INTAKE_FIXTURE_REL}"
    fi
  fi

  local rel_path
  for rel_path in "${CLEANUP_PATHS[@]}"; do
    [[ -n "$rel_path" ]] || continue
    if [[ -e "${REPO_ROOT}/${rel_path}" ]]; then
      rm -f -- "${REPO_ROOT}/${rel_path}"
    fi
  done
}

trap 'cleanup_generated; emit_binary_leaf "test-editor" "finish"' EXIT
emit_binary_leaf "test-editor" "start"

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
    var/tmp/*)
      ;;
    *)
      fail "refusing to queue cleanup path outside var/tmp/: ${rel_path}"
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
  RUN_OUTPUT="$("$@" 2>&1)"
  RUN_STATUS=$?
  set -e
}

assert_file_exists() {
  local rel_path="$1"
  [[ -f "${REPO_ROOT}/${rel_path}" ]] || fail "expected file missing: ${rel_path}"
}

assert_contains() {
  local rel_path="$1"
  local needle="$2"
  if ! grep -Fq -- "$needle" "${REPO_ROOT}/${rel_path}"; then
    fail "expected '${needle}' in ${rel_path}"
  fi
}

assert_output_contains() {
  local needle="$1"
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq -- "$needle"; then
    fail "expected output to contain: ${needle}"
  fi
}

PLAN_SCAFFOLD="var/tmp/editor-test-plan-scaffold-$$.md"
PLAN_LOAD_TARGET="var/tmp/editor-test-plan-load-$$.md"
PLAN_EDIT_TARGET="var/tmp/editor-test-plan-edit-$$.md"
PLAN_FILLED_FIXTURE="var/tmp/editor-test-plan-filled-$$.md"

SLOTS_SCAFFOLD="var/tmp/editor-test-slots-scaffold-$$.md"
SLOTS_LOAD_TARGET="var/tmp/editor-test-slots-load-$$.md"
SLOTS_EDIT_TARGET="var/tmp/editor-test-slots-edit-$$.md"
SLOTS_FILLED_FIXTURE="var/tmp/editor-test-slots-filled-$$.md"
DRAFT_SLOTS_FIXTURE="var/tmp/editor-test-draft-slots-$$.md"
TASK_BASELINE_BACKUP_REL="var/tmp/editor-test-task-backup-$$.md"
TASK_POINTER_BACKUP_REL="var/tmp/editor-test-task-pointer-backup-$$.md"

queue_cleanup_path "$PLAN_SCAFFOLD"
queue_cleanup_path "$PLAN_LOAD_TARGET"
queue_cleanup_path "$PLAN_EDIT_TARGET"
queue_cleanup_path "$PLAN_FILLED_FIXTURE"
queue_cleanup_path "$SLOTS_SCAFFOLD"
queue_cleanup_path "$SLOTS_LOAD_TARGET"
queue_cleanup_path "$SLOTS_EDIT_TARGET"
queue_cleanup_path "$SLOTS_FILLED_FIXTURE"
queue_cleanup_path "$DRAFT_SLOTS_FIXTURE"
queue_cleanup_path "$TASK_BASELINE_BACKUP_REL"
queue_cleanup_path "$TASK_POINTER_BACKUP_REL"

cat > "$PLAN_FILLED_FIXTURE" <<'PLAN_OK'
## Summary
Deliver deterministic plan scaffold authoring support.

## Scope
- In scope: scaffold emit, edit, and validation flows.
- Out of scope: DP rendering behavior changes.

## Architect Handoff
Selected Option: B
Slice Mode: single
Selected Slices: S7
Execution Order: S7
Architect Constraints: no new options; draft from selected fields only

## Implementation Plan (Decision Complete)
1. Emit scaffold.
2. Fill scaffold content.
3. Validate scaffold deterministically.
PLAN_OK

cat > "$SLOTS_FILLED_FIXTURE" <<'SLOTS_OK'
[DP_SCOPED_LOAD_ORDER]
- ops/bin/draft
- ops/lib/scripts/editor.sh

[OBJECTIVE]
- Add deterministic scaffold validation entry points.

[IN_SCOPE]
- Update draft assist flags and scaffold helpers.

[OUT_OF_SCOPE]
- No certify behavior changes.

[SAFETY_INVARIANTS]
- No TASK mutation in assist mode.

[PLAN_STATE]
- S7 execution in progress.

[PLAN_REQUEST]
- Implement scaffold emit, edit, load, and validation pathways.

[PLAN_CHANGELOG]
- UPDATE: ops/bin/draft
- UPDATE: ops/lib/scripts/editor.sh

[PLAN_PATCH]
- Add assist-mode argument parsing and deterministic validation hooks.

[RECEIPT_EXTRA]
- bash tools/test/editor.sh

[CBC_PREFLIGHT]
- Applicable. Deterministic rejection on untouched scaffold prose is bounded and required.
SLOTS_OK

run_capture ./ops/bin/draft --emit-plan-scaffold="$PLAN_SCAFFOLD"
if (( RUN_STATUS != 0 )); then
  fail "emit-plan-scaffold failed"
  printf '%s\n' "$RUN_OUTPUT" >&2
fi
assert_file_exists "$PLAN_SCAFFOLD"
assert_contains "$PLAN_SCAFFOLD" "## Summary"
assert_contains "$PLAN_SCAFFOLD" "## Architect Handoff"

run_capture ./ops/bin/draft --validate-plan-scaffold="$PLAN_SCAFFOLD"
if (( RUN_STATUS == 0 )); then
  fail "expected untouched plan scaffold validation to fail"
fi
assert_output_contains "untouched scaffold line"

run_capture ./ops/bin/draft --emit-plan-scaffold="$PLAN_LOAD_TARGET" --load-scaffold-file="$PLAN_FILLED_FIXTURE"
if (( RUN_STATUS != 0 )); then
  fail "plan scaffold load path failed"
  printf '%s\n' "$RUN_OUTPUT" >&2
fi
assert_output_contains "PASS: draft: plan scaffold"

run_capture ./ops/bin/draft --validate-plan-scaffold="$PLAN_LOAD_TARGET"
if (( RUN_STATUS != 0 )); then
  fail "filled plan scaffold validation failed"
  printf '%s\n' "$RUN_OUTPUT" >&2
fi

run_capture ./ops/bin/draft --emit-plan-scaffold="$PLAN_EDIT_TARGET" --edit-scaffold --scaffold-editor="cp $PLAN_FILLED_FIXTURE"
if (( RUN_STATUS != 0 )); then
  fail "plan scaffold interactive-simulated path failed"
  printf '%s\n' "$RUN_OUTPUT" >&2
fi
assert_output_contains "PASS: draft: plan scaffold"

run_capture ./ops/bin/draft --emit-dp-slots-scaffold="$SLOTS_SCAFFOLD"
if (( RUN_STATUS != 0 )); then
  fail "emit-dp-slots-scaffold failed"
  printf '%s\n' "$RUN_OUTPUT" >&2
fi
assert_file_exists "$SLOTS_SCAFFOLD"
assert_contains "$SLOTS_SCAFFOLD" "[PLAN_PATCH]"
assert_contains "$SLOTS_SCAFFOLD" "[CBC_PREFLIGHT]"

run_capture ./ops/bin/draft --validate-dp-slots-scaffold="$SLOTS_SCAFFOLD"
if (( RUN_STATUS == 0 )); then
  fail "expected untouched dp slots scaffold validation to fail"
fi
assert_output_contains "untouched scaffold line"

run_capture ./ops/bin/draft --emit-dp-slots-scaffold="$SLOTS_LOAD_TARGET" --load-scaffold-file="$SLOTS_FILLED_FIXTURE"
if (( RUN_STATUS != 0 )); then
  fail "dp slots scaffold load path failed"
  printf '%s\n' "$RUN_OUTPUT" >&2
fi
assert_output_contains "PASS: draft: dp slots scaffold"

run_capture ./ops/bin/draft --validate-dp-slots-scaffold="$SLOTS_LOAD_TARGET"
if (( RUN_STATUS != 0 )); then
  fail "filled dp slots scaffold validation failed"
  printf '%s\n' "$RUN_OUTPUT" >&2
fi

run_capture ./ops/bin/draft --emit-dp-slots-scaffold="$SLOTS_EDIT_TARGET" --edit-scaffold --scaffold-editor="cp $SLOTS_FILLED_FIXTURE"
if (( RUN_STATUS != 0 )); then
  fail "dp slots scaffold interactive-simulated path failed"
  printf '%s\n' "$RUN_OUTPUT" >&2
fi
assert_output_contains "PASS: draft: dp slots scaffold"

# Pointer-mode regression guard:
# Base-mode draft must not expand tracked TASK.md when TASK is pointer-mode.
if [[ ! -f "${REPO_ROOT}/TASK.md" ]]; then
  fail "pointer-mode regression fixture missing TASK.md"
else
  cp -- "${REPO_ROOT}/TASK.md" "${REPO_ROOT}/${TASK_BASELINE_BACKUP_REL}"
  TASK_RESTORE_NEEDED=1

  task_line_count="$(awk 'END { print NR }' "${REPO_ROOT}/TASK.md")"
  if [[ "$task_line_count" != "1" ]]; then
    fail "pointer-mode regression requires TASK.md single-line pointer fixture"
  else
    TASK_POINTER_REL="$(normalize_rel_path "$(tr -d '\r' < "${REPO_ROOT}/TASK.md")")"
    if [[ ! "$TASK_POINTER_REL" =~ ^archives/surfaces/[A-Za-z0-9._/-]+\.md$ ]]; then
      fail "pointer-mode regression fixture TASK.md is not archives/surfaces pointer"
    elif [[ ! -f "${REPO_ROOT}/${TASK_POINTER_REL}" ]]; then
      fail "pointer-mode regression fixture pointer target missing: ${TASK_POINTER_REL}"
    else
      cp -- "${REPO_ROOT}/${TASK_POINTER_REL}" "${REPO_ROOT}/${TASK_POINTER_BACKUP_REL}"
      TASK_POINTER_RESTORE_NEEDED=1

      DRAFT_TEST_ID="DP-OPS-9$$"
      DRAFT_TEST_WORK_BRANCH="work/dp-ops-9$$-editor-pointer-regression-2026-03-06"
      DRAFT_INTAKE_FIXTURE_REL="storage/dp/intake/${DRAFT_TEST_ID}.md"
      if [[ -e "${REPO_ROOT}/${DRAFT_INTAKE_FIXTURE_REL}" ]]; then
        DRAFT_INTAKE_FIXTURE_PREEXISTED=1
        fail "pointer-mode regression fixture intake path already exists: ${DRAFT_INTAKE_FIXTURE_REL}"
      fi

      cat > "${REPO_ROOT}/${DRAFT_SLOTS_FIXTURE}" <<'DRAFT_FIXTURE'
[DP_SCOPED_LOAD_ORDER]
- TASK.md
- ops/bin/draft

[OBJECTIVE]
- editor regression fixture for pointer-mode write-target guard.

[IN_SCOPE]
- ops/bin/draft

[OUT_OF_SCOPE]
- none

[SAFETY_INVARIANTS]
- pointer-mode TASK.md remains single-line.

[PLAN_STATE]
- test fixture

[PLAN_REQUEST]
- test pointer-mode update target

[PLAN_CHANGELOG]
- UPDATE: ops/bin/draft

[PLAN_PATCH]
- test-only fixture

[RECEIPT_EXTRA]
- bash tools/test/editor.sh
DRAFT_FIXTURE

      run_capture env DRAFT_ALLOW_DIRTY_TREE=1 ./ops/bin/draft \
        --id="$DRAFT_TEST_ID" \
        --title="Editor Pointer Regression Fixture" \
        --work-branch="$DRAFT_TEST_WORK_BRANCH" \
        --base-head="deadbeef" \
        --slots-file="$DRAFT_SLOTS_FIXTURE"
      if (( RUN_STATUS != 0 )); then
        fail "pointer-mode regression draft generation failed"
        printf '%s\n' "$RUN_OUTPUT" >&2
      else
        if ! cmp -s "${REPO_ROOT}/TASK.md" "${REPO_ROOT}/${TASK_BASELINE_BACKUP_REL}"; then
          fail "pointer-mode regression: tracked TASK.md changed after base-mode draft"
        fi
        if cmp -s "${REPO_ROOT}/${TASK_POINTER_REL}" "${REPO_ROOT}/${TASK_POINTER_BACKUP_REL}"; then
          fail "pointer-mode regression: resolved TASK surface leaf did not update"
        fi
        if [[ ! -f "${REPO_ROOT}/${DRAFT_INTAKE_FIXTURE_REL}" ]]; then
          fail "pointer-mode regression: expected intake file missing: ${DRAFT_INTAKE_FIXTURE_REL}"
        fi
      fi
    fi
  fi
fi

if (( FAILURES > 0 )); then
  exit 1
fi

echo "PASS: editor scaffold test"
