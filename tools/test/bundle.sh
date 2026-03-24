#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${REPO_ROOT:-}" ]]; then
  REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "ERROR: not inside a git repo" >&2; exit 1; }
fi
# shellcheck source=/dev/null
source "${REPO_ROOT}/ops/lib/scripts/common.sh"

usage() {
  cat <<'EOF'
Usage: bash tools/test/bundle.sh [--mode=full|certify-critical] [--slice=route-contract|package-contract|fail-closed|rerun-lineage]
EOF
}

TEST_MODE="full"
BUNDLE_TEST_SLICE=""
for arg in "$@"; do
  case "$arg" in
    --mode=*)   TEST_MODE="${arg#--mode=}" ;;
    --slice=*)  BUNDLE_TEST_SLICE="${arg#--slice=}" ;;
    -h|--help)  usage; exit 0 ;;
    *)          echo "ERROR: unknown arg: ${arg}" >&2; exit 1 ;;
  esac
done

case "$TEST_MODE" in
  full|certify-critical) ;;
  *) echo "ERROR: invalid --mode value: ${TEST_MODE}" >&2; exit 1 ;;
esac

if [[ -n "$BUNDLE_TEST_SLICE" ]]; then
  case "$BUNDLE_TEST_SLICE" in
    route-contract|package-contract|fail-closed|rerun-lineage) ;;
    *) echo "ERROR: invalid --slice value: ${BUNDLE_TEST_SLICE}" >&2; exit 1 ;;
  esac
fi

# ===== Policy =====
BUNDLE_POLICY_REL="ops/lib/manifests/BUNDLE.md"

policy_scalar() {
  awk -F'=' -v k="$1" '$1==k { sub(/^[^=]*=[ \t]*/,""); print; exit }' \
    "${REPO_ROOT}/${BUNDLE_POLICY_REL}"
}

SMOKE_HANDOFF_ROOT="$(policy_scalar smoke_handoff_root)"
SMOKE_DUMP_ROOT="$(policy_scalar smoke_dump_root)"

# ===== Ephemeral input root (per-run isolation) =====
RUN_ID="$$"
EPHEMERAL_ROOT="var/tmp/_smoke/${RUN_ID}"
EPHEMERAL_ROOT_ABS="${REPO_ROOT}/${EPHEMERAL_ROOT}"
export BUNDLE_TEST_HANDOFF_ROOT="${EPHEMERAL_ROOT_ABS}"
mkdir -p "${EPHEMERAL_ROOT_ABS}"

# ===== State =====
FAILURES=0
BUNDLE_SEQ=0
BUNDLE_LAST_STATUS=0
BUNDLE_LAST_OUTPUT=""
BUNDLE_LAST_MANIFEST_ABS=""
declare -a _CLEANUP_FILES=()

# ===== Cleanup =====
_cleanup() {
  rm -rf "${EPHEMERAL_ROOT_ABS}"
  local f
  for f in "${_CLEANUP_FILES[@]:-}"; do
    [[ -n "$f" ]] && rm -f "${REPO_ROOT}/${f}"
  done
  emit_binary_leaf "test-bundle" "finish"
}
trap _cleanup EXIT
emit_binary_leaf "test-bundle" "start"

# ===== Helpers =====
fail() { echo "FAIL: $*" >&2; FAILURES=$((FAILURES + 1)); }

_track() {
  local p="$1"
  [[ -n "$p" ]] || return 0
  _CLEANUP_FILES+=("$p")
}

next_out() {
  local profile="$1"
  local prefix
  prefix="$(policy_scalar "artifact_prefix_${profile}")"
  BUNDLE_SEQ=$((BUNDLE_SEQ + 1))
  printf '%s/%s-smoke-%s-%03d.txt' "$SMOKE_HANDOFF_ROOT" "$prefix" "$$" "$BUNDLE_SEQ"
}

_parse_bundle_output_path() {
  local label="$1"
  printf '%s\n' "$BUNDLE_LAST_OUTPUT" \
    | awk -v l="${label}:" 'index($0,l){sub(/.*: *\.\//,"");sub(/.*: */,"");print;exit}'
}

run_bundle() {
  local out_rel="$1"; shift
  BUNDLE_LAST_STATUS=0
  BUNDLE_LAST_OUTPUT=""
  BUNDLE_LAST_MANIFEST_ABS=""
  BUNDLE_LAST_OUTPUT="$("${REPO_ROOT}/ops/bin/bundle" "$@" "--out=${out_rel}" 2>&1)" \
    || BUNDLE_LAST_STATUS=$?
  # Parse artifact paths from output and track them for cleanup
  local artifact_path manifest_path package_path
  artifact_path="$(_parse_bundle_output_path "Bundle artifact")"
  manifest_path="$(_parse_bundle_output_path "Bundle manifest")"
  package_path="$(_parse_bundle_output_path "Bundle package")"
  if [[ -n "$manifest_path" ]]; then
    BUNDLE_LAST_MANIFEST_ABS="${REPO_ROOT}/${manifest_path}"
    _track "$artifact_path"
    _track "$manifest_path"
    _track "$package_path"
  fi
}

# JSON field extraction from bundle manifest (one key per line format)
mf_string() {
  local key="$1" file="$2"
  awk -v k="\"${key}\":" 'index($0,k){gsub(/.*": *"/,"");gsub(/".*$/,"");print;exit}' "$file"
}

mf_string_in_block() {
  local block="$1" key="$2" file="$3"
  awk -v b="\"${block}\":" -v k="\"${key}\":" \
    'index($0,b){in_block=1} in_block&&index($0,k){
      if(index($0,"null")){print "null";exit}
      gsub(/.*": *"/,"");gsub(/".*$/,"");print;exit
    }' "$file"
}

mf_int_in_block() {
  local block="$1" key="$2" file="$3"
  awk -v b="\"${block}\":" -v k="\"${key}\":" \
    'index($0,b){in_block=1} in_block&&index($0,k){gsub(/.*": */,"");gsub(/[,}].*/,"");print;exit}' "$file"
}

mf_bool_in_block() {
  local block="$1" key="$2" file="$3"
  awk -v b="\"${block}\":" -v k="\"${key}\":" \
    'index($0,b){in_block=1} in_block&&index($0,k){gsub(/.*": */,"");gsub(/[,}].*/,"");print;exit}' "$file"
}

pkg_contains() {
  local needle="$1" file="$2"
  grep -qF "\"${needle}\"" "$file"
}

# ===== Synthetic surface creation =====
make_task() {
  # Follow the live TASK pointer chain so bundle_extract_task_packet_id reaches
  # the surface that actually contains packet_id: (the archive when certify has
  # already converted TASK.md to a pointer, or TASK.md itself before certify).
  local live_task="${REPO_ROOT}/TASK.md"
  local first_line=""
  first_line="$(sed -n '1p' "$live_task")"
  first_line="${first_line%$'\r'}"
  first_line="${first_line#"${first_line%%[![:space:]]*}"}"
  first_line="${first_line%"${first_line##*[![:space:]]}"}"
  if [[ -n "$first_line" && -f "${REPO_ROOT}/${first_line}" ]]; then
    printf '%s\n' "$first_line" > "${EPHEMERAL_ROOT_ABS}/TASK.md"
  else
    printf 'TASK.md\n' > "${EPHEMERAL_ROOT_ABS}/TASK.md"
  fi
}

make_topic() {
  printf '# Smoke Test Topic\nSynthetic topic for bundle smoke testing.\n' \
    > "${EPHEMERAL_ROOT_ABS}/TOPIC.md"
}

make_plan() {
  cat > "${EPHEMERAL_ROOT_ABS}/PLAN.md" <<'EOF'
## Summary
Synthetic plan for bundle smoke testing.

## Key Changes
- None.

## Test Plan
- None.

## Assumptions
- None.
EOF
}

make_results() {
  cat > "${EPHEMERAL_ROOT_ABS}/RESULTS.md" <<'EOF'
- dp_source: TASK.md
# Smoke Results
Synthetic RESULTS for bundle smoke testing.
EOF
}

make_closing() {
  printf '# Closing\nSynthetic closing sidecar for bundle smoke testing.\n' \
    > "${EPHEMERAL_ROOT_ABS}/CLOSING.md"
}

clean_surfaces() {
  rm -f "${EPHEMERAL_ROOT_ABS}/TOPIC.md" \
        "${EPHEMERAL_ROOT_ABS}/PLAN.md" \
        "${EPHEMERAL_ROOT_ABS}/RESULTS.md" \
        "${EPHEMERAL_ROOT_ABS}/CLOSING.md"
}

# ===== Slices =====

slice_route_contract() {
  echo "--- slice: route-contract"
  local out rp rr
  local open_embedded open_path open_source open_trace
  make_task

  # Planning: explicit profile, artifact prefix PLANNING
  make_topic
  out="$(next_out planning)"
  run_bundle "$out" --profile=planning
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "route/planning: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    rp="$(mf_string resolved_profile "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$rp" == "planning" ]] || fail "route/planning: resolved_profile='${rp}' expected 'planning'"
    [[ "$out" == "${SMOKE_HANDOFF_ROOT}/PLANNING-"* ]] \
      || fail "route/planning: artifact prefix wrong: ${out}"
    open_embedded="$(mf_bool_in_block open embedded "$BUNDLE_LAST_MANIFEST_ABS")"
    open_path="$(mf_string_in_block open artifact_path "$BUNDLE_LAST_MANIFEST_ABS")"
    open_source="$(mf_string_in_block open source "$BUNDLE_LAST_MANIFEST_ABS")"
    open_trace="$(mf_string_in_block open trace_id "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$open_embedded" == "false" ]] \
      || fail "route/planning: expected open.embedded=false, got '${open_embedded}'"
    [[ "$open_source" == "refreshed" ]] \
      || fail "route/planning: expected open.source='refreshed', got '${open_source}'"
    [[ "$open_path" == "${EPHEMERAL_ROOT}/OPEN-"* ]] \
      || fail "route/planning: expected open.artifact_path under ${EPHEMERAL_ROOT}, got '${open_path}'"
    [[ -f "${REPO_ROOT}/${open_path}" ]] \
      || fail "route/planning: open artifact missing at ${open_path}"
    [[ "$open_trace" == stela-* ]] \
      || fail "route/planning: invalid open.trace_id '${open_trace}'"
  fi

  # Draft: explicit profile with PLAN.md, artifact prefix DRAFT
  make_plan
  out="$(next_out draft)"
  run_bundle "$out" --profile=draft
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "route/draft: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    rp="$(mf_string resolved_profile "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$rp" == "draft" ]] || fail "route/draft: resolved_profile='${rp}' expected 'draft'"
    [[ "$out" == "${SMOKE_HANDOFF_ROOT}/DRAFT-"* ]] \
      || fail "route/draft: artifact prefix wrong: ${out}"
    open_source="$(mf_string_in_block open source "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$open_source" == "reused" ]] \
      || fail "route/draft: expected open.source='reused', got '${open_source}'"
  fi

  # Auto: no PLAN.md → routes to planning
  clean_surfaces
  make_topic
  out="$(next_out planning)"
  run_bundle "$out" --profile=auto
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "route/auto-no-plan: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    rp="$(mf_string resolved_profile "$BUNDLE_LAST_MANIFEST_ABS")"
    rr="$(mf_string route_reason "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$rp" == "planning" ]] || fail "route/auto-no-plan: resolved_profile='${rp}' expected 'planning'"
    [[ "$rr" == *"PLAN.md missing"* ]] \
      || fail "route/auto-no-plan: route_reason='${rr}' expected 'PLAN.md missing'"
  fi

  # Auto: with valid PLAN.md → routes to draft
  make_plan
  out="$(next_out draft)"
  run_bundle "$out" --profile=auto
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "route/auto-plan: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    rp="$(mf_string resolved_profile "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$rp" == "draft" ]] || fail "route/auto-plan: resolved_profile='${rp}' expected 'draft'"
  fi

  # Alias: hygiene → conform
  clean_surfaces
  make_topic
  out="$(next_out conform)"
  run_bundle "$out" --profile=hygiene
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "route/alias-hygiene: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    rp="$(mf_string resolved_profile "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$rp" == "conform" ]] || fail "route/alias-hygiene: resolved_profile='${rp}' expected 'conform'"
  fi

  # Invalid profile → fail closed
  out="$(next_out planning)"
  run_bundle "$out" --profile=__invalid__
  [[ "$BUNDLE_LAST_STATUS" -ne 0 ]] \
    || fail "route/invalid-profile: expected nonzero exit"

  clean_surfaces
  echo "--- slice: route-contract done"
}

slice_package_contract() {
  echo "--- slice: package-contract"
  local out mf
  make_task

  # Planning: package contains TOPIC.md, not PLAN.md
  make_topic
  out="$(next_out planning)"
  run_bundle "$out" --profile=planning
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "package/planning: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    mf="$BUNDLE_LAST_MANIFEST_ABS"
    pkg_contains "${EPHEMERAL_ROOT}/TOPIC.md" "$mf" \
      || fail "package/planning: package missing TOPIC.md (${EPHEMERAL_ROOT}/TOPIC.md)"
    ! pkg_contains "${EPHEMERAL_ROOT}/PLAN.md" "$mf" \
      || fail "package/planning: package must not contain PLAN.md"
  fi

  # Draft: package contains PLAN.md, not TOPIC.md
  make_plan
  out="$(next_out draft)"
  run_bundle "$out" --profile=draft
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "package/draft: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    mf="$BUNDLE_LAST_MANIFEST_ABS"
    pkg_contains "${EPHEMERAL_ROOT}/PLAN.md" "$mf" \
      || fail "package/draft: package missing PLAN.md (${EPHEMERAL_ROOT}/PLAN.md)"
    ! pkg_contains "${EPHEMERAL_ROOT}/TOPIC.md" "$mf" \
      || fail "package/draft: package must not contain TOPIC.md"
  fi

  # Audit: package contains RESULTS.md and CLOSING.md
  clean_surfaces
  make_results
  make_closing
  out="$(next_out audit)"
  run_bundle "$out" --profile=audit
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "package/audit: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    mf="$BUNDLE_LAST_MANIFEST_ABS"
    pkg_contains "${EPHEMERAL_ROOT}/RESULTS.md" "$mf" \
      || fail "package/audit: package missing RESULTS.md"
    pkg_contains "${EPHEMERAL_ROOT}/CLOSING.md" "$mf" \
      || fail "package/audit: package missing CLOSING.md"
  fi

  clean_surfaces
  echo "--- slice: package-contract done"
}

slice_fail_closed() {
  echo "--- slice: fail-closed"
  local out
  make_task

  # Planning: no TOPIC.md → fail
  clean_surfaces
  out="$(next_out planning)"
  run_bundle "$out" --profile=planning
  [[ "$BUNDLE_LAST_STATUS" -ne 0 ]] \
    || fail "fail-closed/planning-no-topic: expected nonzero exit"

  # Draft: no PLAN.md → fail
  clean_surfaces
  out="$(next_out draft)"
  run_bundle "$out" --profile=draft
  [[ "$BUNDLE_LAST_STATUS" -ne 0 ]] \
    || fail "fail-closed/draft-no-plan: expected nonzero exit"

  # Audit: no RESULTS.md (only CLOSING.md) → fail
  clean_surfaces
  make_closing
  out="$(next_out audit)"
  run_bundle "$out" --profile=audit
  [[ "$BUNDLE_LAST_STATUS" -ne 0 ]] \
    || fail "fail-closed/audit-no-results: expected nonzero exit"

  # Audit: no CLOSING.md (only RESULTS.md) → fail
  clean_surfaces
  make_results
  out="$(next_out audit)"
  run_bundle "$out" --profile=audit
  [[ "$BUNDLE_LAST_STATUS" -ne 0 ]] \
    || fail "fail-closed/audit-no-closing: expected nonzero exit"

  # Invalid profile → fail
  clean_surfaces
  make_topic
  out="$(next_out planning)"
  run_bundle "$out" --profile=__invalid__
  [[ "$BUNDLE_LAST_STATUS" -ne 0 ]] \
    || fail "fail-closed/invalid-profile: expected nonzero exit"

  clean_surfaces
  echo "--- slice: fail-closed done"
}

slice_rerun_lineage() {
  echo "--- slice: rerun-lineage"
  make_task
  make_results
  make_closing

  # Use a fixed suffix so repeat/rerun runs share the same suffix for lineage tracking
  local suffix="rerun-${$}"
  local initial_rel="${SMOKE_HANDOFF_ROOT}/AUDIT-${suffix}.txt"
  local explicit_rerun_rel="${SMOKE_HANDOFF_ROOT}/AUDIT-rerun-only-${suffix}.txt"

  # Explicit --rerun with no prior local artifact must still produce rerun identity
  run_bundle "$explicit_rerun_rel" --profile=audit --rerun
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "rerun-lineage/rerun-without-prior: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    local kind idx supersedes
    kind="$(mf_string_in_block submission kind "$BUNDLE_LAST_MANIFEST_ABS")"
    idx="$(mf_int_in_block submission resubmission_index "$BUNDLE_LAST_MANIFEST_ABS")"
    supersedes="$(mf_string_in_block submission supersedes_bundle_path "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$kind" == "audit_resubmission" ]] \
      || fail "rerun-lineage/rerun-without-prior: submission.kind='${kind}' expected 'audit_resubmission'"
    [[ "$idx" == "1" ]] \
      || fail "rerun-lineage/rerun-without-prior: resubmission_index='${idx}' expected '1'"
    [[ "$supersedes" == "null" ]] \
      || fail "rerun-lineage/rerun-without-prior: supersedes_bundle_path should be null, got '${supersedes}'"
  fi

  # Initial audit
  run_bundle "$initial_rel" --profile=audit
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "rerun-lineage/initial: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    local kind idx
    kind="$(mf_string_in_block submission kind "$BUNDLE_LAST_MANIFEST_ABS")"
    idx="$(mf_int_in_block submission resubmission_index "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$kind" == "audit_submission" ]] \
      || fail "rerun-lineage/initial: submission.kind='${kind}' expected 'audit_submission'"
    [[ "$idx" == "0" ]] \
      || fail "rerun-lineage/initial: resubmission_index='${idx}' expected '0'"
    [[ -f "${REPO_ROOT}/${initial_rel}" ]] \
      || fail "rerun-lineage/initial: artifact not found: ${initial_rel}"
  fi

  # Repeat without --rerun: prior artifact exists, but must still be initial kind
  local no_rerun_rel="${SMOKE_HANDOFF_ROOT}/AUDIT-${suffix}-norr.txt"
  run_bundle "$no_rerun_rel" --profile=audit
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "rerun-lineage/no-rerun: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    local kind idx
    kind="$(mf_string_in_block submission kind "$BUNDLE_LAST_MANIFEST_ABS")"
    idx="$(mf_int_in_block submission resubmission_index "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$kind" == "audit_submission" ]] \
      || fail "rerun-lineage/no-rerun: submission.kind='${kind}' expected 'audit_submission'"
    [[ "$idx" == "0" ]] \
      || fail "rerun-lineage/no-rerun: resubmission_index='${idx}' expected '0'"
  fi

  # With --rerun: must become audit_resubmission, index=1, supersedes set
  run_bundle "$initial_rel" --profile=audit --rerun
  if [[ "$BUNDLE_LAST_STATUS" -ne 0 ]]; then
    fail "rerun-lineage/rerun: expected exit 0; output: ${BUNDLE_LAST_OUTPUT}"
  else
    local kind idx supersedes
    kind="$(mf_string_in_block submission kind "$BUNDLE_LAST_MANIFEST_ABS")"
    idx="$(mf_int_in_block submission resubmission_index "$BUNDLE_LAST_MANIFEST_ABS")"
    supersedes="$(mf_string_in_block submission supersedes_bundle_path "$BUNDLE_LAST_MANIFEST_ABS")"
    [[ "$kind" == "audit_resubmission" ]] \
      || fail "rerun-lineage/rerun: submission.kind='${kind}' expected 'audit_resubmission'"
    [[ "$idx" == "1" ]] \
      || fail "rerun-lineage/rerun: resubmission_index='${idx}' expected '1'"
    [[ "$supersedes" != "null" && -n "$supersedes" ]] \
      || fail "rerun-lineage/rerun: supersedes_bundle_path should be set, got '${supersedes}'"
  fi

  clean_surfaces
  echo "--- slice: rerun-lineage done"
}

# ===== certify-critical gate =====
declare -a _WATCHED_PATHS=(
  "ops/bin/bundle"
  "ops/lib/scripts/bundle.sh"
  "ops/lib/manifests/BUNDLE.md"
  "tools/test/bundle.sh"
)

_watched_path_changed() {
  local changed
  changed="$(git -C "${REPO_ROOT}" diff --name-only; \
             git -C "${REPO_ROOT}" ls-files --others --exclude-standard)"
  local p
  for p in "${_WATCHED_PATHS[@]}"; do
    if printf '%s\n' "$changed" | grep -qF "$p"; then
      return 0
    fi
  done
  return 1
}

# ===== Main dispatch =====
_run_all() {
  slice_route_contract
  slice_package_contract
  slice_fail_closed
  slice_rerun_lineage
}

if [[ -n "$BUNDLE_TEST_SLICE" ]]; then
  case "$BUNDLE_TEST_SLICE" in
    route-contract)   slice_route_contract ;;
    package-contract) slice_package_contract ;;
    fail-closed)      slice_fail_closed ;;
    rerun-lineage)    slice_rerun_lineage ;;
  esac
else
  case "$TEST_MODE" in
    full)
      _run_all
      ;;
    certify-critical)
      if _watched_path_changed; then
        _run_all
      else
        echo "SKIP: no watched bundle-kernel file changed (mode: certify-critical)"
        exit 0
      fi
      ;;
  esac
fi

if (( FAILURES > 0 )); then
  echo "FAIL: bundle smoke test detected ${FAILURES} issue(s) (mode: ${TEST_MODE})" >&2
  exit 1
fi

if [[ -n "$BUNDLE_TEST_SLICE" ]]; then
  echo "PASS: bundle smoke test (slice: ${BUNDLE_TEST_SLICE})"
elif [[ "$TEST_MODE" == "certify-critical" ]]; then
  echo "PASS: bundle smoke test (mode: certify-critical)"
else
  echo "PASS: bundle smoke test"
fi
