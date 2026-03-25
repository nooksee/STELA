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
FACTORY_CENSUS_REGISTRY="docs/ops/registry/factory.md"

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

collect_runtime_factory_paths() {
  local pattern='opt/_factory/(agents|skills|tasks)/[A-Za-z0-9._-]+\.md'

  if command -v rg >/dev/null 2>&1; then
    rg -oN --no-heading -h "$pattern" ops tools docs 2>/dev/null || true
    return 0
  fi

  grep -RhoE -- "$pattern" ops tools docs 2>/dev/null || true
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

extract_factory_matrix_rows() {
  local path="$1"
  awk -F'|' '
    BEGIN { in_matrix=0 }
    /^## Definition Matrix$/ { in_matrix=1; next }
    /^## / { if (in_matrix) exit }
    in_matrix && $0 ~ /^\|/ {
      kind=$2
      id=$3
      row_path=$4
      disposition=$5
      reason=$6
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", kind)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", id)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", row_path)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", disposition)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", reason)
      if (kind == "" || kind == "Kind" || kind ~ /^-+$/) next
      print kind "\t" id "\t" row_path "\t" disposition "\t" reason
    }
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
require_file "$FACTORY_CENSUS_REGISTRY"

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
echo "Registry: docs/ops/registry/factory.md"
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

declare -A census_id_map
declare -A census_path_map

while IFS=$'\t' read -r kind id row_path disposition reason; do
  if [[ -z "$kind" || -z "$id" || -z "$row_path" || -z "$disposition" || -z "$reason" ]]; then
    fail "Factory census row is incomplete in '${FACTORY_CENSUS_REGISTRY}'"
    continue
  fi

  case "$kind" in
    agent)
      if [[ ! "$id" =~ ^R-AGENT-[0-9]{2}$ ]]; then
        fail "Factory census agent id format invalid '${id}'"
      fi
      if [[ "$row_path" != "${FACTORY_DIR}/agents/"* ]]; then
        fail "Factory census path '${row_path}' does not match kind '${kind}'"
      fi
      ;;
    skill)
      if [[ ! "$id" =~ ^S-LEARN-[0-9]{2}$ ]]; then
        fail "Factory census skill id format invalid '${id}'"
      fi
      if [[ "$row_path" != "${FACTORY_DIR}/skills/"* ]]; then
        fail "Factory census path '${row_path}' does not match kind '${kind}'"
      fi
      ;;
    task)
      if [[ ! "$id" =~ ^B-TASK-[0-9]{2}$ ]]; then
        fail "Factory census task id format invalid '${id}'"
      fi
      if [[ "$row_path" != "${FACTORY_DIR}/tasks/"* ]]; then
        fail "Factory census path '${row_path}' does not match kind '${kind}'"
      fi
      ;;
    *)
      fail "Factory census row has invalid kind '${kind}'"
      ;;
  esac

  case "$disposition" in
    keep)
      if [[ ! "$reason" =~ ^K- ]]; then
        fail "Factory census reason '${reason}' does not match disposition '${disposition}'"
      fi
      ;;
    replace)
      if [[ ! "$reason" =~ ^R- ]]; then
        fail "Factory census reason '${reason}' does not match disposition '${disposition}'"
      fi
      ;;
    remove)
      if [[ ! "$reason" =~ ^X- ]]; then
        fail "Factory census reason '${reason}' does not match disposition '${disposition}'"
      fi
      ;;
    *)
      fail "Factory census row has invalid disposition '${disposition}'"
      ;;
  esac

  if [[ ! -f "$row_path" ]]; then
    fail "Factory census path does not exist '${row_path}'"
  fi

  row_key="${kind}:${id}"
  if [[ -n "${census_id_map[$row_key]+set}" ]]; then
    fail "Factory census has duplicate id row '${row_key}'"
  fi
  census_id_map["$row_key"]=1

  if [[ -n "${census_path_map[$row_path]+set}" ]]; then
    fail "Factory census has duplicate path row '${row_path}'"
  fi
  census_path_map["$row_path"]=1
done < <(extract_factory_matrix_rows "$FACTORY_CENSUS_REGISTRY")

if [[ ${#census_path_map[@]} -eq 0 ]]; then
  fail "Factory census matrix has no definition rows in '${FACTORY_CENSUS_REGISTRY}'"
fi

while IFS=$'\t' read -r kind id row_path disposition reason; do
  [[ "$disposition" == "remove" ]] || continue
  if [[ -f "$row_path" ]]; then
    fail "Retired leaf on disk: '${row_path}' has disposition=remove in census but file still exists"
  fi
done < <(extract_factory_matrix_rows "$FACTORY_CENSUS_REGISTRY")

while IFS='|' read -r ret_kind ret_id ret_path ret_dp ret_reason; do
  ret_kind="${ret_kind//[[:space:]]/}"
  ret_path="${ret_path//[[:space:]]/}"
  case "$ret_kind" in
    Kind|---|"") continue ;;
  esac
  [[ -n "$ret_path" ]] || continue
  if [[ -f "$ret_path" ]]; then
    fail "Ghost reappearance: retired definition '${ret_path}' (ID: ${ret_id}) exists on disk; addendum authorization required"
  fi
done < <(awk '/^## Retired Definitions/{f=1;next} f && /^\|/{print}' "$FACTORY_CENSUS_REGISTRY")

while IFS= read -r file; do
  rel_path="${file#${REPO_ROOT}/}"
  if [[ -z "${census_path_map[$rel_path]+set}" ]]; then
    fail "Factory census missing row for definition '${rel_path}'"
  fi
  base_name="$(basename "$rel_path" .md)"
  if [[ -z "${agent_id_map[$base_name]+set}" ]]; then
    fail "Ghost Artifact: '${rel_path}' exists but is not registered in AGENTS.md"
  fi
done < <(find "${FACTORY_DIR}/agents" -type f -name "*.md")

while IFS= read -r file; do
  rel_path="${file#${REPO_ROOT}/}"
  if [[ -z "${census_path_map[$rel_path]+set}" ]]; then
    fail "Factory census missing row for definition '${rel_path}'"
  fi
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
  if [[ -z "${census_path_map[$rel_path]+set}" ]]; then
    fail "Factory census missing row for definition '${rel_path}'"
  fi
  if [[ -z "${task_path_map[$rel_path]+set}" ]]; then
    fail "Ghost Artifact: '${rel_path}' exists but is not registered in TASKS.md"
  fi
done < <(find "${FACTORY_DIR}/tasks" -type f -name "*.md")

mapfile -t runtime_factory_paths < <(collect_runtime_factory_paths | sort -u)
for runtime_path in "${runtime_factory_paths[@]}"; do
  if [[ ! -f "$runtime_path" ]]; then
    continue
  fi
  if [[ -z "${census_path_map[$runtime_path]+set}" ]]; then
    fail "Factory census missing runtime reference row '${runtime_path}'"
  fi
done

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

# baseline: enforce runtime-role naming contract on agent identities.
if compgen -G "${FACTORY_DIR}/agents/*.md" > /dev/null; then
  for agent in "${FACTORY_DIR}/agents"/*.md; do
    agent_name="$(basename "$agent")"
    identity_section="$(extract_section "## Identity Contract" "$agent")"

    runtime_role="$(printf '%s\n' "$identity_section" | awk '/^[[:space:]]*-[[:space:]]*`runtime_role`:[[:space:]]*`[^`]+`[[:space:]]*$/ { line=$0; sub(/^[[:space:]]*-[[:space:]]*`runtime_role`:[[:space:]]*`/, "", line); sub(/`[[:space:]]*$/, "", line); print line; exit }')"
    runtime_role="$(trim "$runtime_role")"
    if [[ -z "$runtime_role" ]]; then
      fail "${agent_name} missing Identity Contract field 'runtime_role'"
    fi

    stance_id="$(printf '%s\n' "$identity_section" | awk '/^[[:space:]]*-[[:space:]]*`stance_id`:[[:space:]]*`[^`]+`[[:space:]]*$/ { line=$0; sub(/^[[:space:]]*-[[:space:]]*`stance_id`:[[:space:]]*`/, "", line); sub(/`[[:space:]]*$/, "", line); print line; exit }')"
    stance_id="$(trim "$stance_id")"
    if [[ -z "$stance_id" ]]; then
      fail "${agent_name} missing Identity Contract field 'stance_id'"
    fi

    case "$runtime_role" in
      foreman|auditor|conformist) ;;
      *) fail "${agent_name} runtime_role '${runtime_role}' is not in allowed set {foreman,auditor,conformist}" ;;
    esac

    case "$stance_id" in
      addenda|audit|conformist) ;;
      *) fail "${agent_name} stance_id '${stance_id}' is not in allowed set {addenda,audit,conformist}" ;;
    esac
  done
fi

# baseline: enforce skill method contract fields.
if compgen -G "${FACTORY_DIR}/skills/*.md" > /dev/null; then
  for skill in "${FACTORY_DIR}/skills"/*.md; do
    skill_name="$(basename "$skill")"
    skill_id_expected="$(basename "$skill" .md | tr '[:lower:]' '[:upper:]')"

    method_count="$(grep -c '^## Method Contract$' "$skill" || true)"
    if [[ "$method_count" -eq 0 ]]; then
      fail "${skill_name} missing required section '## Method Contract'"
      continue
    fi
    if [[ "$method_count" -gt 1 ]]; then
      fail "${skill_name} has duplicate section '## Method Contract'"
    fi

    method_section="$(extract_section "## Method Contract" "$skill")"
    if [[ -z "$(printf '%s\n' "$method_section" | sed '/^[[:space:]]*$/d')" ]]; then
      fail "${skill_name} section '## Method Contract' is empty"
      continue
    fi

    for key in skill_id method inputs outputs invariants; do
      value="$(printf '%s\n' "$method_section" | awk -v key="$key" '
        $0 ~ "^[[:space:]]*-[[:space:]]*`" key "`:[[:space:]]*`[^`]*`[[:space:]]*$" {
          line=$0
          sub("^[[:space:]]*-[[:space:]]*`" key "`:[[:space:]]*`", "", line)
          sub("`[[:space:]]*$", "", line)
          print line
          exit
        }
      ')"
      value="$(trim "$value")"
      if [[ -z "$value" || "$value" == "Not provided" ]]; then
        fail "${skill_name} Method Contract field '${key}' is missing or empty"
      fi
      if [[ "$key" == "skill_id" && "$value" != "$skill_id_expected" ]]; then
        fail "${skill_name} Method Contract skill_id '${value}' does not match expected '${skill_id_expected}'"
      fi
    done
  done
fi

# baseline: enforce task objective contract fields.
if compgen -G "${FACTORY_DIR}/tasks/*.md" > /dev/null; then
  for task in "${FACTORY_DIR}/tasks"/*.md; do
    task_name="$(basename "$task")"
    task_id_expected="$(basename "$task" .md | tr '[:lower:]' '[:upper:]')"

    objective_count="$(grep -c '^## Objective Contract$' "$task" || true)"
    if [[ "$objective_count" -eq 0 ]]; then
      fail "${task_name} missing required section '## Objective Contract'"
      continue
    fi
    if [[ "$objective_count" -gt 1 ]]; then
      fail "${task_name} has duplicate section '## Objective Contract'"
    fi

    objective_section="$(extract_section "## Objective Contract" "$task")"
    if [[ -z "$(printf '%s\n' "$objective_section" | sed '/^[[:space:]]*$/d')" ]]; then
      fail "${task_name} section '## Objective Contract' is empty"
      continue
    fi

    for key in task_id objective inputs outputs invariants; do
      value="$(printf '%s\n' "$objective_section" | awk -v key="$key" '
        $0 ~ "^[[:space:]]*-[[:space:]]*`" key "`:[[:space:]]*`[^`]*`[[:space:]]*$" {
          line=$0
          sub("^[[:space:]]*-[[:space:]]*`" key "`:[[:space:]]*`", "", line)
          sub("`[[:space:]]*$", "", line)
          print line
          exit
        }
      ')"
      value="$(trim "$value")"
      if [[ -z "$value" || "$value" == "Not provided" ]]; then
        fail "${task_name} Objective Contract field '${key}' is missing or empty"
      fi
      if [[ "$key" == "task_id" && "$value" != "$task_id_expected" ]]; then
        fail "${task_name} Objective Contract task_id '${value}' does not match expected '${task_id_expected}'"
      fi
    done
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
