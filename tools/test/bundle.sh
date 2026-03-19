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

usage() {
  cat <<'EOF'
Usage: bash tools/test/bundle.sh [--mode=full|certify-critical] [--slice=closeout-sanity|audit-coherence|route-contract|rerun-lineage]
EOF
}

TEST_MODE="full"
BUNDLE_TEST_SLICE=""
for arg in "$@"; do
  case "$arg" in
    --mode=*)
      TEST_MODE="${arg#--mode=}"
      ;;
    --slice=*)
      BUNDLE_TEST_SLICE="${arg#--slice=}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown arg: ${arg}" >&2
      exit 1
      ;;
  esac
done

case "$TEST_MODE" in
  full|certify-critical)
    ;;
  *)
    echo "ERROR: invalid --mode value: ${TEST_MODE}" >&2
    exit 1
    ;;
esac

if [[ -n "$BUNDLE_TEST_SLICE" ]]; then
  case "$BUNDLE_TEST_SLICE" in
    closeout-sanity|audit-coherence|route-contract|rerun-lineage)
      ;;
    *)
      echo "ERROR: invalid --slice value: ${BUNDLE_TEST_SLICE}" >&2
      exit 1
      ;;
  esac
fi

declare -a CLEANUP_PATHS=()
declare -A CLEANUP_SEEN=()
FAILURES=0
RUN_OUTPUT=""
RUN_STATUS=0
LAST_ARTIFACT=""
LAST_MANIFEST=""
LAST_PACKAGE=""
LAST_ASSEMBLY_POINTER_EMITTED=""
LAST_ASSEMBLY_POINTER_PATH=""
LAST_ASSEMBLY_POINTER_FORMAT=""
BUNDLE_POLICY_REL="ops/lib/manifests/BUNDLE.md"
ARCHITECT_PLAN_BACKUP=""
ARCHITECT_PLAN_RESTORE=0
ARCHITECT_CURRENT_PLAN_BACKUP=""
ARCHITECT_CURRENT_PLAN_RESTORE=0
AUDIT_TASK_BACKUP=""
AUDIT_TASK_RESTORE=0
AUDIT_RESULTS_BACKUP=""
AUDIT_RESULTS_RESTORE=0
AUDIT_CLOSING_BACKUP=""
AUDIT_CLOSING_RESTORE=0
AUDIT_FIXTURE_TASK_REL=""
AUDIT_FIXTURE_RESULTS_REL=""
AUDIT_FIXTURE_CLOSING_REL=""
AUDIT_FIXTURE_PACKET_REL=""
AUDIT_EXPECTED_PACKET_ID=""
AUDIT_EXPECTED_PACKET_SOURCE_REL=""
BUNDLE_OUTPUT_SEQUENCE=0
SMOKE_HANDOFF_ROOT="$(awk -F'=' '$1=="smoke_handoff_root" { print substr($0, index($0, "=") + 1); exit }' "${REPO_ROOT}/${BUNDLE_POLICY_REL}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
SMOKE_DUMP_ROOT="$(awk -F'=' '$1=="smoke_dump_root" { print substr($0, index($0, "=") + 1); exit }' "${REPO_ROOT}/${BUNDLE_POLICY_REL}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"

restore_fixture_overrides() {
  local plan_rel="storage/handoff/PLAN.md"
  local plan_abs="${REPO_ROOT}/${plan_rel}"
  local task_rel="TASK.md"
  local task_abs="${REPO_ROOT}/${task_rel}"

  if (( ARCHITECT_PLAN_RESTORE )) && [[ -n "$ARCHITECT_PLAN_BACKUP" && -f "$ARCHITECT_PLAN_BACKUP" ]]; then
    cp "$ARCHITECT_PLAN_BACKUP" "$plan_abs"
    rm -f "$ARCHITECT_PLAN_BACKUP"
  fi

  if (( ARCHITECT_CURRENT_PLAN_RESTORE )) && [[ -n "$ARCHITECT_CURRENT_PLAN_BACKUP" && -f "$ARCHITECT_CURRENT_PLAN_BACKUP" ]]; then
    cp "$ARCHITECT_CURRENT_PLAN_BACKUP" "${REPO_ROOT}/storage/current/PLAN.md"
    rm -f "$ARCHITECT_CURRENT_PLAN_BACKUP"
  fi

  if (( AUDIT_TASK_RESTORE )) && [[ -n "$AUDIT_TASK_BACKUP" && -f "$AUDIT_TASK_BACKUP" ]]; then
    cp "$AUDIT_TASK_BACKUP" "$task_abs"
    rm -f "$AUDIT_TASK_BACKUP"
  fi

  if (( AUDIT_RESULTS_RESTORE )) && [[ -n "$AUDIT_RESULTS_BACKUP" && -f "$AUDIT_RESULTS_BACKUP" ]]; then
    cp "$AUDIT_RESULTS_BACKUP" "${REPO_ROOT}/storage/handoff/RESULTS.md"
    rm -f "$AUDIT_RESULTS_BACKUP"
  fi

  if (( AUDIT_CLOSING_RESTORE )) && [[ -n "$AUDIT_CLOSING_BACKUP" && -f "$AUDIT_CLOSING_BACKUP" ]]; then
    cp "$AUDIT_CLOSING_BACKUP" "${REPO_ROOT}/storage/handoff/CLOSING.md"
    rm -f "$AUDIT_CLOSING_BACKUP"
  fi

  [[ -n "$AUDIT_FIXTURE_TASK_REL" ]] && rm -f -- "${REPO_ROOT}/${AUDIT_FIXTURE_TASK_REL}"

  return 0
}

cleanup_generated() {
  local rel_path
  for rel_path in "${CLEANUP_PATHS[@]}"; do
    [[ -n "$rel_path" ]] || continue
    if [[ -e "${REPO_ROOT}/${rel_path}" ]]; then
      rm -f -- "${REPO_ROOT}/${rel_path}"
    fi
  done

  return 0
}

trap 'restore_fixture_overrides; cleanup_generated; emit_binary_leaf "test-bundle" "finish"' EXIT
emit_binary_leaf "test-bundle" "start"

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

test_packet_id_increment() {
  local seed="$1"
  local offset="$2"
  local prefix=""
  local numeric=""
  local next_value=0

  [[ "$offset" =~ ^-?[0-9]+$ ]] || return 1
  if [[ "$seed" =~ ^(.+)([0-9]{4})$ ]]; then
    prefix="${BASH_REMATCH[1]}"
    numeric="${BASH_REMATCH[2]}"
  else
    return 1
  fi

  next_value=$((10#${numeric} + offset))
  (( next_value >= 0 )) || return 1
  printf '%s%04d' "$prefix" "$next_value"
}

resolve_current_task_packet_id_for_test() {
  local task_rel="TASK.md"
  local task_abs="${REPO_ROOT}/${task_rel}"
  local task_source_abs="$task_abs"
  local first_line=""

  [[ -f "$task_abs" ]] || return 1

  first_line="$(sed -n '1p' "$task_abs" | sed 's/\r$//')"
  if [[ -n "$first_line" && -f "${REPO_ROOT}/${first_line}" ]]; then
    task_source_abs="${REPO_ROOT}/${first_line}"
  fi

  awk '
    /^packet_id:[[:space:]]*/ {
      line=$0
      sub(/^packet_id:[[:space:]]*/, "", line)
      print line
      exit
    }
    /^###[[:space:]]*DP-[^:]+:/ {
      line=$0
      sub(/^###[[:space:]]*/, "", line)
      sub(/:.*/, "", line)
      print line
      exit
    }
  ' "$task_source_abs"
}

resolve_expected_architect_packet_id() {
  local current_packet_id=""
  current_packet_id="$(resolve_current_task_packet_id_for_test)"
  [[ "$current_packet_id" =~ ^DP-[A-Z]+-[0-9]{4,}$ ]] || return 1
  test_packet_id_increment "$current_packet_id" 1
}

queue_cleanup_path() {
  local rel_path
  rel_path="$(normalize_rel_path "$1")"
  [[ -n "$rel_path" ]] || return 0

  case "$rel_path" in
    storage/*|var/tmp/*|archives/surfaces/*)
      ;;
    *)
      fail "refusing to queue cleanup path outside storage/, archives/surfaces/, or var/tmp/: ${rel_path}"
      return 1
      ;;
  esac

  if [[ -z "${CLEANUP_SEEN[$rel_path]+x}" ]]; then
    CLEANUP_SEEN["$rel_path"]=1
    CLEANUP_PATHS+=("$rel_path")
  fi
}

resolve_current_task_surface_rel() {
  local task_rel="TASK.md"
  local task_abs="${REPO_ROOT}/${task_rel}"
  local first_line=""

  [[ -f "$task_abs" ]] || {
    fail "TASK.md missing while resolving current task surface"
    return 1
  }

  first_line="$(sed -n '1p' "$task_abs")"
  first_line="$(trim "$first_line")"
  if [[ -n "$first_line" && -f "${REPO_ROOT}/${first_line}" ]]; then
    printf '%s' "$first_line"
    return 0
  fi

  printf '%s' "$task_rel"
}

ensure_architect_plan_fixture() {
  ensure_plan_restore_state
  ensure_architect_current_plan_fixture
  local plan_rel="storage/handoff/PLAN.md"
  local plan_abs="${REPO_ROOT}/${plan_rel}"

  mkdir -p "$(dirname "$plan_abs")"
  cat > "$plan_abs" <<'EOF'
## Architect Handoff
Selected Option: A (Dispatch Reliability Corridor)
Slice Mode: multi
Selected Slices: T1
Execution Order: T1
Architect Constraints:
- test fixture architect constraint

## Pending Slice Definitions
### T1 - Architect Transport Slice Intent
Objective:
- test fixture objective

Scope:
- test fixture scope

Acceptance gate:
- test fixture acceptance gate
EOF
  if (( ! ARCHITECT_PLAN_RESTORE )); then
    queue_cleanup_path "$plan_rel"
  fi
}

ensure_architect_plan_autobind_fixture() {
  ensure_plan_restore_state
  ensure_architect_current_plan_fixture
  local plan_rel="storage/handoff/PLAN.md"
  local plan_abs="${REPO_ROOT}/${plan_rel}"

  mkdir -p "$(dirname "$plan_abs")"
  cat > "$plan_abs" <<'EOF'
## Architect Handoff
Selected Option: A (Dispatch Reliability Corridor)
Slice Mode: multi
Selected Slices: T1
Execution Order: T1
Omitted Slice Mode: auto-bind
Architect Constraints:
- test fixture architect constraint

## Pending Slice Definitions
### T1 - Architect Transport Slice Intent
Objective:
- test fixture objective

Scope:
- test fixture scope

Acceptance gate:
- test fixture acceptance gate
EOF
  if (( ! ARCHITECT_PLAN_RESTORE )); then
    queue_cleanup_path "$plan_rel"
  fi
}

ensure_architect_current_plan_fixture() {
  local current_plan_rel="storage/current/PLAN.md"
  local current_plan_abs="${REPO_ROOT}/${current_plan_rel}"

  if (( ARCHITECT_CURRENT_PLAN_RESTORE == 0 )) && [[ -f "$current_plan_abs" ]]; then
    mkdir -p "${REPO_ROOT}/var/tmp"
    ARCHITECT_CURRENT_PLAN_BACKUP="$(mktemp "${REPO_ROOT}/var/tmp/bundle-current-plan-backup.XXXXXX")"
    cp "$current_plan_abs" "$ARCHITECT_CURRENT_PLAN_BACKUP"
    ARCHITECT_CURRENT_PLAN_RESTORE=1
  fi

  mkdir -p "$(dirname "$current_plan_abs")"
  cat > "$current_plan_abs" <<'EOF'
# DP Plan: Current Accepted Multi-Slice Fixture

## Summary
Current accepted multi-slice plan fixture for architect bundle smoke tests.

## Architect Handoff
Selected Option: RECOMMENDED
Slice Mode: multi
Selected Slices: D2
Execution Order: D1 -> D2 -> D3
EOF
  if (( ! ARCHITECT_CURRENT_PLAN_RESTORE )); then
    queue_cleanup_path "$current_plan_rel"
  fi
}

ensure_plan_restore_state() {
  local plan_rel="storage/handoff/PLAN.md"
  local plan_abs="${REPO_ROOT}/${plan_rel}"

  if (( ARCHITECT_PLAN_RESTORE == 0 )) && [[ -f "$plan_abs" ]]; then
    mkdir -p "${REPO_ROOT}/var/tmp"
    ARCHITECT_PLAN_BACKUP="$(mktemp "${REPO_ROOT}/var/tmp/bundle-plan-backup.XXXXXX")"
    cp "$plan_abs" "$ARCHITECT_PLAN_BACKUP"
    ARCHITECT_PLAN_RESTORE=1
  fi
}

ensure_plan_absent_fixture() {
  local plan_rel="storage/handoff/PLAN.md"
  local plan_abs="${REPO_ROOT}/${plan_rel}"

  ensure_plan_restore_state
  rm -f -- "$plan_abs"
}

ensure_analyst_topic_fixture() {
  local topic_rel="storage/handoff/TOPIC.md"
  local topic_abs="${REPO_ROOT}/${topic_rel}"

  if [[ -f "$topic_abs" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$topic_abs")"
  cat > "$topic_abs" <<'EOF'
Topic fixture for analyst bundle smoke tests.
EOF
  queue_cleanup_path "$topic_rel"
}

ensure_audit_receipt_fixture() {
  local task_rel="TASK.md"
  local task_abs="${REPO_ROOT}/${task_rel}"
  local branch=""
  local current_results_rel=""
  local current_closing_rel=""
  local current_packet_source_rel=""
  local current_results_dp_source_rel=""

  if [[ -f "$task_abs" ]]; then
    local current_pointer=""
    local current_packet_id=""
    current_pointer="$(sed -n '1p' "$task_abs" | sed 's/\r$//')"
    if [[ -n "$current_pointer" && -f "${REPO_ROOT}/${current_pointer}" ]]; then
      current_packet_id="$(awk '/^packet_id:[[:space:]]*/ { sub(/^packet_id:[[:space:]]*/, "", $0); print; exit }' "${REPO_ROOT}/${current_pointer}")"
      current_results_rel="storage/handoff/RESULTS.md"
      current_closing_rel="storage/handoff/CLOSING.md"
      if [[ -f "${REPO_ROOT}/${current_results_rel}" ]]; then
        current_results_dp_source_rel="$(awk '
          /^-[[:space:]]*dp_source:[[:space:]]*/ {
            line=$0
            sub(/^[^:]*:[[:space:]]*/, "", line)
            print line
            exit
          }
        ' "${REPO_ROOT}/${current_results_rel}")"
        current_results_dp_source_rel="$(trim "$current_results_dp_source_rel")"
      fi
      if [[ -n "$current_results_dp_source_rel" && -f "${REPO_ROOT}/${current_results_dp_source_rel}" ]]; then
        current_packet_source_rel="$current_results_dp_source_rel"
      elif [[ "$current_packet_id" =~ ^DP-[A-Z]+-[0-9]{4,}$ ]]; then
        current_packet_source_rel="$current_pointer"
      elif [[ -f "${REPO_ROOT}/storage/dp/intake/DP.md" ]] && grep -Eq "^###[[:space:]]+${current_packet_id}:" "${REPO_ROOT}/storage/dp/intake/DP.md"; then
        current_packet_source_rel="storage/dp/intake/DP.md"
      fi
      if [[ "$current_packet_id" =~ ^DP-[A-Z]+-[0-9]{4,}$ \
        && -f "${REPO_ROOT}/${current_results_rel}" \
        && -f "${REPO_ROOT}/${current_closing_rel}" \
        && -n "$current_packet_source_rel" ]]; then
        if [[ -n "$current_results_dp_source_rel" && "$current_results_dp_source_rel" != "$current_packet_source_rel" ]]; then
          current_packet_source_rel=""
        else
        AUDIT_EXPECTED_PACKET_ID="$current_packet_id"
        AUDIT_EXPECTED_PACKET_SOURCE_REL="$current_packet_source_rel"
        return 0
        fi
      fi
    fi
  fi

  if (( AUDIT_TASK_RESTORE == 0 )) && [[ -f "$task_abs" ]]; then
    mkdir -p "${REPO_ROOT}/var/tmp"
    AUDIT_TASK_BACKUP="$(mktemp "${REPO_ROOT}/var/tmp/bundle-task-backup.XXXXXX")"
    cp "$task_abs" "$AUDIT_TASK_BACKUP"
    AUDIT_TASK_RESTORE=1
  fi

  if (( AUDIT_RESULTS_RESTORE == 0 )) && [[ -f "${REPO_ROOT}/storage/handoff/RESULTS.md" ]]; then
    mkdir -p "${REPO_ROOT}/var/tmp"
    AUDIT_RESULTS_BACKUP="$(mktemp "${REPO_ROOT}/var/tmp/bundle-results-backup.XXXXXX")"
    cp "${REPO_ROOT}/storage/handoff/RESULTS.md" "$AUDIT_RESULTS_BACKUP"
    AUDIT_RESULTS_RESTORE=1
  fi

  if (( AUDIT_CLOSING_RESTORE == 0 )) && [[ -f "${REPO_ROOT}/storage/handoff/CLOSING.md" ]]; then
    mkdir -p "${REPO_ROOT}/var/tmp"
    AUDIT_CLOSING_BACKUP="$(mktemp "${REPO_ROOT}/var/tmp/bundle-closing-backup.XXXXXX")"
    cp "${REPO_ROOT}/storage/handoff/CLOSING.md" "$AUDIT_CLOSING_BACKUP"
    AUDIT_CLOSING_RESTORE=1
  fi

  branch="$(git rev-parse --abbrev-ref HEAD)"
  # Keep the synthetic TASK pointer in archives/surfaces so dump's active-pointer
  # inclusion path sees the same shape in clean CI checkouts.
  AUDIT_FIXTURE_TASK_REL="archives/surfaces/TASK-DP-OPS-9999-fixture.md"
  AUDIT_FIXTURE_RESULTS_REL="storage/handoff/RESULTS.md"
  AUDIT_FIXTURE_CLOSING_REL="storage/handoff/CLOSING.md"
  AUDIT_FIXTURE_PACKET_REL="$AUDIT_FIXTURE_TASK_REL"
  AUDIT_FIXTURE_SUPPORT_PACKET_REL="archives/surfaces/BUNDLE-FIXTURE-SUPPORT-DP-OPS-9999.md"
  AUDIT_FIXTURE_SUPPORT_HANDOFF_REL="storage/handoff/BUNDLE-FIXTURE-DP-OPS-9999.md"
  AUDIT_EXPECTED_PACKET_ID="DP-OPS-9999"
  AUDIT_EXPECTED_PACKET_SOURCE_REL="$AUDIT_FIXTURE_PACKET_REL"

  mkdir -p "${REPO_ROOT}/var/tmp" "${REPO_ROOT}/storage/handoff" "${REPO_ROOT}/archives/surfaces"
  cat > "${REPO_ROOT}/${AUDIT_FIXTURE_TASK_REL}" <<'EOF'
---
packet_id: DP-OPS-9999
---
## 3. Current Dispatch Packet (DP)

### DP-OPS-9999: Bundle audit fixture

## 3.1 Freshness Gate (Must Pass Before Work)
Base Branch: main
Required Work Branch: work/dp-ops-9999-bundle-audit-fixture
Base HEAD: 0000000

### 3.2.2 DP-Scoped Load Order (Declare the exact files required for this packet)
1. archives/surfaces/BUNDLE-FIXTURE-SUPPORT-DP-OPS-9999.md
2. storage/handoff/BUNDLE-FIXTURE-DP-OPS-9999.md
EOF
  printf '%s\n' "${AUDIT_FIXTURE_TASK_REL}" > "$task_abs"
  cat > "${REPO_ROOT}/${AUDIT_FIXTURE_RESULTS_REL}" <<EOF
# DP-OPS-9999 RESULTS

## Certification Metadata
- DP ID: DP-OPS-9999
- Certified At (UTC): 2026-03-16T00:00:00Z
- Branch: ${branch}

## Scope Verification
- Target Files allowlist pointer: storage/dp/active/allowlist.txt
- dp_source: ${AUDIT_FIXTURE_PACKET_REL}
- dump_manifest: none
EOF
  cat > "${REPO_ROOT}/${AUDIT_FIXTURE_CLOSING_REL}" <<'EOF'
Commit Message
Add test bundle audit fixture

Create Pull Request (Title)
DP-OPS-9999 TEST: bundle audit fixture

Create Pull Request (Description)
## Fixture
Bundle audit test fixture.

Confirm Merge (Commit Message)
Ship test bundle audit fixture

Confirm Merge (Extended Description)
storage/dp/active/allowlist.txt

Confirm Merge (Add a Comment)
Is this test bundle audit fixture suitable for integration testing purposes?
EOF
  cat > "${REPO_ROOT}/${AUDIT_FIXTURE_SUPPORT_PACKET_REL}" <<'EOF'
# Bundle Fixture Support Packet

Audit dump explicit-include support fixture.
EOF
  cat > "${REPO_ROOT}/${AUDIT_FIXTURE_SUPPORT_HANDOFF_REL}" <<'EOF'
# Bundle Fixture Handoff

Audit dump explicit-include handoff fixture.
EOF

  if (( AUDIT_RESULTS_RESTORE == 0 )); then
    queue_cleanup_path "$AUDIT_FIXTURE_RESULTS_REL"
  fi
  if (( AUDIT_CLOSING_RESTORE == 0 )); then
    queue_cleanup_path "$AUDIT_FIXTURE_CLOSING_REL"
  fi
  queue_cleanup_path "$AUDIT_FIXTURE_PACKET_REL"
  queue_cleanup_path "$AUDIT_FIXTURE_SUPPORT_PACKET_REL"
  queue_cleanup_path "$AUDIT_FIXTURE_SUPPORT_HANDOFF_REL"
}

extract_fixture_dp_scoped_paths() {
  local packet_rel="$1"
  awk '
    function emit_candidate(line, path) {
      path=""
      if (match(line, /^[[:space:]]*([0-9]+[.]|-)[[:space:]]*`([^`]+)`/, m)) {
        path=m[2]
      } else if (match(line, /^[[:space:]]*([0-9]+[.]|-)[[:space:]]*([A-Za-z0-9._\/-]+)/, m)) {
        path=m[2]
      }
      if (path != "") {
        print path
      }
    }
    BEGIN {
      in_load_order=0
    }
    /^### 3[.]2[.]2([.]|[[:space:]])/ { in_load_order=1; next }
    in_load_order && /^##[[:space:]]*3[.]3([.]|[[:space:]])/ { exit }
    in_load_order && /^### 3[.]3([.]|[[:space:]])/ { exit }
    in_load_order { emit_candidate($0) }
  ' "${REPO_ROOT}/${packet_rel}"
}

run_capture() {
  RUN_OUTPUT=""
  RUN_STATUS=0
  set +e
  RUN_OUTPUT="$("$@" 2>&1)"
  RUN_STATUS=$?
  set -e
}

parse_bundle_output_path() {
  local label="$1"
  printf '%s\n' "$RUN_OUTPUT" | sed -n "s/^${label}:[[:space:]]*//p" | tail -n 1
}

extract_manifest_value() {
  local manifest_rel="$1"
  local key="$2"
  sed -n -E "s/^[[:space:]]*\"${key}\":[[:space:]]*\"([^\"]*)\"[,]?[[:space:]]*$/\\1/p" "${REPO_ROOT}/${manifest_rel}" | head -n 1
}

extract_request_field() {
  local manifest_rel="$1"
  local field="$2"
  awk -v field="$field" '
    /"request"[[:space:]]*:[[:space:]]*{/ { in_req=1; depth=1; next }
    in_req {
      if (/{/) { depth++ }
      if (/}/) {
        depth--
        if (depth <= 0) {
          in_req=0
          exit
        }
      }
      if (match($0, "\"" field "\"[[:space:]]*:[[:space:]]*\"([^\"]*)\"", parts)) {
        print parts[1]
        exit
      }
      if (match($0, "\"" field "\"[[:space:]]*:[[:space:]]*(true|false|null)", parts)) {
        print parts[1]
        exit
      }
    }
  ' "${REPO_ROOT}/${manifest_rel}" | head -n 1
}

extract_submission_field() {
  local manifest_rel="$1"
  local field="$2"
  awk -v field="$field" '
    /"submission"[[:space:]]*:[[:space:]]*{/ { in_submission=1; depth=1; next }
    in_submission {
      if (/{/) { depth++ }
      if (/}/) {
        depth--
        if (depth <= 0) {
          in_submission=0
          exit
        }
      }
      if (match($0, "\"" field "\"[[:space:]]*:[[:space:]]*\"([^\"]*)\"", parts)) {
        print parts[1]
        exit
      }
      if (match($0, "\"" field "\"[[:space:]]*:[[:space:]]*(true|false|null|[0-9]+)", parts)) {
        print parts[1]
        exit
      }
    }
  ' "${REPO_ROOT}/${manifest_rel}" | head -n 1
}

extract_assembly_pointer_emitted() {
  local manifest_rel="$1"
  awk '
    /"pointer"[[:space:]]*:[[:space:]]*{/ { in_pointer=1; depth=1; next }
    in_pointer {
      if (/{/) { depth++ }
      if (/}/) {
        depth--
        if (depth <= 0) {
          in_pointer=0
          exit
        }
      }
      if (/"emitted"[[:space:]]*:[[:space:]]*true/) {
        print "true"
        exit
      }
      if (/"emitted"[[:space:]]*:[[:space:]]*false/) {
        print "false"
        exit
      }
    }
  ' "${REPO_ROOT}/${manifest_rel}" | head -n 1
}

extract_assembly_pointer_path() {
  local manifest_rel="$1"
  awk '
    /"pointer"[[:space:]]*:[[:space:]]*{/ { in_pointer=1; depth=1; next }
    in_pointer {
      if (/{/) { depth++ }
      if (/}/) {
        depth--
        if (depth <= 0) {
          in_pointer=0
          exit
        }
      }
      if (/"path"[[:space:]]*:[[:space:]]*null/) {
        print ""
        exit
      }
      if (match($0, /"path"[[:space:]]*:[[:space:]]*"([^"]+)"/, parts)) {
        print parts[1]
        exit
      }
    }
  ' "${REPO_ROOT}/${manifest_rel}" | head -n 1
}

extract_assembly_pointer_format() {
  local manifest_rel="$1"
  awk '
    /"pointer"[[:space:]]*:[[:space:]]*{/ { in_pointer=1; depth=1; next }
    in_pointer {
      if (/{/) { depth++ }
      if (/}/) {
        depth--
        if (depth <= 0) {
          in_pointer=0
          exit
        }
      }
      if (match($0, /"format"[[:space:]]*:[[:space:]]*"([^"]+)"/, parts)) {
        print parts[1]
        exit
      }
    }
  ' "${REPO_ROOT}/${manifest_rel}" | head -n 1
}

assert_dump_scope_matches_profile() {
  local manifest_rel="$1"
  local profile="$2"
  local expected_scope=""
  local actual_scope=""

  expected_scope="$(policy_scalar "dump_scope_${profile}")"
  if [[ -z "$expected_scope" ]]; then
    fail "policy missing dump scope key for profile=${profile}"
    return
  fi

  actual_scope="$(extract_manifest_value "$manifest_rel" "scope")"
  if [[ "$actual_scope" != "$expected_scope" ]]; then
    fail "profile=${profile} manifest dump scope mismatch: expected ${expected_scope}, got ${actual_scope}"
  fi
}

policy_scalar() {
  local key="$1"
  awk -F'=' -v key="$key" '$1==key { print substr($0, index($0, "=") + 1); exit }' "${REPO_ROOT}/${BUNDLE_POLICY_REL}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
}

expected_artifact_prefix_for_profile() {
  local profile="$1"
  policy_scalar "artifact_prefix_${profile}"
}

next_bundle_output_path() {
  local resolved_profile="$1"
  local prefix=""

  prefix="$(expected_artifact_prefix_for_profile "$resolved_profile")"
  if [[ -z "$prefix" ]]; then
    fail "policy missing artifact prefix for explicit bundle output profile: ${resolved_profile}"
    return 1
  fi

  BUNDLE_OUTPUT_SEQUENCE=$((BUNDLE_OUTPUT_SEQUENCE + 1))
  printf '%s/%s-bundle-smoke-%s-%03d.txt' "$SMOKE_HANDOFF_ROOT" "$prefix" "$$" "$BUNDLE_OUTPUT_SEQUENCE"
}

run_bundle_capture() {
  local resolved_profile="$1"
  shift
  local out_rel=""

  out_rel="$(next_bundle_output_path "$resolved_profile")" || return 1
  run_capture "${REPO_ROOT}/ops/bin/bundle" "$@" "--out=${out_rel}"
}

assert_file_exists() {
  local rel_path="$1"
  [[ -f "${REPO_ROOT}/${rel_path}" ]] || fail "expected file missing: ${rel_path}"
}

assert_prefix() {
  local rel_path="$1"
  local prefix="$2"
  case "$rel_path" in
    "$prefix"*)
      ;;
    *)
      fail "path '${rel_path}' does not start with '${prefix}'"
      ;;
  esac
}

assert_manifest_has() {
  local manifest_rel="$1"
  local expected="$2"
  if ! grep -Fq -- "$expected" "${REPO_ROOT}/${manifest_rel}"; then
    fail "manifest ${manifest_rel} missing expected content: ${expected}"
  fi
}

registry_first_id() {
  local registry_rel="$1"
  awk -F'|' '
    /^\|[[:space:]]*[^|]+[[:space:]]*\|/ {
      id=$2
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      if (id != "" && id != "ID" && id !~ /^-+$/) {
        print id
        exit
      }
    }
  ' "${REPO_ROOT}/${registry_rel}"
}

track_bundle_outputs() {
  local artifact_path
  local manifest_path
  local package_path
  local dump_payload_path
  local dump_manifest_path
  local resolved_profile=""
  local expected_prefix=""
  local legacy_prefix=""
  local legacy_emit_policy=""
  local legacy_artifact_path=""
  local legacy_manifest_path=""
  local legacy_package_path=""
  local expected_pointer_candidate=""

  LAST_ARTIFACT=""
  LAST_MANIFEST=""
  LAST_PACKAGE=""
  LAST_ASSEMBLY_POINTER_EMITTED=""
  LAST_ASSEMBLY_POINTER_PATH=""
  LAST_ASSEMBLY_POINTER_FORMAT=""

  artifact_path="$(parse_bundle_output_path "Bundle artifact")"
  manifest_path="$(parse_bundle_output_path "Bundle manifest")"
  package_path="$(parse_bundle_output_path "Bundle package")"

  if [[ -z "$artifact_path" || -z "$manifest_path" || -z "$package_path" ]]; then
    fail "bundle output did not include artifact/manifest/package paths"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  artifact_path="$(normalize_rel_path "$artifact_path")"
  manifest_path="$(normalize_rel_path "$manifest_path")"
  package_path="$(normalize_rel_path "$package_path")"

  LAST_ARTIFACT="$artifact_path"
  LAST_MANIFEST="$manifest_path"
  LAST_PACKAGE="$package_path"

  assert_file_exists "$artifact_path"
  assert_file_exists "$manifest_path"
  assert_file_exists "$package_path"

  resolved_profile="$(extract_manifest_value "$manifest_path" "resolved_profile")"
  expected_prefix="$(expected_artifact_prefix_for_profile "$resolved_profile")"
  if [[ -z "$expected_prefix" ]]; then
    fail "policy missing artifact prefix for resolved profile: ${resolved_profile}"
  else
    assert_prefix "$artifact_path" "${SMOKE_HANDOFF_ROOT}/${expected_prefix}-"
    assert_prefix "$manifest_path" "${SMOKE_HANDOFF_ROOT}/${expected_prefix}-"
    assert_prefix "$package_path" "${SMOKE_HANDOFF_ROOT}/${expected_prefix}-"
  fi

  if ! grep -Fq 'Stance template key: stance-' "${REPO_ROOT}/${artifact_path}"; then
    fail "bundle artifact missing stance template key marker: ${artifact_path}"
  fi

  queue_cleanup_path "$artifact_path"
  queue_cleanup_path "$manifest_path"
  queue_cleanup_path "$package_path"

  dump_payload_path="$(extract_manifest_value "$manifest_path" "payload_path")"
  dump_manifest_path="$(extract_manifest_value "$manifest_path" "manifest_path")"

  if [[ -n "$dump_payload_path" ]]; then
    assert_prefix "$dump_payload_path" "${SMOKE_DUMP_ROOT}/dump-"
    assert_file_exists "$dump_payload_path"
    queue_cleanup_path "$dump_payload_path"
  else
    fail "manifest ${manifest_path} missing dump payload_path"
  fi

  if [[ -n "$dump_manifest_path" ]]; then
    assert_prefix "$dump_manifest_path" "${SMOKE_DUMP_ROOT}/dump-"
    assert_file_exists "$dump_manifest_path"
    queue_cleanup_path "$dump_manifest_path"
  else
    fail "manifest ${manifest_path} missing dump manifest_path"
  fi

  legacy_prefix="$(policy_scalar compatibility_legacy_bundle_prefix)"
  legacy_emit_policy="$(policy_scalar compatibility_emit_legacy_bundle_artifacts)"
  if [[ "$legacy_emit_policy" == "true" && "$expected_prefix" != "$legacy_prefix" ]]; then
    assert_manifest_has "$manifest_path" '"legacy_emitted": true'
    legacy_artifact_path="$(extract_manifest_value "$manifest_path" "legacy_bundle_path")"
    legacy_manifest_path="$(extract_manifest_value "$manifest_path" "legacy_manifest_path")"
    legacy_package_path="$(extract_manifest_value "$manifest_path" "legacy_package_path")"

    if [[ -z "$legacy_artifact_path" || -z "$legacy_manifest_path" || -z "$legacy_package_path" ]]; then
      fail "manifest ${manifest_path} missing legacy artifact compatibility paths"
    else
      assert_prefix "$legacy_artifact_path" "${SMOKE_HANDOFF_ROOT}/${legacy_prefix}-"
      assert_prefix "$legacy_manifest_path" "${SMOKE_HANDOFF_ROOT}/${legacy_prefix}-"
      assert_prefix "$legacy_package_path" "${SMOKE_HANDOFF_ROOT}/${legacy_prefix}-"
      assert_file_exists "$legacy_artifact_path"
      assert_file_exists "$legacy_manifest_path"
      assert_file_exists "$legacy_package_path"
      queue_cleanup_path "$legacy_artifact_path"
      queue_cleanup_path "$legacy_manifest_path"
      queue_cleanup_path "$legacy_package_path"
    fi
  else
    assert_manifest_has "$manifest_path" '"legacy_emitted": false'
  fi

  LAST_ASSEMBLY_POINTER_EMITTED="$(extract_assembly_pointer_emitted "$manifest_path")"
  LAST_ASSEMBLY_POINTER_PATH="$(extract_assembly_pointer_path "$manifest_path")"
  LAST_ASSEMBLY_POINTER_FORMAT="$(extract_assembly_pointer_format "$manifest_path")"
  expected_pointer_candidate="${artifact_path%.txt}.assembly-pointer.json"

  if [[ "$LAST_ASSEMBLY_POINTER_EMITTED" == "true" ]]; then
    if [[ -z "$LAST_ASSEMBLY_POINTER_PATH" ]]; then
      fail "manifest ${manifest_path} marks assembly pointer emitted=true but path is empty"
    else
      assert_prefix "$LAST_ASSEMBLY_POINTER_PATH" "${SMOKE_HANDOFF_ROOT}/"
      assert_file_exists "$LAST_ASSEMBLY_POINTER_PATH"
      queue_cleanup_path "$LAST_ASSEMBLY_POINTER_PATH"
      if [[ "$LAST_ASSEMBLY_POINTER_PATH" != "$expected_pointer_candidate" ]]; then
        fail "assembly pointer path mismatch: expected ${expected_pointer_candidate}, got ${LAST_ASSEMBLY_POINTER_PATH}"
      fi
      assert_manifest_has "$manifest_path" "\"${LAST_ASSEMBLY_POINTER_PATH}\""
    fi
  elif [[ "$LAST_ASSEMBLY_POINTER_EMITTED" == "false" ]]; then
    if [[ -n "$LAST_ASSEMBLY_POINTER_PATH" ]]; then
      fail "manifest ${manifest_path} marks assembly pointer emitted=false but path is not null"
    fi
  else
    fail "manifest ${manifest_path} missing assembly.pointer.emitted value"
  fi

  if [[ "$LAST_ASSEMBLY_POINTER_FORMAT" != "json" ]]; then
    fail "manifest ${manifest_path} assembly.pointer.format mismatch: expected json, got ${LAST_ASSEMBLY_POINTER_FORMAT}"
  fi
}

expected_stance_template_for_profile() {
  local profile="$1"
  case "$profile" in
    analyst|project)
      printf 'stance-analyst'
      ;;
    architect)
      printf 'stance-architect'
      ;;
    audit)
      printf 'stance-auditor'
      ;;
    conform)
      printf 'stance-conformist'
      ;;
    foreman)
      printf 'stance-foreman'
      ;;
    *)
      printf ''
      ;;
  esac
}

test_stance_template_renderer() {
  local first_render=""
  local second_render=""

  run_capture "${REPO_ROOT}/ops/bin/manifest" render stance-analyst --out=-
  if (( RUN_STATUS != 0 )); then
    fail "manifest stance render failed (first run)"
    echo "$RUN_OUTPUT" >&2
    return
  fi
  first_render="$RUN_OUTPUT"

  if printf '%s\n' "$first_render" | grep -Fq '{{@include:'; then
    fail "manifest stance render left unresolved include directive"
  fi
  if ! printf '%s\n' "$first_render" | grep -Fq 'Follow constraints in `ops/lib/manifests/CONSTRAINTS.md` (Sections 1 & 2).'; then
    fail "manifest stance render missing included shared rules"
  fi

  run_capture "${REPO_ROOT}/ops/bin/manifest" render stance-analyst --out=-
  if (( RUN_STATUS != 0 )); then
    fail "manifest stance render failed (second run)"
    echo "$RUN_OUTPUT" >&2
    return
  fi
  second_render="$RUN_OUTPUT"

  if [[ "$first_render" != "$second_render" ]]; then
    fail "manifest stance render is non-deterministic across repeated runs"
  fi
}

test_valid_profiles() {
  local profile
  local resolved
  local template_key
  local expected_template_key

  ensure_analyst_topic_fixture
  ensure_audit_receipt_fixture
  ensure_architect_plan_fixture
  for profile in analyst architect audit conform; do
    run_bundle_capture "$profile" --profile="$profile"
    if (( RUN_STATUS != 0 )); then
      fail "bundle failed for profile=${profile}"
      echo "$RUN_OUTPUT" >&2
      continue
    fi

    track_bundle_outputs
    [[ -n "$LAST_MANIFEST" ]] || continue

    assert_manifest_has "$LAST_MANIFEST" '"bundle_version": "2"'
    resolved="$(extract_manifest_value "$LAST_MANIFEST" "resolved_profile")"
    if [[ "$profile" == "auto" ]]; then
      case "$resolved" in
        analyst|architect)
          ;;
        *)
          fail "auto profile resolved to unsupported value: ${resolved}"
          ;;
      esac
    else
      if [[ "$resolved" != "$profile" ]]; then
        fail "profile=${profile} manifest resolved_profile mismatch: ${resolved}"
      fi
    fi

    template_key="$(extract_manifest_value "$LAST_MANIFEST" "stance_template_key")"
    expected_template_key="$(expected_stance_template_for_profile "$resolved")"
    if [[ -z "$template_key" ]]; then
      fail "profile=${profile} manifest missing prompt.stance_template_key"
    elif [[ "$template_key" != "$expected_template_key" ]]; then
      fail "profile=${profile} manifest stance_template_key mismatch: expected ${expected_template_key}, got ${template_key}"
    fi

    assert_dump_scope_matches_profile "$LAST_MANIFEST" "$resolved"
    if [[ "$LAST_ASSEMBLY_POINTER_EMITTED" != "false" ]]; then
      fail "profile=${profile} should not emit assembly pointer without ATS triplet"
    fi
  done
}

test_auto_profile_default_route() {
  local resolved=""
  local route_reason=""

  ensure_plan_absent_fixture
  ensure_analyst_topic_fixture

  run_bundle_capture analyst --profile=auto
  if (( RUN_STATUS != 0 )); then
    fail "auto default route should succeed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" ]] || return

  resolved="$(extract_manifest_value "$LAST_MANIFEST" "resolved_profile")"
  route_reason="$(extract_manifest_value "$LAST_MANIFEST" "route_reason")"
  if [[ "$resolved" != "analyst" ]]; then
    fail "auto default route resolved_profile mismatch: expected analyst, got ${resolved}"
  fi
  if [[ "$route_reason" != "auto: PLAN.md missing" ]]; then
    fail "auto default route_reason mismatch: ${route_reason}"
  fi
}

test_auto_profile_plan_route() {
  local resolved=""
  local route_reason=""

  ensure_architect_plan_fixture

  run_bundle_capture architect --profile=auto
  if (( RUN_STATUS != 0 )); then
    fail "auto plan route should succeed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" ]] || return

  resolved="$(extract_manifest_value "$LAST_MANIFEST" "resolved_profile")"
  route_reason="$(extract_manifest_value "$LAST_MANIFEST" "route_reason")"
  if [[ "$resolved" != "architect" ]]; then
    fail "auto plan route resolved_profile mismatch: expected architect, got ${resolved}"
  fi
  if [[ "$route_reason" != "auto: PLAN.md present and plan lint passed" ]]; then
    fail "auto plan route_reason mismatch: ${route_reason}"
  fi
}

test_analyst_contract() {
  local request_topic_source=""
  local request_output_surface=""
  local package_listing=""
  local topic_path=""
  local backup_path=""
  local dump_payload_path=""
  local dump_manifest_path=""

  ensure_analyst_topic_fixture

  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=analyst "--out=${SMOKE_HANDOFF_ROOT}/ANALYST-bundle-smoke-$$-manifest-fail.txt"
  if (( RUN_STATUS != 0 )); then
    fail "analyst contract path failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" ]] || return

  request_topic_source="$(extract_request_field "$LAST_MANIFEST" "topic_source")"
  request_output_surface="$(extract_request_field "$LAST_MANIFEST" "output_surface")"
  if [[ "$request_topic_source" != "storage/handoff/TOPIC.md" ]]; then
    fail "analyst request.topic_source mismatch: expected storage/handoff/TOPIC.md, got ${request_topic_source}"
  fi
  if [[ "$request_output_surface" != "storage/handoff/PLAN.md" ]]; then
    fail "analyst request.output_surface mismatch: expected storage/handoff/PLAN.md, got ${request_output_surface}"
  fi

  if ! grep -Fq '[REQUEST]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "analyst bundle text missing [REQUEST] block"
  fi
  if ! grep -Fq -- '- topic_source: storage/handoff/TOPIC.md' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "analyst bundle text missing topic_source line"
  fi
  if ! grep -Fq -- '- output_surface: storage/handoff/PLAN.md' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "analyst bundle text missing output_surface line"
  fi
  if ! grep -Fq -- '- storage/handoff/TOPIC.md: present' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "analyst bundle text missing TOPIC handoff line"
  fi
  if ! grep -Fq 'Default analyst behavior is discussion mode.' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "analyst bundle text missing discussion-mode default line"
  fi
  if ! grep -Fq 'For default analyst mode: include one `Recommendation:` line naming the preferred option.' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "analyst bundle text missing recommendation contract line"
  fi
  if ! grep -Fq 'For explicit plan-output mode: output only the complete PLAN markdown code block.' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "analyst bundle text missing explicit plan-output line"
  fi
  if grep -Fq -- '- storage/handoff/PLAN.md:' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "analyst bundle text should not advertise PLAN.md as handoff input"
  fi

  if grep -Fq '"plan": {' "${REPO_ROOT}/${LAST_MANIFEST}"; then
    fail "analyst manifest should not emit top-level plan input metadata"
  fi

  dump_payload_path="$(extract_manifest_value "$LAST_MANIFEST" "payload_path")"
  dump_manifest_path="$(extract_manifest_value "$LAST_MANIFEST" "manifest_path")"
  if [[ -z "$dump_payload_path" ]]; then
    fail "analyst manifest missing dump payload_path"
  elif ! grep -Fq '<<< FILE BEGIN: storage/handoff/TOPIC.md' "${REPO_ROOT}/${dump_payload_path}"; then
    fail "analyst dump payload missing storage/handoff/TOPIC.md file block"
  elif ! grep -Fq '[persistence metadata-only]' "${REPO_ROOT}/${dump_payload_path}"; then
    fail "analyst dump payload missing metadata-only cold persistence entries"
  fi
  if [[ -z "$dump_manifest_path" ]]; then
    fail "analyst manifest missing dump manifest_path"
  elif ! grep -Fq 'Include files (explicit): storage/handoff/TOPIC.md' "${REPO_ROOT}/${dump_manifest_path}"; then
    fail "analyst dump manifest missing explicit TOPIC include provenance"
  elif ! grep -Fq 'Persistence profile: analyst' "${REPO_ROOT}/${dump_manifest_path}"; then
    fail "analyst dump manifest missing persistence profile"
  fi
  if [[ "$(extract_manifest_value "$LAST_MANIFEST" "persistence_profile")" != "analyst" ]]; then
    fail "analyst bundle manifest dump.persistence_profile mismatch"
  fi

  package_listing="$(tar -tf "${REPO_ROOT}/${LAST_PACKAGE}")"
  if ! printf '%s\n' "$package_listing" | grep -Fxq 'storage/handoff/TOPIC.md'; then
    fail "analyst package missing storage/handoff/TOPIC.md"
  fi
  if printf '%s\n' "$package_listing" | grep -Fxq 'storage/handoff/PLAN.md'; then
    fail "analyst package should not include storage/handoff/PLAN.md"
  fi

  topic_path="${REPO_ROOT}/storage/handoff/TOPIC.md"
  backup_path="$(mktemp "${REPO_ROOT}/var/tmp/analyst-topic-backup.XXXXXX")"
  cp "$topic_path" "$backup_path"
  rm -f "$topic_path"

  run_bundle_capture analyst --profile=analyst

  cp "$backup_path" "$topic_path"
  rm -f "$backup_path"

  if (( RUN_STATUS == 0 )); then
    fail "analyst bundle should fail closed when TOPIC.md is missing"
  fi
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq 'analyst requires storage/handoff/TOPIC.md'; then
    fail "analyst missing-topic failure message mismatch"
  fi
}

test_architect_slice_valid() {
  local slice_id="T1"
  local expected_packet_id=""

  ensure_architect_plan_fixture
  local request_slice_id_val=""
  local request_validated_val=""
  local request_source_val=""
  local request_packet_id_val=""
  local request_dp_draft_path_val=""
  local request_sidecar_val=""
  local request_title_suffix_val=""
  local package_listing=""
  local dump_payload_path=""
  local dump_manifest_path=""

  expected_packet_id="$(resolve_expected_architect_packet_id)" || {
    fail "unable to resolve expected architect packet id from current TASK"
    return
  }

  run_bundle_capture architect --profile=architect --slice="$slice_id"
  if (( RUN_STATUS != 0 )); then
    fail "architect --slice=${slice_id} should succeed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" && -n "$LAST_ARTIFACT" ]] || return

  if ! grep -Fq '[REQUEST]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing [REQUEST] block for valid slice"
  fi
  if ! grep -Fq "slice_id: ${slice_id}" "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing valid slice_id marker"
  fi
  if ! grep -Fq 'slice_validated: true' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing slice_validated: true"
  fi
  if ! grep -Fq "packet_id: ${expected_packet_id}" "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing packet_id: ${expected_packet_id}"
  fi
  if ! grep -Fq 'current_plan_source: storage/current/PLAN.md' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing current_plan_source marker"
  fi
  if ! grep -Fq 'dp_draft_path: storage/dp/intake/DP.md' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing active dp_draft_path marker"
  fi
  if ! grep -Fq 'closing_sidecar: storage/handoff/CLOSING.md' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing closing sidecar marker"
  fi
  if ! grep -Fq 'title_suffix: Architect Transport Slice Intent' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing title_suffix marker"
  fi
  if ! grep -Fq -- '- storage/handoff/PLAN.md: present' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing PLAN handoff line"
  fi
  if ! grep -Fq -- '- storage/current/PLAN.md: present' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing current PLAN line"
  fi
  if grep -Fq -- '- storage/handoff/TOPIC.md:' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text should not advertise TOPIC.md as disposable input"
  fi
  if ! grep -Fq '[ACTIVE SLICE PROJECTION]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing [ACTIVE SLICE PROJECTION] block"
  fi
  if ! grep -Fq 'selected_option: A (Dispatch Reliability Corridor)' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect projection missing selected option"
  fi
  if ! grep -Fq 'execution_order: T1 -> T1.1 -> T1.2' "${REPO_ROOT}/${LAST_ARTIFACT}" && ! grep -Fq 'execution_order: T1' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect projection missing execution order"
  fi

  request_slice_id_val="$(extract_request_field "$LAST_MANIFEST" "slice_id")"
  request_validated_val="$(extract_request_field "$LAST_MANIFEST" "slice_validated")"
  request_source_val="$(extract_request_field "$LAST_MANIFEST" "plan_source")"
  request_packet_id_val="$(extract_request_field "$LAST_MANIFEST" "packet_id")"
  request_dp_draft_path_val="$(extract_request_field "$LAST_MANIFEST" "dp_draft_path")"
  request_sidecar_val="$(extract_request_field "$LAST_MANIFEST" "closing_sidecar")"
  request_title_suffix_val="$(extract_request_field "$LAST_MANIFEST" "title_suffix")"

  if [[ "$request_slice_id_val" != "$slice_id" ]]; then
    fail "architect request.slice_id mismatch: expected ${slice_id}, got ${request_slice_id_val}"
  fi
  if [[ "$request_validated_val" != "true" ]]; then
    fail "architect request.slice_validated mismatch: expected true, got ${request_validated_val}"
  fi
  if [[ "$request_source_val" != "storage/handoff/PLAN.md" ]]; then
    fail "architect request.plan_source mismatch: expected storage/handoff/PLAN.md, got ${request_source_val}"
  fi
  if [[ "$request_packet_id_val" != "$expected_packet_id" ]]; then
    fail "architect request.packet_id mismatch: expected ${expected_packet_id}, got ${request_packet_id_val}"
  fi
  if [[ "$(extract_request_field "$LAST_MANIFEST" "current_plan_source")" != "storage/current/PLAN.md" ]]; then
    fail "architect request.current_plan_source mismatch: expected storage/current/PLAN.md"
  fi
  if [[ "$request_dp_draft_path_val" != "storage/dp/intake/DP.md" ]]; then
    fail "architect request.dp_draft_path mismatch: expected storage/dp/intake/DP.md, got ${request_dp_draft_path_val}"
  fi
  if [[ "$request_sidecar_val" != "storage/handoff/CLOSING.md" ]]; then
    fail "architect request.closing_sidecar mismatch: expected storage/handoff/CLOSING.md, got ${request_sidecar_val}"
  fi
  if [[ "$request_title_suffix_val" != "Architect Transport Slice Intent" ]]; then
    fail "architect request.title_suffix mismatch: expected Architect Transport Slice Intent, got ${request_title_suffix_val}"
  fi

  dump_payload_path="$(extract_manifest_value "$LAST_MANIFEST" "payload_path")"
  dump_manifest_path="$(extract_manifest_value "$LAST_MANIFEST" "manifest_path")"
  if [[ -z "$dump_payload_path" ]]; then
    fail "architect manifest missing dump payload_path"
  elif ! grep -Fq '<<< FILE BEGIN: storage/handoff/PLAN.md' "${REPO_ROOT}/${dump_payload_path}"; then
    fail "architect dump payload missing storage/handoff/PLAN.md file block"
  elif ! grep -Fq '<<< FILE BEGIN: storage/current/PLAN.md' "${REPO_ROOT}/${dump_payload_path}"; then
    fail "architect dump payload missing storage/current/PLAN.md file block"
  fi
  if [[ -z "$dump_manifest_path" ]]; then
    fail "architect manifest missing dump manifest_path"
  elif ! grep -Fq 'storage/handoff/PLAN.md' "${REPO_ROOT}/${dump_manifest_path}" || ! grep -Fq 'storage/current/PLAN.md' "${REPO_ROOT}/${dump_manifest_path}"; then
    fail "architect dump manifest missing explicit PLAN include provenance"
  elif ! grep -Fq 'Persistence profile: architect' "${REPO_ROOT}/${dump_manifest_path}"; then
    fail "architect dump manifest missing persistence profile"
  fi
  if [[ "$(extract_manifest_value "$LAST_MANIFEST" "persistence_profile")" != "architect" ]]; then
    fail "architect bundle manifest dump.persistence_profile mismatch"
  fi

  package_listing="$(tar -tf "${REPO_ROOT}/${LAST_PACKAGE}")"
  if ! printf '%s\n' "$package_listing" | grep -Fxq 'storage/handoff/PLAN.md'; then
    fail "architect package missing storage/handoff/PLAN.md"
  fi
  if ! printf '%s\n' "$package_listing" | grep -Fxq 'storage/current/PLAN.md'; then
    fail "architect package missing storage/current/PLAN.md"
  fi
  if printf '%s\n' "$package_listing" | grep -Fxq 'storage/handoff/TOPIC.md'; then
    fail "architect package should not include storage/handoff/TOPIC.md"
  fi
}

test_architect_slice_ad_hoc() {
  local request_slice_id_val=""
  local request_validated_val=""
  local request_source_val=""
  local request_packet_id_val=""
  local request_sidecar_val=""
  local request_title_suffix_val=""
  local request_current_plan_source_val=""

  ensure_architect_plan_fixture
  run_bundle_capture architect --profile=architect
  if (( RUN_STATUS != 0 )); then
    fail "architect ad hoc run should succeed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" && -n "$LAST_ARTIFACT" ]] || return

  if ! grep -Fq '[REQUEST]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect bundle text missing [REQUEST] block for ad hoc run"
  fi
  if ! grep -Fq 'slice_id: (ad hoc)' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect ad hoc bundle text missing ad hoc slice marker"
  fi
  if ! grep -Fq 'slice_validated: false' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect ad hoc bundle text missing slice_validated: false"
  fi
  if ! grep -Fq 'packet_id: (none)' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect ad hoc bundle text missing packet_id: (none)"
  fi
  if ! grep -Fq 'closing_sidecar: (none)' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect ad hoc bundle text missing closing_sidecar: (none)"
  fi
  if grep -Fq '[ACTIVE SLICE PROJECTION]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect ad hoc bundle text should not emit [ACTIVE SLICE PROJECTION]"
  fi

  request_slice_id_val="$(extract_request_field "$LAST_MANIFEST" "slice_id")"
  request_validated_val="$(extract_request_field "$LAST_MANIFEST" "slice_validated")"
  request_source_val="$(extract_request_field "$LAST_MANIFEST" "plan_source")"
  request_current_plan_source_val="$(extract_request_field "$LAST_MANIFEST" "current_plan_source")"
  request_packet_id_val="$(extract_request_field "$LAST_MANIFEST" "packet_id")"
  request_sidecar_val="$(extract_request_field "$LAST_MANIFEST" "closing_sidecar")"
  request_title_suffix_val="$(extract_request_field "$LAST_MANIFEST" "title_suffix")"

  if [[ "$request_slice_id_val" != "null" ]]; then
    fail "architect ad hoc request.slice_id mismatch: expected null, got ${request_slice_id_val}"
  fi
  if [[ "$request_validated_val" != "false" ]]; then
    fail "architect ad hoc request.slice_validated mismatch: expected false, got ${request_validated_val}"
  fi
  if [[ "$request_source_val" != "null" ]]; then
    fail "architect ad hoc request.plan_source mismatch: expected null, got ${request_source_val}"
  fi
  if [[ "$request_current_plan_source_val" != "storage/current/PLAN.md" ]]; then
    fail "architect ad hoc request.current_plan_source mismatch: expected storage/current/PLAN.md, got ${request_current_plan_source_val}"
  fi
  if [[ "$request_packet_id_val" != "null" ]]; then
    fail "architect ad hoc request.packet_id mismatch: expected null, got ${request_packet_id_val}"
  fi
  if [[ "$request_sidecar_val" != "null" ]]; then
    fail "architect ad hoc request.closing_sidecar mismatch: expected null, got ${request_sidecar_val}"
  fi
  if [[ "$request_title_suffix_val" != "null" ]]; then
    fail "architect ad hoc request.title_suffix mismatch: expected null, got ${request_title_suffix_val}"
  fi
}

test_architect_slice_implicit_bind() {
  local expected_packet_id=""
  local request_slice_id_val=""
  local request_validated_val=""
  local request_source_val=""
  local request_current_plan_source_val=""
  local request_packet_id_val=""
  local request_sidecar_val=""
  local request_title_suffix_val=""

  ensure_architect_plan_autobind_fixture
  expected_packet_id="$(resolve_expected_architect_packet_id)" || {
    fail "unable to resolve expected architect implicit-bind packet id from current TASK"
    return
  }

  run_bundle_capture architect --profile=architect
  if (( RUN_STATUS != 0 )); then
    fail "architect implicit-bind run should succeed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" && -n "$LAST_ARTIFACT" ]] || return

  if ! grep -Fq '[REQUEST]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect implicit-bind bundle text missing [REQUEST] block"
  fi
  if ! grep -Fq 'slice_id: T1' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect implicit-bind bundle text missing slice_id: T1"
  fi
  if ! grep -Fq 'slice_validated: true' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect implicit-bind bundle text missing slice_validated: true"
  fi
  if ! grep -Fq "packet_id: ${expected_packet_id}" "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect implicit-bind bundle text missing packet_id: ${expected_packet_id}"
  fi
  if ! grep -Fq 'current_plan_source: storage/current/PLAN.md' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect implicit-bind bundle text missing current_plan_source marker"
  fi
  if ! grep -Fq 'closing_sidecar: storage/handoff/CLOSING.md' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect implicit-bind bundle text missing closing sidecar marker"
  fi
  if ! grep -Fq 'title_suffix: Architect Transport Slice Intent' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect implicit-bind bundle text missing title_suffix marker"
  fi
  if ! grep -Fq '[ACTIVE SLICE PROJECTION]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "architect implicit-bind bundle text missing [ACTIVE SLICE PROJECTION]"
  fi

  request_slice_id_val="$(extract_request_field "$LAST_MANIFEST" "slice_id")"
  request_validated_val="$(extract_request_field "$LAST_MANIFEST" "slice_validated")"
  request_source_val="$(extract_request_field "$LAST_MANIFEST" "plan_source")"
  request_current_plan_source_val="$(extract_request_field "$LAST_MANIFEST" "current_plan_source")"
  request_packet_id_val="$(extract_request_field "$LAST_MANIFEST" "packet_id")"
  request_sidecar_val="$(extract_request_field "$LAST_MANIFEST" "closing_sidecar")"
  request_title_suffix_val="$(extract_request_field "$LAST_MANIFEST" "title_suffix")"

  if [[ "$request_slice_id_val" != "T1" ]]; then
    fail "architect implicit-bind request.slice_id mismatch: expected T1, got ${request_slice_id_val}"
  fi
  if [[ "$request_validated_val" != "true" ]]; then
    fail "architect implicit-bind request.slice_validated mismatch: expected true, got ${request_validated_val}"
  fi
  if [[ "$request_source_val" != "storage/handoff/PLAN.md" ]]; then
    fail "architect implicit-bind request.plan_source mismatch: expected storage/handoff/PLAN.md, got ${request_source_val}"
  fi
  if [[ "$request_current_plan_source_val" != "storage/current/PLAN.md" ]]; then
    fail "architect implicit-bind request.current_plan_source mismatch: expected storage/current/PLAN.md, got ${request_current_plan_source_val}"
  fi
  if [[ "$request_packet_id_val" != "$expected_packet_id" ]]; then
    fail "architect implicit-bind request.packet_id mismatch: expected ${expected_packet_id}, got ${request_packet_id_val}"
  fi
  if [[ "$request_sidecar_val" != "storage/handoff/CLOSING.md" ]]; then
    fail "architect implicit-bind request.closing_sidecar mismatch: expected storage/handoff/CLOSING.md, got ${request_sidecar_val}"
  fi
  if [[ "$request_title_suffix_val" != "Architect Transport Slice Intent" ]]; then
    fail "architect implicit-bind request.title_suffix mismatch: expected Architect Transport Slice Intent, got ${request_title_suffix_val}"
  fi
}

test_audit_contract() {
  local package_listing=""
  local dump_payload_path=""
  local dump_manifest_path=""
  local audit_results_rel=""
  local audit_closing_rel=""
  local audit_task_surface_rel=""
  local audit_packet_source_rel=""
  local scoped_rel=""
  local results_dp_source_line=""

  ensure_audit_receipt_fixture
  [[ -n "$AUDIT_EXPECTED_PACKET_ID" ]] || {
    fail "audit contract expected packet id did not resolve"
    return
  }
  audit_results_rel="storage/handoff/RESULTS.md"
  audit_closing_rel="storage/handoff/CLOSING.md"
  audit_task_surface_rel="$(resolve_current_task_surface_rel)"
  audit_packet_source_rel="$AUDIT_EXPECTED_PACKET_SOURCE_REL"

  if [[ -f "${REPO_ROOT}/${audit_results_rel}" ]]; then
    results_dp_source_line="$(awk '
      /^-[[:space:]]*dp_source:[[:space:]]*/ {
        line=$0
        sub(/^[^:]*:[[:space:]]*/, "", line)
        print line
        exit
      }
    ' "${REPO_ROOT}/${audit_results_rel}")"
    results_dp_source_line="$(trim "$results_dp_source_line")"
    if [[ "$results_dp_source_line" != "$audit_packet_source_rel" ]]; then
      fail "audit RESULTS dp_source mismatch: expected ${audit_packet_source_rel}, got ${results_dp_source_line:-"(missing)"}"
    fi
  fi

  run_bundle_capture audit --profile=audit
  if (( RUN_STATUS != 0 )); then
    fail "audit contract path failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" && -n "$LAST_ARTIFACT" ]] || return

  if grep -Fq '[HANDOFF]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "audit bundle text should not emit [HANDOFF]"
  fi

  dump_payload_path="$(extract_manifest_value "$LAST_MANIFEST" "payload_path")"
  dump_manifest_path="$(extract_manifest_value "$LAST_MANIFEST" "manifest_path")"
  if [[ -z "$dump_payload_path" ]]; then
    fail "audit manifest missing dump payload_path"
  else
    if ! grep -Fq "<<< FILE BEGIN: ${audit_results_rel}" "${REPO_ROOT}/${dump_payload_path}"; then
      fail "audit dump payload missing current RESULTS file block"
    fi
    if ! grep -Fq "<<< FILE BEGIN: ${audit_closing_rel}" "${REPO_ROOT}/${dump_payload_path}"; then
      fail "audit dump payload missing current closing sidecar file block"
    fi
    if ! grep -Fq "<<< FILE BEGIN: ${audit_task_surface_rel}" "${REPO_ROOT}/${dump_payload_path}"; then
      fail "audit dump payload missing current TASK leaf file block"
    fi
    if ! grep -Fq "<<< FILE BEGIN: ${audit_packet_source_rel}" "${REPO_ROOT}/${dump_payload_path}"; then
      fail "audit dump payload missing current packet source file block"
    fi
  fi
  if [[ -z "$dump_manifest_path" ]]; then
    fail "audit manifest missing dump manifest_path"
  elif ! grep -Fq "Include files (explicit): ${audit_results_rel} ${audit_closing_rel} ${audit_packet_source_rel}" "${REPO_ROOT}/${dump_manifest_path}"; then
    fail "audit dump manifest missing explicit RESULTS/CLOSING/packet-source include provenance"
  elif ! grep -Fq 'Persistence profile: audit' "${REPO_ROOT}/${dump_manifest_path}"; then
    fail "audit dump manifest missing persistence profile"
  fi
  while IFS= read -r scoped_rel || [[ -n "$scoped_rel" ]]; do
    [[ -n "$scoped_rel" ]] || continue
    if [[ ! -f "${REPO_ROOT}/${scoped_rel}" ]]; then
      continue
    fi
    if ! grep -Fq "<<< FILE BEGIN: ${scoped_rel}" "${REPO_ROOT}/${dump_payload_path}"; then
      fail "audit dump payload missing scoped audit evidence file block: ${scoped_rel}"
    fi
    if ! grep -Fq "${scoped_rel}" "${REPO_ROOT}/${dump_manifest_path}"; then
      fail "audit dump manifest missing scoped audit evidence include provenance: ${scoped_rel}"
    fi
  done < <(extract_fixture_dp_scoped_paths "$audit_packet_source_rel")
  if [[ "$(extract_manifest_value "$LAST_MANIFEST" "persistence_profile")" != "audit" ]]; then
    fail "audit bundle manifest dump.persistence_profile mismatch"
  fi

  package_listing="$(tar -tf "${REPO_ROOT}/${LAST_PACKAGE}")"
  if ! printf '%s\n' "$package_listing" | grep -Fxq "$audit_results_rel"; then
    fail "audit package missing current RESULTS file"
  fi
  if ! printf '%s\n' "$package_listing" | grep -Fxq "$audit_closing_rel"; then
    fail "audit package missing current closing sidecar"
  fi
  if ! printf '%s\n' "$package_listing" | grep -Fxq "$audit_packet_source_rel"; then
    fail "audit package missing current packet source file"
  fi
  if printf '%s\n' "$package_listing" | grep -Fxq 'storage/handoff/TOPIC.md'; then
    fail "audit package should not include storage/handoff/TOPIC.md"
  fi
  if printf '%s\n' "$package_listing" | grep -Fxq 'storage/handoff/PLAN.md'; then
    fail "audit package should not include storage/handoff/PLAN.md"
  fi
}

test_bundle_closeout_sanity() {
  local dump_manifest_path=""
  local package_listing=""

  ensure_audit_receipt_fixture

  run_bundle_capture audit --profile=audit
  if (( RUN_STATUS != 0 )); then
    fail "audit closeout sanity path failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" && -n "$LAST_ARTIFACT" && -n "$LAST_PACKAGE" ]] || return

  if [[ "$(extract_manifest_value "$LAST_MANIFEST" "resolved_profile")" != "audit" ]]; then
    fail "audit closeout sanity resolved_profile mismatch"
  fi
  if [[ "$(extract_submission_field "$LAST_MANIFEST" "kind")" != "audit_submission" ]]; then
    fail "audit closeout sanity submission.kind mismatch"
  fi
  if grep -Fq '[HANDOFF]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "audit closeout sanity bundle text should not emit [HANDOFF]"
  fi

  dump_manifest_path="$(extract_manifest_value "$LAST_MANIFEST" "manifest_path")"
  if [[ -z "$dump_manifest_path" ]]; then
    fail "audit closeout sanity manifest missing dump manifest_path"
  elif ! grep -Fq 'Persistence profile: audit' "${REPO_ROOT}/${dump_manifest_path}"; then
    fail "audit closeout sanity dump manifest missing persistence profile"
  fi

  package_listing="$(tar -tf "${REPO_ROOT}/${LAST_PACKAGE}")"
  if ! printf '%s\n' "$package_listing" | grep -Fxq "storage/handoff/RESULTS.md"; then
    fail "audit closeout sanity package missing current RESULTS file"
  fi
  if ! printf '%s\n' "$package_listing" | grep -Fxq "storage/handoff/CLOSING.md"; then
    fail "audit closeout sanity package missing current closing sidecar"
  fi
}

test_audit_resubmission_identity() {
  local requested_out_rel=""
  local expected_rerun_rel=""
  local first_artifact=""
  local first_manifest=""
  local repeat_artifact=""
  local repeat_manifest=""
  local rerun_artifact=""
  local rerun_manifest=""
  local rerun_dump_payload=""
  local rerun_submission_kind=""
  local rerun_submission_index=""
  local rerun_supersedes=""
  local rerun_refresh_reason=""

  ensure_audit_receipt_fixture
  requested_out_rel="${SMOKE_HANDOFF_ROOT}/AUDIT-rerun-smoke-$$.txt"
  expected_rerun_rel="${SMOKE_HANDOFF_ROOT}/AUDIT-R1-rerun-smoke-$$.txt"

  # Step 1: initial delivery — no prior artifact, no --rerun, must produce AUDIT-*
  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=audit "--out=${requested_out_rel}"
  if (( RUN_STATUS != 0 )); then
    fail "audit initial invocation failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi
  track_bundle_outputs
  first_artifact="$LAST_ARTIFACT"
  first_manifest="$LAST_MANIFEST"
  if [[ "$first_artifact" != "$requested_out_rel" ]]; then
    fail "audit initial artifact path mismatch: expected ${requested_out_rel}, got ${first_artifact}"
  fi
  if [[ "$(extract_submission_field "$first_manifest" "kind")" != "audit_submission" ]]; then
    fail "audit initial submission.kind mismatch"
  fi
  if [[ "$(extract_submission_field "$first_manifest" "resubmission_index")" != "0" ]]; then
    fail "audit initial submission.resubmission_index mismatch"
  fi
  if [[ "$(extract_submission_field "$first_manifest" "supersedes_bundle_path")" != "null" ]]; then
    fail "audit initial submission.supersedes_bundle_path should be null"
  fi

  # Step 2: repeat without --rerun — stale prior artifact exists; must still produce AUDIT-* (not AUDIT-R1-*)
  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=audit "--out=${requested_out_rel}"
  if (( RUN_STATUS != 0 )); then
    fail "audit repeat (no --rerun) invocation failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi
  track_bundle_outputs
  repeat_artifact="$LAST_ARTIFACT"
  repeat_manifest="$LAST_MANIFEST"
  if [[ "$repeat_artifact" != "$requested_out_rel" ]]; then
    fail "audit stale-file repeat (no --rerun): expected initial identity ${requested_out_rel}, got ${repeat_artifact}"
  fi
  if [[ "$(extract_submission_field "$repeat_manifest" "kind")" != "audit_submission" ]]; then
    fail "audit stale-file repeat (no --rerun): submission.kind must remain audit_submission"
  fi
  if [[ "$(extract_submission_field "$repeat_manifest" "resubmission_index")" != "0" ]]; then
    fail "audit stale-file repeat (no --rerun): submission.resubmission_index must remain 0"
  fi

  # Step 3: explicit --rerun — prior AUDIT-* artifact present; must produce AUDIT-R1-* with lineage
  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=audit --rerun "--out=${requested_out_rel}"
  if (( RUN_STATUS != 0 )); then
    fail "audit explicit --rerun invocation failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi
  track_bundle_outputs
  rerun_artifact="$LAST_ARTIFACT"
  rerun_manifest="$LAST_MANIFEST"
  rerun_submission_kind="$(extract_submission_field "$rerun_manifest" "kind")"
  rerun_submission_index="$(extract_submission_field "$rerun_manifest" "resubmission_index")"
  rerun_supersedes="$(extract_submission_field "$rerun_manifest" "supersedes_bundle_path")"
  rerun_refresh_reason="$(extract_submission_field "$rerun_manifest" "refresh_reason")"
  rerun_dump_payload="$(extract_manifest_value "$rerun_manifest" "payload_path")"

  if [[ "$rerun_artifact" != "$expected_rerun_rel" ]]; then
    fail "audit rerun artifact path mismatch: expected ${expected_rerun_rel}, got ${rerun_artifact}"
  fi
  if [[ "$rerun_submission_kind" != "audit_resubmission" ]]; then
    fail "audit rerun submission.kind mismatch: expected audit_resubmission, got ${rerun_submission_kind:-"(missing)"}"
  fi
  if [[ "$rerun_submission_index" != "1" ]]; then
    fail "audit rerun submission.resubmission_index mismatch: expected 1, got ${rerun_submission_index:-"(missing)"}"
  fi
  if [[ "$rerun_supersedes" != "$first_artifact" ]]; then
    fail "audit rerun submission.supersedes_bundle_path mismatch: expected ${first_artifact}, got ${rerun_supersedes:-"(missing)"}"
  fi
  if [[ "$rerun_refresh_reason" != "rerun" ]]; then
    fail "audit rerun submission.refresh_reason mismatch: expected rerun, got ${rerun_refresh_reason:-"(missing)"}"
  fi
  if [[ "$rerun_dump_payload" != "${SMOKE_DUMP_ROOT}/dump-core-AUDIT-R1-rerun-smoke-$$.txt" ]]; then
    fail "audit rerun dump payload path mismatch: expected ${SMOKE_DUMP_ROOT}/dump-core-AUDIT-R1-rerun-smoke-$$.txt, got ${rerun_dump_payload:-"(missing)"}"
  fi
  if ! grep -Fq '[SUBMISSION]' "${REPO_ROOT}/${rerun_artifact}"; then
    fail "audit rerun bundle text missing [SUBMISSION] block"
  fi
  if ! grep -Fq -- "- supersedes: ${first_artifact}" "${REPO_ROOT}/${rerun_artifact}"; then
    fail "audit rerun bundle text missing supersedes line"
  fi
}

test_architect_slice_unknown_fails() {
  ensure_architect_plan_fixture
  run_bundle_capture architect --profile=architect --slice=UNKNOWN
  if (( RUN_STATUS == 0 )); then
    fail "architect unknown --slice should fail"
  fi
}

test_architect_slice_blank_fails() {
  run_bundle_capture architect --profile=architect --slice=
  if (( RUN_STATUS == 0 )); then
    fail "architect blank --slice should fail"
  fi
}

test_architect_slice_non_architect_fails() {
  run_bundle_capture analyst --profile=analyst --slice=T1
  if (( RUN_STATUS == 0 )); then
    fail "--slice with non-architect profile should fail"
  fi
}

test_foreman_invalid_paths() {
  run_bundle_capture foreman --profile=foreman
  if (( RUN_STATUS == 0 )); then
    fail "foreman path without --intent should fail"
  fi

  run_bundle_capture foreman --profile=foreman --intent="bad format"
  if (( RUN_STATUS == 0 )); then
    fail "foreman path with malformed --intent should fail"
  fi
}

test_foreman_valid_path() {
  local decision_leaf
  local decision_id
  local intent
  local resolved
  local manifest_decision_id
  local template_key

  decision_leaf="$(find "${REPO_ROOT}/archives/decisions" -maxdepth 1 -type f -name 'RoR-*.md' | sort | head -n 1)"
  if [[ -z "$decision_leaf" ]]; then
    fail "no decision leaves found under archives/decisions/"
    return
  fi
  decision_id="$(basename "$decision_leaf" .md)"
  intent="ADDENDUM REQUIRED: ${decision_id} - bundle smoke gate test"

  run_bundle_capture foreman --profile=foreman --intent="$intent"
  if (( RUN_STATUS != 0 )); then
    fail "foreman path with valid --intent failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" ]] || return

  resolved="$(extract_manifest_value "$LAST_MANIFEST" "resolved_profile")"
  if [[ "$resolved" != "foreman" ]]; then
    fail "foreman manifest resolved_profile mismatch: ${resolved}"
  fi

  manifest_decision_id="$(extract_manifest_value "$LAST_MANIFEST" "decision_id")"
  if [[ "$manifest_decision_id" != "$decision_id" ]]; then
    fail "foreman manifest decision_id mismatch: expected ${decision_id}, got ${manifest_decision_id}"
  fi

  template_key="$(extract_manifest_value "$LAST_MANIFEST" "stance_template_key")"
  if [[ "$template_key" != "stance-foreman" ]]; then
    fail "foreman manifest stance_template_key mismatch: expected stance-foreman, got ${template_key}"
  fi

  assert_dump_scope_matches_profile "$LAST_MANIFEST" "foreman"
  assert_manifest_has "$LAST_MANIFEST" '"decision_leaf_present": true'
}

test_legacy_hygiene_alias() {
  local resolved
  local requested
  local route_reason
  local expected_status
  local expected_remove_after
  local actual_status
  local actual_remove_after

  run_bundle_capture conform --profile=hygiene
  if (( RUN_STATUS != 0 )); then
    fail "legacy hygiene alias path failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" ]] || return

  resolved="$(extract_manifest_value "$LAST_MANIFEST" "resolved_profile")"
  requested="$(extract_manifest_value "$LAST_MANIFEST" "requested_profile")"
  route_reason="$(extract_manifest_value "$LAST_MANIFEST" "route_reason")"

  if [[ "$resolved" != "conform" ]]; then
    fail "legacy hygiene alias resolved_profile mismatch: expected conform, got ${resolved}"
  fi
  if [[ "$requested" != "hygiene" ]]; then
    fail "legacy hygiene alias requested_profile mismatch: expected hygiene, got ${requested}"
  fi
  if [[ "$route_reason" != "explicit profile alias: hygiene -> conform" ]]; then
    fail "legacy hygiene alias route_reason mismatch: ${route_reason}"
  fi
  assert_dump_scope_matches_profile "$LAST_MANIFEST" "$resolved"
  assert_manifest_has "$LAST_MANIFEST" '"profile_alias": {'
  assert_manifest_has "$LAST_MANIFEST" '"from": "hygiene"'
  assert_manifest_has "$LAST_MANIFEST" '"to": "conform"'

  expected_status="$(policy_scalar profile_alias_legacy_hygiene_deprecation_status)"
  expected_remove_after="$(policy_scalar profile_alias_legacy_hygiene_remove_after_dp)"
  actual_status="$(extract_manifest_value "$LAST_MANIFEST" "deprecation_status")"
  actual_remove_after="$(extract_manifest_value "$LAST_MANIFEST" "remove_after_dp")"
  if [[ "$actual_status" != "$expected_status" ]]; then
    fail "legacy hygiene alias deprecation_status mismatch: expected ${expected_status}, got ${actual_status}"
  fi
  if [[ "$actual_remove_after" != "$expected_remove_after" ]]; then
    fail "legacy hygiene alias remove_after_dp mismatch: expected ${expected_remove_after}, got ${actual_remove_after}"
  fi
}

test_manifest_fail_closed() {
  local policy_abs="${REPO_ROOT}/${BUNDLE_POLICY_REL}"
  local backup_path=""

  [[ -f "$policy_abs" ]] || {
    fail "bundle policy missing for fail-closed test: ${BUNDLE_POLICY_REL}"
    return
  }

  backup_path="$(mktemp "${REPO_ROOT}/var/tmp/bundle-policy-backup.XXXXXX")"
  cp "$policy_abs" "$backup_path"

  # Remove one required key to force parser failure.
  grep -v '^supported_profiles=' "$backup_path" > "$policy_abs"

  run_bundle_capture analyst --profile=analyst
  if (( RUN_STATUS == 0 )); then
    fail "bundle should fail when required manifest key is missing"
  fi
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq 'bundle policy missing required key'; then
    fail "bundle fail-closed output did not include expected manifest-key error"
  fi

  cp "$backup_path" "$policy_abs"
  rm -f "$backup_path"
}

test_ats_partial_flags_fail() {
  ensure_analyst_topic_fixture
  run_bundle_capture analyst --profile=analyst --agent-id=R-AGENT-01
  if (( RUN_STATUS == 0 )); then
    fail "ATS partial flags should fail"
  fi
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq 'assembly validation requires all ATS flags together'; then
    fail "ATS partial flags failure message mismatch"
  fi
}

test_ats_unknown_ids_fail() {
  local known_agent_id
  local known_skill_id
  local known_task_id
  ensure_analyst_topic_fixture
  known_agent_id="$(registry_first_id "docs/ops/registry/agents.md")"
  known_skill_id="$(registry_first_id "docs/ops/registry/skills.md")"
  known_task_id="$(registry_first_id "docs/ops/registry/tasks.md")"
  if [[ -z "$known_agent_id" || -z "$known_skill_id" || -z "$known_task_id" ]]; then
    fail "unable to resolve canonical ATS IDs from registries for negative tests"
    return
  fi

  run_bundle_capture analyst --profile=analyst --agent-id=R-AGENT-99 --skill-id="$known_skill_id" --task-id="$known_task_id"
  if (( RUN_STATUS == 0 )); then
    fail "unknown agent_id should fail"
  fi
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq "unknown agent_id 'R-AGENT-99'"; then
    fail "unknown agent_id failure message mismatch"
  fi

  run_bundle_capture analyst --profile=analyst --agent-id="$known_agent_id" --skill-id=S-LEARN-99 --task-id="$known_task_id"
  if (( RUN_STATUS == 0 )); then
    fail "unknown skill_id should fail"
  fi
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq "unknown skill_id 'S-LEARN-99'"; then
    fail "unknown skill_id failure message mismatch"
  fi

  run_bundle_capture analyst --profile=analyst --agent-id="$known_agent_id" --skill-id="$known_skill_id" --task-id=B-TASK-99
  if (( RUN_STATUS == 0 )); then
    fail "unknown task_id should fail"
  fi
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq "unknown task_id 'B-TASK-99'"; then
    fail "unknown task_id failure message mismatch"
  fi
}

test_ats_valid_triplet() {
  local known_agent_id
  local known_skill_id
  local known_task_id
  local manifest_agent_id
  local manifest_skill_id
  local manifest_task_id
  local policy_manifest_path

  ensure_analyst_topic_fixture

  known_agent_id="$(registry_first_id "docs/ops/registry/agents.md")"
  known_skill_id="$(registry_first_id "docs/ops/registry/skills.md")"
  known_task_id="$(registry_first_id "docs/ops/registry/tasks.md")"
  if [[ -z "$known_agent_id" || -z "$known_skill_id" || -z "$known_task_id" ]]; then
    fail "unable to resolve canonical ATS IDs from registries for positive test"
    return
  fi
  policy_manifest_path="$(policy_scalar assembly_policy_manifest)"
  if [[ -z "$policy_manifest_path" ]]; then
    fail "bundle policy missing assembly_policy_manifest key"
    return
  fi

  run_bundle_capture analyst --profile=analyst --agent-id="$known_agent_id" --skill-id="$known_skill_id" --task-id="$known_task_id"
  if (( RUN_STATUS != 0 )); then
    fail "valid ATS triplet path failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" ]] || return

  manifest_agent_id="$(extract_manifest_value "$LAST_MANIFEST" "agent_id")"
  manifest_skill_id="$(extract_manifest_value "$LAST_MANIFEST" "skill_id")"
  manifest_task_id="$(extract_manifest_value "$LAST_MANIFEST" "task_id")"
  if [[ "$manifest_agent_id" != "$known_agent_id" ]]; then
    fail "ATS manifest agent_id mismatch: expected ${known_agent_id}, got ${manifest_agent_id}"
  fi
  if [[ "$manifest_skill_id" != "$known_skill_id" ]]; then
    fail "ATS manifest skill_id mismatch: expected ${known_skill_id}, got ${manifest_skill_id}"
  fi
  if [[ "$manifest_task_id" != "$known_task_id" ]]; then
    fail "ATS manifest task_id mismatch: expected ${known_task_id}, got ${manifest_task_id}"
  fi

  assert_manifest_has "$LAST_MANIFEST" '"assembly": {'
  assert_manifest_has "$LAST_MANIFEST" '"applied": true'
  assert_manifest_has "$LAST_MANIFEST" '"pointer": {'
  assert_manifest_has "$LAST_MANIFEST" '"emitted": true'
  assert_manifest_has "$LAST_MANIFEST" "\"policy_manifest\": \"${policy_manifest_path}\""
  assert_manifest_has "$LAST_MANIFEST" "\"agents\": \"docs/ops/registry/agents.md\""
  assert_manifest_has "$LAST_MANIFEST" "\"skills\": \"docs/ops/registry/skills.md\""
  assert_manifest_has "$LAST_MANIFEST" "\"tasks\": \"docs/ops/registry/tasks.md\""
  if [[ "$LAST_ASSEMBLY_POINTER_EMITTED" != "true" ]]; then
    fail "ATS valid triplet should emit assembly pointer"
  fi
  if [[ -z "$LAST_ASSEMBLY_POINTER_PATH" ]]; then
    fail "ATS valid triplet emitted pointer path is empty"
  fi
}

test_meta_shim() {
  local fixture_slug="stela"
  local fixture_dir="${REPO_ROOT}/projects/${fixture_slug}"
  local fixture_readme="${fixture_dir}/README.md"
  local fixture_dir_created=0
  local fixture_readme_created=0
  local project_out_rel=""
  local project_manifest=""
  local project_artifact=""
  local project_package=""
  local project_name=""
  local resolved_profile=""
  local route_reason=""
  local dump_payload=""
  local dump_manifest=""

  if [[ ! -d "$fixture_dir" ]]; then
    mkdir -p "$fixture_dir"
    fixture_dir_created=1
  fi
  if [[ ! -f "$fixture_readme" ]]; then
    printf '# %s\n' "$fixture_slug" > "$fixture_readme"
    fixture_readme_created=1
  fi

  run_capture "${REPO_ROOT}/ops/bin/meta"
  if (( RUN_STATUS == 0 )); then
    fail "meta without project argument should fail"
  fi
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq 'project name is required'; then
    fail "meta missing-argument failure message mismatch"
  fi

  run_capture "${REPO_ROOT}/ops/bin/meta" does-not-exist
  if (( RUN_STATUS == 0 )); then
    fail "meta with missing project should fail"
  fi
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq 'project not found: projects/does-not-exist'; then
    fail "meta missing-project failure message mismatch"
  fi

  project_out_rel="$(next_bundle_output_path project)" || return
  run_capture "${REPO_ROOT}/ops/bin/meta" "$fixture_slug" "--out=${project_out_rel}"
  if (( RUN_STATUS != 0 )); then
    fail "meta shim failed for valid project fixture"
    echo "$RUN_OUTPUT" >&2
  else
    if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq "project context generated: ${fixture_slug}"; then
      fail "meta success output missing completion line"
    fi

    project_manifest="${project_out_rel%.txt}.manifest.json"
    if [[ -z "$project_manifest" ]]; then
      fail "meta run did not produce a PROJECT manifest"
    else
      assert_file_exists "$project_manifest"
      queue_cleanup_path "$project_manifest"

      resolved_profile="$(extract_manifest_value "$project_manifest" "resolved_profile")"
      if [[ "$resolved_profile" != "project" ]]; then
        fail "meta shim delegated run resolved_profile mismatch: expected project, got ${resolved_profile}"
      fi

      project_name="$(extract_manifest_value "$project_manifest" "project")"
      if [[ "$project_name" != "$fixture_slug" ]]; then
        fail "meta shim delegated run project field mismatch: expected ${fixture_slug}, got ${project_name}"
      fi

      route_reason="$(extract_manifest_value "$project_manifest" "route_reason")"
      if [[ "$route_reason" != "explicit profile" ]]; then
        fail "meta shim delegated run route_reason mismatch: ${route_reason}"
      fi

      project_artifact="$(extract_manifest_value "$project_manifest" "bundle_path")"
      if [[ -z "$project_artifact" ]]; then
        fail "meta delegated manifest missing bundle_path"
      else
        assert_prefix "$project_artifact" "${SMOKE_HANDOFF_ROOT}/PROJECT-"
        assert_file_exists "$project_artifact"
        queue_cleanup_path "$project_artifact"
        project_package="${project_artifact%.txt}.tar"
        assert_file_exists "$project_package"
        queue_cleanup_path "$project_package"
      fi

      dump_payload="$(extract_manifest_value "$project_manifest" "payload_path")"
      dump_manifest="$(extract_manifest_value "$project_manifest" "manifest_path")"
      if [[ -n "$dump_payload" ]]; then
        assert_file_exists "$dump_payload"
        queue_cleanup_path "$dump_payload"
      else
        fail "meta delegated manifest missing dump payload_path"
      fi
      if [[ -n "$dump_manifest" ]]; then
        assert_file_exists "$dump_manifest"
        queue_cleanup_path "$dump_manifest"
      else
        fail "meta delegated manifest missing dump manifest_path"
      fi

      assert_dump_scope_matches_profile "$project_manifest" "project"
    fi
  fi

  if (( fixture_readme_created )); then
    rm -f -- "$fixture_readme"
  fi
  if (( fixture_dir_created )); then
    rmdir "$fixture_dir" 2>/dev/null || true
  fi
}

run_full_suite() {
  test_bundle_closeout_sanity
  test_audit_contract
  test_audit_resubmission_identity
  test_manifest_fail_closed
  test_stance_template_renderer
  test_valid_profiles
  test_auto_profile_default_route
  test_auto_profile_plan_route
  test_analyst_contract
  test_architect_slice_valid
  test_architect_slice_implicit_bind
  test_architect_slice_ad_hoc
  test_architect_slice_unknown_fails
  test_architect_slice_blank_fails
  test_architect_slice_non_architect_fails
  test_foreman_invalid_paths
  test_foreman_valid_path
  test_legacy_hygiene_alias
  test_ats_partial_flags_fail
  test_ats_unknown_ids_fail
  test_ats_valid_triplet
  test_meta_shim
}

run_certify_critical_suite() {
  test_bundle_closeout_sanity
  test_audit_contract
}

test_spine_block_contract() {
  # Verify [SPINE] block is present in bundle text output and contains expected contract lines.
  ensure_analyst_topic_fixture

  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=analyst "--out=${SMOKE_HANDOFF_ROOT}/ANALYST-spine-smoke-$$-manifest.txt"
  if (( RUN_STATUS != 0 )); then
    fail "spine block contract: analyst run failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_ARTIFACT" ]] || return

  if ! grep -Fq '[SPINE]' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "spine block contract: [SPINE] block missing from analyst bundle text"
  fi
  if ! grep -Fq -- '- Main chain: TOPIC.md -> PLAN.md -> storage/dp/intake/DP.md -> execution -> RESULTS + CLOSING -> audit bundle -> merge' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "spine block contract: main chain line missing or incorrect"
  fi
  if ! grep -Fq -- '- Active draft surface: storage/dp/intake/DP.md (latest-wins); packet identity remains DP-OPS-XXXX.' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "spine block contract: active draft identity line missing or incorrect"
  fi
  if ! grep -Fq -- '- Certify requires STELA_TRACE_ID from OPEN artifact or STELA_TRACE_ID env var.' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "spine block contract: certify STELA_TRACE_ID line missing"
  fi
  if ! grep -Fq -- '- Audit dump: ./ops/bin/bundle --profile=audit --out=auto (separate from operator session refresh)' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "spine block contract: audit dump line missing or incorrect"
  fi
  if ! grep -Fq -- '- Secondary lanes: foreman/addendum (intervention), conform/conformist (normalization), execution-decision (disposable/manual)' "${REPO_ROOT}/${LAST_ARTIFACT}"; then
    fail "spine block contract: secondary lanes line missing or incorrect"
  fi
}

run_route_contract_slice() {
  test_manifest_fail_closed
  test_stance_template_renderer
  test_valid_profiles
  test_auto_profile_default_route
  test_auto_profile_plan_route
  test_analyst_contract
  test_architect_slice_valid
  test_architect_slice_implicit_bind
  test_architect_slice_ad_hoc
  test_architect_slice_unknown_fails
  test_architect_slice_blank_fails
  test_architect_slice_non_architect_fails
  test_foreman_invalid_paths
  test_foreman_valid_path
  test_legacy_hygiene_alias
  test_ats_partial_flags_fail
  test_ats_unknown_ids_fail
  test_ats_valid_triplet
  test_meta_shim
  test_spine_block_contract
}

run_slice() {
  case "$1" in
    closeout-sanity)
      test_bundle_closeout_sanity
      ;;
    audit-coherence)
      test_audit_contract
      ;;
    route-contract)
      run_route_contract_slice
      ;;
    rerun-lineage)
      test_audit_resubmission_identity
      ;;
  esac
}

if [[ -n "$BUNDLE_TEST_SLICE" ]]; then
  run_slice "$BUNDLE_TEST_SLICE"
else
  case "$TEST_MODE" in
    full)
      run_full_suite
      ;;
    certify-critical)
      run_certify_critical_suite
      ;;
  esac
fi

if (( FAILURES > 0 )); then
  echo "FAIL: bundle smoke test detected ${FAILURES} issue(s) (mode: ${TEST_MODE})." >&2
  exit 1
fi

if [[ -n "$BUNDLE_TEST_SLICE" ]]; then
  echo "PASS: bundle smoke test (slice: ${BUNDLE_TEST_SLICE})"
elif [[ "$TEST_MODE" == "full" ]]; then
  echo "PASS: bundle smoke test"
else
  echo "PASS: bundle smoke test (mode: ${TEST_MODE})"
fi
