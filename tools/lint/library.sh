#!/usr/bin/env bash
set -euo pipefail

# Stela Library Guard (Registry Enforcement)
# Purpose: Ensure registry-managed library surfaces stay synchronized.
# Logic:
# 1. No Dead Ends: All paths or IDs in registries must exist on disk.
# 2. No Ghosts: All registry-managed library files must be registered.

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

LIBRARY_DIR="opt/_factory"
AGENTS_REGISTRY="docs/ops/registry/AGENTS.md"
SKILLS_REGISTRY="docs/ops/registry/SKILLS.md"
TASKS_REGISTRY="docs/ops/registry/TASKS.md"

failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    echo "CRITICAL: Registry file missing at ${REPO_ROOT}/${path}" >&2
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

extract_section() {
  local section="$1"
  local path="$2"
  awk -v section="$section" '
    BEGIN { in_section=0 }
    $0 == section { in_section=1; next }
    /^## / { if (in_section) exit }
    in_section { print }
  ' "$path"
}

require_file "$AGENTS_REGISTRY"
require_file "$SKILLS_REGISTRY"
require_file "$TASKS_REGISTRY"

if ! bash tools/lint/agent.sh; then
  fail "Agent linter failed. See output above."
fi

if ! bash tools/lint/task.sh; then
  fail "Task linter failed. See output above."
fi

echo "Stela Library Verification"
echo "Registry: docs/ops/registry/AGENTS.md"
echo "Registry: docs/ops/registry/SKILLS.md"
echo "Registry: docs/ops/registry/TASKS.md"
echo "------------------------"

mapfile -t agent_ids < <(awk -F'|' '
  $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*---/ {
    id=$2
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    if (id != "ID" && id != "") print id
  }
' "$AGENTS_REGISTRY")

declare -A agent_id_map
for id in "${agent_ids[@]}"; do
  agent_id_map["$id"]=1
  agent_path="${LIBRARY_DIR}/agents/${id}.md"
  if [[ ! -f "$agent_path" ]]; then
    fail "Dead End: Registry references missing agent file '${agent_path}'"
  fi
done

mapfile -t skill_paths < <(awk -F'|' '
  $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*---/ {
    id=$2
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    if (id == "ID" || id == "") next
    path=$4
    gsub(/^[[:space:]]+/, "", path)
    gsub(/[[:space:]]+$/, "", path)
    if (path != "") print path
  }
' "$SKILLS_REGISTRY")

declare -A skill_path_map
for path in "${skill_paths[@]}"; do
  skill_path_map["$path"]=1
  if [[ ! -f "$path" ]]; then
    fail "Dead End: Registry points to missing file '${path}'"
  fi
done

mapfile -t task_paths < <(awk -F'|' '
  $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*---/ {
    id=$2
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    if (id == "ID" || id == "") next
    path=$4
    gsub(/^[[:space:]]+/, "", path)
    gsub(/[[:space:]]+$/, "", path)
    if (path != "") print path
  }
' "$TASKS_REGISTRY")

declare -A task_path_map
for path in "${task_paths[@]}"; do
  task_path_map["$path"]=1
  if [[ ! -f "$path" ]]; then
    fail "Dead End: Registry points to missing file '${path}'"
  fi
done

# Ghost checks for registry-managed library folders.

while IFS= read -r file; do
  rel_path="${file#${REPO_ROOT}/}"
  base_name="$(basename "$rel_path" .md)"
  if [[ -z "${agent_id_map[$base_name]+set}" ]]; then
    fail "Ghost Artifact: '${rel_path}' exists but is not registered in AGENTS.md"
  fi
done < <(find "${LIBRARY_DIR}/agents" -type f -name "*.md")

while IFS= read -r file; do
  rel_path="${file#${REPO_ROOT}/}"
  if [[ -z "${skill_path_map[$rel_path]+set}" ]]; then
    fail "Ghost Artifact: '${rel_path}' exists but is not registered in SKILLS.md"
  fi
done < <(find "${LIBRARY_DIR}/skills" -type f -name "*.md")

skills_meta="${LIBRARY_DIR}/SKILLS.md"
if [[ -f "$skills_meta" ]]; then
  if [[ -z "${skill_path_map[$skills_meta]+set}" ]]; then
    fail "Ghost Artifact: '${skills_meta}' exists but is not registered in SKILLS.md"
  fi
fi

while IFS= read -r file; do
  rel_path="${file#${REPO_ROOT}/}"
  if [[ -z "${task_path_map[$rel_path]+set}" ]]; then
    fail "Ghost Artifact: '${rel_path}' exists but is not registered in TASKS.md"
  fi
done < <(find "${LIBRARY_DIR}/tasks" -type f -name "*.md")

skills_dir="${LIBRARY_DIR}/skills"
if compgen -G "${skills_dir}/*.md" > /dev/null; then
  for skill in "${skills_dir}"/*.md; do
    skill_name="$(basename "$skill")"

    provenance_count="$(grep -c "^## Provenance$" "$skill" || true)"
    if [[ "$provenance_count" -eq 0 ]]; then
      fail "${skill_name} missing required section '## Provenance'"
    elif [[ "$provenance_count" -gt 1 ]]; then
      fail "${skill_name} has duplicate section '## Provenance'"
    fi

    pointers_section="$(extract_section "## Pointers" "$skill")"
    if [[ -z "$pointers_section" ]]; then
      fail "${skill_name} missing required section '## Pointers'"
      continue
    fi

    mapfile -t pointer_tokens < <(printf '%s\n' "$pointers_section" | { grep -oE '`[^`]+`' || true; } | sed -e 's/`//g')
    if (( ${#pointer_tokens[@]} == 0 )); then
      fail "${skill_name} Pointers section has no backticked paths"
    fi

    for token in "${pointer_tokens[@]}"; do
      normalized="$(normalize_token "$token")"
      if [[ "$normalized" == *" "* ]]; then
        continue
      fi
      if [[ "$normalized" == /* || "$normalized" == ~* ]]; then
        fail "${skill_name} pointer token uses absolute or home path '${token}'"
        continue
      fi
      case "$normalized" in
        PoT.md|TASK.md|docs/*|ops/*|tools/*|*.md|*.sh)
          if [[ ! -e "$normalized" ]]; then
            fail "${skill_name} pointer token '${token}' does not exist"
          fi
          ;;
      esac
    done

    if grep -Eq '^[[:space:]]*[0-9]+\.[[:space:]]' "$skill"; then
      fail "${skill_name} contains numbered list steps; skills must be pointer-first"
    fi
  done
fi

duplicate_patterns=(
  "git status --porcelain"
  "npm run lint"
  "ruff check"
  "flake8"
  "npm run build"
  "npm run test"
  "pytest"
  "git diff --stat"
)

if compgen -G "${LIBRARY_DIR}/tasks/*.md" > /dev/null; then
  for task in "${LIBRARY_DIR}/tasks"/*.md; do
    if grep -q "S-LEARN-01" "$task"; then
      task_name="$(basename "$task")"
      for pattern in "${duplicate_patterns[@]}"; do
        if grep -Fq "$pattern" "$task"; then
          fail "Duplicate verification instructions in '${task_name}' referencing S-LEARN-01: '${pattern}'"
        fi
      done
    fi
  done
fi
if [[ $failures -eq 0 ]]; then
  echo "OK: Library Integrity Verified."
  exit 0
else
  echo "FAILED: $failures error(s) detected." >&2
  exit 1
fi
