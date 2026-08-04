#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

usage() {
  cat <<'USAGE'
Usage: tools/lint/schema.sh [--test]
USAGE
}

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

extract_frontmatter() {
  local path="$1"
  local line_no=0
  local line=""
  local found_end=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))
    if (( line_no == 1 )); then
      if [[ "$line" != "---" ]]; then
        return 2
      fi
      continue
    fi

    if [[ "$line" == "---" ]]; then
      found_end=1
      break
    fi

    printf '%s\n' "$line"
  done < "$path"

  if (( found_end == 0 )); then
    return 3
  fi
}

frontmatter_value() {
  local key="$1"
  local content="$2"
  printf '%s\n' "$content" | awk -v key="$key" '
    $0 ~ ("^" key ":[[:space:]]*") {
      value=$0
      sub("^[^:]+:[[:space:]]*", "", value)
      print value
      exit
    }
  '
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

schema_test_mode=0
if [[ "$#" -gt 1 ]]; then
  usage >&2
  exit 1
fi
case "${1:-}" in
  "")
    ;;
  --test)
    schema_test_mode=1
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  die "Must be run inside a git repository."
fi

cd "$REPO_ROOT" || exit 1
trap 'emit_binary_leaf "lint-schema" "finish"' EXIT
emit_binary_leaf "lint-schema" "start"

DEFINITIONS_DIR="${REPO_ROOT}/archives/definitions"
[[ -d "$DEFINITIONS_DIR" ]] || die "missing definitions directory: archives/definitions"
SURFACES_DIR="${REPO_ROOT}/archives/surfaces"
[[ -d "$SURFACES_DIR" ]] || die "missing surfaces directory: archives/surfaces"
MANIFESTS_DIR="${REPO_ROOT}/archives/manifests"
[[ -d "$MANIFESTS_DIR" ]] || die "missing manifests directory: archives/manifests"

lint_schema_leaf() {
  local path="$1"
  local rel_path="$2"
  frontmatter=""
  if ! frontmatter="$(extract_frontmatter "$path")"; then
    status=$?
    if [[ "$status" -eq 2 ]]; then
      fail "${rel_path}: first line must be YAML front-matter delimiter '---'"
    fi
    if [[ "$status" -eq 3 ]]; then
      fail "${rel_path}: YAML front-matter block is not closed with '---'"
    fi
    fail "${rel_path}: failed to parse YAML front-matter block"
  fi

  trace_id="$(trim "$(frontmatter_value "trace_id" "$frontmatter")")"
  packet_id="$(trim "$(frontmatter_value "packet_id" "$frontmatter")")"
  created_at="$(trim "$(frontmatter_value "created_at" "$frontmatter")")"
  previous="$(trim "$(frontmatter_value "previous" "$frontmatter")")"

  [[ -n "$trace_id" ]] || fail "${rel_path}: missing or empty front-matter key 'trace_id'"
  [[ -n "$packet_id" ]] || fail "${rel_path}: missing or empty front-matter key 'packet_id'"
  [[ -n "$created_at" ]] || fail "${rel_path}: missing or empty front-matter key 'created_at'"
  [[ -n "$previous" ]] || fail "${rel_path}: missing or empty front-matter key 'previous'"

  if [[ ! "$created_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
    fail "${rel_path}: created_at must use ISO-8601 UTC format with Z suffix (YYYY-MM-DDTHH:MM:SSZ)"
  fi

  if [[ "$previous" != "(none)" ]]; then
    if [[ "$previous" == /* || "$previous" == ./* || "$previous" == ../* ]]; then
      fail "${rel_path}: previous must be repository-relative or '(none)'"
    fi
    if [[ "$previous" == *".."* ]]; then
      fail "${rel_path}: previous must not contain '..' path segments"
    fi
    if [[ ! "$previous" =~ ^[A-Za-z0-9._/-]+\.md$ ]]; then
      fail "${rel_path}: previous must end with .md and contain only repository-relative path characters"
    fi
  fi
}

is_surface_schema_candidate() {
  local rel_path="$1"
  local filename="${rel_path#archives/surfaces/}"
  if [[ "$filename" =~ ^PoW-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$ ]]; then
    return 0
  fi
  if [[ "$filename" =~ ^SoP-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$ ]]; then
    return 0
  fi
  if [[ "$filename" =~ ^TASK-DP-[A-Z]+-[0-9]{4,}-[0-9a-f]{7,}\.md$ ]]; then
    return 0
  fi
  return 1
}

is_manifest_schema_candidate() {
  local rel_path="$1"
  local filename="${rel_path#archives/manifests/}"
  if [[ "$filename" =~ ^compile-[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}-[0-9a-f]{7,}\.md$ ]]; then
    return 0
  fi
  return 1
}

resolve_current_surface_source() {
  local root_path="$1"
  local line_count=""
  local pointer=""

  [[ -f "$root_path" ]] || fail "missing current surface: ${root_path#${REPO_ROOT}/}"
  line_count="$(awk 'END { print NR }' "$root_path")"
  if [[ "$line_count" != "1" ]]; then
    printf '%s' "$root_path"
    return 0
  fi

  pointer="$(trim "$(cat "$root_path")")"
  pointer="${pointer#./}"
  [[ "$pointer" =~ ^archives/surfaces/[A-Za-z0-9._/-]+\.md$ ]] \
    || fail "current surface pointer is invalid: ${root_path#${REPO_ROOT}/} -> ${pointer}"
  [[ -f "${REPO_ROOT}/${pointer}" ]] \
    || fail "current surface pointer target is missing: ${root_path#${REPO_ROOT}/} -> ${pointer}"
  printf '%s' "${REPO_ROOT}/${pointer}"
}

lint_current_sop_contract() {
  local root_path="$1"
  local source_path="$2"
  local -a labels=(
    "Current objective"
    "Accepted baseline"
    "Provisional work"
    "Unresolved tensions"
    "Rejected directions"
    "Exact next action"
  )
  local label=""
  local count=0
  local value=""
  local shipment_count=0
  local line_count=""
  local frontmatter=""
  local state_model=""

  line_count="$(awk 'END { print NR }' "$root_path")"
  if [[ "$line_count" == "1" ]]; then
    frontmatter="$(extract_frontmatter "$source_path")" \
      || fail "current SoP pointer target lacks valid frontmatter: ${source_path#${REPO_ROOT}/}"
    state_model="$(trim "$(frontmatter_value "state_model" "$frontmatter")")"
    [[ "$state_model" == "present-v1" ]] \
      || fail "current SoP pointer target must declare state_model: present-v1 in ${source_path#${REPO_ROOT}/}"
  fi

  for label in "${labels[@]}"; do
    count="$(grep -cE "^-[[:space:]]+${label}:[[:space:]]*[^[:space:]].*$" "$source_path" || true)"
    [[ "$count" == "1" ]] \
      || fail "current SoP field must appear exactly once: field=${label} count=${count} source=${source_path#${REPO_ROOT}/}"
    value="$(sed -nE "s/^-[[:space:]]+${label}:[[:space:]]*//p" "$source_path")"
    if grep -Eiq '(^|[^[:alnum:]])(TBD|TODO|PLACEHOLDER|REPLACE_ME)([^[:alnum:]]|$)' <<< "$value"; then
      fail "current SoP field contains placeholder text: field=${label} source=${source_path#${REPO_ROOT}/}"
    fi
  done

  shipment_count="$(grep -cE '^##[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}.*DP-[A-Z]+-[0-9]{4,}' "$source_path" || true)"
  [[ "$shipment_count" == "1" ]] \
    || fail "current SoP must contain exactly one latest-shipment entry: count=${shipment_count} source=${source_path#${REPO_ROOT}/}"
}

extract_pow_receipt_value() {
  local source_path="$1"
  local field="$2"
  awk -v field="$field" '
    /^-[[:space:]]+Receipt pointers:[[:space:]]*$/ { in_receipts=1; next }
    in_receipts && /^-[[:space:]]+Notes:[[:space:]]*$/ { exit }
    in_receipts && $0 ~ "^[[:space:]]+-[[:space:]]+" field ":[[:space:]]*" {
      line=$0
      sub("^[[:space:]]+-[[:space:]]+" field ":[[:space:]]*", "", line)
      print line
    }
  ' "$source_path"
}

normalize_pow_receipt_value() {
  local value="$1"
  value="$(trim "$value")"
  value="${value#\`}"
  value="${value%\`}"
  printf '%s' "$value"
}

pow_transition_is_in_progress() {
  local source_path="$1"
  local source_rel="${source_path#${REPO_ROOT}/}"
  if ! git diff --quiet HEAD -- PoW.md "$source_rel"; then
    return 0
  fi
  if git ls-files --others --exclude-standard -- "$source_rel" | grep -Fqx "$source_rel"; then
    return 0
  fi
  return 1
}

lint_current_pow_contract() {
  local root_path="$1"
  local source_path="$2"
  local line_count=""
  local frontmatter=""
  local proof_model=""
  local proof_state=""
  local results_value=""
  local packet_value=""

  line_count="$(awk 'END { print NR }' "$root_path")"
  [[ "$line_count" == "1" ]] \
    || fail "current PoW must be a single pointer head: ${root_path#${REPO_ROOT}/}"
  frontmatter="$(extract_frontmatter "$source_path")" \
    || fail "current PoW pointer target lacks valid frontmatter: ${source_path#${REPO_ROOT}/}"
  proof_model="$(trim "$(frontmatter_value "proof_model" "$frontmatter")")"
  proof_state="$(trim "$(frontmatter_value "proof_state" "$frontmatter")")"
  [[ "$proof_model" == "durable-v1" ]] \
    || fail "current PoW pointer target must declare proof_model: durable-v1 in ${source_path#${REPO_ROOT}/}"
  [[ "$proof_state" == "complete" || "$proof_state" == "legacy-gap" ]] \
    || fail "current PoW pointer target must declare proof_state: complete or legacy-gap in ${source_path#${REPO_ROOT}/}"

  results_value="$(normalize_pow_receipt_value "$(extract_pow_receipt_value "$source_path" "RESULTS")")"
  packet_value="$(normalize_pow_receipt_value "$(extract_pow_receipt_value "$source_path" "PACKET")")"
  [[ -n "$results_value" ]] || fail "current PoW is missing one RESULTS receipt pointer"
  [[ -n "$packet_value" ]] || fail "current PoW is missing one PACKET receipt pointer"
  [[ "$(extract_pow_receipt_value "$source_path" "RESULTS" | wc -l)" == "1" ]] \
    || fail "current PoW must contain exactly one RESULTS receipt pointer"
  [[ "$(extract_pow_receipt_value "$source_path" "PACKET" | wc -l)" == "1" ]] \
    || fail "current PoW must contain exactly one PACKET receipt pointer"

  [[ "$packet_value" =~ ^archives/surfaces/(TASK|ADDENDUM)-DP-[A-Z]+-[0-9]{4,}(-ADDENDUM-[A-Z])?-[0-9a-f]{7,}[.]md$ ]] \
    || fail "current PoW PACKET pointer is not a durable TASK or ADDENDUM leaf: ${packet_value}"
  if [[ ! -f "${REPO_ROOT}/${packet_value}" ]] && ! pow_transition_is_in_progress "$source_path"; then
    fail "current PoW PACKET pointer target is missing: ${packet_value}"
  fi

  if [[ "$proof_state" == "legacy-gap" ]]; then
    [[ "$results_value" == "unavailable (legacy body not retained)" ]] \
      || fail "legacy-gap PoW must report the exact unavailable RESULTS state"
    return 0
  fi

  [[ "$results_value" =~ ^archives/surfaces/RESULTS-DP-[A-Z]+-[0-9]{4,}(-ADDENDUM-[A-Z])?-[0-9a-f]{7,}[.]md$ ]] \
    || fail "current PoW RESULTS pointer is not a durable archived receipt: ${results_value}"
  if [[ ! -f "${REPO_ROOT}/${results_value}" ]] && ! pow_transition_is_in_progress "$source_path"; then
    fail "current PoW RESULTS pointer target is missing: ${results_value}"
  fi
}

lint_current_task_pointer_contract() {
  local root_path="$1"
  local source_path="$2"
  local line_count=""
  local frontmatter=""
  local routing_state=""
  local packet_state=""

  line_count="$(awk 'END { print NR }' "$root_path")"
  if [[ "$line_count" != "1" ]]; then
    return 0
  fi

  frontmatter="$(extract_frontmatter "$source_path")" \
    || fail "current TASK pointer target lacks valid frontmatter: ${source_path#${REPO_ROOT}/}"
  routing_state="$(trim "$(frontmatter_value "routing_state" "$frontmatter")")"
  packet_state="$(trim "$(frontmatter_value "packet_state" "$frontmatter")")"
  [[ "$routing_state" == "idle" ]] \
    || fail "pointer-head TASK must declare routing_state: idle in ${source_path#${REPO_ROOT}/}"
  [[ "$packet_state" == "completed" ]] \
    || fail "pointer-head TASK must declare packet_state: completed in ${source_path#${REPO_ROOT}/}"
}

lint_current_ror_leaf_contract() {
  local source_path="$1"
  local source_rel="$2"
  local frontmatter=""
  local trace_id=""
  local decision_id=""
  local packet_id=""
  local decision_type=""
  local created_at=""
  local authorized_by=""
  local filename="${source_rel##*/}"
  local expected_decision_id=""
  local label=""
  local count=0
  local line_no=0
  local previous_line=0
  local status_value=""
  local -a labels=("Context" "Decision" "Consequence" "Pointer" "Status")

  [[ "$filename" =~ ^(RoR-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3})-[a-z0-9][a-z0-9-]*[.]md$ ]] \
    || fail "current RoR target filename is invalid: ${source_rel}"
  expected_decision_id="${BASH_REMATCH[1]}"

  frontmatter="$(extract_frontmatter "$source_path")" \
    || fail "current RoR target lacks valid frontmatter: ${source_rel}"
  trace_id="$(trim "$(frontmatter_value "trace_id" "$frontmatter")")"
  decision_id="$(trim "$(frontmatter_value "decision_id" "$frontmatter")")"
  packet_id="$(trim "$(frontmatter_value "packet_id" "$frontmatter")")"
  decision_type="$(trim "$(frontmatter_value "decision_type" "$frontmatter")")"
  created_at="$(trim "$(frontmatter_value "created_at" "$frontmatter")")"
  authorized_by="$(trim "$(frontmatter_value "authorized_by" "$frontmatter")")"

  [[ -n "$trace_id" ]] || fail "current RoR target is missing trace_id: ${source_rel}"
  [[ "$decision_id" == "$expected_decision_id" ]] \
    || fail "current RoR decision_id does not match its filename: ${source_rel}"
  [[ "$packet_id" =~ ^DP-[A-Z]+-[0-9]{4,}$ ]] \
    || fail "current RoR packet_id is invalid: ${source_rel}"
  [[ "$decision_type" =~ ^[a-z0-9][a-z0-9-]*$ ]] \
    || fail "current RoR decision_type is invalid: ${source_rel}"
  [[ "$created_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]] \
    || fail "current RoR created_at must use ISO-8601 UTC format with Z suffix: ${source_rel}"
  [[ "$authorized_by" =~ ^(Operator|Integrator|Contractor|Auditor)$ ]] \
    || fail "current RoR authorized_by value is invalid: ${source_rel}"
  if [[ "$decision_type" == "op" && "$authorized_by" != "Operator" ]]; then
    fail "current RoR Operator decision must declare authorized_by: Operator: ${source_rel}"
  fi

  if grep -Eiq 'Populate during execution[.]|(^|[^[:alnum:]])(TBD|TODO|PLACEHOLDER|REPLACE_ME)([^[:alnum:]]|$)' "$source_path"; then
    fail "current RoR target contains unresolved scaffold text: ${source_rel}"
  fi

  for label in "${labels[@]}"; do
    count="$(grep -cE "^##[[:space:]]+${label}[[:space:]]*$" "$source_path" || true)"
    [[ "$count" == "1" ]] \
      || fail "current RoR section must appear exactly once: section=${label} count=${count} source=${source_rel}"
    line_no="$(grep -nE "^##[[:space:]]+${label}[[:space:]]*$" "$source_path" | cut -d: -f1)"
    (( line_no > previous_line )) \
      || fail "current RoR sections are out of order at ${label}: ${source_rel}"
    previous_line="$line_no"
  done

  status_value="$(awk '
    /^##[[:space:]]+Status[[:space:]]*$/ { in_status=1; next }
    in_status && /^[[:space:]]*$/ { next }
    in_status { print; exit }
  ' "$source_path")"
  status_value="$(trim "$status_value")"
  [[ -n "$status_value" ]] || fail "current RoR status is empty: ${source_rel}"
  case "${status_value,,}" in
    draft*|pending*|proposed*)
      fail "current RoR status is provisional: status=${status_value} source=${source_rel}"
      ;;
  esac
}

resolve_current_ror_source() {
  local root_path="$1"
  local line_count=""
  local pointer=""

  [[ -f "$root_path" ]] || fail "missing current surface: ${root_path#${REPO_ROOT}/}"
  line_count="$(awk 'END { print NR }' "$root_path")"
  [[ "$line_count" == "1" ]] \
    || fail "current RoR must be a single pointer head: ${root_path#${REPO_ROOT}/}"
  pointer="$(trim "$(cat "$root_path")")"
  pointer="${pointer#./}"
  [[ "$pointer" =~ ^archives/decisions/RoR-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}-[a-z0-9][a-z0-9-]*[.]md$ ]] \
    || fail "current RoR pointer is invalid: ${root_path#${REPO_ROOT}/} -> ${pointer}"
  [[ -f "${REPO_ROOT}/${pointer}" ]] \
    || fail "current RoR pointer target is missing: ${root_path#${REPO_ROOT}/} -> ${pointer}"
  printf '%s' "${REPO_ROOT}/${pointer}"
}

write_ror_test_leaf() {
  local path="$1"
  local decision_id="$2"
  local authorized_by="$3"
  local decision_text="$4"
  local status="$5"
  cat > "$path" <<EOF
---
trace_id: schema-ror-test
decision_id: ${decision_id}
packet_id: DP-OPS-9999
decision_type: op
created_at: 2026-08-04T12:00:00Z
authorized_by: ${authorized_by}
---

## Context

Bounded schema test context.

## Decision

${decision_text}

## Consequence

Bounded schema test consequence.

## Pointer

- Authorized by: ${authorized_by}

## Status

${status}
EOF
}

run_ror_contract_self_test() {
  local fixture_root=""
  local valid_rel="archives/decisions/RoR-2026-08-04-001-op-9999.md"
  local placeholder_rel="archives/decisions/RoR-2026-08-04-002-op-9999.md"
  local authority_rel="archives/decisions/RoR-2026-08-04-003-op-9999.md"
  local pending_rel="archives/decisions/RoR-2026-08-04-004-op-9999.md"
  local mismatch_rel="archives/decisions/RoR-2026-08-04-005-op-9999.md"
  local passed=0

  mkdir -p "${REPO_ROOT}/var/tmp"
  fixture_root="$(mktemp -d "${REPO_ROOT}/var/tmp/schema-ror.XXXXXX")"
  mkdir -p "${fixture_root}/archives/decisions"
  write_ror_test_leaf "${fixture_root}/${valid_rel}" "RoR-2026-08-04-001" "Operator" "Approve the bounded test." "approved"
  write_ror_test_leaf "${fixture_root}/${placeholder_rel}" "RoR-2026-08-04-002" "Operator" "Populate during execution." "approved"
  write_ror_test_leaf "${fixture_root}/${authority_rel}" "RoR-2026-08-04-003" "Integrator" "Approve the bounded test." "approved"
  write_ror_test_leaf "${fixture_root}/${pending_rel}" "RoR-2026-08-04-004" "Operator" "Approve the bounded test." "pending"
  write_ror_test_leaf "${fixture_root}/${mismatch_rel}" "RoR-2026-08-04-999" "Operator" "Approve the bounded test." "approved"

  printf '%s\n' "$valid_rel" > "${fixture_root}/RoR.md"
  if (REPO_ROOT="$fixture_root"; source_path="$(resolve_current_ror_source "${fixture_root}/RoR.md")"; lint_current_ror_leaf_contract "$source_path" "$valid_rel"); then
    passed=$((passed + 1))
  else
    fail "RoR self-test expected a settled Operator decision to pass"
  fi

  printf '%s\n%s\n' "$valid_rel" "$placeholder_rel" > "${fixture_root}/RoR.md"
  if (REPO_ROOT="$fixture_root"; resolve_current_ror_source "${fixture_root}/RoR.md" >/dev/null 2>&1); then
    fail "RoR self-test expected a multi-line pointer head to fail"
  fi
  passed=$((passed + 1))

  for test_rel in "$placeholder_rel" "$authority_rel" "$pending_rel" "$mismatch_rel"; do
    printf '%s\n' "$test_rel" > "${fixture_root}/RoR.md"
    if (REPO_ROOT="$fixture_root"; source_path="$(resolve_current_ror_source "${fixture_root}/RoR.md")"; lint_current_ror_leaf_contract "$source_path" "$test_rel" >/dev/null 2>&1); then
      fail "RoR self-test expected invalid fixture to fail: ${test_rel}"
    fi
    passed=$((passed + 1))
  done

  rm -r "$fixture_root"
  [[ "$passed" == "6" ]] || fail "RoR self-test count mismatch: expected=6 actual=${passed}"
  echo "OK: current RoR contract tests passed (${passed}/6)."
}

if (( schema_test_mode == 1 )); then
  run_ror_contract_self_test
  exit 0
fi

run_ror_contract_self_test >/dev/null

definitions_checked=0
surfaces_checked=0
manifests_checked=0

mapfile -t definition_candidates < <(find "$DEFINITIONS_DIR" -maxdepth 1 -type f | sort)
for path in "${definition_candidates[@]}"; do
  rel_path="${path#${REPO_ROOT}/}"
  if [[ "$rel_path" == "archives/definitions/.gitkeep" ]]; then
    continue
  fi
  if [[ "$rel_path" != *.md ]]; then
    continue
  fi
  lint_schema_leaf "$path" "$rel_path"
  definitions_checked=$((definitions_checked + 1))
done

mapfile -t surface_candidates < <(find "$SURFACES_DIR" -maxdepth 1 -type f | sort)
for path in "${surface_candidates[@]}"; do
  rel_path="${path#${REPO_ROOT}/}"
  if [[ "$rel_path" == "archives/surfaces/.gitkeep" ]]; then
    continue
  fi
  if [[ "$rel_path" != *.md ]]; then
    continue
  fi
  if ! is_surface_schema_candidate "$rel_path"; then
    continue
  fi
  lint_schema_leaf "$path" "$rel_path"
  surfaces_checked=$((surfaces_checked + 1))
done

mapfile -t manifest_candidates < <(find "$MANIFESTS_DIR" -maxdepth 1 -type f | sort)
for path in "${manifest_candidates[@]}"; do
  rel_path="${path#${REPO_ROOT}/}"
  if [[ "$rel_path" == "archives/manifests/.gitkeep" ]]; then
    continue
  fi
  if [[ "$rel_path" != *.md ]]; then
    continue
  fi
  if ! is_manifest_schema_candidate "$rel_path"; then
    continue
  fi
  lint_schema_leaf "$path" "$rel_path"
  manifests_checked=$((manifests_checked + 1))
done

current_sop_source="$(resolve_current_surface_source "${REPO_ROOT}/SoP.md")"
lint_current_sop_contract "${REPO_ROOT}/SoP.md" "$current_sop_source"

current_pow_source="$(resolve_current_surface_source "${REPO_ROOT}/PoW.md")"
lint_current_pow_contract "${REPO_ROOT}/PoW.md" "$current_pow_source"

current_task_source="$(resolve_current_surface_source "${REPO_ROOT}/TASK.md")"
lint_current_task_pointer_contract "${REPO_ROOT}/TASK.md" "$current_task_source"

current_ror_source="$(resolve_current_ror_source "${REPO_ROOT}/RoR.md")"
lint_current_ror_leaf_contract "$current_ror_source" "${current_ror_source#${REPO_ROOT}/}"

checked=$((definitions_checked + surfaces_checked + manifests_checked))
echo "OK: schema lint passed (${checked} file(s) checked: definitions=${definitions_checked}, surfaces=${surfaces_checked}, manifests=${manifests_checked})."
