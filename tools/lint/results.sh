#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/lint/results.sh [path]
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
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

RESULTS_TEMPLATE_PATH="ops/src/surfaces/results.md.tpl"
RESULTS_TEMPLATE_SHA256="6365ca6aeab1880f7f0b42b0412e9dd3e325263aed1dadee1679a5f6d64c2e8f"

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
if [[ "$#" -eq 1 ]]; then
  target="$1"
  if [[ "$target" != /* ]]; then
    target="${REPO_ROOT}/${target}"
  fi
  targets+=("$target")
  explicit_target=1
else
  while IFS= read -r path; do
    targets+=("$path")
  done < <(find "${REPO_ROOT}/storage/handoff" -maxdepth 1 -type f -name 'DP-OPS-*-RESULTS.md' | sort)
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
  "^## Mandatory Closing Block$"
)

required_closing_labels=(
  "^Primary Commit Header [(]plaintext[)][[:space:]]*$"
  "^Pull Request Title [(]plaintext[)][[:space:]]*$"
  "^Pull Request Description [(]markdown[)][[:space:]]*$"
  "^Final Squash Stub [(]plaintext[)]( [(]Must differ from #1[)]| [(]must differ from Primary Commit Header[)])?[[:space:]]*$"
  "^Extended Technical Manifest [(]plaintext[)][[:space:]]*$"
  "^Review Conversation Starter [(]markdown[)][[:space:]]*$"
)

placeholder_regex='{{|}}|TBD|TODO|PLACEHOLDER|ENTER_|REPLACE_|populate during execution|do not pre-fill|DP-XXXX'
unresolved_artifact_marker_regex='<PORCELAIN_ARTIFACT>|<SESSION_ARTIFACT>|<DUMP_ARTIFACT>|<[^>]*ARTIFACT[^>]*>'
forbidden_disposable_regex='Local artifacts|Disposable artifact policy|storage/handoff/OPEN-|storage/handoff/OPEN-PORCELAIN-|storage/handoff/\*|storage/dumps/dump-|storage/dumps/\*|OPEN-work-dp-ops-[0-9]+|OPEN-PORCELAIN-work-dp-ops-[0-9]+|dump-platform-work-dp-ops-[0-9]+'

failures=0
checked=0

for target in "${targets[@]}"; do
  if [[ ! -f "$target" ]]; then
    fail "RESULTS file missing: ${target#${REPO_ROOT}/}"
    continue
  fi

  rel_target="${target#${REPO_ROOT}/}"

  if ! grep -Eq '^## Certification Metadata$' "$target"; then
    if (( explicit_target )); then
      fail "${rel_target}: not a certification RESULTS receipt (missing '## Certification Metadata')"
    else
      echo "SKIP: legacy RESULTS format: ${rel_target}"
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
      fail "${rel_target}: Git Hash mismatch (receipt ${recorded_hash}, repo ${current_hash})"
    fi
  fi

  closing_block="$(extract_field_block "$target" '^## Mandatory Closing Block[[:space:]]*$' '')"
  if ! has_nonempty_content "$closing_block"; then
    fail "${rel_target}: Mandatory Closing Block is empty"
    continue
  fi

  label_pattern=""
  for label_pattern in "${required_closing_labels[@]}"; do
    if ! grep -Eq "$label_pattern" <<< "$closing_block"; then
      fail "${rel_target}: closing block missing label matching ${label_pattern}"
    fi
  done

  if grep -Eiq "$placeholder_regex" <<< "$closing_block"; then
    fail "${rel_target}: closing block contains placeholder text"
  fi

  strict_value="$(
    extract_field_block "$target" '^Primary Commit Header [(]plaintext[)][[:space:]]*$' '^Pull Request Title [(]plaintext[)][[:space:]]*$'
  )"
  if ! has_nonempty_content "$strict_value"; then
    fail "${rel_target}: Primary Commit Header value is empty"
  fi

  strict_value="$(
    extract_field_block "$target" '^Pull Request Title [(]plaintext[)][[:space:]]*$' '^Pull Request Description [(]markdown[)][[:space:]]*$'
  )"
  if ! has_nonempty_content "$strict_value"; then
    fail "${rel_target}: Pull Request Title value is empty"
  fi

  strict_value="$(
    extract_field_block "$target" '^Final Squash Stub [(]plaintext[)]( [(]Must differ from #1[)]| [(]must differ from Primary Commit Header[)])?[[:space:]]*$' '^Extended Technical Manifest [(]plaintext[)][[:space:]]*$'
  )"
  if ! has_nonempty_content "$strict_value"; then
    fail "${rel_target}: Final Squash Stub value is empty"
  fi

  strict_value="$(
    extract_field_block "$target" '^Extended Technical Manifest [(]plaintext[)][[:space:]]*$' '^Review Conversation Starter [(]markdown[)][[:space:]]*$'
  )"
  if ! has_nonempty_content "$strict_value"; then
    fail "${rel_target}: Extended Technical Manifest value is empty"
  fi
done

if (( failures )); then
  exit 1
fi

if [[ "$checked" -eq 0 ]]; then
  echo "OK: no certifiable RESULTS receipts found."
  exit 0
fi

echo "OK: RESULTS lint passed (${checked} file(s) checked)."
