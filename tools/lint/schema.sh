#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/lint/schema.sh
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
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

DEFINITIONS_DIR="${REPO_ROOT}/archives/definitions"
[[ -d "$DEFINITIONS_DIR" ]] || die "missing definitions directory: archives/definitions"
SURFACES_DIR="${REPO_ROOT}/archives/surfaces"
[[ -d "$SURFACES_DIR" ]] || die "missing surfaces directory: archives/surfaces"

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

definitions_checked=0
surfaces_checked=0

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

checked=$((definitions_checked + surfaces_checked))
echo "OK: schema lint passed (${checked} file(s) checked: definitions=${definitions_checked}, surfaces=${surfaces_checked})."
