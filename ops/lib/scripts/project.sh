#!/usr/bin/env bash

project_die() {
  echo "ERROR: $*" >&2
  exit 1
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

project_is_valid_id() {
  [[ "$1" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]
}

project_require_valid_id() {
  local project_id="$1"
  if [[ -z "$project_id" ]]; then
    project_die "Project ID is required."
  fi
  if ! project_is_valid_id "$project_id"; then
    project_die "Invalid project ID: ${project_id}"
  fi
}
