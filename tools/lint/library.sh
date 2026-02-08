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

LIBRARY_DIR="docs/library"
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
if [[ $failures -eq 0 ]]; then
  echo "OK: Library Integrity Verified."
  exit 0
else
  echo "FAILED: $failures error(s) detected." >&2
  exit 1
fi
