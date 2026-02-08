#!/usr/bin/env bash
set -euo pipefail

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

TASKS_DIR="docs/library/tasks"
TASKS_REGISTRY="docs/ops/registry/TASKS.md"

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

is_placeholder_value() {
  local value="$1"
  if [[ -z "$value" ]]; then
    return 0
  fi
  case "$value" in
    *"["*|*"]"*|*"TBD"*|*"TODO"*|*"ENTER_"*|*"REPLACE_"*|*"Not provided"*)
      return 0
      ;;
  esac
  return 1
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

field_value() {
  local label="$1"
  local path="$2"
  awk -v label="$label" '
    {
      needle = "**" label ":**"
      pos = index($0, needle)
      if (pos) {
        text = substr($0, pos + length(needle))
        gsub(/^[[:space:]]+/, "", text)
        print text
        exit
      }
    }
  ' "$path"
}

require_file "$TASKS_REGISTRY"

if [[ ! -d "$TASKS_DIR" ]]; then
  fail "Tasks directory missing at ${TASKS_DIR}"
fi

contraction_pattern="\\b(don\\x27t|can\\x27t|won\\x27t|it\\x27s|shouldn\\x27t|didn\\x27t|doesn\\x27t|isn\\x27t|aren\\x27t|wasn\\x27t|weren\\x27t|haven\\x27t|hasn\\x27t|hadn\\x27t|wouldn\\x27t|couldn\\x27t|mustn\\x27t|shan\\x27t|let\\x27s|they\\x27re|we\\x27re|you\\x27re|i\\x27m|i\\x27ve|i\\x27ll|i\\x27d)\\b"
contraction_hits="$(rg -n -i "$contraction_pattern" "$TASKS_DIR" 2>/dev/null || true)"
if [[ -n "$contraction_hits" ]]; then
  fail "Contractions found in task files."
  echo "$contraction_hits" >&2
fi

mapfile -t registry_rows < <(awk -F'|' '
  $0 ~ /^\|/ && $0 !~ /^\|[[:space:]]*---/ {
    id=$2; name=$3; path=$4
    gsub(/^[[:space:]]+/, "", id)
    gsub(/[[:space:]]+$/, "", id)
    gsub(/^[[:space:]]+/, "", name)
    gsub(/[[:space:]]+$/, "", name)
    gsub(/^[[:space:]]+/, "", path)
    gsub(/[[:space:]]+$/, "", path)
    if (id != "" && id != "ID") print id "|" name "|" path
  }
' "$TASKS_REGISTRY")

declare -A registry_ids

declare -A registry_paths

declare -A registry_names

for row in "${registry_rows[@]}"; do
  id="${row%%|*}"
  rest="${row#*|}"
  name="${rest%%|*}"
  path="${rest#*|}"

  if [[ -n "${registry_ids[$id]+set}" ]]; then
    fail "Registry duplicate task ID '${id}'"
  else
    registry_ids["$id"]=1
  fi

  if [[ -n "$path" ]]; then
    if [[ -n "${registry_paths[$path]+set}" ]]; then
      fail "Registry duplicate task path '${path}'"
    else
      registry_paths["$path"]=1
    fi
  fi

  registry_names["$id"]="$name"

  if [[ -n "$path" && ! -f "$path" ]]; then
    fail "Registry references missing task file '${path}'"
  fi

done

if compgen -G "${TASKS_DIR}/*.md" > /dev/null; then
  while IFS= read -r file; do
    rel_path="${file#${REPO_ROOT}/}"
    if [[ -z "${registry_paths[$rel_path]+set}" ]]; then
      fail "Ghost task file '${rel_path}' is not registered"
    fi
  done < <(find "${TASKS_DIR}" -maxdepth 1 -type f -name '*.md')
fi

if compgen -G "${TASKS_DIR}/*.md" > /dev/null; then
  for task in "${TASKS_DIR}"/*.md; do
    task_name="$(basename "$task")"
    header_line="$(head -n 1 "$task" | tr -d '\r')"
    if [[ ! "$header_line" =~ ^#\ Task:\  ]]; then
      fail "${task_name} missing required '# Task: <name>' header"
    fi

    task_id="$(basename "$task" .md)"
    registry_name="${registry_names[$task_id]:-}"
    if [[ -n "$registry_name" ]]; then
      header_name="${header_line#\# }"
      if [[ "$header_name" != "$registry_name" ]]; then
        fail "${task_name} header name '${header_name}' does not match registry name '${registry_name}'"
      fi
    fi

    for section in "## Provenance" "## Orchestration" "## Pointers" "## Execution Logic" "## Scope Boundary"; do
      section_count="$(grep -c "^${section}$" "$task" || true)"
      if [[ "$section_count" -eq 0 ]]; then
        fail "${task_name} missing required section '${section}'"
      elif [[ "$section_count" -gt 1 ]]; then
        fail "${task_name} has duplicate section '${section}'"
      fi
    done

    for label in "Captured" "DP-ID" "Branch" "HEAD" "Objective"; do
      value="$(field_value "$label" "$task")"
      value="$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      if is_placeholder_value "$value"; then
        fail "${task_name} missing or placeholder value for '${label}'"
      fi
    done

    for label in "Primary Agent" "Supporting Agents"; do
      value="$(field_value "$label" "$task")"
      value="$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
      if is_placeholder_value "$value"; then
        fail "${task_name} missing or placeholder value for '${label}'"
      fi
    done

    pointers_section="$(extract_section "## Pointers" "$task")"

    if ! grep -q 'PoT.md' <<< "$pointers_section"; then
      fail "${task_name} missing PoT.md pointer in Pointers section"
    fi
    if ! grep -q 'docs/GOVERNANCE.md' <<< "$pointers_section"; then
      fail "${task_name} missing docs/GOVERNANCE.md pointer in Pointers section"
    fi
    if ! grep -q 'TASK.md' <<< "$pointers_section"; then
      fail "${task_name} missing TASK.md pointer in Pointers section"
    fi

    mapfile -t pointer_tokens < <(printf '%s\n' "$pointers_section" | grep -oE '`[^`]+`' | sed -e 's/`//g' || true)
    for token in "${pointer_tokens[@]}"; do
      normalized="$(normalize_token "$token")"
      if [[ "$normalized" == *" "* ]]; then
        continue
      fi
      if [[ "$normalized" == /* || "$normalized" == ~* ]]; then
        fail "${task_name} pointer token uses absolute or home path '${token}'"
        continue
      fi
      case "$normalized" in
        PoT.md|TASK.md|docs/*|ops/*|tools/*|*.md|*.sh)
          if [[ ! -e "$REPO_ROOT/$normalized" ]]; then
            fail "${task_name} pointer token '${token}' does not exist"
          fi
          ;;
      esac
    done

    mapfile -t agent_refs < <(rg -o "R-AGENT-[0-9]{2,}" "$task" | sort -u)
    for ref in "${agent_refs[@]}"; do
      if [[ ! -f "$REPO_ROOT/docs/library/agents/${ref}.md" ]]; then
        fail "${task_name} references missing agent ${ref}"
      fi
    done

    mapfile -t skill_refs < <(rg -o "S-LEARN-[0-9]{2,}" "$task" | sort -u)
    for ref in "${skill_refs[@]}"; do
      if [[ ! -f "$REPO_ROOT/docs/library/skills/${ref}.md" ]]; then
        fail "${task_name} references missing skill ${ref}"
      fi
    done

    execution_section="$(extract_section "## Execution Logic" "$task")"
    ambiguous_pattern='(^|[^[:alpha:]])(check|review|ensure|confirm|validate|verify|audit|analyze|assess|inspect)($|[^[:alpha:]])'
    while IFS= read -r line; do
      if [[ "$line" =~ ^[[:space:]]*[0-9]+\.[[:space:]] ]]; then
        if echo "$line" | grep -Eqi "$ambiguous_pattern" && [[ "$line" != *'`'* ]]; then
          fail "${task_name} contains narrative execution language without pointers: ${line}"
        fi
      fi
    done <<< "$execution_section"
  done
fi

if (( failures > 0 )); then
  echo "FAILED: ${failures} error(s) detected." >&2
  exit 1
fi

echo "OK: Task lint checks passed."
