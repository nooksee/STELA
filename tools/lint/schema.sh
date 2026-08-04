#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

usage() {
  cat <<'USAGE'
Usage: tools/lint/schema.sh
USAGE
}

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

extract_frontmatter() {
  local path="$1"
  local line_no=0
  local line=""
  local found_end=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))
    if (( line_no == 1 )); then
      if [[ "$line" != "---" ]]; then
        return 2
      fi
      continue
    fi

    if [[ "$line" == "---" ]]; then
      found_end=1
      break
    fi

    printf '%s\n' "$line"
  done < "$path"

  if (( found_end == 0 )); then
    return 3
  fi
}

frontmatter_value() {
  local key="$1"
  local content="$2"
  printf '%s\n' "$content" | awk -v key="$key" '
    $0 ~ ("^" key ":[[:space:]]*") {
      value=$0
      sub("^[^:]+:[[:space:]]*", "", value)
      print value
      exit
    }
  '
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "$#" -gt 0 ]]; then
  usage >&2
  exit 1
fi

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  die "Must be run inside a git repository."
fi

cd "$REPO_ROOT" || exit 1
trap 'emit_binary_leaf "lint-schema" "finish"' EXIT
emit_binary_leaf "lint-schema" "start"

DEFINITIONS_DIR="${REPO_ROOT}/archives/definitions"
[[ -d "$DEFINITIONS_DIR" ]] || die "missing definitions directory: archives/definitions"
SURFACES_DIR="${REPO_ROOT}/archives/surfaces"
[[ -d "$SURFACES_DIR" ]] || die "missing surfaces directory: archives/surfaces"
MANIFESTS_DIR="${REPO_ROOT}/archives/manifests"
[[ -d "$MANIFESTS_DIR" ]] || die "missing manifests directory: archives/manifests"

lint_schema_leaf() {
  local path="$1"
  local rel_path="$2"
  frontmatter=""
  if ! frontmatter="$(extract_frontmatter "$path")"; then
    status=$?
    if [[ "$status" -eq 2 ]]; then
      fail "${rel_path}: first line must be YAML front-matter delimiter '---'"
    fi
    if [[ "$status" -eq 3 ]]; then
      fail "${rel_path}: YAML front-matter block is not closed with '---'"
    fi
    fail "${rel_path}: failed to parse YAML front-matter block"
  fi

  trace_id="$(trim "$(frontmatter_value "trace_id" "$frontmatter")")"
  packet_id="$(trim "$(frontmatter_value "packet_id" "$frontmatter")")"
  created_at="$(trim "$(frontmatter_value "created_at" "$frontmatter")")"
  previous="$(trim "$(frontmatter_value "previous" "$frontmatter")")"

  [[ -n "$trace_id" ]] || fail "${rel_path}: missing or empty front-matter key 'trace_id'"
  [[ -n "$packet_id" ]] || fail "${rel_path}: missing or empty front-matter key 'packet_id'"
  [[ -n "$created_at" ]] || fail "${rel_path}: missing or empty front-matter key 'created_at'"
  [[ -n "$previous" ]] || fail "${rel_path}: missing or empty front-matter key 'previous'"

  if [[ ! "$created_at" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]; then
    fail "${rel_path}: created_at must use ISO-8601 UTC format with Z suffix (YYYY-MM-DDTHH:MM:SSZ)"
  fi

  if [[ "$previous" != "(none)" ]]; then
    if [[ "$previous" == /* || "$previous" == ./* || "$previous" == ../* ]]; then
      fail "${rel_path}: previous must be repository-relative or '(none)'"
    fi
    if [[ "$previous" == *".."* ]]; then
      fail "${rel_path}: previous must not contain '..' path segments"
    fi
    if [[ ! "$previous" =~ ^[A-Za-z0-9._/-]+\.md$ ]]; then
      fail "${rel_path}: previous must end with .md and contain only repository-relative path characters"
    fi
  fi
}

is_surface_schema_candidate() {
  local rel_path="$1"
  local filename="${rel_path#archives/surfaces/}"
  if [[ "$filename" =~ ^PoW-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$ ]]; then
    return 0
  fi
  if [[ "$filename" =~ ^SoP-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$ ]]; then
    return 0
  fi
  if [[ "$filename" =~ ^TASK-DP-[A-Z]+-[0-9]{4,}-[0-9a-f]{7,}\.md$ ]]; then
    return 0
  fi
  return 1
}

is_manifest_schema_candidate() {
  local rel_path="$1"
  local filename="${rel_path#archives/manifests/}"
  if [[ "$filename" =~ ^compile-[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}-[0-9a-f]{7,}\.md$ ]]; then
    return 0
  fi
  return 1
}

resolve_current_surface_source() {
  local root_path="$1"
  local line_count=""
  local pointer=""

  [[ -f "$root_path" ]] || fail "missing current surface: ${root_path#${REPO_ROOT}/}"
  line_count="$(awk 'END { print NR }' "$root_path")"
  if [[ "$line_count" != "1" ]]; then
    printf '%s' "$root_path"
    return 0
  fi

  pointer="$(trim "$(cat "$root_path")")"
  pointer="${pointer#./}"
  [[ "$pointer" =~ ^archives/surfaces/[A-Za-z0-9._/-]+\.md$ ]] \
    || fail "current surface pointer is invalid: ${root_path#${REPO_ROOT}/} -> ${pointer}"
  [[ -f "${REPO_ROOT}/${pointer}" ]] \
    || fail "current surface pointer target is missing: ${root_path#${REPO_ROOT}/} -> ${pointer}"
  printf '%s' "${REPO_ROOT}/${pointer}"
}

lint_current_sop_contract() {
  local root_path="$1"
  local source_path="$2"
  local -a labels=(
    "Current objective"
    "Accepted baseline"
    "Provisional work"
    "Unresolved tensions"
    "Rejected directions"
    "Exact next action"
  )
  local label=""
  local count=0
  local value=""
  local shipment_count=0
  local line_count=""
  local frontmatter=""
  local state_model=""

  line_count="$(awk 'END { print NR }' "$root_path")"
  if [[ "$line_count" == "1" ]]; then
    frontmatter="$(extract_frontmatter "$source_path")" \
      || fail "current SoP pointer target lacks valid frontmatter: ${source_path#${REPO_ROOT}/}"
    state_model="$(trim "$(frontmatter_value "state_model" "$frontmatter")")"
    [[ "$state_model" == "present-v1" ]] \
      || fail "current SoP pointer target must declare state_model: present-v1 in ${source_path#${REPO_ROOT}/}"
  fi

  for label in "${labels[@]}"; do
    count="$(grep -cE "^-[[:space:]]+${label}:[[:space:]]*[^[:space:]].*$" "$source_path" || true)"
    [[ "$count" == "1" ]] \
      || fail "current SoP field must appear exactly once: field=${label} count=${count} source=${source_path#${REPO_ROOT}/}"
    value="$(sed -nE "s/^-[[:space:]]+${label}:[[:space:]]*//p" "$source_path")"
    if grep -Eiq '(^|[^[:alnum:]])(TBD|TODO|PLACEHOLDER|REPLACE_ME)([^[:alnum:]]|$)' <<< "$value"; then
      fail "current SoP field contains placeholder text: field=${label} source=${source_path#${REPO_ROOT}/}"
    fi
  done

  shipment_count="$(grep -cE '^##[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}.*DP-[A-Z]+-[0-9]{4,}' "$source_path" || true)"
  [[ "$shipment_count" == "1" ]] \
    || fail "current SoP must contain exactly one latest-shipment entry: count=${shipment_count} source=${source_path#${REPO_ROOT}/}"
}

lint_current_task_pointer_contract() {
  local root_path="$1"
  local source_path="$2"
  local line_count=""
  local frontmatter=""
  local routing_state=""
  local packet_state=""

  line_count="$(awk 'END { print NR }' "$root_path")"
  if [[ "$line_count" != "1" ]]; then
    return 0
  fi

  frontmatter="$(extract_frontmatter "$source_path")" \
    || fail "current TASK pointer target lacks valid frontmatter: ${source_path#${REPO_ROOT}/}"
  routing_state="$(trim "$(frontmatter_value "routing_state" "$frontmatter")")"
  packet_state="$(trim "$(frontmatter_value "packet_state" "$frontmatter")")"
  [[ "$routing_state" == "idle" ]] \
    || fail "pointer-head TASK must declare routing_state: idle in ${source_path#${REPO_ROOT}/}"
  [[ "$packet_state" == "completed" ]] \
    || fail "pointer-head TASK must declare packet_state: completed in ${source_path#${REPO_ROOT}/}"
}

definitions_checked=0
surfaces_checked=0
manifests_checked=0

mapfile -t definition_candidates < <(find "$DEFINITIONS_DIR" -maxdepth 1 -type f | sort)
for path in "${definition_candidates[@]}"; do
  rel_path="${path#${REPO_ROOT}/}"
  if [[ "$rel_path" == "archives/definitions/.gitkeep" ]]; then
    continue
  fi
  if [[ "$rel_path" != *.md ]]; then
    continue
  fi
  lint_schema_leaf "$path" "$rel_path"
  definitions_checked=$((definitions_checked + 1))
done

mapfile -t surface_candidates < <(find "$SURFACES_DIR" -maxdepth 1 -type f | sort)
for path in "${surface_candidates[@]}"; do
  rel_path="${path#${REPO_ROOT}/}"
  if [[ "$rel_path" == "archives/surfaces/.gitkeep" ]]; then
    continue
  fi
  if [[ "$rel_path" != *.md ]]; then
    continue
  fi
  if ! is_surface_schema_candidate "$rel_path"; then
    continue
  fi
  lint_schema_leaf "$path" "$rel_path"
  surfaces_checked=$((surfaces_checked + 1))
done

mapfile -t manifest_candidates < <(find "$MANIFESTS_DIR" -maxdepth 1 -type f | sort)
for path in "${manifest_candidates[@]}"; do
  rel_path="${path#${REPO_ROOT}/}"
  if [[ "$rel_path" == "archives/manifests/.gitkeep" ]]; then
    continue
  fi
  if [[ "$rel_path" != *.md ]]; then
    continue
  fi
  if ! is_manifest_schema_candidate "$rel_path"; then
    continue
  fi
  lint_schema_leaf "$path" "$rel_path"
  manifests_checked=$((manifests_checked + 1))
done

current_sop_source="$(resolve_current_surface_source "${REPO_ROOT}/SoP.md")"
lint_current_sop_contract "${REPO_ROOT}/SoP.md" "$current_sop_source"

current_task_source="$(resolve_current_surface_source "${REPO_ROOT}/TASK.md")"
lint_current_task_pointer_contract "${REPO_ROOT}/TASK.md" "$current_task_source"

checked=$((definitions_checked + surfaces_checked + manifests_checked))
echo "OK: schema lint passed (${checked} file(s) checked: definitions=${definitions_checked}, surfaces=${surfaces_checked}, manifests=${manifests_checked})."
