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

normalize_field_value() {
  local value="$1"
  value="$(trim "$value")"
  value="${value#\`}"
  value="${value%\`}"
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

RESULTS_TEMPLATE_PATH="ops/src/surfaces/results.md.tpl"
RESULTS_TEMPLATE_SHA256="744366096d84794478c973310c80e7e667a74d186c5e632d6953cf71a15ddc7f"

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
  if [[ -f "${REPO_ROOT}/storage/handoff/RESULTS.md" ]]; then
    targets+=("${REPO_ROOT}/storage/handoff/RESULTS.md")
  fi
  while IFS= read -r path; do
    targets+=("$path")
  done < <(find "${REPO_ROOT}/storage/handoff" -maxdepth 1 -type f -name 'DP-OPS-*-RESULTS*.md' | sort)
elif (( explicit_target == 0 )); then
  active_target="${REPO_ROOT}/storage/handoff/RESULTS.md"
  if [[ -f "$active_target" ]]; then
    targets+=("$active_target")
    inferred_target=1
  fi

  if (( inferred_target == 0 )); then
    mapfile -t discovered_targets < <(find "${REPO_ROOT}/storage/handoff" -maxdepth 1 -type f \( -name 'RESULTS.md' -o -name 'DP-OPS-*-RESULTS*.md' \) | sort)
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
  "^## Worker Execution Narrative$"
)

unresolved_artifact_marker_regex='<PORCELAIN_ARTIFACT>|<SESSION_ARTIFACT>|<DUMP_ARTIFACT>|<[^>]*ARTIFACT[^>]*>'
forbidden_disposable_regex='Local artifacts:|Disposable artifact policy|storage/handoff/OPEN-|storage/handoff/OPEN-PORCELAIN-|storage/handoff/\*|storage/dumps/dump-|storage/dumps/\*|OPEN-work-dp-ops-[0-9]+|OPEN-PORCELAIN-work-dp-ops-[0-9]+|dump-platform-work-dp-ops-[0-9]+'
narrative_scaffold_lines=(
  "Paste the verbatim outputs of git rev-parse --abbrev-ref HEAD, git rev-parse --short HEAD, and git status --porcelain captured before any work-branch edits began, then add a short preflight lint status summary."
  "Describe each change made: what was modified, created, or removed, and why."
  "Describe any anomalies, open items, or residue. State None. if all items are resolved."
  "Decision Required: Yes|No"
  "Decision Leaf: archives/decisions/... or None"
)
required_preflight_commands=(
  "git rev-parse --abbrev-ref HEAD"
  "git rev-parse --short HEAD"
  "git status --porcelain"
)
absolute_filesystem_path_regex='(^|[^[:alnum:]_.-])/[[:alnum:]_.-]+(/[[:alnum:]_.-]+)+'
clickable_markdown_link_regex='\[[^][]+\]\([^)]*\)'
fused_fence_heading_regex='^(~~~|```)###[[:space:]]'

failures=0
checked=0
hash_parity_skips=0
narrative_scaffold_skips=0
narrative_path_hygiene_skips=0
decision_coherence_skips=0
preflight_proof_skips=0
command_log_fence_skips=0

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

  command_log_block="$(extract_field_block "$target" '^## Verification Command Log[[:space:]]*$' '^## Git State Impact[[:space:]]*$')"
  command_log_fence_error=""
  if grep -Eq "$fused_fence_heading_regex" <<< "$command_log_block"; then
    command_log_fence_error="Verification Command Log contains a fused fence/heading boundary; command headings must start on their own line"
  fi
  if [[ -n "$command_log_fence_error" ]]; then
    if (( explicit_target || inferred_target )); then
      fail "${rel_target}: ${command_log_fence_error}"
    else
      command_log_fence_skips=$((command_log_fence_skips + 1))
    fi
  fi

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

  narrative_block="$(extract_field_block "$target" '^## Worker Execution Narrative[[:space:]]*$' '')"
  scaffold_line_detected=0
  scaffold_line=""
  for scaffold_line in "${narrative_scaffold_lines[@]}"; do
    if grep -Fqx "$scaffold_line" <<< "$narrative_block"; then
      scaffold_line_detected=1
      break
    fi
  done
  if (( scaffold_line_detected == 1 )); then
    if (( explicit_target || inferred_target )); then
      fail "${rel_target}: Worker Execution Narrative contains untouched scaffold instruction prose"
    else
      narrative_scaffold_skips=$((narrative_scaffold_skips + 1))
    fi
  fi

  preflight_block="$(extract_field_block "$target" '^### Preflight State[[:space:]]*$' '^### Implemented Changes[[:space:]]*$')"
  preflight_proof_error=""
  if [[ -z "$(printf '%s\n' "$preflight_block" | sed '/^[[:space:]]*$/d')" ]]; then
    preflight_proof_error="Worker Execution Narrative Preflight State subsection is empty"
  else
    required_preflight_command=""
    for required_preflight_command in "${required_preflight_commands[@]}"; do
      if ! grep -Fq -- "$required_preflight_command" <<< "$preflight_block"; then
        preflight_proof_error="Worker Execution Narrative Preflight State missing required execution-start command output: ${required_preflight_command}"
        break
      fi
    done
  fi
  if [[ -n "$preflight_proof_error" ]]; then
    if (( explicit_target || inferred_target )); then
      fail "${rel_target}: ${preflight_proof_error}"
    else
      preflight_proof_skips=$((preflight_proof_skips + 1))
    fi
  fi

  narrative_path_hygiene_error=""
  clickable_link_match="$(grep -En "$clickable_markdown_link_regex" <<< "$narrative_block" | head -n 1 || true)"
  if [[ -n "$clickable_link_match" ]]; then
    narrative_path_hygiene_error="Worker Execution Narrative contains clickable markdown links; use plain repo-relative path text only"
  else
    absolute_path_match="$(grep -En "$absolute_filesystem_path_regex" <<< "$narrative_block" | head -n 1 || true)"
    if [[ -n "$absolute_path_match" ]]; then
      narrative_path_hygiene_error="Worker Execution Narrative contains an absolute filesystem path; use repo-relative path text only"
    fi
  fi
  if [[ -n "$narrative_path_hygiene_error" ]]; then
    if (( explicit_target || inferred_target )); then
      fail "${rel_target}: ${narrative_path_hygiene_error}"
    else
      narrative_path_hygiene_skips=$((narrative_path_hygiene_skips + 1))
    fi
  fi

  if ! grep -Eq '^Decision Required:' <<< "$narrative_block"; then
    fail "${rel_target}: Worker Execution Narrative Decision Leaf subsection missing 'Decision Required:' line"
  fi
  if ! grep -Eq '^Decision Leaf:' <<< "$narrative_block"; then
    fail "${rel_target}: Worker Execution Narrative Decision Leaf subsection missing 'Decision Leaf:' line"
  fi

  decision_required_line="$(grep -E '^Decision Required:' <<< "$narrative_block" | head -n 1 || true)"
  decision_leaf_line="$(grep -E '^Decision Leaf:' <<< "$narrative_block" | head -n 1 || true)"
  decision_required_value="$(normalize_field_value "${decision_required_line#Decision Required:}")"
  decision_leaf_value="$(normalize_field_value "${decision_leaf_line#Decision Leaf:}")"
  decision_coherence_error=""
  case "$decision_required_value" in
    Yes)
      if [[ ! "$decision_leaf_value" =~ ^archives/decisions/RoR-[A-Za-z0-9._-]+\.md$ ]]; then
        decision_coherence_error="Decision Required is 'Yes' but Decision Leaf is not a valid RoR path"
      fi
      ;;
    No)
      if [[ "$decision_leaf_value" != "None" ]]; then
        decision_coherence_error="Decision Required is 'No' but Decision Leaf is not 'None'"
      fi
      ;;
    *)
      decision_coherence_error="Decision Required value must be exactly 'Yes' or 'No'"
      ;;
  esac

  if [[ -n "$decision_coherence_error" ]]; then
    if (( explicit_target || inferred_target )); then
      fail "${rel_target}: ${decision_coherence_error} (found Decision Required='${decision_required_value}', Decision Leaf='${decision_leaf_value}')"
    else
      decision_coherence_skips=$((decision_coherence_skips + 1))
    fi
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
if (( narrative_scaffold_skips > 0 )); then
  echo "NOTE: skipped scaffold-prose enforcement for ${narrative_scaffold_skips} historical receipt(s); pass an explicit path to enforce."
fi
if (( narrative_path_hygiene_skips > 0 )); then
  echo "NOTE: skipped narrative path-hygiene enforcement for ${narrative_path_hygiene_skips} historical receipt(s); pass an explicit path to enforce."
fi
if (( decision_coherence_skips > 0 )); then
  echo "NOTE: skipped Decision Required/Decision Leaf coherence enforcement for ${decision_coherence_skips} historical receipt(s); pass an explicit path to enforce."
fi
if (( preflight_proof_skips > 0 )); then
  echo "NOTE: skipped strict Preflight State execution-start proof enforcement for ${preflight_proof_skips} historical receipt(s); pass an explicit path to enforce."
fi
if (( command_log_fence_skips > 0 )); then
  echo "NOTE: skipped strict command-log fence-integrity enforcement for ${command_log_fence_skips} historical receipt(s); pass an explicit path to enforce."
fi

echo "OK: RESULTS lint passed (${checked} file(s) checked)."
