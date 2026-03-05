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

  if ! grep -Fq 'Stance template key: stance-' "${REPO_ROOT}/${artifact_path}"; then
    fail "bundle artifact missing stance template key marker: ${artifact_path}"
  fi

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
  for profile in analyst architect audit conform auto; do
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

    template_key="$(extract_manifest_value "$LAST_MANIFEST" "stance_template_key")"
    expected_template_key="$(expected_stance_template_for_profile "$resolved")"
    if [[ -z "$template_key" ]]; then
      fail "profile=${profile} manifest missing prompt.stance_template_key"
    elif [[ "$template_key" != "$expected_template_key" ]]; then
      fail "profile=${profile} manifest stance_template_key mismatch: expected ${expected_template_key}, got ${template_key}"
    fi

    assert_dump_scope_matches_profile "$LAST_MANIFEST" "$resolved"
  done
}

test_foreman_invalid_paths() {
  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=foreman --out=auto
  if (( RUN_STATUS == 0 )); then
    fail "foreman path without --intent should fail"
  fi

  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=foreman --intent="bad format" --out=auto
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

  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=foreman --intent="$intent" --out=auto
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

test_legacy_auditor_alias() {
  local decision_leaf
  local decision_id
  local intent
  local resolved
  local requested
  local route_reason
  local expected_status
  local expected_remove_after
  local actual_status
  local actual_remove_after

  decision_leaf="$(find "${REPO_ROOT}/archives/decisions" -maxdepth 1 -type f -name 'RoR-*.md' | sort | head -n 1)"
  if [[ -z "$decision_leaf" ]]; then
    fail "no decision leaves found under archives/decisions/"
    return
  fi
  decision_id="$(basename "$decision_leaf" .md)"
  intent="ADDENDUM REQUIRED: ${decision_id} - bundle smoke gate alias test"

  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=auditor --intent="$intent" --out=auto
  if (( RUN_STATUS != 0 )); then
    fail "legacy auditor alias path with valid --intent failed"
    echo "$RUN_OUTPUT" >&2
    return
  fi

  track_bundle_outputs
  [[ -n "$LAST_MANIFEST" ]] || return

  resolved="$(extract_manifest_value "$LAST_MANIFEST" "resolved_profile")"
  requested="$(extract_manifest_value "$LAST_MANIFEST" "requested_profile")"
  route_reason="$(extract_manifest_value "$LAST_MANIFEST" "route_reason")"

  if [[ "$resolved" != "foreman" ]]; then
    fail "legacy auditor alias resolved_profile mismatch: expected foreman, got ${resolved}"
  fi
  if [[ "$requested" != "auditor" ]]; then
    fail "legacy auditor alias requested_profile mismatch: expected auditor, got ${requested}"
  fi
  if [[ "$route_reason" != "explicit profile alias: auditor -> foreman" ]]; then
    fail "legacy auditor alias route_reason mismatch: ${route_reason}"
  fi
  assert_dump_scope_matches_profile "$LAST_MANIFEST" "$resolved"
  assert_manifest_has "$LAST_MANIFEST" '"profile_alias": {'
  assert_manifest_has "$LAST_MANIFEST" '"from": "auditor"'
  assert_manifest_has "$LAST_MANIFEST" '"to": "foreman"'

  expected_status="$(policy_scalar profile_alias_legacy_auditor_deprecation_status)"
  expected_remove_after="$(policy_scalar profile_alias_legacy_auditor_remove_after_dp)"
  actual_status="$(extract_manifest_value "$LAST_MANIFEST" "deprecation_status")"
  actual_remove_after="$(extract_manifest_value "$LAST_MANIFEST" "remove_after_dp")"
  if [[ "$actual_status" != "$expected_status" ]]; then
    fail "legacy auditor alias deprecation_status mismatch: expected ${expected_status}, got ${actual_status}"
  fi
  if [[ "$actual_remove_after" != "$expected_remove_after" ]]; then
    fail "legacy auditor alias remove_after_dp mismatch: expected ${expected_remove_after}, got ${actual_remove_after}"
  fi
}

test_legacy_hygiene_alias() {
  local resolved
  local requested
  local route_reason
  local expected_status
  local expected_remove_after
  local actual_status
  local actual_remove_after

  run_capture "${REPO_ROOT}/ops/bin/bundle" --profile=hygiene --out=auto
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
test_stance_template_renderer
test_valid_profiles
test_foreman_invalid_paths
test_foreman_valid_path
test_legacy_auditor_alias
test_legacy_hygiene_alias

if (( FAILURES > 0 )); then
  echo "FAIL: bundle smoke test detected ${FAILURES} issue(s)." >&2
  exit 1
fi

echo "PASS: bundle smoke test"
