#!/usr/bin/env bash

project_lib_die() {
  echo "ERROR: $*" >&2
  exit 1
}

project_lib_trim() {
  local s="$1"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf "%s" "$s"
}

project_lib_require_repo_root() {
  if ! command -v git >/dev/null 2>&1; then
    project_lib_die "git is required but was not found on PATH."
  fi

  local repo_root
  if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    project_lib_die "git repo not found. Run from repo root."
  fi

  if [[ "$(pwd -P)" != "$repo_root" ]]; then
    project_lib_die "Run from repo root: $repo_root"
  fi

  PROJECT_LIB_REPO_ROOT="$repo_root"
}

project_lib_registry_rel() {
  printf "%s" "docs/library/datasets/PROJECT_REGISTRY.md"
}

project_lib_registry_path() {
  printf "%s/%s" "$PROJECT_LIB_REPO_ROOT" "$(project_lib_registry_rel)"
}

project_lib_template_rel() {
  printf "%s" "ops/init/projects/default/README.md"
}

project_lib_template_path() {
  printf "%s/%s" "$PROJECT_LIB_REPO_ROOT" "$(project_lib_template_rel)"
}

project_lib_subdir_template_rel() {
  local subdir="$1"
  printf "%s" "ops/init/projects/default/${subdir}/README.md"
}

project_lib_subdir_template_path() {
  local subdir="$1"
  printf "%s/%s" "$PROJECT_LIB_REPO_ROOT" "$(project_lib_subdir_template_rel "$subdir")"
}

project_lib_require_registry() {
  local rel path
  rel="$(project_lib_registry_rel)"
  path="$(project_lib_registry_path)"
  if [[ ! -f "$path" ]]; then
    echo "ERROR: Missing registry: $rel" >&2
    return 1
  fi
}

project_lib_slugify() {
  local raw="$1"
  raw="$(printf "%s" "$raw" | tr '[:upper:]' '[:lower:]')"
  raw="$(printf "%s" "$raw" | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')"
  printf "%s" "$raw"
}

project_lib_next_project_id() {
  local max=0
  local id

  while IFS=$'\t' read -r id _; do
    if [[ "$id" =~ ^proj-([0-9]+)$ ]]; then
      local num="${BASH_REMATCH[1]}"
      if (( 10#$num > max )); then
        max=$((10#$num))
      fi
    fi
  done < <(project_lib_registry_rows)

  printf "proj-%04d" $((max + 1))
}

project_lib_is_valid_id() {
  [[ "$1" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]
}

project_lib_registry_rows() {
  local path
  project_lib_require_registry
  path="$(project_lib_registry_path)"

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

project_lib_registry_has_id() {
  local target_id="$1"
  local id name created status root notes

  while IFS=$'\t' read -r id name created status root notes; do
    if [[ "$id" == "$target_id" ]]; then
      return 0
    fi
  done < <(project_lib_registry_rows)

  return 1
}

project_lib_registry_has_root_path() {
  local target_root="$1"
  local id name created status root notes

  while IFS=$'\t' read -r id name created status root notes; do
    if [[ "$root" == "$target_root" ]]; then
      return 0
    fi
  done < <(project_lib_registry_rows)

  return 1
}

project_lib_escape_sed() {
  printf "%s" "$1" | sed -e 's/[\\/&]/\\&/g'
}

project_lib_render_template() {
  local template="$1"
  local project_id="$2"
  local display_name="$3"
  local created_at="$4"

  local esc_id esc_name esc_date
  esc_id="$(project_lib_escape_sed "$project_id")"
  esc_name="$(project_lib_escape_sed "$display_name")"
  esc_date="$(project_lib_escape_sed "$created_at")"

  sed \
    -e "s/{{PROJECT_ID}}/$esc_id/g" \
    -e "s/{{DISPLAY_NAME}}/$esc_name/g" \
    -e "s/{{CREATED_AT}}/$esc_date/g" \
    "$template"
}

project_lib_get_current_project_id() {
  local path
  project_lib_require_registry
  path="$(project_lib_registry_path)"

  awk '
    /^Current[[:space:]]*:/ {
      sub(/^Current[[:space:]]*:[[:space:]]*/, "", $0)
      sub(/[[:space:]]+$/, "", $0)
      print $0
      exit
    }
  ' "$path"
}

project_lib_set_current_project_id() {
  local project_id="$1"
  local rel path tmp
  rel="$(project_lib_registry_rel)"
  path="$(project_lib_registry_path)"

  if [[ ! -f "$path" ]]; then
    echo "ERROR: Missing registry: $rel" >&2
    return 1
  fi

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

project_lib_add_registry_entry() {
  local project_id="$1"
  local display_name="$2"
  local created_at="$3"
  local status="$4"
  local root_path="$5"
  local notes="$6"

  local rel path tmp
  rel="$(project_lib_registry_rel)"
  path="$(project_lib_registry_path)"

  if [[ ! -f "$path" ]]; then
    echo "ERROR: Missing registry: $rel" >&2
    return 1
  fi

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
