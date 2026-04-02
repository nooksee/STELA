#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

usage() {
  cat <<'USAGE'
Usage: tools/lint/dp.sh [--test] [path|-]
USAGE
}

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1
trap 'emit_binary_leaf "lint-dp" "finish"' EXIT
emit_binary_leaf "lint-dp" "start"

CANONICAL_DP_TEMPLATE_PATH="ops/src/surfaces/dp.md.tpl"
CANONICAL_DP_TEMPLATE_SHA256="e1076015c7e6a4cbb2cd050e3e40ba5ad90906697b1a78d4ccb98f605b7b8e82"
CANONICAL_ADDENDUM_TEMPLATE_PATH="ops/src/stances/addendum.md.tpl"
CANONICAL_ADDENDUM_TEMPLATE_SHA256="715db3fae0598a85a0fa490c16f590dd08e6d6f02fa9b18224ce48625612f624"
TEMPLATE_RENDER_BIN="ops/bin/template"
ALLOWLIST_POINTER_PATH_DEFAULT="storage/dp/active/allowlist.txt"

failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

strip_backticks() {
  local value="$1"
  if [[ "$value" == \`* ]]; then
    value="${value#\`}"
  fi
  if [[ "$value" == *\` ]]; then
    value="${value%\`}"
  fi
  printf '%s' "$value"
}

extract_hash() {
  local value="$1"
  printf '%s' "$value" | grep -oE '[0-9a-f]{7,}' | head -n1 || true
}

contains_placeholder() {
  local lowered
  lowered="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"

  if [[ -z "$lowered" ]]; then
    return 0
  fi

  case "$lowered" in
    *"tbd"*|*"todo"*|*"populate during execution"*|*"do not pre-fill"*|*"dp-xxxx"*|*"xxxx"*|*"0000000"*|*"{{"*|*"}}"*|*"<fill"*|*"replace_"*|*"enter_"*)
      return 0
      ;;
  esac

  return 1
}

sha256_file() {
  local path="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{print $1}'
    return
  fi
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$path" | awk '{print $1}'
    return
  fi
  echo ""
}

sha256_stdin() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum | awk '{print $1}'
    return
  fi
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 | awk '{print $1}'
    return
  fi
  echo ""
}

canonical_template_hash() {
  if [[ -n "${DP_CANONICAL_TEMPLATE_SHA256_OVERRIDE:-}" ]]; then
    printf '%s' "${DP_CANONICAL_TEMPLATE_SHA256_OVERRIDE}"
    return
  fi
  printf '%s' "$CANONICAL_DP_TEMPLATE_SHA256"
}

allowlist_pointer_path() {
  if [[ -n "${DP_ALLOWLIST_POINTER_OVERRIDE:-}" ]]; then
    printf '%s' "${DP_ALLOWLIST_POINTER_OVERRIDE}"
    return
  fi
  printf '%s' "$ALLOWLIST_POINTER_PATH_DEFAULT"
}

path_is_deleted_tracked_in_active_diff() {
  local path="$1"
  if git diff --name-only --diff-filter=D -- "$path" | grep -Fxq "$path"; then
    return 0
  fi
  if git diff --cached --name-only --diff-filter=D -- "$path" | grep -Fxq "$path"; then
    return 0
  fi
  return 1
}

check_template_hash_preflight() {
  local expected_hash
  local actual_hash

  expected_hash="$(canonical_template_hash)"
  actual_hash="$(sha256_file "$CANONICAL_DP_TEMPLATE_PATH")"

  if [[ ! -f "$CANONICAL_DP_TEMPLATE_PATH" ]]; then
    fail "canonical DP template missing: ${CANONICAL_DP_TEMPLATE_PATH}"
    return
  fi

  if [[ -z "$actual_hash" ]]; then
    fail "unable to compute sha256 for canonical DP template"
    return
  fi

  if [[ ! "$expected_hash" =~ ^[0-9a-f]{64}$ ]]; then
    fail "canonical template hash constant is invalid in tools/lint/dp.sh"
    return
  fi

  if [[ "$actual_hash" != "$expected_hash" ]]; then
    fail "canonical template hash mismatch for ${CANONICAL_DP_TEMPLATE_PATH} (expected ${expected_hash}, got ${actual_hash})"
  fi
}

check_addendum_template_hash() {
  if [[ ! -f "$CANONICAL_ADDENDUM_TEMPLATE_PATH" ]]; then
    fail "canonical addendum template missing: ${CANONICAL_ADDENDUM_TEMPLATE_PATH}"
    return
  fi

  local actual_hash
  actual_hash="$(sha256_file "$CANONICAL_ADDENDUM_TEMPLATE_PATH")"

  if [[ -z "$actual_hash" ]]; then
    fail "unable to compute sha256 for canonical addendum template"
    return
  fi

  if [[ "$actual_hash" != "$CANONICAL_ADDENDUM_TEMPLATE_SHA256" ]]; then
    fail "canonical addendum template hash mismatch for ${CANONICAL_ADDENDUM_TEMPLATE_PATH} (expected ${CANONICAL_ADDENDUM_TEMPLATE_SHA256}, got ${actual_hash})"
  fi
}

lint_addendum_intake() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    fail "addendum intake file not found: ${path}"
    return
  fi

  local auth_block
  local base_dp_value
  local addendum_id_value
  local scope_delta
  local objective_block
  local receipt_block
  local compact

  auth_block="$(extract_block "$path" '^Operator Authorization:[[:space:]]*$' '^Base Packet:[[:space:]]*')"
  base_dp_value="$(extract_field_value "Base Packet" "$path")"
  addendum_id_value="$(extract_field_value "Addendum ID" "$path")"
  scope_delta="$(extract_block "$path" '^Exact paths added by this addendum [(]one per line; no globs; no brace expansion[)]:[[:space:]]*$' '^## A[.]3([.]|[[:space:]])')"
  objective_block="$(extract_block "$path" '^## A[.]3[[:space:]]+Addendum Objective[[:space:]]*$' '^## A[.]4([.]|[[:space:]])')"
  receipt_block="$(awk '
    BEGIN { found=0 }
    /^\*\*Addendum-specific receipt commands:\*\*[[:space:]]*$/ { found=1; next }
    found { print }
  ' "$path")"

  compact="$(printf '%s\n' "$base_dp_value" | sed '/^[[:space:]]*$/d')"
  [[ -n "$compact" ]] || fail "addendum intake missing required slot: BASE_DP_ID"
  compact="$(printf '%s\n' "$addendum_id_value" | sed '/^[[:space:]]*$/d')"
  [[ -n "$compact" ]] || fail "addendum intake missing required slot: ADDENDUM_ID"
  compact="$(printf '%s\n' "$auth_block" | sed '/^[[:space:]]*$/d')"
  [[ -n "$compact" ]] || fail "addendum intake missing required slot: OPERATOR_AUTHORIZATION"
  compact="$(printf '%s\n' "$scope_delta" | sed '/^[[:space:]]*$/d')"
  [[ -n "$compact" ]] || fail "addendum intake missing required slot: SCOPE_DELTA"
  compact="$(printf '%s\n' "$objective_block" | sed '/^[[:space:]]*$/d')"
  [[ -n "$compact" ]] || fail "addendum intake missing required slot: ADDENDUM_OBJECTIVE"
  compact="$(printf '%s\n' "$receipt_block" | sed '/^[[:space:]]*$/d')"
  [[ -n "$compact" ]] || fail "addendum intake missing required slot: ADDENDUM_RECEIPT"

  if contains_placeholder "$auth_block"; then
    fail "addendum intake OPERATOR_AUTHORIZATION contains a placeholder value"
  fi

  base_dp_value="$(strip_backticks "$(trim "$base_dp_value")")"
  if [[ ! "$base_dp_value" =~ ^DP-OPS-[0-9]{4}$ ]]; then
    fail "addendum intake BASE_DP_ID does not match required pattern DP-OPS-XXXX: ${base_dp_value}"
  fi

  addendum_id_value="$(strip_backticks "$(trim "$addendum_id_value")")"
  if [[ ! "$addendum_id_value" =~ ^[A-Z]$ ]]; then
    fail "addendum intake ADDENDUM_ID must be a single uppercase letter A-Z: ${addendum_id_value}"
  fi

  while IFS= read -r line; do
    line="$(trim "$line")"
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ [*?{}\[\]] ]]; then
      fail "addendum intake SCOPE_DELTA entry contains a glob or brace expansion: ${line}"
    fi
    if [[ "$line" =~ \  ]]; then
      fail "addendum intake SCOPE_DELTA entry contains whitespace: ${line}"
    fi
  done <<< "$scope_delta"

  check_receipt_block_replayability "$receipt_block" "Addendum receipt command"
}

render_canonical_template_non_strict() {
  local out_path="$1"

  if [[ ! -x "$TEMPLATE_RENDER_BIN" ]]; then
    fail "template renderer missing or not executable: ${TEMPLATE_RENDER_BIN}"
    return 1
  fi

  if ! "$TEMPLATE_RENDER_BIN" render dp --non-strict --out="$out_path"; then
    fail "failed to render canonical DP template in non-strict mode via ${TEMPLATE_RENDER_BIN}"
    return 1
  fi
}

is_task_surface() {
  local path="$1"
  grep -Eq '^#[[:space:]]*STELA TASK DASHBOARD' "$path" \
    && grep -Eq '^##[[:space:]]*3[.][[:space:]]*Current Dispatch Packet \(DP\)' "$path"
}

resolve_task_surface_path() {
  local source_path="$1"
  if [[ "$(basename "$source_path")" != "TASK.md" ]]; then
    printf '%s' "$source_path"
    return 0
  fi

  local line_count
  line_count="$(awk 'END { print NR }' "$source_path")"
  if [[ "$line_count" != "1" ]]; then
    printf '%s' "$source_path"
    return 0
  fi

  local pointer_path
  pointer_path="$(trim "$(strip_backticks "$(cat "$source_path")")")"
  pointer_path="${pointer_path#./}"
  if [[ "$pointer_path" == "${REPO_ROOT}/"* ]]; then
    pointer_path="${pointer_path#${REPO_ROOT}/}"
  fi

  if [[ ! "$pointer_path" =~ ^archives/surfaces/[A-Za-z0-9._/-]+\.md$ ]]; then
    fail "TASK is single-line but not a valid archives/surfaces pointer"
    return 1
  fi

  local target_path="${REPO_ROOT}/${pointer_path}"
  if [[ ! -f "$target_path" ]]; then
    fail "TASK pointer target missing: ${pointer_path}"
    return 1
  fi

  printf '%s' "$target_path"
}

extract_dp_payload() {
  local source_path="$1"
  local payload_path="$2"

  if ! is_task_surface "$source_path"; then
    cp "$source_path" "$payload_path"
    return 0
  fi

  local section_count
  section_count="$(grep -cE '^##[[:space:]]*3[.][[:space:]]*Current Dispatch Packet \(DP\)[[:space:]]*$' "$source_path" || true)"
  if [[ "$section_count" != "1" ]]; then
    fail "TASK.md must contain exactly one '## 3. Current Dispatch Packet (DP)' section"
    return 1
  fi

  local dp_heading_count
  dp_heading_count="$(awk '
    BEGIN { in_section=0; count=0 }
    /^##[[:space:]]*3[.][[:space:]]*Current Dispatch Packet [(]DP[)][[:space:]]*$/ { in_section=1; next }
    in_section && /^##[[:space:]]*[0-9]+[.]/ && $0 !~ /^##[[:space:]]*3[.]/ { in_section=0 }
    in_section && /^### DP-/ { count++ }
    END { print count }
  ' "$source_path")"
  if [[ "$dp_heading_count" != "1" ]]; then
    fail "TASK.md must contain exactly one active '### DP-' block inside Section 3"
    return 1
  fi

  awk '
    BEGIN { in_section=0; in_block=0 }
    /^##[[:space:]]*3[.][[:space:]]*Current Dispatch Packet [(]DP[)][[:space:]]*$/ { in_section=1; next }
    in_section && /^##[[:space:]]*[0-9]+[.]/ && $0 !~ /^##[[:space:]]*3[.]/ { exit }
    in_section && /^### DP-/ { in_block=1 }
    in_block { print }
  ' "$source_path" > "$payload_path"

  if [[ ! -s "$payload_path" ]]; then
    fail "TASK.md missing extractable DP payload"
    return 1
  fi

  return 0
}

extract_field_value() {
  local label="$1"
  local path="$2"
  awk -v label="$label" '
    {
      if ($0 ~ "^" label ":[[:space:]]*") {
        text=$0
        sub("^" label ":[[:space:]]*", "", text)
        print text
        exit
      }
    }
  ' "$path"
}

extract_block() {
  local path="$1"
  local start_pattern="$2"
  local stop_pattern="$3"
  awk -v start_regex="$start_pattern" -v stop_regex="$stop_pattern" '
    BEGIN { in_block=0 }
    $0 ~ start_regex { in_block=1; next }
    in_block && $0 ~ stop_regex { exit }
    in_block { print }
  ' "$path"
}

block_has_content() {
  local value="$1"
  local compact
  compact="$(printf '%s\n' "$value" | sed '/^[[:space:]]*$/d')"
  if [[ -z "$compact" ]]; then
    return 1
  fi

  local filtered
  filtered="$(printf '%s\n' "$compact" | awk '
    {
      lower=tolower($0)
      if ($0 ~ /^[[:space:]]*{{[A-Z0-9_]+}}[[:space:]]*$/) { next }
      if (lower ~ /populate during execution|do not pre-fill|tbd|todo|dp-xxxx|xxxx/) { next }
      print
    }
  ' | sed '/^[[:space:]]*$/d')"

  [[ -n "$filtered" ]]
}

normalize_dp_structure() {
  local path="$1"
  awk '
    function emit(name) {
      print "{{" name "}}"
    }

    mode == "DP_SCOPED_LOAD_ORDER" {
      if ($0 ~ /^##[[:space:]]*3[.]3([.]|[[:space:]])/) {
        mode=""
        print $0
      }
      next
    }

    mode == "OBJECTIVE" {
      if ($0 ~ /^In scope:[[:space:]]*$/) {
        print $0
        emit("IN_SCOPE")
        mode="IN_SCOPE"
      }
      next
    }

    mode == "IN_SCOPE" {
      if ($0 ~ /^Out of scope:[[:space:]]*$/) {
        print $0
        emit("OUT_OF_SCOPE")
        mode="OUT_OF_SCOPE"
      }
      next
    }

    mode == "OUT_OF_SCOPE" {
      if ($0 ~ /^Safety and invariants:[[:space:]]*$/) {
        print $0
        emit("SAFETY_INVARIANTS")
        mode="SAFETY_INVARIANTS"
      }
      next
    }

    mode == "SAFETY_INVARIANTS" {
      if ($0 ~ /^Target Files allowlist [(]hard gate[)]:[[:space:]]*$/) {
        print $0
        mode="ALLOWLIST_POINTER"
      }
      next
    }

    mode == "ALLOWLIST_POINTER" {
      if ($0 ~ /^[[:space:]]*-[[:space:]]+/) {
        print "- {{ALLOWLIST_POINTER}}"
        mode=""
      }
      next
    }

    mode == "PLAN_STATE" {
      if ($0 ~ /^### 3[.]4[.]2/) {
        print $0
        emit("PLAN_REQUEST")
        mode="PLAN_REQUEST"
      }
      next
    }

    mode == "PLAN_REQUEST" {
      if ($0 ~ /^### 3[.]4[.]3/) {
        print $0
        emit("PLAN_CHANGELOG")
        mode="PLAN_CHANGELOG"
      }
      next
    }

    mode == "PLAN_CHANGELOG" {
      if ($0 ~ /^### 3[.]4[.]4/) {
        print $0
        emit("PLAN_PATCH")
        mode="PLAN_PATCH"
      }
      next
    }

    mode == "PLAN_PATCH" {
      if ($0 ~ /^### 3[.]4[.]5/) {
        print $0
        emit("RECEIPT_EXTRA")
        mode="RECEIPT_EXTRA"
      }
      next
    }

    mode == "CBC_PREFLIGHT" {
      if ($0 ~ /^##[[:space:]]*3[.]2([.]|[[:space:]])/) {
        mode=""
        print $0
      }
      next
    }

    mode == "RECEIPT_EXTRA" {
      if ($0 ~ /^##[[:space:]]*3[.]5([.]|[[:space:]])/) {
        mode=""
        print $0
      }
      next
    }

    {
      if ($0 ~ /^### \{\{DP_ID\}\}:[[:space:]].*$/) {
        print "### DP-OPS-0000: {{DP_TITLE}}"
        next
      }
      if ($0 ~ /^### DP-[^:]+:[[:space:]].*$/) {
        print "### DP-OPS-0000: {{DP_TITLE}}"
        next
      }
      if ($0 ~ /^Base Branch:[[:space:]]*/) {
        print "Base Branch: {{BASE_BRANCH}}"
        next
      }
      if ($0 ~ /^(Required Work Branch|Work Branch):[[:space:]]*/) {
        print "Work Branch: {{PROPOSED_WORK_BRANCH}}"
        next
      }
      if ($0 ~ /^Base HEAD:[[:space:]]*/) {
        print "Base HEAD: {{BASE_HEAD}}"
        next
      }
      if ($0 ~ /^Freshness Stamp:[[:space:]]*/) {
        print "Freshness Stamp: {{FRESHNESS_STAMP}}"
        next
      }

      if ($0 ~ /^### 3[.]2[.]2([.]|[[:space:]])/) {
        print $0
        emit("DP_SCOPED_LOAD_ORDER")
        mode="DP_SCOPED_LOAD_ORDER"
        next
      }

      if ($0 ~ /^### CbC Design Discipline Preflight/) {
        print $0
        emit("CBC_PREFLIGHT")
        mode="CBC_PREFLIGHT"
        next
      }

      if ($0 ~ /^Objective:[[:space:]]*$/) {
        print $0
        emit("OBJECTIVE")
        mode="OBJECTIVE"
        next
      }

      if ($0 ~ /^### 3[.]4[.]1/) {
        print $0
        emit("PLAN_STATE")
        mode="PLAN_STATE"
        next
      }

      if ($0 ~ /--dp=\{\{DP_ID\}\}/) {
        gsub(/--dp=\{\{DP_ID\}\}/, "--dp=DP-OPS-0000")
        print $0
        next
      }

      if ($0 ~ /--dp=DP-[A-Z]+-[0-9]{4,}/) {
        gsub(/--dp=DP-[A-Z]+-[0-9]{4,}/, "--dp=DP-OPS-0000")
        print $0
        next
      }

      # Canonicalize §3.5.1 closing-sidecar prose references so template/body
      # placeholders and fixture substitutions hash to the same normalized form.
      if ($0 ~ /storage\/handoff\/CLOSING-\{\{DP_ID\}\}\.md/) {
        gsub(/storage\/handoff\/CLOSING-\{\{DP_ID\}\}\.md/, "storage/handoff/CLOSING.md")
        print $0
        next
      }

      if ($0 ~ /storage\/handoff\/CLOSING-DP-[A-Z]+-[0-9]{4,}\.md/) {
        gsub(/storage\/handoff\/CLOSING-DP-[A-Z]+-[0-9]{4,}\.md/, "storage/handoff/CLOSING.md")
        print $0
        next
      }

      print $0
    }
  ' "$path"
}

check_structure_hash() {
  local payload_path="$1"
  local template_hash
  local payload_hash
  local rendered_template

  if [[ ! -f "$CANONICAL_DP_TEMPLATE_PATH" ]]; then
    return
  fi

  rendered_template="$(mktemp)"
  if ! render_canonical_template_non_strict "$rendered_template"; then
    rm -f "$rendered_template"
    return
  fi

  template_hash="$(normalize_dp_structure "$rendered_template" | sha256_stdin)"
  payload_hash="$(normalize_dp_structure "$payload_path" | sha256_stdin)"
  rm -f "$rendered_template"

  if [[ -z "$template_hash" || -z "$payload_hash" ]]; then
    fail "unable to compute DP structure hashes"
    return
  fi

  if [[ "$payload_hash" != "$template_hash" ]]; then
    fail "DP structure hash mismatch against canonical template"
  fi
}

check_required_fields() {
  local path="$1"

  local heading
  local dp_id
  local dp_title
  heading="$(grep -m1 -E '^### DP-' "$path" || true)"
  if [[ -z "$heading" ]]; then
    fail "missing DP heading (expected '### DP-...: ...')"
  else
    dp_id="$(printf '%s' "$heading" | sed -E 's/^###[[:space:]]*(DP-[^:]+):.*$/\1/')"
    dp_title="$(printf '%s' "$heading" | sed -E 's/^###[[:space:]]*DP-[^:]+:[[:space:]]*(.*)$/\1/')"

    if [[ ! "$dp_id" =~ ^DP-[A-Z]+-[0-9]{4,}$ ]]; then
      fail "invalid DP id in heading: ${dp_id}"
    fi
    if contains_placeholder "$dp_title"; then
      fail "placeholder value for DP title"
    fi
  fi

  local base_branch
  local work_branch
  local base_head_raw
  local freshness_stamp
  local base_head

  base_branch="$(trim "$(strip_backticks "$(extract_field_value "Base Branch" "$path")")")"
  work_branch="$(trim "$(strip_backticks "$(extract_field_value "Work Branch" "$path")")")"
  if [[ -z "$work_branch" ]]; then
    work_branch="$(trim "$(strip_backticks "$(extract_field_value "Required Work Branch" "$path")")")"
  fi
  base_head_raw="$(trim "$(strip_backticks "$(extract_field_value "Base HEAD" "$path")")")"
  freshness_stamp="$(trim "$(strip_backticks "$(extract_field_value "Freshness Stamp" "$path")")")"

  if [[ -z "$base_branch" ]]; then
    fail "missing value for 'Base Branch'"
  elif contains_placeholder "$base_branch"; then
    fail "missing or placeholder value for 'Base Branch'"
  fi
  if [[ -z "$work_branch" ]]; then
    fail "missing value for 'Work Branch'"
  elif contains_placeholder "$work_branch"; then
    fail "missing or placeholder value for 'Work Branch'"
  fi
  if [[ -z "$base_head_raw" ]]; then
    fail "missing value for 'Base HEAD'"
  elif contains_placeholder "$base_head_raw"; then
    fail "missing or placeholder value for 'Base HEAD'"
  fi
  if [[ -z "$freshness_stamp" ]]; then
    fail "missing value for 'Freshness Stamp'"
  elif contains_placeholder "$freshness_stamp"; then
    fail "missing or placeholder value for 'Freshness Stamp'"
  fi

  base_head="$(extract_hash "$base_head_raw")"
  if [[ -z "$base_head" ]]; then
    fail "invalid Base HEAD hash"
  fi

  local scoped_load_order
  local objective_block
  local in_scope_block
  local out_scope_block
  local safety_block
  local state_block
  local request_block
  local changelog_block
  local patch_block
  local receipt_block
  local cbc_preflight_block

  scoped_load_order="$(extract_block "$path" '^### 3[.]2[.]2' '^## 3[.]3([.]|[[:space:]])')"
  objective_block="$(extract_block "$path" '^Objective:[[:space:]]*$' '^In scope:[[:space:]]*$')"
  in_scope_block="$(extract_block "$path" '^In scope:[[:space:]]*$' '^Out of scope:[[:space:]]*$')"
  out_scope_block="$(extract_block "$path" '^Out of scope:[[:space:]]*$' '^Safety and invariants:[[:space:]]*$')"
  safety_block="$(extract_block "$path" '^Safety and invariants:[[:space:]]*$' '^Target Files allowlist [(]hard gate[)]:[[:space:]]*$')"
  state_block="$(extract_block "$path" '^### 3[.]4[.]1' '^### 3[.]4[.]2')"
  request_block="$(extract_block "$path" '^### 3[.]4[.]2' '^### 3[.]4[.]3')"
  changelog_block="$(extract_block "$path" '^### 3[.]4[.]3' '^### 3[.]4[.]4')"
  patch_block="$(extract_block "$path" '^### 3[.]4[.]4' '^### 3[.]4[.]5')"
  receipt_block="$(extract_block "$path" '^### 3[.]4[.]5' '^## 3[.]5([.]|[[:space:]])')"
  cbc_preflight_block="$(extract_block "$path" '^### CbC Design Discipline Preflight' '^## 3[.]2([.]|[[:space:]])')"

  if ! block_has_content "$scoped_load_order"; then
    fail "missing or placeholder content for DP-scoped load order"
  fi
  if ! block_has_content "$objective_block"; then
    fail "missing or placeholder content for Objective"
  fi
  if ! block_has_content "$in_scope_block"; then
    fail "missing or placeholder content for In scope"
  fi
  if ! block_has_content "$out_scope_block"; then
    fail "missing or placeholder content for Out of scope"
  fi
  if ! block_has_content "$safety_block"; then
    fail "missing or placeholder content for Safety and invariants"
  fi
  if ! block_has_content "$state_block"; then
    fail "missing or placeholder content for 3.4.1 State"
  fi
  if ! block_has_content "$request_block"; then
    fail "missing or placeholder content for 3.4.2 Request"
  fi
  if ! block_has_content "$changelog_block"; then
    fail "missing or placeholder content for 3.4.3 Changelog"
  fi
  if ! block_has_content "$patch_block"; then
    fail "missing or placeholder content for 3.4.4 Patch / Diff"
  fi
  if ! block_has_content "$receipt_block"; then
    fail "missing or placeholder content for 3.4.5 Receipt"
  fi
  if ! block_has_content "$cbc_preflight_block"; then
    fail "missing or placeholder content for CbC Design Discipline Preflight (TASK.md §3.1.1)"
  fi
}

check_freshness_stamp_format() {
  local path="$1"
  local freshness_stamp
  freshness_stamp="$(trim "$(strip_backticks "$(extract_field_value "Freshness Stamp" "$path")")")"
  if [[ -z "$freshness_stamp" ]]; then
    return 0
  fi
  if contains_placeholder "$freshness_stamp"; then
    return 0
  fi
  if [[ ! "$freshness_stamp" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    fail "Freshness Stamp must be YYYY-MM-DD format only; got: ${freshness_stamp}"
  fi
}

receipt_command_first_token_allowed() {
  local first_token="$1"
  case "$first_token" in
    git|bash|./*|ops/bin/*|comm|cat|ls|cp|mv|rm|find|sed|awk|grep|rg|echo|printf|sh|test)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

check_receipt_block_replayability() {
  local receipt_block="$1"
  local section_label="$2"
  local line=""
  local trimmed_line=""
  local candidate=""
  local first_token=""

  [[ -n "$receipt_block" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -z "$line" ]] && continue
    trimmed_line="$(trim "$line")"
    [[ "$trimmed_line" == -* ]] || continue

    candidate="${trimmed_line#- }"
    candidate="$(trim "$candidate")"
    [[ -n "$candidate" ]] || continue

    if [[ "$candidate" == \`* && "$candidate" == *\` ]]; then
      candidate="${candidate#\`}"
      candidate="${candidate%\`}"
      candidate="$(trim "$candidate")"
    fi

    case "$candidate" in
      "**Mandatory receipt commands"*|"**DP-specific receipt commands"*|"**Addendum-specific receipt commands"*|"Mandatory receipt commands"*|"DP-specific receipt commands"*|"Addendum-specific receipt commands"*|"Required pasted outputs:"*|"Mandatory Closing Block"*|"Mandatory Closing Sidecar"*|"Verify Section "*|"Worker runs"*|"Purpose:"*)
        continue
        ;;
      "Note: "*)
        continue
        ;;
    esac

    if [[ "$candidate" =~ ^(\./)?ops/bin/certify([[:space:]]|$) ]]; then
      continue
    fi
    if [[ "$candidate" =~ ^bash[[:space:]]+tools/lint/results[.]sh([[:space:]]|$) ]]; then
      continue
    fi
    if [[ "$candidate" =~ ^![[:space:]]+ ]]; then
      candidate="${candidate#!}"
      candidate="$(trim "$candidate")"
      [[ -n "$candidate" ]] || continue
    fi

    if [[ "$candidate" == *"\`"* ]]; then
      fail "${section_label} contains inline backticks (rejected by certify replay): ${trimmed_line}"
      continue
    fi
    if [[ "$candidate" == *'$('* ]]; then
      fail "${section_label} contains command substitution (rejected by certify replay): ${trimmed_line}"
      continue
    fi

    first_token="${candidate%%[[:space:]]*}"
    if [[ "$candidate" == *"{"* || "$candidate" == *"}"* || "$candidate" == *"*"* || "$candidate" == *"?"* || "$candidate" == *"["* ]]; then
      case "$first_token" in
        grep|rg)
          ;;
        *)
          fail "${section_label} contains unsupported brace/glob pattern (rejected by certify replay): ${trimmed_line}"
          continue
          ;;
      esac
    fi

    if ! receipt_command_first_token_allowed "$first_token"; then
      fail "${section_label} uses unsupported first token (rejected by certify replay): ${trimmed_line}"
    fi
  done <<< "$receipt_block"
}

check_receipt_command_replayability() {
  local path="$1"
  local receipt_block
  receipt_block="$(extract_block "$path" '^### 3[.]4[.]5' '^## 3[.]5([.]|[[:space:]])')"
  if [[ -z "$receipt_block" ]]; then
    return 0
  fi
  check_receipt_block_replayability "$receipt_block" "Section 3.4.5 receipt command"
}

check_closeout_section_shape() {
  local path="$1"
  local closeout_block
  local compact_block
  local line
  local lowered

  closeout_block="$(awk '
    BEGIN { in_closeout=0 }
    /^##[[:space:]]*3[.]5([.]|[[:space:]])/ { in_closeout=1; next }
    in_closeout && /^### 3[.]5[.]1([.]|[[:space:]])/ { exit }
    in_closeout && /^##[[:space:]]*[0-9]+[.]/ { exit }
    in_closeout { print }
  ' "$path")"

  compact_block="$(printf '%s\n' "$closeout_block" | sed '/^[[:space:]]*$/d')"
  if [[ -z "$compact_block" ]]; then
    fail "§3.5 Closeout section is empty or missing"
    return
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    lowered="$(printf '%s' "$line" | tr '[:upper:]' '[:lower:]')"
    if [[ "$lowered" =~ route[[:space:]]+to[[:space:]]+[a-z] \
      || "$lowered" =~ hand[[:space:]]*off[[:space:]]+to \
      || "$lowered" =~ pass[[:space:]]+to[[:space:]]+[a-z] \
      || "$lowered" =~ send[[:space:]]+to[[:space:]]+[a-z] ]]; then
      fail "§3.5 contains non-canonical closeout routing phrase: ${line}"
      return
    fi
  done <<< "$closeout_block"
}

check_mandatory_receipt_commands() {
  local path="$1"
  local receipt_block

  receipt_block="$(extract_block "$path" '^### 3[.]4[.]5' '^## 3[.]5([.]|[[:space:]])')"
  if [[ -z "$receipt_block" ]]; then
    return 0
  fi

  local -a mandatory_commands=(
    "bash tools/lint/dp.sh TASK.md"
    "bash tools/lint/task.sh"
    "bash tools/lint/integrity.sh"
    "bash tools/lint/style.sh"
    "./ops/bin/llms"
    "git diff --name-only"
    "git diff --stat"
    "comm -23 <(git diff --name-only | sort) <(sort storage/dp/active/allowlist.txt) || true"
    "comm -23 <(git ls-files --others --exclude-standard | sort) <(sort storage/dp/active/allowlist.txt) || true"
    "./ops/bin/open"
  )

  local cmd
  for cmd in "${mandatory_commands[@]}"; do
    if ! printf '%s\n' "$receipt_block" | grep -Fq -- "- ${cmd}"; then
      fail "§3.4.5 mandatory receipt command missing: ${cmd}"
    fi
  done

  local integrity_count
  integrity_count="$(printf '%s\n' "$receipt_block" | grep -Fxc -- '- bash tools/lint/integrity.sh' || true)"
  if (( integrity_count < 2 )); then
    fail "§3.4.5 mandatory receipt command missing required second occurrence: bash tools/lint/integrity.sh"
  fi
}

check_sidecar_not_prepopulated() {
  local path="$1"
  local sidecar_block

  sidecar_block="$(awk '
    BEGIN { in_sidecar=0 }
    /^### 3[.]5[.]1([.]|[[:space:]])/ { in_sidecar=1; next }
    in_sidecar && /^##[[:space:]]*[0-9]+[.]/ { exit }
    in_sidecar { print }
  ' "$path")"

  if [[ -z "$sidecar_block" ]]; then
    return 0
  fi

  local -a sidecar_labels=(
    "Commit Message"
    "Create Pull Request (Title)"
    "Create Pull Request (Description)"
    "Confirm Merge (Commit Message)"
    "Confirm Merge (Extended Description)"
    "Confirm Merge (Add a Comment)"
  )

  local lbl
  local field_value
  for lbl in "${sidecar_labels[@]}"; do
    field_value="$(printf '%s\n' "$sidecar_block" | awk -v label="$lbl" '
      {
        line=$0
        gsub(/^[[:space:]]*-[[:space:]]*/, "", line)
        if (index(line, label ":") == 1) {
          sub("^" label ":[[:space:]]*", "", line)
          print line
          exit
        }
      }
    ')"
    field_value="$(trim "$field_value")"
    if [[ -n "$field_value" ]]; then
      fail "§3.5.1 closing-sidecar field pre-populated by architect (must be left blank): ${lbl}"
    fi
  done
}
check_dp_packet_coherence() {
  local path="$1"
  local heading
  local dp_id
  local work_branch
  local sidecar_path
  local sidecar_dp_id

  heading="$(grep -m1 -E '^### DP-' "$path" || true)"
  [[ -n "$heading" ]] || return
  dp_id="$(printf '%s' "$heading" | sed -E 's/^###[[:space:]]*(DP-[^:]+):.*$/\1/')"
  [[ "$dp_id" =~ ^DP-[A-Z]+-[0-9]{4,}$ ]] || return

  work_branch="$(trim "$(strip_backticks "$(extract_field_value "Work Branch" "$path")")")"
  if [[ -z "$work_branch" ]]; then
    work_branch="$(trim "$(strip_backticks "$(extract_field_value "Required Work Branch" "$path")")")"
  fi
  if [[ -n "$work_branch" ]] && ! contains_placeholder "$work_branch"; then
    if [[ ! "$work_branch" =~ ^work/[^[:space:]]+-[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      fail "Work Branch must follow 'work/<DP-ID>-YYYY-MM-DD' form (PoT.md §6.2.1): ${work_branch}"
    fi
  fi

  sidecar_path="$(grep -m1 -Eo 'storage/handoff/CLOSING\.md|storage/handoff/CLOSING-DP-[A-Z]+-[0-9]{4,}(-ADDENDUM-[A-Z]+)?\.md' "$path" || true)"
  if [[ -z "$sidecar_path" ]]; then
    fail "missing canonical closing-sidecar path in §3.5.1 (expected storage/handoff/CLOSING.md)"
    return
  fi

  if [[ "$sidecar_path" == "storage/handoff/CLOSING.md" ]]; then
    return
  fi

  sidecar_dp_id="$(printf '%s' "$sidecar_path" | sed -E 's#^storage/handoff/CLOSING-(DP-[A-Z]+-[0-9]{4,})(-ADDENDUM-[A-Z]+)?\.md$#\1#')"
  if [[ "$sidecar_dp_id" != "$dp_id" ]]; then
    fail "closing-sidecar DP id mismatch: heading uses '${dp_id}' but §3.5.1 uses '${sidecar_dp_id}'"
  fi
}

check_allowlist_pointer_integrity() {
  local path="$1"
  local allowlist_block
  local pointer_line
  local pointer_path
  local expected_pointer

  allowlist_block="$(extract_block "$path" '^Target Files allowlist [(]hard gate[)]:[[:space:]]*$' '^## 3[.]4([.]|[[:space:]])')"
  pointer_line="$(printf '%s\n' "$allowlist_block" | grep -E '^[[:space:]]*-[[:space:]]+' | head -n1 || true)"

  if [[ -z "$pointer_line" ]]; then
    fail "Target Files allowlist pointer entry missing"
    return
  fi

  if [[ "$(printf '%s\n' "$allowlist_block" | grep -Ec '^[[:space:]]*-[[:space:]]+' || true)" != "1" ]]; then
    fail "Target Files allowlist must contain exactly one pointer entry"
    return
  fi

  pointer_path="$(printf '%s' "$pointer_line" | sed -E 's/^[[:space:]]*-[[:space:]]+//')"
  pointer_path="$(trim "$(strip_backticks "$pointer_path")")"
  expected_pointer="$(allowlist_pointer_path)"

  if [[ "$pointer_path" != "$expected_pointer" ]]; then
    fail "Target Files allowlist pointer must be '${expected_pointer}'"
    return
  fi

  local pointer_fs_path="$pointer_path"
  if [[ "$pointer_fs_path" != /* ]]; then
    pointer_fs_path="${REPO_ROOT}/${pointer_fs_path}"
  fi

  if [[ ! -f "$pointer_fs_path" ]]; then
    fail "allowlist pointer file missing: ${pointer_path}"
    return
  fi

  local -a entries=()
  mapfile -t entries < <(awk 'NF { print }' "$pointer_fs_path")
  if (( ${#entries[@]} == 0 )); then
    fail "allowlist pointer file is empty: ${pointer_path}"
    return
  fi

  local entry
  local normalized
  for entry in "${entries[@]}"; do
    normalized="$(trim "$entry")"
    if [[ -z "$normalized" ]]; then
      continue
    fi

    if [[ "$normalized" == -* || "$normalized" == \** ]]; then
      fail "allowlist entry must be a plain path (no markdown bullets): ${normalized}"
      continue
    fi

    normalized="${normalized#./}"
    if [[ "$normalized" == /* ]]; then
      if [[ "$normalized" == "${REPO_ROOT}/"* ]]; then
        normalized="${normalized#${REPO_ROOT}/}"
      else
        fail "allowlist entry is outside repository root: ${entry}"
        continue
      fi
    fi

    case "$normalized" in
      storage/dp/intake/DP.md)
        ;;
      storage/dp/intake/DP-*.md|storage/dp/intake/*-ADDENDUM-*.md)
        ;;
      storage/handoff/CLOSING-*.md)
        ;;
      storage/handoff/*|storage/dumps/*|storage/dp/intake/*)
        fail "allowlist entry must be persistent repo state (runtime artifact prefix forbidden): ${normalized}"
        continue
        ;;
    esac

    if [[ "$normalized" == *"*"* || "$normalized" == *"?"* || "$normalized" == *"["* ]]; then
      case "$normalized" in
        .github/*|tools/*|ops/*|docs/*|storage/*|archives/*|logs/*)
          # Wildcard policy entries are allowed for generated artifact families.
          continue
          ;;
        *)
          fail "allowlist wildcard entry must use an approved repo-relative prefix: ${normalized}"
          continue
          ;;
      esac
    fi

    if [[ ! -e "${REPO_ROOT}/${normalized}" ]]; then
      # The active DP draft surface is disposable and gitignored; clean CI clones do
      # not materialize it until a draft run does. Allow the canonical allowlist
      # entry to exist without forcing presence on disk.
      if [[ "$normalized" == storage/dp/intake/DP.md ]]; then
        continue
      fi
      # Allow closing-sidecar allowlist entries even when the runtime file is absent
      # (for example in clean CI clones where storage/handoff is gitignored).
      if [[ "$normalized" == storage/handoff/CLOSING-*.md ]]; then
        continue
      fi
      # Allow legacy packet-scoped intake surfaces to remain in the allowlist before
      # current runtime commands materialize or supersede them.
      if [[ "$normalized" == storage/dp/intake/DP-*.md || "$normalized" == storage/dp/intake/*-ADDENDUM-*.md ]]; then
        continue
      fi
      # Allow deleted tracked files to stay in the allowlist while a DP is in-flight.
      # This keeps the hard gate satisfiable for deletion patches without masking typos.
      if path_is_deleted_tracked_in_active_diff "${normalized}"; then
        continue
      fi
      # Allow planned Phase 2 surface leaf targets that are generated by ops/bin/certify.
      if [[ "$normalized" =~ ^archives/surfaces/PoW-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$ \
        || "$normalized" =~ ^archives/surfaces/SoP-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$ \
        || "$normalized" =~ ^archives/surfaces/TASK-DP-[A-Z]+-[0-9]{4,}-[0-9a-f]{7,}\.md$ ]]; then
        continue
      fi
      fail "allowlist entry does not exist: ${normalized}"
    fi
  done
}

check_dump_selection_scope() {
  local path="$1"
  local receipt_block
  local line=""
  local trimmed_line=""
  local packet_header=""
  local packet_seq=""
  local enforce_hard_gate=0

  receipt_block="$(extract_block "$path" '^### 3[.]4[.]5' '^## 3[.]5([.]|[[:space:]])')"
  if [[ -z "$receipt_block" ]]; then
    return 0
  fi

  packet_header="$(grep -m1 -E '^###[[:space:]]+DP-[A-Z]+-[0-9]{4,}:' "$path" || true)"
  if [[ "$packet_header" =~ ^###[[:space:]]+DP-[A-Z]+-([0-9]{4,}): ]]; then
    packet_seq="${BASH_REMATCH[1]}"
    if (( 10#${packet_seq} >= 95 )); then
      enforce_hard_gate=1
    fi
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" != *"./ops/bin/dump"* && "$line" != *"ops/bin/dump"* ]]; then
      continue
    fi
    if [[ "$line" == *"--selection=dp"* || "$line" == *"--selection=dp+allowlist"* ]]; then
      continue
    fi
    trimmed_line="$(trim "$line")"
    if (( enforce_hard_gate )); then
      fail "dump invocation found without --selection=dp or --selection=dp+allowlist: \"${trimmed_line}\". Scoped selection is required for DP-authorized sessions."
    else
      echo "WARN: legacy packet grandfathered for dump selection scope enforcement: \"${trimmed_line}\". Packets DP-OPS-0095 and newer fail without --selection=dp or --selection=dp+allowlist."
    fi
  done <<< "$receipt_block"
}

check_proposed_token_scan() {
  local path="$1"
  local found=0
  local lineno=0
  local line=""
  local scrubbed=""
  while IFS= read -r line || [[ -n "$line" ]]; do
    lineno=$(( lineno + 1 ))
    scrubbed="$(printf '%s' "$line" | sed 's/PROPOSED_[A-Z][A-Z_]*/SCHEMA_ID/g')"
    if [[ "$scrubbed" == *PROPOSED* ]]; then
      echo "PROPOSED token at line ${lineno}: ${line}" >&2
      found=1
    fi
  done < "$path"
  if (( found )); then
    fail "PROPOSED is a drafting marker and must not appear in a finalized DP — remove it before worker execution"
  fi
}

check_foreign_citation_contamination() {
  local path="$1"
  local hit
  local line_number
  local line_text

  hit="$(awk '
    index($0, ":contentReference[") {
      printf "%d\t%s\n", NR, $0
      exit
    }
  ' "$path")"

  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    fail "dp: contamination: line ${line_number}: ${line_text}"
    return 1
  fi

  echo "PASS: dp: contamination: no foreign citation tokens detected"
  return 0
}

check_include_metadata_leakage() {
  local path="$1"
  local hit
  local line_number
  local line_text

  hit="$(awk '
    $0 ~ /^[[:space:]]*<!-- CCD:/ || $0 ~ /^[[:space:]]*---[[:space:]]*$/ {
      printf "%d\t%s\n", NR, $0
      exit
    }
  ' "$path")"

  if [[ -n "$hit" ]]; then
    IFS=$'\t' read -r line_number line_text <<< "$hit"
    fail "dp: include metadata leakage: line ${line_number}: ${line_text}"
    return 1
  fi

  echo "PASS: dp: include metadata leakage: no leaked include metadata detected"
  return 0
}

lint_payload() {
  local path="$1"
  failures=0

  check_proposed_token_scan "$path"
  check_foreign_citation_contamination "$path"
  check_include_metadata_leakage "$path"
  check_template_hash_preflight
  check_structure_hash "$path"
  check_required_fields "$path"
  check_allowlist_pointer_integrity "$path"
  check_dump_selection_scope "$path"
  check_freshness_stamp_format "$path"
  check_dp_packet_coherence "$path"
  check_receipt_command_replayability "$path"
  check_closeout_section_shape "$path"
  check_mandatory_receipt_commands "$path"
  check_sidecar_not_prepopulated "$path"

  if (( failures )); then
    return 1
  fi

  echo "OK: DP lint passed"
}

lint_path() {
  local path="$1"

  if [[ ! -f "$path" ]]; then
    fail "Missing file: $path"
    return 1
  fi

  local source_path="$path"
  if [[ "$(basename "$path")" == "TASK.md" ]]; then
    if ! source_path="$(resolve_task_surface_path "$path")"; then
      return 1
    fi
  fi

  if [[ "$(basename "$source_path")" == "RESULTS.md" || "$source_path" == *-RESULTS.md ]]; then
    bash tools/lint/results.sh "$source_path"
    return $?
  fi

  if [[ "$(basename "$source_path")" == "ADDENDUM.md" || "$(basename "$source_path")" =~ ^DP-OPS-[0-9]{4}-ADDENDUM-[A-Z]\.md$ ]]; then
    lint_addendum_intake "$source_path"
    return $?
  fi

  local payload_tmp
  payload_tmp="$(mktemp)"

  if ! extract_dp_payload "$source_path" "$payload_tmp"; then
    rm -f "$payload_tmp"
    return 1
  fi

  if ! lint_payload "$payload_tmp"; then
    rm -f "$payload_tmp"
    return 1
  fi

  rm -f "$payload_tmp"
}

render_fixture_from_template() {
  local out_path="$1"
  local allowlist_pointer="$2"
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

  dp_scoped_load_order='- tools/lint/dp.sh
- docs/ops/specs/tools/lint/dp.md'
  objective='- Validate template-hash flow for DP lint.'
  in_scope='- tools/lint/dp.sh'
  out_scope='- Unrelated repo refactors.'
  safety='- Keep deterministic outputs and pointer-first allowlist mode.'
  plan_state='- DP lint now validates structure through canonical template hashing.'
  plan_request='- Confirm template hash, structure hash, and required-field integrity checks.'
  plan_changelog='- Updated tools/lint/dp.sh
- Added ops/src/surfaces/dp.md.tpl'
  plan_patch='- Implemented structure hashing
- Added allowlist pointer integrity checks'
  receipt_extra='- ops/bin/manifest stance-fixture --out=-
- ./ops/bin/open --out=auto --dp="DP-OPS-0000"
- bash tools/lint/dp.sh TASK.md
- git diff --name-only
- git diff --stat'
  cbc_preflight='Not applicable. The fixture validates DP lint behavior and is not a DP that changes an enforcement surface.'

  template_source="$(mktemp)"
  render_canonical_template_non_strict "$template_source"

  : > "$out_path"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line//'{{DP_ID}}'/DP-OPS-0000}"
    line="${line//'{{DP_TITLE}}'/Fixture structure-hash lint coverage}"
    line="${line//'{{BASE_BRANCH}}'/main}"
    line="${line//'{{PROPOSED_WORK_BRANCH}}'/work/dp-ops-0000-2026-02-14}"
    line="${line//'{{BASE_HEAD}}'/d3801c3a}"
    line="${line//'{{FRESHNESS_STAMP}}'/2026-02-14}"

    case "$line" in
      "{{DP_SCOPED_LOAD_ORDER}}")
        printf '%s\n' "$dp_scoped_load_order" >> "$out_path"
        ;;
      "{{OBJECTIVE}}")
        printf '%s\n' "$objective" >> "$out_path"
        ;;
      "{{IN_SCOPE}}")
        printf '%s\n' "$in_scope" >> "$out_path"
        ;;
      "{{OUT_OF_SCOPE}}")
        printf '%s\n' "$out_scope" >> "$out_path"
        ;;
      "{{SAFETY_INVARIANTS}}")
        printf '%s\n' "$safety" >> "$out_path"
        ;;
      "{{PLAN_STATE}}")
        printf '%s\n' "$plan_state" >> "$out_path"
        ;;
      "{{PLAN_REQUEST}}")
        printf '%s\n' "$plan_request" >> "$out_path"
        ;;
      "{{PLAN_CHANGELOG}}")
        printf '%s\n' "$plan_changelog" >> "$out_path"
        ;;
      "{{PLAN_PATCH}}")
        printf '%s\n' "$plan_patch" >> "$out_path"
        ;;
      "{{RECEIPT_EXTRA}}")
        printf '%s\n' "$receipt_extra" >> "$out_path"
        ;;
      "{{CBC_PREFLIGHT}}")
        printf '%s\n' "$cbc_preflight" >> "$out_path"
        ;;
      "- storage/dp/active/allowlist.txt")
        printf '%s\n' "- ${allowlist_pointer}" >> "$out_path"
        ;;
      *)
        printf '%s\n' "$line" >> "$out_path"
        ;;
    esac
  done < "$template_source"

  rm -f "$template_source"
}

run_test() {
  local tmp_allowlist_valid
  local tmp_allowlist_bad
  local tmp_valid
  local tmp_structure_bad
  local tmp_pointer_bad
  local tmp_allowlist_file_bad
  local tmp_results_valid
  local tmp_results_invalid
  local tmp_results_preflight_invalid
  local tmp_proposed_marker_bad
  local tmp_proposed_prose_ok
  local tmp_proposed_schema_ok
  local tmp_contamination_bad
  local tmp_receipt_token_bad
  local tmp_ccd_bad
  local tmp_frontmatter_bad

  failures=0
  check_template_hash_preflight
  check_addendum_template_hash
  printf 'CANONICAL_DP_TEMPLATE_SHA256=%s\n' "$CANONICAL_DP_TEMPLATE_SHA256"
  printf 'CANONICAL_ADDENDUM_TEMPLATE_SHA256=%s\n' "$CANONICAL_ADDENDUM_TEMPLATE_SHA256"
  if (( failures )); then
    exit 1
  fi

  tmp_allowlist_valid="$(mktemp)"
  tmp_allowlist_bad="$(mktemp)"
  tmp_valid="$(mktemp)"
  tmp_structure_bad="$(mktemp)"
  tmp_pointer_bad="$(mktemp)"
  tmp_allowlist_file_bad="$(mktemp)"
  tmp_results_valid="$(mktemp --suffix=-RESULTS.md)"
  tmp_results_invalid="$(mktemp --suffix=-RESULTS.md)"
  tmp_proposed_marker_bad="$(mktemp)"
  tmp_proposed_prose_ok="$(mktemp)"
  tmp_proposed_schema_ok="$(mktemp)"
  tmp_contamination_bad="$(mktemp)"
  local current_git_hash
  current_git_hash="$(git rev-parse HEAD)"

  printf '%s\n' "tools/lint/dp.sh" > "$tmp_allowlist_valid"
  printf '%s\n' "path/that/does/not/exist.txt" > "$tmp_allowlist_bad"

  render_fixture_from_template "$tmp_valid" "$tmp_allowlist_valid"
  # Clean fixture (no provisional markers) must pass.
  DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_valid" >/dev/null

  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" DP_CANONICAL_TEMPLATE_SHA256_OVERRIDE="0000000000000000000000000000000000000000000000000000000000000000" lint_path "$tmp_valid" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected canonical template hash mismatch failure" >&2
    exit 1
  fi

  cp "$tmp_valid" "$tmp_structure_bad"
  sed -i 's/^## 3.4 Execution Plan (A-E)$/## 3.4 Execution Plan (BROKEN)/' "$tmp_structure_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_structure_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected DP structure hash mismatch failure" >&2
    exit 1
  fi

  tmp_closeout_bad="$(mktemp)"
  awk '
    /^### 3\.5\.1/ && !inserted {
      print "- Route to contractor for certification"
      inserted=1
    }
    { print }
  ' "$tmp_valid" > "$tmp_closeout_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_closeout_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad" "$tmp_closeout_bad"
    echo "FAIL: --test expected non-canonical closeout routing phrase failure" >&2
    exit 1
  fi
  rm -f "$tmp_closeout_bad"

  tmp_coherence_bad="$(mktemp)"
  cp "$tmp_valid" "$tmp_coherence_bad"
  sed -i 's#^Work Branch: .*#Work Branch: work/no-date-fragment#' "$tmp_coherence_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_coherence_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad" "$tmp_coherence_bad"
    echo "FAIL: --test expected packet-coherence work-branch form failure" >&2
    exit 1
  fi
  sed -i 's#storage/handoff/CLOSING.md#storage/handoff/CLOSING-DP-OPS-9999.md#g' "$tmp_coherence_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_coherence_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad" "$tmp_coherence_bad"
    echo "FAIL: --test expected packet-coherence sidecar mismatch failure" >&2
    exit 1
  fi
  rm -f "$tmp_coherence_bad"

  cp "$tmp_valid" "$tmp_proposed_schema_ok"
  printf '%s\n' '# The PROPOSED_WORK_BRANCH slot is a schema identifier.' >> "$tmp_proposed_schema_ok"
  failures=0
  check_proposed_token_scan "$tmp_proposed_schema_ok" >/dev/null 2>&1
  if (( failures )); then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected schema-identifier form to pass drafting-marker scan" >&2
    exit 1
  fi
  rm -f "$tmp_proposed_schema_ok"

  cp "$tmp_valid" "$tmp_pointer_bad"
  sed -i "s#^- ${tmp_allowlist_valid}\$#- storage/dp/active/not-canonical.txt#" "$tmp_pointer_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_pointer_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected allowlist pointer mismatch failure" >&2
    exit 1
  fi

  render_fixture_from_template "$tmp_allowlist_file_bad" "$tmp_allowlist_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_bad" lint_path "$tmp_allowlist_file_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected allowlist file validation failure" >&2
    exit 1
  fi

  cat > "$tmp_results_valid" <<TESTRESULTS
# DP-OPS-0099 RESULTS

## Certification Metadata
- Packet ID: DP-OPS-0099
- Git Hash: ${current_git_hash}

## Scope Verification
### Integrity Lint Output
PASS

## Verification Command Log
- bash tools/lint/dp.sh TASK.md

## Git State Impact
### git diff --name-only
tools/lint/dp.sh

### git diff --stat
 tools/lint/dp.sh | 1 +

## Contractor Execution Narrative
### Preflight State
~~~text
git rev-parse --abbrev-ref HEAD
work/dp-ops-0099-2026-01-01
git rev-parse --short HEAD
abcdef1
git status --porcelain
~~~
Preflight lints passed: bash tools/lint/dp.sh TASK.md; bash tools/lint/task.sh.

### Implemented Changes
Updated tools/lint/dp.sh to delegate RESULTS validation to tools/lint/results.sh.

### Closeout Notes
None.

### Decision Leaf
Decision Required: No
Decision Leaf: None
TESTRESULTS
  lint_path "$tmp_results_valid" >/dev/null

  cat > "$tmp_results_invalid" <<TESTRESULTS
# DP-OPS-0099 RESULTS

## Certification Metadata
- Packet ID: DP-OPS-0099
- Git Hash: ${current_git_hash}

## Scope Verification
### Integrity Lint Output
PASS

## Verification Command Log
- bash tools/lint/dp.sh TASK.md

## Git State Impact
### git diff --name-only
tools/lint/dp.sh

### git diff --stat
 tools/lint/dp.sh | 1 +

## Contractor Execution Narrative
### Preflight State
~~~text
git rev-parse --abbrev-ref HEAD
work/dp-ops-0099-2026-01-01
git rev-parse --short HEAD
abcdef1
git status --porcelain
~~~
Preflight lints passed: bash tools/lint/dp.sh TASK.md; bash tools/lint/task.sh.

### Implemented Changes
Updated tools/lint/dp.sh to delegate RESULTS validation to tools/lint/results.sh.

### Closeout Notes
None.

### Decision Leaf
Decision Required: No
TESTRESULTS
  if lint_path "$tmp_results_invalid" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected RESULTS validation failure" >&2
    exit 1
  fi

  tmp_results_preflight_invalid="$(mktemp --suffix=-RESULTS.md)"
  cat > "$tmp_results_preflight_invalid" <<TESTRESULTS
# DP-OPS-0099 RESULTS

## Certification Metadata
- Packet ID: DP-OPS-0099
- Git Hash: ${current_git_hash}

## Scope Verification
### Integrity Lint Output
PASS

## Verification Command Log
- bash tools/lint/dp.sh TASK.md

## Git State Impact
### git diff --name-only
tools/lint/dp.sh

### git diff --stat
 tools/lint/dp.sh | 1 +

## Contractor Execution Narrative
### Preflight State
~~~text
git rev-parse --abbrev-ref HEAD
work/dp-ops-0099-2026-01-01
git rev-parse --short HEAD
abcdef1
~~~
Preflight lints passed: bash tools/lint/dp.sh TASK.md; bash tools/lint/task.sh.

### Implemented Changes
Updated tools/lint/dp.sh to delegate RESULTS validation to tools/lint/results.sh.

### Closeout Notes
None.

### Decision Leaf
Decision Required: No
Decision Leaf: None
TESTRESULTS
  if lint_path "$tmp_results_preflight_invalid" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_results_preflight_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected RESULTS preflight-proof validation failure" >&2
    exit 1
  fi

  # Disallowed provisional-marker form must fail.
  cp "$tmp_valid" "$tmp_proposed_marker_bad"
  sed -i 's#^Work Branch: .*#Work Branch: PROPOSED-work/dp-ops-0000-2026-02-14#' "$tmp_proposed_marker_bad"
  failures=0
  # Expected-negative self-check: suppress emitted FAIL lines from the detector so
  # successful --test runs do not contain contradictory FAIL/OK receipt evidence.
  check_proposed_token_scan "$tmp_proposed_marker_bad" >/dev/null 2>&1
  if (( failures == 0 )); then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected direct PROPOSED provisional-marker scan failure" >&2
    exit 1
  fi
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_proposed_marker_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected PROPOSED provisional-marker scan failure" >&2
    exit 1
  fi

  # Prose containing the word PROPOSED must also fail — the word is forbidden anywhere in a finalized DP.
  cp "$tmp_valid" "$tmp_proposed_prose_ok"
  sed -i 's/^-\s*Validate template-hash flow for DP lint\.$/- This lint validates removal of PROPOSED drafting markers./' "$tmp_proposed_prose_ok"
  failures=0
  check_proposed_token_scan "$tmp_proposed_prose_ok" >/dev/null 2>&1
  if (( failures == 0 )); then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected prose-only PROPOSED scan failure" >&2
    exit 1
  fi
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_proposed_prose_ok" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected prose-only PROPOSED lint failure" >&2
    exit 1
  fi

  cp "$tmp_valid" "$tmp_contamination_bad"
  printf '%s\n' ':contentReference[oaicite:0]{index=0}' >> "$tmp_contamination_bad"
  failures=0
  # Expected-negative self-check: suppress emitted FAIL line from the detector.
  check_foreign_citation_contamination "$tmp_contamination_bad" >/dev/null 2>&1 || true
  if (( failures == 0 )); then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected direct contamination scan failure" >&2
    exit 1
  fi
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_contamination_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected contamination lint failure" >&2
    exit 1
  fi

  failures=0
  check_foreign_citation_contamination "$tmp_valid" >/dev/null
  if (( failures )); then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected direct contamination scan clean pass" >&2
    exit 1
  fi

  tmp_ccd_bad="$(mktemp)"
  cp "$tmp_valid" "$tmp_ccd_bad"
  printf '%s\n' '<!-- CCD: ff_target="test" ff_band="10-20" -->' >> "$tmp_ccd_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_ccd_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad" "$tmp_ccd_bad"
    echo "FAIL: --test expected CCD metadata leakage failure" >&2
    exit 1
  fi
  rm -f "$tmp_ccd_bad"

  tmp_frontmatter_bad="$(mktemp)"
  cp "$tmp_valid" "$tmp_frontmatter_bad"
  printf '%s\n' '---' >> "$tmp_frontmatter_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_frontmatter_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad" "$tmp_frontmatter_bad"
    echo "FAIL: --test expected frontmatter delimiter leakage failure" >&2
    exit 1
  fi
  rm -f "$tmp_frontmatter_bad"

  tmp_receipt_missing_bad="$(mktemp)"
  cp "$tmp_valid" "$tmp_receipt_missing_bad"
  sed -i '/^- bash tools\/lint\/integrity\.sh$/d' "$tmp_receipt_missing_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_receipt_missing_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad" "$tmp_receipt_missing_bad"
    echo "FAIL: --test expected missing mandatory receipt command failure" >&2
    exit 1
  fi
  rm -f "$tmp_receipt_missing_bad"

  tmp_receipt_token_bad="$(mktemp)"
  cp "$tmp_valid" "$tmp_receipt_token_bad"
  sed -i 's#^- ops/bin/manifest stance-fixture --out=-$#- python tools/example.py#' "$tmp_receipt_token_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_receipt_token_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_results_preflight_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad" "$tmp_receipt_token_bad"
    echo "FAIL: --test expected unsupported receipt first-token failure" >&2
    exit 1
  fi
  rm -f "$tmp_receipt_token_bad"

  tmp_sidecar_prepop_bad="$(mktemp)"
  cp "$tmp_valid" "$tmp_sidecar_prepop_bad"
  sed -i 's/^- Commit Message$/- Commit Message: feat: prefilled/' "$tmp_sidecar_prepop_bad"
  if DP_ALLOWLIST_POINTER_OVERRIDE="$tmp_allowlist_valid" lint_path "$tmp_sidecar_prepop_bad" >/dev/null 2>&1; then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad" "$tmp_sidecar_prepop_bad"
    echo "FAIL: --test expected sidecar pre-population failure" >&2
    exit 1
  fi
  rm -f "$tmp_sidecar_prepop_bad"

  failures=0
  check_mandatory_receipt_commands "$tmp_valid"
  check_sidecar_not_prepopulated "$tmp_valid"
  if (( failures )); then
    rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
    echo "FAIL: --test expected canonical pass through mandatory receipt and sidecar checks" >&2
    exit 1
  fi

  rm -f "$tmp_allowlist_valid" "$tmp_allowlist_bad" "$tmp_valid" "$tmp_structure_bad" "$tmp_pointer_bad" "$tmp_allowlist_file_bad" "$tmp_results_valid" "$tmp_results_invalid" "$tmp_results_preflight_invalid" "$tmp_proposed_marker_bad" "$tmp_proposed_prose_ok" "$tmp_proposed_schema_ok" "$tmp_contamination_bad"
  echo "OK: --test passed"
}

declare -a FILTERED_ARGS=()
while (( $# > 0 )); do
  case "$1" in
    --selection=*)
      shift
      ;;
    --selection)
      if (( $# < 2 )); then
        usage >&2
        fail "Missing value for --selection"
        exit 1
      fi
      shift 2
      ;;
    --dump-dir=*)
      shift
      ;;
    --dump-dir)
      if (( $# < 2 )); then
        usage >&2
        fail "Missing value for --dump-dir"
        exit 1
      fi
      shift 2
      ;;
    *)
      FILTERED_ARGS+=("$1")
      shift
      ;;
  esac
done

set -- "${FILTERED_ARGS[@]}"

if (( $# > 1 )); then
  usage >&2
  fail "Too many arguments"
  exit 1
fi

case "${1:-}" in
  --test)
    run_test
    exit 0
    ;;
  "")
    tmp_stdin="$(mktemp)"
    cat > "$tmp_stdin"
    if [[ -s "$tmp_stdin" ]]; then
      lint_path "$tmp_stdin"
      rm -f "$tmp_stdin"
      exit $?
    fi
    rm -f "$tmp_stdin"
    if [[ -f "TASK.md" ]]; then
      lint_path "TASK.md"
      exit $?
    fi
    usage >&2
    fail "No input provided"
    exit 1
    ;;
  -)
    tmp_stdin="$(mktemp)"
    cat > "$tmp_stdin"
    lint_path "$tmp_stdin"
    rm -f "$tmp_stdin"
    ;;
  *)
    lint_path "$1"
    ;;
esac
