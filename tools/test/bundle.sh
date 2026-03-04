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
LAST_ARTIFACT=""
LAST_MANIFEST=""
LAST_PACKAGE=""
BUNDLE_POLICY_REL="ops/lib/manifests/BUNDLE.md"

cleanup_generated() {
  local rel_path
  for rel_path in "${CLEANUP_PATHS[@]}"; do
    [[ -n "$rel_path" ]] || continue
    if [[ -e "${REPO_ROOT}/${rel_path}" ]]; then
      rm -f -- "${REPO_ROOT}/${rel_path}"
    fi
  done
}

trap 'cleanup_generated; emit_binary_leaf "test-bundle" "finish"' EXIT
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

track_bundle_outputs() {
  local artifact_path
  local manifest_path
  local package_path
  local dump_payload_path
  local dump_manifest_path

  LAST_ARTIFACT=""
  LAST_MANIFEST=""
  LAST_PACKAGE=""

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

  assert_prefix "$artifact_path" "storage/handoff/BUNDLE-"
  assert_prefix "$manifest_path" "storage/handoff/BUNDLE-"
  assert_prefix "$package_path" "storage/handoff/BUNDLE-"

  assert_file_exists "$artifact_path"
  assert_file_exists "$manifest_path"
  assert_file_exists "$package_path"

  queue_cleanup_path "$artifact_path"
  queue_cleanup_path "$manifest_path"
  queue_cleanup_path "$package_path"

  dump_payload_path="$(extract_manifest_value "$manifest_path" "payload_path")"
  dump_manifest_path="$(extract_manifest_value "$manifest_path" "manifest_path")"

  if [[ -n "$dump_payload_path" ]]; then
    assert_file_exists "$dump_payload_path"
    queue_cleanup_path "$dump_payload_path"
  else
    fail "manifest ${manifest_path} missing dump payload_path"
  fi

  if [[ -n "$dump_manifest_path" ]]; then
    assert_file_exists "$dump_manifest_path"
    queue_cleanup_path "$dump_manifest_path"
  else
    fail "manifest ${manifest_path} missing dump manifest_path"
  fi
}

test_valid_profiles() {
  local profile
  local resolved
  for profile in analyst architect audit hygiene auto; do
    run_capture "${REPO_ROOT}/ops/bin/bundle" --profile="$profile" --out=auto
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
  done
}

test_auditor_invalid_paths() {
  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=auditor --out=auto
  if (( RUN_STATUS == 0 )); then
    fail "auditor path without --intent should fail"
  fi

  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=auditor --intent="bad format" --out=auto
  if (( RUN_STATUS == 0 )); then
    fail "auditor path with malformed --intent should fail"
  fi
}

test_auditor_valid_path() {
  local decision_leaf
  local decision_id
  local intent
  local resolved
  local manifest_decision_id

  decision_leaf="$(find "${REPO_ROOT}/archives/decisions" -maxdepth 1 -type f -name 'RoR-*.md' | sort | head -n 1)"
  if [[ -z "$decision_leaf" ]]; then
    fail "no decision leaves found under archives/decisions/"
    return
  fi
  decision_id="$(basename "$decision_leaf" .md)"
  intent="ADDENDUM REQUIRED: ${decision_id} - bundle smoke gate test"

  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=auditor --intent="$intent" --out=auto
  if (( RUN_STATUS != 0 )); then
    fail "auditor path with valid --intent failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" ]] || return

  resolved="$(extract_manifest_value "$LAST_MANIFEST" "resolved_profile")"
  if [[ "$resolved" != "auditor" ]]; then
    fail "auditor manifest resolved_profile mismatch: ${resolved}"
  fi

  manifest_decision_id="$(extract_manifest_value "$LAST_MANIFEST" "decision_id")"
  if [[ "$manifest_decision_id" != "$decision_id" ]]; then
    fail "auditor manifest decision_id mismatch: expected ${decision_id}, got ${manifest_decision_id}"
  fi

  assert_manifest_has "$LAST_MANIFEST" '"decision_leaf_present": true'
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

  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=analyst --out=auto
  if (( RUN_STATUS == 0 )); then
    fail "bundle should fail when required manifest key is missing"
  fi
  if ! printf '%s\n' "$RUN_OUTPUT" | grep -Fq 'bundle policy missing required key'; then
    fail "bundle fail-closed output did not include expected manifest-key error"
  fi

  cp "$backup_path" "$policy_abs"
  rm -f "$backup_path"
}

test_manifest_fail_closed
test_valid_profiles
test_auditor_invalid_paths
test_auditor_valid_path

if (( FAILURES > 0 )); then
  echo "FAIL: bundle smoke test detected ${FAILURES} issue(s)." >&2
  exit 1
fi

echo "PASS: bundle smoke test"
