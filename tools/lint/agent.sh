#!/usr/bin/env bash
set -euo pipefail

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

AGENTS_DIR="opt/_factory/agents"
AGENTS_REGISTRY="docs/ops/registry/AGENTS.md"

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

normalize_token() {
  local value="$1"
  if [[ "$value" == ./* ]]; then
    value="${value#./}"
  fi
  printf '%s' "$value"
}

extract_pointers_section() {
  local path="$1"
  awk '
    BEGIN { in_section=0 }
    /^## Pointers[[:space:]]*$/ { in_section=1; next }
    /^## / { in_section=0 }
    in_section { print }
  ' "$path"
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

provenance_field_present() {
  local field="$1"
  local path="$2"
  if ! grep -nE "^[[:space:]]*- \\*\\*${field}\\*\\*:[[:space:]]*[^[:space:]]|^[[:space:]]*- \\*\\*${field}:\\*\\*[[:space:]]*[^[:space:]]" "$path" >/dev/null; then
    return 1
  fi
  return 0
}

require_file "$AGENTS_REGISTRY"

if [[ ! -d "$AGENTS_DIR" ]]; then
  fail "Level 2: Agents directory missing at ${AGENTS_DIR}"
fi

echo "Agent Immunological Lint"
echo "Registry: ${AGENTS_REGISTRY}"
echo "Directory: ${AGENTS_DIR}"
echo "------------------------"

# Level 2: Registry Alignment
mapfile -t registry_rows < <(awk -F'|' '
  $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*---/ {
    id=$2; name=$3
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    gsub(/^[[:space:]]+/, "", name)
    gsub(/[[:space:]]+$/, "", name)
    if (id != "" && id != "ID") print id "|" name
  }
' "$AGENTS_REGISTRY")

declare -A registry_ids

declare -A registry_names
for row in "${registry_rows[@]}"; do
  id="${row%%|*}"
  name="${row#*|}"

  if [[ -n "${registry_ids[$id]+set}" ]]; then
    fail "Level 2: ${AGENTS_REGISTRY} duplicate agent ID '${id}'"
  else
    registry_ids["$id"]=1
  fi

  if [[ -n "${registry_names[$name]+set}" && "${registry_names[$name]}" != "$id" ]]; then
    fail "Level 2: ${AGENTS_REGISTRY} duplicate agent name '${name}' for IDs '${registry_names[$name]}' and '${id}'"
  else
    registry_names["$name"]="$id"
  fi

done

for id in "${!registry_ids[@]}"; do
  agent_path="${AGENTS_DIR}/${id}.md"
  if [[ ! -f "$agent_path" ]]; then
    fail "Level 2: ${AGENTS_REGISTRY} references missing agent file '${agent_path}'"
  fi

done

if compgen -G "${AGENTS_DIR}/*.md" > /dev/null; then
  while IFS= read -r file; do
    base_name="$(basename "$file" .md)"
    if [[ -z "${registry_ids[$base_name]+set}" ]]; then
      fail "Level 2: Ghost agent file '${AGENTS_DIR}/${base_name}.md' is not registered"
    fi
  done < <(find "${AGENTS_DIR}" -maxdepth 1 -type f -name '*.md')
fi

# Levels 1, 3, 4, 5: File checks
if compgen -G "${AGENTS_DIR}/*.md" > /dev/null; then
  for agent in "${AGENTS_DIR}"/*.md; do
    agent_name="$(basename "$agent")"

    required_sections=("## Provenance" "## Role" "## Specialization" "## Pointers" "## Scope Boundary")
    for section in "${required_sections[@]}"; do
      section_count="$(grep -c "^${section}$" "$agent" || true)"
      if [[ "$section_count" -eq 0 ]]; then
        fail "Level 1: ${agent_name} missing required '${section}' section"
        continue
      fi
      if [[ "$section_count" -gt 1 ]]; then
        fail "Level 1: ${agent_name} has duplicate '${section}' sections"
        continue
      fi
      if ! section_has_content "$section" "$agent"; then
        fail "Level 1: ${agent_name} section '${section}' is empty"
      fi
    done

    required_fields=("Captured" "DP-ID" "Branch" "HEAD" "Objective")
    for field in "${required_fields[@]}"; do
      if ! provenance_field_present "$field" "$agent"; then
        fail "Level 1: ${agent_name} missing Provenance field '${field}'"
      fi
    done

    pointers_section="$(extract_pointers_section "$agent")"
    toolchain_lines="$(printf '%s\n' "$pointers_section" | grep -E '^[[:space:]]*-[[:space:]]*Authorized toolchain:' || true)"
    toolchain_count="$(printf '%s\n' "$toolchain_lines" | sed '/^$/d' | wc -l | tr -d '[:space:]')"

    if [[ "$toolchain_count" -eq 0 ]]; then
      fail "Level 1: ${agent_name} missing Authorized toolchain entry in Pointers section"
    elif [[ "$toolchain_count" -gt 1 ]]; then
      fail "Level 1: ${agent_name} has duplicate Authorized toolchain entries"
    fi

    required_pointer_tokens=("PoT.md" "docs/GOVERNANCE.md" "TASK.md")
    for token in "${required_pointer_tokens[@]}"; do
      if ! grep -q "\`$token\`" <<< "$pointers_section"; then
        fail "Level 1: ${agent_name} missing required pointer '${token}'"
      fi
    done

    mapfile -t pointer_tokens < <(printf '%s\n' "$pointers_section" | grep -oE '`[^`]+`' | sed -e 's/`//g' || true)
    for token in "${pointer_tokens[@]}"; do
      normalized="$(normalize_token "$token")"
      if [[ "$normalized" == /* || "$normalized" == ~* ]]; then
        fail "Level 3: ${agent_name} pointer token uses absolute or home path '${token}'"
        continue
      fi
      if [[ ! -e "$REPO_ROOT/$normalized" ]]; then
        fail "Level 3: ${agent_name} pointer token '${token}' does not exist"
      fi
      if [[ "$normalized" == opt/_factory/skills/* && ! -f "$REPO_ROOT/$normalized" ]]; then
        fail "Level 3: ${agent_name} JIT skill path '${token}' does not exist"
      fi
    done

    mapfile -t toolchain_tokens < <(printf '%s\n' "$toolchain_lines" | grep -oE '`[^`]+`' | sed -e 's/`//g' || true)
    for tool in "${toolchain_tokens[@]}"; do
      normalized="$(normalize_token "$tool")"
      if [[ "$normalized" == /* || "$normalized" == ~* ]]; then
        fail "Level 5: ${agent_name} toolchain token uses absolute or home path '${tool}'"
        continue
      fi

      if [[ "$normalized" == ops/bin/* ]]; then
        if [[ ! -f "$REPO_ROOT/$normalized" ]]; then
          fail "Level 3: ${agent_name} toolchain binary '${tool}' does not exist"
        fi
      elif [[ "$normalized" == tools/lint/* || "$normalized" == tools/test/* || "$normalized" == tools/verify.sh ]]; then
        if [[ ! -f "$REPO_ROOT/$normalized" ]]; then
          fail "Level 3: ${agent_name} toolchain helper '${tool}' does not exist"
        fi
      else
        fail "Level 5: ${agent_name} toolchain token '${tool}' is not an authorized repo-relative executable"
      fi
    done

    hazard_patterns=(
      'storage/archives/agents'
      'storage/archives/'
      'storage/archives'
      'storage/handoff'
      'storage/dumps'
      'OPEN-[A-Za-z0-9._-]+\\.txt'
      'dump-[A-Za-z0-9._-]+\\.txt'
      'chat log'
      'chatlog'
      'transcript'
      'handoff artifact'
      'handoff artifacts'
    )

    for pattern in "${hazard_patterns[@]}"; do
      if grep -nE "$pattern" "$agent" >/dev/null; then
        fail "Level 4: ${agent_name} references disposable artifact pattern '${pattern}'"
      fi
    done

    if grep -nEi '(context|CONTEXT\.md).*(docs/library|opt/_factory)/(agents|skills|tasks)|(docs/library|opt/_factory)/(agents|skills|tasks).*(context|CONTEXT\.md)' "$agent" >/dev/null; then
      fail "Level 4: ${agent_name} attempts recursive context expansion"
    fi
  done
else
  echo "No agent files found in ${AGENTS_DIR}."
fi

if (( failures > 0 )); then
  echo "FAILED: ${failures} error(s) detected." >&2
  exit 1
fi

echo "OK: Agent immunological checks passed."
