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
trap 'emit_binary_leaf "lint-agent" "finish"' EXIT
emit_binary_leaf "lint-agent" "start"

AGENTS_DIR="opt/_factory/agents"
AGENTS_REGISTRY="docs/ops/registry/agents.md"

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

extract_section() {
  local section="$1"
  local path="$2"
  awk -v section="$section" '
    BEGIN { in_section=0 }
    $0 == section { in_section=1; next }
    in_section && /^## / { exit }
    in_section { print }
  ' "$path"
}

identity_value() {
  local key="$1"
  local path="$2"
  local identity_section
  identity_section="$(extract_section "## Identity Contract" "$path")"
  printf '%s\n' "$identity_section" | awk -v key="$key" '
    $0 ~ "^[[:space:]]*-[[:space:]]*`?" key "`?:[[:space:]]*`[^`]+`[[:space:]]*$" {
      line = $0
      sub(/^[[:space:]]*-[[:space:]]*`?[^` :]+`?:[[:space:]]*`/, "", line)
      sub(/`[[:space:]]*$/, "", line)
      print line
      exit
    }
  '
}

stance_id_allowed() {
  local stance_id="$1"
  case "$stance_id" in
    addenda|analyst|architect|audit|conformist|contractor)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
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
declare -A registry_id_slugs

declare -A registry_names
for row in "${registry_rows[@]}"; do
  id="${row%%|*}"
  name="${row#*|}"

  if [[ -n "${registry_ids[$id]+set}" ]]; then
    fail "Level 2: ${AGENTS_REGISTRY} duplicate agent ID '${id}'"
  else
    registry_ids["$id"]=1
    registry_id_slugs["${id,,}"]=1
  fi

  if [[ -n "${registry_names[$name]+set}" && "${registry_names[$name]}" != "$id" ]]; then
    fail "Level 2: ${AGENTS_REGISTRY} duplicate agent name '${name}' for IDs '${registry_names[$name]}' and '${id}'"
  else
    registry_names["$name"]="$id"
  fi

done

for id in "${!registry_ids[@]}"; do
  id_slug="${id,,}"
  agent_path="${AGENTS_DIR}/${id_slug}.md"
  if [[ ! -f "$agent_path" ]]; then
    fail "Level 2: ${AGENTS_REGISTRY} references missing agent file '${agent_path}'"
  fi

done

if compgen -G "${AGENTS_DIR}/*.md" > /dev/null; then
  while IFS= read -r file; do
    base_name="$(basename "$file" .md)"
    if [[ -z "${registry_id_slugs[$base_name]+set}" ]]; then
      fail "Level 2: Ghost agent file '${AGENTS_DIR}/${base_name}.md' is not registered"
    fi
  done < <(find "${AGENTS_DIR}" -maxdepth 1 -type f -name '*.md')
fi

# Levels 1, 3, 4, 5: File checks
if compgen -G "${AGENTS_DIR}/*.md" > /dev/null; then
  for agent in "${AGENTS_DIR}"/*.md; do
    agent_name="$(basename "$agent")"

    required_sections=("## Provenance" "## Role" "## Specialization" "## Identity Contract" "## Capability Tags" "## Pointers" "## Skill Bindings" "## Scope Boundary")
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

    declared_agent_id="$(trim "$(identity_value "agent_id" "$agent")")"
    if [[ -z "$declared_agent_id" ]]; then
      fail "Level 1: ${agent_name} missing Identity Contract field 'agent_id'"
    else
      expected_agent_id="$(basename "$agent" .md | tr '[:lower:]' '[:upper:]')"
      if [[ "$declared_agent_id" != "$expected_agent_id" ]]; then
        fail "Level 1: ${agent_name} agent_id '${declared_agent_id}' does not match expected '${expected_agent_id}'"
      fi
      if [[ -z "${registry_ids[$declared_agent_id]+set}" ]]; then
        fail "Level 2: ${agent_name} agent_id '${declared_agent_id}' is not registered in ${AGENTS_REGISTRY}"
      fi
    fi

    declared_stance_id="$(trim "$(identity_value "stance_id" "$agent")")"
    if [[ -z "$declared_stance_id" ]]; then
      fail "Level 1: ${agent_name} missing Identity Contract field 'stance_id'"
    elif ! stance_id_allowed "$declared_stance_id"; then
      fail "Level 1: ${agent_name} stance_id '${declared_stance_id}' is not an allowed canonical stance"
    fi

    capability_section="$(extract_section "## Capability Tags" "$agent")"
    capability_count="$(printf '%s\n' "$capability_section" | grep -Ec '^[[:space:]]*-[[:space:]]*`[^`]+`[[:space:]]*$' || true)"
    if [[ "$capability_count" -lt 1 ]]; then
      fail "Level 1: ${agent_name} Capability Tags section must contain at least one backticked tag bullet"
    fi

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

    if grep -Eq '^[[:space:]]*-[[:space:]]*JIT skills:' <<< "$pointers_section"; then
      fail "Level 1: ${agent_name} legacy 'JIT skills' pointer block is forbidden; use ## Skill Bindings"
    fi

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

    skill_bindings_section="$(extract_section "## Skill Bindings" "$agent")"
    if ! grep -Eq '^[[:space:]]*-[[:space:]]*`required_skills`:[[:space:]]*$' <<< "$skill_bindings_section"; then
      fail "Level 1: ${agent_name} Skill Bindings section missing '`required_skills`' label"
    fi
    if ! grep -Eq '^[[:space:]]*-[[:space:]]*`optional_skills`:[[:space:]]*$' <<< "$skill_bindings_section"; then
      fail "Level 1: ${agent_name} Skill Bindings section missing '`optional_skills`' label"
    fi
    required_skill_count="$(printf '%s\n' "$skill_bindings_section" | grep -Ec '^[[:space:]]*-[[:space:]]*`opt/_factory/skills/s-learn-[0-9]{2}[.]md`[[:space:]]*$' || true)"
    if [[ "$required_skill_count" -lt 1 ]]; then
      fail "Level 1: ${agent_name} Skill Bindings must include at least one required skill path"
    fi
    optional_skill_valid_count="$(printf '%s\n' "$skill_bindings_section" | grep -Ec '^[[:space:]]*-[[:space:]]*`opt/_factory/skills/s-learn-[0-9]{2}[.]md`[[:space:]]*$|^[[:space:]]*-[[:space:]]*[(]none[)]$' || true)"
    if [[ "$optional_skill_valid_count" -lt 1 ]]; then
      fail "Level 1: ${agent_name} Skill Bindings optional list must contain skill paths or '(none)'"
    fi

    envelope_pattern='Output only:|Emit exactly one fenced markdown code block|First non-empty line inside the code block'
    if grep -nE "$envelope_pattern" "$agent" >/dev/null; then
      fail "Level 4: ${agent_name} contains stance-envelope directives; role files must not embed output-envelope rules"
    fi

    hazard_patterns=(
      'archives/definitions'
      'archives/definitions'
      'archives/definitions'
      'archives/manifests'
      'archives/surfaces'
      'archives/'
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

    if grep -nEi '(context|CONTEXT\.md).*(docs/factory|opt/_factory)/(agents|skills|tasks)|(docs/factory|opt/_factory)/(agents|skills|tasks).*(context|CONTEXT\.md)' "$agent" >/dev/null; then
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
