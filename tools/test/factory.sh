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

cleanup_generated() {
  local rel_path
  for rel_path in "${CLEANUP_PATHS[@]}"; do
    [[ -n "$rel_path" ]] || continue
    if [[ -e "${REPO_ROOT}/${rel_path}" ]]; then
      rm -f -- "${REPO_ROOT}/${rel_path}"
    fi
  done
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
    storage/handoff/*|storage/dumps/*)
      ;;
    *)
      fail "refusing to queue cleanup path outside storage/: ${rel_path}"
      return 1
      ;;
  esac

  if [[ -z "${CLEANUP_SEEN[$rel_path]+x}" ]]; then
    CLEANUP_SEEN["$rel_path"]=1
    CLEANUP_PATHS+=("$rel_path")
  fi
}

ensure_analyst_topic_fixture() {
  local topic_rel="storage/handoff/TOPIC.md"
  local topic_abs="${REPO_ROOT}/${topic_rel}"

  if [[ -f "$topic_abs" ]]; then
    return 0
  fi

  mkdir -p "$(dirname "$topic_abs")"
  cat > "$topic_abs" <<'EOF'
Factory ATS smoke topic fixture.
EOF
  queue_cleanup_path "$topic_rel"
}

parse_bundle_output_path() {
  local label="$1"
  printf '%s\n' "$RUN_OUTPUT" | sed -n "s/^${label}:[[:space:]]*//p" | tail -n 1
}

assert_file_exists() {
  local rel_path="$1"
  [[ -f "${REPO_ROOT}/${rel_path}" ]] || fail "expected file missing: ${rel_path}"
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

ensure_analyst_topic_fixture

run_capture ./ops/bin/bundle --profile=auto --agent-id=R-AGENT-09 --skill-id=S-LEARN-09 --task-id=B-TASK-09 --out=auto
if (( RUN_STATUS != 0 )); then
  fail "factory ATS smoke bundle invocation failed: ${RUN_OUTPUT}"
  echo "FAILED: ${FAILURES} issue(s) detected." >&2
  exit 1
fi

artifact_rel="$(normalize_rel_path "$(parse_bundle_output_path "Bundle artifact")")"
manifest_rel="$(normalize_rel_path "$(parse_bundle_output_path "Bundle manifest")")"
package_rel="$(normalize_rel_path "$(parse_bundle_output_path "Bundle package")")"

if [[ -z "$artifact_rel" || -z "$manifest_rel" || -z "$package_rel" ]]; then
  fail "bundle output missing artifact/manifest/package paths"
else
  queue_cleanup_path "$artifact_rel"
  queue_cleanup_path "$manifest_rel"
  queue_cleanup_path "$package_rel"
fi

assert_file_exists "$artifact_rel"
assert_file_exists "$manifest_rel"
assert_file_exists "$package_rel"

payload_rel="$(extract_manifest_scalar "$manifest_rel" "payload_path")"
dump_manifest_rel="$(extract_manifest_scalar "$manifest_rel" "manifest_path")"
if [[ -n "$payload_rel" ]]; then
  queue_cleanup_path "$payload_rel"
  assert_file_exists "$payload_rel"
fi
if [[ -n "$dump_manifest_rel" ]]; then
  queue_cleanup_path "$dump_manifest_rel"
  assert_file_exists "$dump_manifest_rel"
fi

pointer_rel="$(extract_pointer_path "$manifest_rel")"
if [[ -n "$pointer_rel" ]]; then
  queue_cleanup_path "$pointer_rel"
  assert_file_exists "$pointer_rel"
fi

assert_manifest_has "$manifest_rel" '"applied": true'
assert_manifest_has "$manifest_rel" '"agent_id": "R-AGENT-09"'
assert_manifest_has "$manifest_rel" '"skill_id": "S-LEARN-09"'
assert_manifest_has "$manifest_rel" '"task_id": "B-TASK-09"'
assert_manifest_has "$manifest_rel" '"emitted": true'
assert_manifest_has "$manifest_rel" '"path": "storage/handoff/'

if ! grep -Fq '[ASSEMBLY]' "${REPO_ROOT}/${artifact_rel}"; then
  fail "bundle artifact missing [ASSEMBLY] block"
fi
if ! grep -Fq 'agent_id: R-AGENT-09' "${REPO_ROOT}/${artifact_rel}"; then
  fail "bundle artifact missing agent_id: R-AGENT-09"
fi
if ! grep -Fq 'skill_id: S-LEARN-09' "${REPO_ROOT}/${artifact_rel}"; then
  fail "bundle artifact missing skill_id: S-LEARN-09"
fi
if ! grep -Fq 'task_id: B-TASK-09' "${REPO_ROOT}/${artifact_rel}"; then
  fail "bundle artifact missing task_id: B-TASK-09"
fi

if (( FAILURES > 0 )); then
  echo "FAILED: ${FAILURES} issue(s) detected." >&2
  exit 1
fi

echo "PASS: factory smoke test"
