#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

usage() {
  cat <<'USAGE'
Usage: tools/lint/results.sh [--all|path]
USAGE
}

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

extract_field_block() {
  local path="$1"
  local start_pattern="$2"
  local stop_regex="$3"
  awk -v start_regex="$start_pattern" -v stop_regex="$stop_regex" '
    BEGIN { in_block=0 }
    $0 ~ start_regex { in_block=1; next }
    in_block && stop_regex != "" && $0 ~ stop_regex { exit }
    in_block { print }
  ' "$path"
}

has_nonempty_content() {
  local value="$1"
  [[ -n "$(printf '%s\n' "$value" | sed '/^[[:space:]]*$/d')" ]]
}

extract_field_block_by_label() {
  local path="$1"
  local start_label="$2"
  local stop_label="${3:-}"
  awk -v start_label="$start_label" -v stop_label="$stop_label" '
    BEGIN { in_block=0 }
    $0 == start_label { in_block=1; next }
    in_block && stop_label != "" && $0 == stop_label { exit }
    in_block { print }
  ' "$path"
}

CLOSING_LABELS_MANIFEST_PATH="ops/lib/manifests/CLOSING.md"
declare -a CURRENT_CLOSING_LABELS=()

load_current_closing_labels() {
  [[ -f "$CLOSING_LABELS_MANIFEST_PATH" ]] || die "closing labels manifest missing: ${CLOSING_LABELS_MANIFEST_PATH}"
  if ! grep -Eq '^##[[:space:]]+Section 1:[[:space:]]+Current Closeout Labels[[:space:]]*$' "$CLOSING_LABELS_MANIFEST_PATH"; then
    die "closing labels manifest missing required SSOT section heading"
  fi

  mapfile -t CURRENT_CLOSING_LABELS < <(
    awk '
      /^##[[:space:]]+Section 1:[[:space:]]+Current Closeout Labels[[:space:]]*$/ { in_section=1; next }
      in_section && /^##[[:space:]]+/ { exit }
      in_section && /[^[:space:]]/ { print }
    ' "$CLOSING_LABELS_MANIFEST_PATH"
  )

  if [[ "${#CURRENT_CLOSING_LABELS[@]}" -ne 6 ]]; then
    die "closing labels manifest must define exactly six current labels (found ${#CURRENT_CLOSING_LABELS[@]})"
  fi
}

RESULTS_TEMPLATE_PATH="ops/src/surfaces/results.md.tpl"
RESULTS_TEMPLATE_SHA256="b50fb633128d2806c675e52d2e026005d7129557acf47daa3b38f764d258a6dc"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  die "Must be run inside a git repository."
fi

cd "$REPO_ROOT" || exit 1
trap 'emit_binary_leaf "lint-results" "finish"' EXIT
emit_binary_leaf "lint-results" "start"

if [[ "$#" -gt 1 ]]; then
  usage >&2
  exit 1
fi

if [[ ! -f "$RESULTS_TEMPLATE_PATH" ]]; then
  die "RESULTS template missing: ${RESULTS_TEMPLATE_PATH}"
fi

template_hash="$(sha256_file "$RESULTS_TEMPLATE_PATH")"
if [[ -z "$template_hash" ]]; then
  die "failed to compute sha256 for ${RESULTS_TEMPLATE_PATH}"
fi
if [[ "$template_hash" != "$RESULTS_TEMPLATE_SHA256" ]]; then
  die "template drift detected for ${RESULTS_TEMPLATE_PATH} (expected ${RESULTS_TEMPLATE_SHA256}, got ${template_hash})"
fi

load_current_closing_labels

declare -a targets=()
explicit_target=0
scan_all=0
inferred_target=0

branch_name="$(git rev-parse --abbrev-ref HEAD)"
active_dp_id=""
if [[ "$branch_name" =~ ^work/(dp-[a-z0-9]+-[0-9]{4,})-[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  active_dp_id="$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')"
fi

if [[ "$#" -eq 1 ]]; then
  if [[ "$1" == "--all" ]]; then
    scan_all=1
  else
    target="$1"
    if [[ "$target" != /* ]]; then
      target="${REPO_ROOT}/${target}"
    fi
    targets+=("$target")
    explicit_target=1
  fi
fi

if (( scan_all )); then
  while IFS= read -r path; do
    targets+=("$path")
  done < <(find "${REPO_ROOT}/storage/handoff" -maxdepth 1 -type f -name 'DP-OPS-*-RESULTS.md' | sort)
elif (( explicit_target == 0 )); then
  if [[ -n "$active_dp_id" ]]; then
    active_target="${REPO_ROOT}/storage/handoff/${active_dp_id}-RESULTS.md"
    if [[ -f "$active_target" ]]; then
      targets+=("$active_target")
      inferred_target=1
    fi
  fi

  if (( inferred_target == 0 )); then
    mapfile -t discovered_targets < <(find "${REPO_ROOT}/storage/handoff" -maxdepth 1 -type f -name 'DP-OPS-*-RESULTS.md' | sort)
    if [[ "${#discovered_targets[@]}" -eq 1 ]]; then
      targets+=("${discovered_targets[0]}")
      inferred_target=1
    elif [[ "${#discovered_targets[@]}" -gt 1 ]]; then
      die "multiple RESULTS receipts detected; pass an explicit path or --all"
    fi
  fi
fi

if [[ "${#targets[@]}" -eq 0 ]]; then
  echo "OK: no RESULTS receipts found under storage/handoff/"
  exit 0
fi

required_headings=(
  "^## Certification Metadata$"
  "^## Scope Verification$"
  "^### Integrity Lint Output$"
  "^## Verification Command Log$"
  "^## Git State Impact$"
  "^### git diff --name-only$"
  "^### git diff --stat$"
  "^## Contractor Execution Narrative$"
  "^## Mandatory Closing Block$"
)

placeholder_regex='{{|}}|TBD|TODO|PLACEHOLDER|ENTER_|REPLACE_|populate during execution|do not pre-fill|DP-XXXX'
unresolved_artifact_marker_regex='<PORCELAIN_ARTIFACT>|<SESSION_ARTIFACT>|<DUMP_ARTIFACT>|<[^>]*ARTIFACT[^>]*>'
forbidden_disposable_regex='Local artifacts|Disposable artifact policy|storage/handoff/OPEN-|storage/handoff/OPEN-PORCELAIN-|storage/handoff/\*|storage/dumps/dump-|storage/dumps/\*|OPEN-work-dp-ops-[0-9]+|OPEN-PORCELAIN-work-dp-ops-[0-9]+|dump-platform-work-dp-ops-[0-9]+'

failures=0
checked=0
hash_parity_skips=0

for target in "${targets[@]}"; do
  if [[ ! -f "$target" ]]; then
    fail "RESULTS file missing: ${target#${REPO_ROOT}/}"
    continue
  fi

  rel_target="${target#${REPO_ROOT}/}"

  if ! grep -Eq '^## Certification Metadata$' "$target"; then
    if (( explicit_target || inferred_target )); then
      fail "${rel_target}: not a certification RESULTS receipt (missing '## Certification Metadata')"
    else
      echo "SKIP: non-certification RESULTS format: ${rel_target}"
    fi
    continue
  fi

  checked=$((checked + 1))

  heading_pattern=""
  for heading_pattern in "${required_headings[@]}"; do
    if ! grep -Eq "$heading_pattern" "$target"; then
      fail "${rel_target}: missing required heading matching ${heading_pattern}"
    fi
  done

  narrative_required_subheadings=(
    "^### Preflight State$"
    "^### Implemented Changes$"
    "^### Closeout Notes$"
    "^### Decision Leaf$"
  )
  subheading_pattern=""
  for subheading_pattern in "${narrative_required_subheadings[@]}"; do
    if ! grep -Eq "$subheading_pattern" "$target"; then
      fail "${rel_target}: missing required narrative subheading matching ${subheading_pattern}"
    fi
  done

  narrative_block="$(extract_field_block "$target" '^## Contractor Execution Narrative[[:space:]]*$' '^## Mandatory Closing Block[[:space:]]*$')"
  if ! grep -Eq '^Decision Required:' <<< "$narrative_block"; then
    fail "${rel_target}: Contractor Execution Narrative Decision Leaf subsection missing 'Decision Required:' line"
  fi
  if ! grep -Eq '^Decision Leaf:' <<< "$narrative_block"; then
    fail "${rel_target}: Contractor Execution Narrative Decision Leaf subsection missing 'Decision Leaf:' line"
  fi

  if grep -Eiq "$forbidden_disposable_regex" "$target"; then
    fail "${rel_target}: contains forbidden disposable-artifact references"
  fi

  if grep -Eiq "$unresolved_artifact_marker_regex" "$target"; then
    fail "${rel_target}: contains unresolved artifact placeholder markers"
  fi

  recorded_hash="$(awk '
    /^-[[:space:]]*Git Hash:[[:space:]]*/ {
      value=$0
      sub(/^[^:]*:[[:space:]]*/, "", value)
      print value
      exit
    }
  ' "$target")"
  recorded_hash="$(trim "$recorded_hash")"
  if [[ -z "$recorded_hash" ]]; then
    fail "${rel_target}: missing Git Hash value"
  else
    current_hash="$(git rev-parse HEAD)"
    if [[ "$recorded_hash" != "$current_hash" ]]; then
      if (( explicit_target )); then
        fail "${rel_target}: Git Hash mismatch (receipt ${recorded_hash}, repo ${current_hash})"
      else
        hash_parity_skips=$((hash_parity_skips + 1))
      fi
    fi
  fi

  closing_block="$(extract_field_block "$target" '^## Mandatory Closing Block[[:space:]]*$' '')"
  if ! has_nonempty_content "$closing_block"; then
    fail "${rel_target}: Mandatory Closing Block is empty"
    continue
  fi

  label=""
  for label in "${CURRENT_CLOSING_LABELS[@]}"; do
    if ! grep -Fxq "$label" <<< "$closing_block"; then
      fail "${rel_target}: closing block missing label '${label}'"
    fi
  done

  if grep -Eiq "$placeholder_regex" <<< "$closing_block"; then
    fail "${rel_target}: closing block contains placeholder text"
  fi

  for ((i=0; i<${#CURRENT_CLOSING_LABELS[@]}; i++)); do
    label="${CURRENT_CLOSING_LABELS[i]}"
    next_label=""
    if (( i + 1 < ${#CURRENT_CLOSING_LABELS[@]} )); then
      next_label="${CURRENT_CLOSING_LABELS[i+1]}"
    fi
    strict_value="$(
      extract_field_block_by_label "$target" "$label" "$next_label"
    )"
    if ! has_nonempty_content "$strict_value"; then
      fail "${rel_target}: ${label} value is empty"
    fi
  done
done

if (( failures )); then
  exit 1
fi

if [[ "$checked" -eq 0 ]]; then
  echo "OK: no certifiable RESULTS receipts found."
  exit 0
fi

if (( hash_parity_skips > 0 )); then
  echo "NOTE: skipped Git Hash parity for ${hash_parity_skips} clean historical receipt(s); pass an explicit path to enforce."
fi

echo "OK: RESULTS lint passed (${checked} file(s) checked)."
