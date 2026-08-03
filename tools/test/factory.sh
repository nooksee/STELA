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

declare -a CLEANUP_PATHS=()
declare -A CLEANUP_SEEN=()
FAILURES=0
RUN_OUTPUT=""
RUN_STATUS=0
BUNDLE_POLICY_REL="ops/lib/manifests/BUNDLE.md"
SMOKE_HANDOFF_ROOT="$(awk -F'=' '$1=="smoke_handoff_root" { print substr($0, index($0, "=") + 1); exit }' "${REPO_ROOT}/${BUNDLE_POLICY_REL}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
SMOKE_DUMP_ROOT="$(awk -F'=' '$1=="smoke_dump_root" { print substr($0, index($0, "=") + 1); exit }' "${REPO_ROOT}/${BUNDLE_POLICY_REL}" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
FIXTURE_REL="var/tmp/_smoke/factory-fixture-$$"
FIXTURE_ABS="${REPO_ROOT}/${FIXTURE_REL}"
FIXTURE_HANDOFF_ABS="${FIXTURE_ABS}/handoff"
FIXTURE_POLICY_REL="${FIXTURE_REL}/ASSEMBLY.md"
FIXTURE_POLICY_ABS="${REPO_ROOT}/${FIXTURE_POLICY_REL}"
FIXTURE_AGENT_ID="R-AGENT-90"
FIXTURE_SKILL_ID="S-LEARN-90"
FIXTURE_TASK_ID="B-TASK-90"
LIVE_REGISTRIES=(
  "docs/ops/registry/agents.md"
  "docs/ops/registry/skills.md"
  "docs/ops/registry/tasks.md"
)
GIT_STATUS_BEFORE="$(git status --porcelain)"
LIVE_REGISTRY_HASHES_BEFORE="$(sha256sum "${LIVE_REGISTRIES[@]}")"

cleanup_generated() {
  local rel_path
  for rel_path in "${CLEANUP_PATHS[@]}"; do
    [[ -n "$rel_path" ]] || continue
    if [[ -e "${REPO_ROOT}/${rel_path}" ]]; then
      rm -f -- "${REPO_ROOT}/${rel_path}"
    fi
  done
  rm -rf -- "$FIXTURE_ABS"
}

trap 'cleanup_generated; emit_binary_leaf "test-factory" "finish"' EXIT
emit_binary_leaf "test-factory" "start"

fail() {
  echo "FAIL: $*" >&2
  FAILURES=$((FAILURES + 1))
}

run_capture() {
  RUN_OUTPUT=""
  RUN_STATUS=0
  set +e
  RUN_OUTPUT="$("$@" 2>&1)"
  RUN_STATUS=$?
  set -e
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

next_bundle_output_path() {
  printf '%s/PLANNING-factory-smoke-%s.txt' "$SMOKE_HANDOFF_ROOT" "$$"
}

parse_bundle_output_path() {
  local label="$1"
  printf '%s\n' "$RUN_OUTPUT" | sed -n "s/^${label}:[[:space:]]*//p" | tail -n 1
}

assert_file_exists() {
  local rel_path="$1"
  [[ -n "$rel_path" && -f "${REPO_ROOT}/${rel_path}" ]] || fail "expected file missing: ${rel_path:-<empty>}"
}

assert_manifest_has() {
  local manifest_rel="$1"
  local expected="$2"
  if ! grep -Fq -- "$expected" "${REPO_ROOT}/${manifest_rel}"; then
    fail "manifest ${manifest_rel} missing expected content: ${expected}"
  fi
}

extract_manifest_scalar() {
  local manifest_rel="$1"
  local key="$2"
  sed -n -E "s/^[[:space:]]*\"${key}\":[[:space:]]*\"([^\"]*)\"[,]?[[:space:]]*$/\1/p" "${REPO_ROOT}/${manifest_rel}" | head -n 1
}

extract_pointer_path() {
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

create_fixture_registry() {
  local path="$1"
  local id="$2"
  local name="$3"
  mkdir -p "$(dirname "$path")"
  {
    printf '# Disposable Factory Test Registry\n\n'
    printf '| ID | Name | Fixture |\n'
    printf '| --- | --- | --- |\n'
    printf '| %s | %s | true |\n' "$id" "$name"
  } > "$path"
}

mkdir -p "$FIXTURE_HANDOFF_ABS"
printf 'Factory ATS isolated smoke topic fixture.\n' > "${FIXTURE_HANDOFF_ABS}/TOPIC.md"
create_fixture_registry "${FIXTURE_ABS}/agents.md" "$FIXTURE_AGENT_ID" "disposable-agent"
create_fixture_registry "${FIXTURE_ABS}/skills.md" "$FIXTURE_SKILL_ID" "disposable-skill"
create_fixture_registry "${FIXTURE_ABS}/tasks.md" "$FIXTURE_TASK_ID" "disposable-task"

sed \
  -e "s#^registry_agents_path=.*#registry_agents_path=${FIXTURE_REL}/agents.md#" \
  -e "s#^registry_skills_path=.*#registry_skills_path=${FIXTURE_REL}/skills.md#" \
  -e "s#^registry_tasks_path=.*#registry_tasks_path=${FIXTURE_REL}/tasks.md#" \
  "${REPO_ROOT}/ops/lib/manifests/ASSEMBLY.md" > "$FIXTURE_POLICY_ABS"

for fixture_id in "$FIXTURE_AGENT_ID" "$FIXTURE_SKILL_ID" "$FIXTURE_TASK_ID"; do
  if grep -Fq -- "$fixture_id" "${LIVE_REGISTRIES[@]}"; then
    fail "disposable fixture ID appears in live registry: ${fixture_id}"
  fi
done

run_capture env -u BUNDLE_TEST_HANDOFF_ROOT \
  "BUNDLE_TEST_ASSEMBLY_POLICY_PATH=${FIXTURE_POLICY_ABS}" \
  ./ops/bin/bundle --profile=planning "--out=$(next_bundle_output_path)"
if (( RUN_STATUS == 0 )) || [[ "$RUN_OUTPUT" != *"BUNDLE_TEST_ASSEMBLY_POLICY_PATH requires BUNDLE_TEST_HANDOFF_ROOT"* ]]; then
  fail "test assembly policy override was not rejected without handoff isolation"
fi

run_capture env \
  "BUNDLE_TEST_HANDOFF_ROOT=${FIXTURE_HANDOFF_ABS}" \
  "BUNDLE_TEST_ASSEMBLY_POLICY_PATH=${REPO_ROOT}/ops/lib/manifests/ASSEMBLY.md" \
  ./ops/bin/bundle --profile=planning "--out=$(next_bundle_output_path)"
if (( RUN_STATUS == 0 )) || [[ "$RUN_OUTPUT" != *"test assembly policy must resolve under var/tmp/"* ]]; then
  fail "test assembly policy override was not rejected outside var/tmp"
fi

run_capture env \
  "BUNDLE_TEST_HANDOFF_ROOT=${FIXTURE_HANDOFF_ABS}" \
  "BUNDLE_TEST_ASSEMBLY_POLICY_PATH=${FIXTURE_POLICY_ABS}" \
  ./ops/bin/bundle \
  --profile=auto \
  "--agent-id=${FIXTURE_AGENT_ID}" \
  "--skill-id=${FIXTURE_SKILL_ID}" \
  "--task-id=${FIXTURE_TASK_ID}" \
  "--out=$(next_bundle_output_path)"

if (( RUN_STATUS != 0 )); then
  fail "factory ATS smoke bundle invocation failed: ${RUN_OUTPUT}"
  echo "FAILED: ${FAILURES} issue(s) detected." >&2
  exit 1
fi

artifact_rel="$(normalize_rel_path "$(parse_bundle_output_path "Bundle artifact")")"
manifest_rel="$(normalize_rel_path "$(parse_bundle_output_path "Bundle manifest")")"
package_rel="$(normalize_rel_path "$(parse_bundle_output_path "Bundle package")")"

if [[ -z "$artifact_rel" || -z "$manifest_rel" || -z "$package_rel" ]]; then
  fail "bundle output missing artifact, manifest, or package path"
else
  for rel_path in "$artifact_rel" "$manifest_rel" "$package_rel"; do
    case "$rel_path" in
      "${SMOKE_HANDOFF_ROOT}/"*)
        ;;
      *)
        fail "factory smoke output should be under ${SMOKE_HANDOFF_ROOT}/: ${rel_path}"
        ;;
    esac
    queue_cleanup_path "$rel_path"
    assert_file_exists "$rel_path"
  done
fi

resolved_profile="$(extract_manifest_scalar "$manifest_rel" "resolved_profile")"
if [[ "$resolved_profile" != "planning" ]]; then
  fail "factory ATS smoke expected auto route to planning, got: ${resolved_profile}"
fi

payload_rel="$(extract_manifest_scalar "$manifest_rel" "payload_path")"
dump_manifest_rel="$(extract_manifest_scalar "$manifest_rel" "manifest_path")"
for rel_path in "$payload_rel" "$dump_manifest_rel"; do
  [[ -n "$rel_path" ]] || continue
  case "$rel_path" in
    "${SMOKE_DUMP_ROOT}/"*)
      ;;
    *)
      fail "factory smoke dump output should be under ${SMOKE_DUMP_ROOT}/: ${rel_path}"
      ;;
  esac
  queue_cleanup_path "$rel_path"
  assert_file_exists "$rel_path"
done

pointer_rel="$(extract_pointer_path "$manifest_rel")"
if [[ -n "$pointer_rel" ]]; then
  queue_cleanup_path "$pointer_rel"
  assert_file_exists "$pointer_rel"
fi

assert_manifest_has "$manifest_rel" '"applied": true'
assert_manifest_has "$manifest_rel" "\"policy_manifest\": \"${FIXTURE_POLICY_REL}\""
assert_manifest_has "$manifest_rel" "\"agent_id\": \"${FIXTURE_AGENT_ID}\""
assert_manifest_has "$manifest_rel" "\"skill_id\": \"${FIXTURE_SKILL_ID}\""
assert_manifest_has "$manifest_rel" "\"task_id\": \"${FIXTURE_TASK_ID}\""
assert_manifest_has "$manifest_rel" '"emitted": true'

if ! grep -Fq '[ASSEMBLY]' "${REPO_ROOT}/${artifact_rel}"; then
  fail "bundle artifact missing [ASSEMBLY] block"
fi
for expected in \
  "agent_id: ${FIXTURE_AGENT_ID}" \
  "skill_id: ${FIXTURE_SKILL_ID}" \
  "task_id: ${FIXTURE_TASK_ID}"; do
  if ! grep -Fq -- "$expected" "${REPO_ROOT}/${artifact_rel}"; then
    fail "bundle artifact missing ${expected}"
  fi
done

if [[ "$(sha256sum "${LIVE_REGISTRIES[@]}")" != "$LIVE_REGISTRY_HASHES_BEFORE" ]]; then
  fail "factory smoke test changed a live Factory registry"
fi

cleanup_generated
if [[ "$(git status --porcelain)" != "$GIT_STATUS_BEFORE" ]]; then
  fail "factory smoke test changed tracked or untracked repository state"
fi

if (( FAILURES > 0 )); then
  echo "FAILED: ${FAILURES} issue(s) detected." >&2
  exit 1
fi

echo "PASS: factory smoke test; isolated ATS fixture 1/1; isolation guards 2/2; live registry parity 3/3"
