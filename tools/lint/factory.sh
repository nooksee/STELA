#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

# Stela Factory Guard (Registry and Head Enforcement)
# Purpose: Ensure definition registries and factory pointer heads remain synchronized.

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1
trap 'emit_binary_leaf "lint-factory" "finish"' EXIT
emit_binary_leaf "lint-factory" "start"

FACTORY_DIR="opt/_factory"
AGENTS_HEAD="opt/_factory/AGENTS.md"
TASKS_HEAD="opt/_factory/TASKS.md"
SKILLS_HEAD="opt/_factory/SKILLS.md"
AGENTS_REGISTRY="docs/ops/registry/agents.md"
SKILLS_REGISTRY="docs/ops/registry/skills.md"
TASKS_REGISTRY="docs/ops/registry/tasks.md"

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

validate_chain_head() {
  local head_path="$1"
  local chain_name="$2"
  local expected_spec="$3"
  local expected_registry="$4"
  local expected_candidate_origin="$5"
  local expected_promotion_origin="$6"

  local candidate=""
  local promotion=""
  local spec=""
  local registry=""

  local line_no=0
  local expected_key=""
  local key=""
  local value=""
  local line=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))

    if [[ -z "$line" ]]; then
      fail "${chain_name}: ${head_path} contains blank line ${line_no}; head must be exactly four key lines"
      continue
    fi

    if [[ "$line" != *:* ]]; then
      fail "${chain_name}: ${head_path} line ${line_no} missing key separator ':'"
      continue
    fi

    key="${line%%:*}"
    key="$(trim "$key")"
    value="${line#*:}"
    value="$(trim "$value")"

    case "$line_no" in
      1) expected_key="candidate" ;;
      2) expected_key="promotion" ;;
      3) expected_key="spec" ;;
      4) expected_key="registry" ;;
      *)
        fail "${chain_name}: ${head_path} has more than four lines"
        expected_key=""
        ;;
    esac

    if [[ -n "$expected_key" && "$key" != "$expected_key" ]]; then
      fail "${chain_name}: ${head_path} line ${line_no} must start with '${expected_key}:'"
    fi

    if [[ -z "$value" ]]; then
      fail "${chain_name}: ${head_path} line ${line_no} value is empty"
      continue
    fi

    case "$key" in
      candidate) candidate="$value" ;;
      promotion) promotion="$value" ;;
      spec) spec="$value" ;;
      registry) registry="$value" ;;
      *)
        fail "${chain_name}: ${head_path} line ${line_no} has unexpected key '${key}'"
        ;;
    esac
  done < "$head_path"

  if [[ "$line_no" -ne 4 ]]; then
    fail "${chain_name}: ${head_path} must contain exactly four lines"
  fi

  if [[ "$spec" != "$expected_spec" ]]; then
    fail "${chain_name}: spec pointer mismatch. Expected '${expected_spec}', found '${spec}'"
  fi
  if [[ "$registry" != "$expected_registry" ]]; then
    fail "${chain_name}: registry pointer mismatch. Expected '${expected_registry}', found '${registry}'"
  fi

  if [[ -n "$spec" && ! -f "$spec" ]]; then
    fail "${chain_name}: spec pointer target missing '${spec}'"
  fi
  if [[ -n "$registry" && ! -f "$registry" ]]; then
    fail "${chain_name}: registry pointer target missing '${registry}'"
  fi

  validate_head_value "$chain_name" "$head_path" "candidate" "$candidate" "$expected_candidate_origin"
  validate_head_value "$chain_name" "$head_path" "promotion" "$promotion" "$expected_promotion_origin"
}

validate_head_value() {
  local chain_name="$1"
  local head_path="$2"
  local key="$3"
  local value="$4"
  local origin_sentinel="$5"

  if [[ "$value" == *"-(origin)" ]]; then
    if [[ "$value" != "$origin_sentinel" ]]; then
      fail "${chain_name}: ${head_path} ${key}: uses unexpected origin sentinel '${value}'"
    fi
    return 0
  fi

  if [[ "$value" != archives/definitions/* ]]; then
    fail "${chain_name}: ${head_path} ${key}: must point under archives/definitions or use origin sentinel"
    return 0
  fi

  if [[ ! -f "$value" ]]; then
    fail "${chain_name}: ${head_path} ${key}: unresolved pointer '${value}'"
  fi
}

require_file "$AGENTS_HEAD"
require_file "$TASKS_HEAD"
require_file "$SKILLS_HEAD"
require_file "$AGENTS_REGISTRY"
require_file "$SKILLS_REGISTRY"
require_file "$TASKS_REGISTRY"

validate_chain_head \
  "$AGENTS_HEAD" \
  "agents" \
  "docs/ops/specs/definitions/agents.md" \
  "docs/ops/registry/agents.md" \
  "archives/definitions/agent-candidate-(origin)" \
  "archives/definitions/agent-promotion-(origin)"

validate_chain_head \
  "$TASKS_HEAD" \
  "tasks" \
  "docs/ops/specs/definitions/tasks.md" \
  "docs/ops/registry/tasks.md" \
  "archives/definitions/task-candidate-(origin)" \
  "archives/definitions/task-promotion-(origin)"

validate_chain_head \
  "$SKILLS_HEAD" \
  "skills" \
  "docs/ops/specs/definitions/skills.md" \
  "docs/ops/registry/skills.md" \
  "archives/definitions/skill-candidate-(origin)" \
  "archives/definitions/skill-promotion-(origin)"

if ! bash tools/lint/agent.sh; then
  fail "Agent linter failed. See output above."
fi

if ! bash tools/lint/task.sh; then
  fail "Task linter failed. See output above."
fi

echo "Stela Factory Verification"
echo "Registry: docs/ops/registry/agents.md"
echo "Registry: docs/ops/registry/skills.md"
echo "Registry: docs/ops/registry/tasks.md"
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
  id_slug="${id,,}"
  agent_id_map["$id_slug"]=1
  agent_path="${FACTORY_DIR}/agents/${id_slug}.md"
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

while IFS= read -r file; do
  rel_path="${file#${REPO_ROOT}/}"
  base_name="$(basename "$rel_path" .md)"
  if [[ -z "${agent_id_map[$base_name]+set}" ]]; then
    fail "Ghost Artifact: '${rel_path}' exists but is not registered in AGENTS.md"
  fi
done < <(find "${FACTORY_DIR}/agents" -type f -name "*.md")

while IFS= read -r file; do
  rel_path="${file#${REPO_ROOT}/}"
  if [[ -z "${skill_path_map[$rel_path]+set}" ]]; then
    fail "Ghost Artifact: '${rel_path}' exists but is not registered in SKILLS.md"
  fi
done < <(find "${FACTORY_DIR}/skills" -type f -name "*.md")

skills_meta="${FACTORY_DIR}/SKILLS.md"
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
done < <(find "${FACTORY_DIR}/tasks" -type f -name "*.md")

skills_dir="${FACTORY_DIR}/skills"
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

if compgen -G "${FACTORY_DIR}/tasks/*.md" > /dev/null; then
  for task in "${FACTORY_DIR}/tasks"/*.md; do
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
  echo "OK: Factory Integrity Verified."
  exit 0
else
  echo "FAILED: $failures error(s) detected." >&2
  exit 1
fi
