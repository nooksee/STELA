#!/usr/bin/env bash
set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "ERROR: git is required but was not found on PATH" >&2
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ERROR: rg is required but was not found on PATH" >&2
  exit 1
fi

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"
if [[ -z "$REPO_ROOT" ]]; then
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

AGENTS_REGISTRY="docs/ops/registry/AGENTS.md"
SKILLS_REGISTRY="docs/ops/registry/SKILLS.md"
TASKS_REGISTRY="docs/ops/registry/TASKS.md"

for registry in "$AGENTS_REGISTRY" "$SKILLS_REGISTRY" "$TASKS_REGISTRY"; do
  if [[ ! -f "$registry" ]]; then
    echo "ERROR: Missing registry at ${registry}" >&2
    exit 1
  fi
done

mapfile -t stela_files < <(find "${REPO_ROOT}/projects" -maxdepth 2 -name "STELA.md" -print | sort)

if (( ${#stela_files[@]} == 0 )); then
  echo "No projects found."
  exit 0
fi

declare -A valid_agents
while IFS= read -r token; do
  valid_agents["$token"]=1
done < <(awk -F'|' '
  $0 ~ /^\\|/ && $0 !~ /^\\|[[:space:]]*---/ {
    id=$2
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    if (id != "ID" && id != "") print id
  }
' "$AGENTS_REGISTRY" | sort -u)

declare -A valid_tasks
while IFS= read -r token; do
  valid_tasks["$token"]=1
done < <(awk -F'|' '
  $0 ~ /^\\|/ && $0 !~ /^\\|[[:space:]]*---/ {
    id=$2
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    if (id != "ID" && id != "") print id
  }
' "$TASKS_REGISTRY" | sort -u)

declare -A valid_skills
while IFS= read -r token; do
  valid_skills["$token"]=1
done < <(awk -F'|' '
  $0 ~ /^\\|/ && $0 !~ /^\\|[[:space:]]*---/ {
    id=$2
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    if (id != "ID" && id != "") print id
  }
' "$SKILLS_REGISTRY" | sort -u)

failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures + 1))
}

for stela in "${stela_files[@]}"; do
  rel_stela="${stela#${REPO_ROOT}/}"

  mapfile -t agent_refs < <(rg -o "R-AGENT-[0-9]{2,}" "$stela" | sort -u)
  for ref in "${agent_refs[@]}"; do
    if [[ -z "${valid_agents[$ref]+set}" ]]; then
      fail "Dead Pointer: ${rel_stela} references unknown agent ${ref}"
    fi
  done

  mapfile -t task_refs < <(rg -o "B-TASK-[0-9]{2,}" "$stela" | sort -u)
  for ref in "${task_refs[@]}"; do
    if [[ -z "${valid_tasks[$ref]+set}" ]]; then
      fail "Dead Pointer: ${rel_stela} references unknown task ${ref}"
    fi
  done

  mapfile -t skill_refs < <(rg -o "S-LEARN-[0-9]{2,}" "$stela" | sort -u)
  for ref in "${skill_refs[@]}"; do
    if [[ -z "${valid_skills[$ref]+set}" ]]; then
      fail "Dead Pointer: ${rel_stela} references unknown skill ${ref}"
    fi
  done

done

if (( failures > 0 )); then
  echo "FAILED: ${failures} dead pointer(s) detected." >&2
  exit 1
fi

echo "OK: Project STELA references verified for agents, tasks, and skills."
