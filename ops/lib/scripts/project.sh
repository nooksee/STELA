#!/usr/bin/env bash

project_die() {
  echo "ERROR: $*" >&2
  exit 1
}

project_trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf "%s" "$s"
}

project_require_safe_token() {
  local label="$1"
  local value="$2"

  if [[ -z "$value" ]]; then
    project_die "Missing ${label}."
  fi

  if [[ ! "$value" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    project_die "Invalid ${label}: ${value}"
  fi
}

project_require_realpath() {
  local path="$1"
  local resolved=""

  if ! command -v realpath >/dev/null 2>&1; then
    project_die "realpath is required but was not found on PATH."
  fi

  if ! resolved="$(realpath "$path" 2>/dev/null)"; then
    project_die "Failed to resolve path: ${path}"
  fi

  printf "%s" "$resolved"
}

project_require_path_under_root() {
  local label="$1"
  local repo_root="$2"
  local path="$3"
  local resolved=""
  local root_resolved=""

  if [[ -z "$path" ]]; then
    project_die "Missing ${label} path."
  fi

  root_resolved="$(project_require_realpath "$repo_root")"
  resolved="$(project_require_realpath "$path")"

  case "$resolved" in
    "$root_resolved"|"$root_resolved/"*)
      ;;
    *)
      project_die "Resolved ${label} path escapes repo: ${path}"
      ;;
  esac

  printf "%s" "$resolved"
}

project_resolve_agent_file() {
  local target="$1"
  local repo_root="${PROJECT_REPO_ROOT:-}"
  local match=""
  local match_count=0
  local file name

  project_require_safe_token "agent name" "$target"

  if [[ -z "$repo_root" ]]; then
    if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
      project_die "git repo not found. Run from repo root."
    fi
  fi
  repo_root="$(project_require_realpath "$repo_root")"

  for file in "${repo_root}"/docs/library/agents/R-AGENT-*.md; do
    [[ -f "$file" ]] || continue
    name="$(awk '
      BEGIN { in_header=0 }
      /^---[[:space:]]*$/ { if (in_header == 0) { in_header=1; next } else { exit } }
      in_header && /^name:[[:space:]]*/ {
        sub(/^name:[[:space:]]*/, "", $0)
        print $0
        exit
      }
    ' "$file")"
    if [[ "$name" == "$target" ]]; then
      match="$file"
      match_count=$((match_count + 1))
    fi
  done

  if (( match_count == 0 )); then
    project_die "Agent not found: ${target}"
  fi
  if (( match_count > 1 )); then
    project_die "Agent name is ambiguous: ${target}"
  fi

  match="$(project_require_path_under_root "agent file" "$repo_root" "$match")"
  printf "%s" "$match"
}

project_extract_agent_role() {
  local file="$1"
  local repo_root="${PROJECT_REPO_ROOT:-}"
  local role

  if [[ -z "$repo_root" ]]; then
    if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
      project_die "git repo not found. Run from repo root."
    fi
  fi
  repo_root="$(project_require_realpath "$repo_root")"

  file="$(project_require_path_under_root "agent file" "$repo_root" "$file")"
  role="$(awk '
    BEGIN { in_header=0; in_body=0 }
    /^---[[:space:]]*$/ {
      if (in_header == 0) { in_header=1; next }
      in_body=1
      next
    }
    in_body { print }
  ' "$file")"

  role="$(printf "%s\n" "$role" | sed "/./,\$!d")"
  if [[ -z "$role" ]]; then
    project_die "Agent role content missing: ${file}"
  fi

  printf "%s" "$role"
}

project_require_repo_root() {
  if ! command -v git >/dev/null 2>&1; then
    project_die "git is required but was not found on PATH."
  fi

  local repo_root
  if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    project_die "git repo not found. Run from repo root."
  fi
  repo_root="$(project_require_realpath "$repo_root")"

  if [[ "$(pwd -P)" != "$repo_root" ]]; then
    project_die "Run from repo root: $repo_root"
  fi

  PROJECT_REPO_ROOT="$repo_root"
}

project_registry_rel() {
  printf "%s" "ops/lib/manifests/PROJECTS.md"
}

project_registry_path() {
  printf "%s/%s" "$PROJECT_REPO_ROOT" "$(project_registry_rel)"
}

project_template_rel() {
  printf "%s" "ops/lib/project/SCAFFOLD.md"
}

project_template_path() {
  printf "%s/%s" "$PROJECT_REPO_ROOT" "$(project_template_rel)"
}

project_stela_template_rel() {
  printf "%s" "ops/lib/project/STELA.md"
}

project_stela_template_path() {
  printf "%s/%s" "$PROJECT_REPO_ROOT" "$(project_stela_template_rel)"
}

project_require_registry() {
  local rel path
  rel="$(project_registry_rel)"
  path="$(project_registry_path)"
  if [[ ! -f "$path" ]]; then
    echo "ERROR: Missing registry: $rel" >&2
    return 1
  fi
}

project_slugify() {
  local raw="$1"
  raw="$(printf "%s" "$raw" | tr '[:upper:]' '[:lower:]')"
  raw="$(printf "%s" "$raw" | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
  printf "%s" "$raw"
}

project_next_project_id() {
  local max=0
  local id

  while IFS=$'\t' read -r id _; do
    if [[ "$id" =~ ^proj-([0-9]+)$ ]]; then
      local num="${BASH_REMATCH[1]}"
      if (( 10#$num > max )); then
        max=$((10#$num))
      fi
    fi
  done < <(project_registry_rows)

  printf "proj-%04d" $((max + 1))
}

project_is_valid_id() {
  [[ "$1" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]
}

project_registry_rows() {
  local path
  project_require_registry
  path="$(project_registry_path)"
  path="$(project_require_path_under_root "registry" "$PROJECT_REPO_ROOT" "$path")"

  awk -F'|' '
    function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s; }
    /^##[[:space:]]+Registry/ { in_reg=1; next }
    in_reg && /^##[[:space:]]+/ { exit }
    in_reg && /^\|/ {
      id=trim($2)
      if (id == "" || id ~ /^-+$/ || id == "project_id") { next }
      name=trim($3)
      created=trim($4)
      status=trim($5)
      root=trim($6)
      notes=trim($7)
      print id "\t" name "\t" created "\t" status "\t" root "\t" notes
    }
  ' "$path"
}

project_registry_has_id() {
  local target_id="$1"
  local id name created status root notes

  project_require_safe_token "project id" "$target_id"
  while IFS=$'\t' read -r id name created status root notes; do
    if [[ "$id" == "$target_id" ]]; then
      return 0
    fi
  done < <(project_registry_rows)

  return 1
}

project_registry_has_root_path() {
  local target_root="$1"
  local id name created status root notes

  while IFS=$'\t' read -r id name created status root notes; do
    if [[ "$root" == "$target_root" ]]; then
      return 0
    fi
  done < <(project_registry_rows)

  return 1
}

project_escape_sed() {
  printf "%s" "$1" | sed -e 's/[\\/&]/\\&/g'
}

project_render_template() {
  local template="$1"
  local project_id="$2"
  local display_name="$3"
  local created_at="$4"

  project_require_safe_token "project id" "$project_id"
  project_require_safe_token "display name" "$display_name"
  project_require_safe_token "created at" "$created_at"
  template="$(project_require_path_under_root "template" "$PROJECT_REPO_ROOT" "$template")"

  local esc_id esc_name esc_date
  esc_id="$(project_escape_sed "$project_id")"
  esc_name="$(project_escape_sed "$display_name")"
  esc_date="$(project_escape_sed "$created_at")"

  sed \
    -e "s/{{PROJECT_ID}}/$esc_id/g" \
    -e "s/{{DISPLAY_NAME}}/$esc_name/g" \
    -e "s/{{CREATED_AT}}/$esc_date/g" \
    "$template"
}

project_get_current_project_id() {
  local path
  project_require_registry
  path="$(project_registry_path)"
  path="$(project_require_path_under_root "registry" "$PROJECT_REPO_ROOT" "$path")"

  awk '
    /^Current[[:space:]]*:/ {
      sub(/^Current[[:space:]]*:[[:space:]]*/, "", $0)
      sub(/[[:space:]]+$/, "", $0)
      if ($0 == "none" || $0 == "(none)" || $0 == "-") { exit }
      print $0
      exit
    }
  ' "$path"
}

project_set_current_project_id() {
  local project_id="$1"
  local rel path tmp
  rel="$(project_registry_rel)"
  path="$(project_registry_path)"

  project_require_safe_token "project id" "$project_id"
  if [[ ! -f "$path" ]]; then
    echo "ERROR: Missing registry: $rel" >&2
    return 1
  fi
  path="$(project_require_path_under_root "registry" "$PROJECT_REPO_ROOT" "$path")"

  tmp="$(mktemp)"
  if ! awk -v new_id="$project_id" '
      BEGIN { updated=0 }
      /^Current[[:space:]]*:/ {
        print "Current: " new_id
        updated=1
        next
      }
      { print }
      END { if (!updated) { exit 2 } }
    ' "$path" > "$tmp"; then
    rm -f "$tmp"
    echo "ERROR: Failed to update current project: $rel" >&2
    return 1
  fi

  cat "$tmp" > "$path"
  rm -f "$tmp"
}

project_add_registry_entry() {
  local project_id="$1"
  local display_name="$2"
  local created_at="$3"
  local status="$4"
  local root_path="$5"
  local notes="$6"

  local rel path tmp
  rel="$(project_registry_rel)"
  path="$(project_registry_path)"

  project_require_safe_token "project id" "$project_id"
  project_require_safe_token "display name" "$display_name"
  project_require_safe_token "created at" "$created_at"
  project_require_safe_token "status" "$status"
  project_require_safe_token "notes" "$notes"
  if [[ ! -f "$path" ]]; then
    echo "ERROR: Missing registry: $rel" >&2
    return 1
  fi
  path="$(project_require_path_under_root "registry" "$PROJECT_REPO_ROOT" "$path")"
  project_require_path_under_root "root path" "$PROJECT_REPO_ROOT" "${PROJECT_REPO_ROOT}/${root_path}" >/dev/null

  tmp="$(mktemp)"
  local row="| $project_id | $display_name | $created_at | $status | $root_path | $notes |"

  if ! awk -v row="$row" '
      /^##[[:space:]]+Registry/ { in_reg=1 }
      in_reg && /^##[[:space:]]+/ && $0 !~ /^##[[:space:]]+Registry/ {
        if (in_table && !inserted) { print row; inserted=1 }
        in_reg=0
      }
      in_reg && in_table && $0 !~ /^\|/ && !inserted {
        print row
        inserted=1
      }
      { print }
      in_reg && /^\|[[:space:]]*-+/ { in_table=1 }
      END {
        if (in_reg && in_table && !inserted) { print row; inserted=1 }
        if (!in_table) { exit 2 }
      }
    ' "$path" > "$tmp"; then
    rm -f "$tmp"
    echo "ERROR: Failed to update registry: $rel" >&2
    return 1
  fi

  # Preserve original file mode by writing back into the existing path.
  cat "$tmp" > "$path"
  rm -f "$tmp"
}
