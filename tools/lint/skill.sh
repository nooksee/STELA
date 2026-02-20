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
trap 'emit_binary_leaf "lint-skill" "finish"' EXIT
emit_binary_leaf "lint-skill" "start"

SKILLS_DIR="opt/_factory/skills"
SKILLS_REGISTRY="docs/ops/registry/SKILLS.md"
CONTEXT_MANIFEST="ops/lib/manifests/CONTEXT.md"

failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "CRITICAL: Required file missing at ${REPO_ROOT}/${path}" >&2
    exit 2
  fi
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

section_has_content() {
  local section="$1"
  local path="$2"
  awk -v section="$section" '
    BEGIN { in_section=0; found=0; has_content=0 }
    $0 == section { in_section=1; found=1; next }
    in_section {
      if ($0 ~ /^## /) { exit }
      if ($0 ~ /[^[:space:]]/) { has_content=1; exit }
    }
    END { if (!found || !has_content) exit 1 }
  ' "$path"
}

require_file "$SKILLS_REGISTRY"
require_file "$CONTEXT_MANIFEST"

echo "Skill Lint"
echo "Registry: ${SKILLS_REGISTRY}"
echo "Directory: ${SKILLS_DIR}"
echo "------------------------"

if grep -nE '(docs/|opt/_factory)/skills/|S-LEARN-' "$CONTEXT_MANIFEST" >/dev/null; then
  fail "Skills are referenced in ops/lib/manifests/CONTEXT.md"
fi

mapfile -t registry_rows < <(awk -F'|' '
  $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*---/ {
    id=$2
    path=$4
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    gsub(/^[[:space:]]+/, "", path)
    gsub(/[[:space:]]+$/, "", path)
    if (id != "" && id != "ID") print id "|" path
  }
' "$SKILLS_REGISTRY")

declare -A registry_ids
declare -A registry_paths

for row in "${registry_rows[@]}"; do
  id="${row%%|*}"
  path="${row#*|}"

  if [[ -n "${registry_ids[$id]+set}" ]]; then
    fail "${SKILLS_REGISTRY} has duplicate ID '${id}'"
  else
    registry_ids["$id"]=1
  fi

  if [[ -n "$path" ]]; then
    if [[ -n "${registry_paths[$path]+set}" ]]; then
      fail "${SKILLS_REGISTRY} has duplicate file path '${path}'"
    else
      registry_paths["$path"]=1
    fi

    if [[ ! -f "$path" ]]; then
      fail "${SKILLS_REGISTRY} references missing file '${path}'"
    fi
  fi

done

if [[ ! -d "$SKILLS_DIR" ]]; then
  fail "Skills directory missing at ${SKILLS_DIR}"
fi

if compgen -G "${SKILLS_DIR}/S-LEARN-*.md" > /dev/null; then
  for skill in "${SKILLS_DIR}"/S-LEARN-*.md; do
    skill_name="$(basename "$skill")"
    skill_id="${skill_name%.md}"

    if [[ -z "${registry_ids[$skill_id]+set}" ]]; then
      fail "Ghost skill file '${skill}' is not registered in ${SKILLS_REGISTRY}"
    fi

    if grep -nE '\bTODO\b|\bTBD\b|ENTER_|REPLACE_|\[ID\]|\[TITLE\]' "$skill" >/dev/null; then
      fail "${skill_name} contains placeholder markers"
    fi

    if ! head -n 1 "$skill" | grep -qE '^# S-LEARN-[0-9]+: .+'; then
      fail "${skill_name} header must be '# S-LEARN-XX: <title>'"
    fi

    required_sections=(
      "## Provenance"
      "## Scope"
      "## Pointers"
    )

    for section in "${required_sections[@]}"; do
      section_count="$(grep -c "^${section}$" "$skill" || true)"
      if [[ "$section_count" -eq 0 ]]; then
        fail "${skill_name} missing required section '${section}'"
        continue
      fi
      if [[ "$section_count" -gt 1 ]]; then
        fail "${skill_name} has duplicate section '${section}'"
        continue
      fi
      if ! section_has_content "$section" "$skill"; then
        fail "${skill_name} section '${section}' is empty"
      fi
    done

    invocation_count="$(grep -c -E '^## Invocation Guidance$|^## Invocation guidance$' "$skill" || true)"
    if [[ "$invocation_count" -eq 0 ]]; then
      fail "${skill_name} missing required section '## Invocation Guidance'"
    elif [[ "$invocation_count" -gt 1 ]]; then
      fail "${skill_name} has duplicate Invocation Guidance sections"
    fi
  done
else
  echo "No skill files found in ${SKILLS_DIR}."
fi

if (( failures > 0 )); then
  echo "FAILED: ${failures} error(s) detected." >&2
  exit 1
fi

echo "OK: Skill lint checks passed."
