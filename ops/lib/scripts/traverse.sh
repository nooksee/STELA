#!/usr/bin/env bash
set -euo pipefail

source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd -P)"

scope="platform"
target=""

include_dirs=()
exclude_dirs=()
ignore_patterns=()

usage() {
  cat <<'USAGE'
Usage: ops/lib/scripts/traverse.sh [--scope=platform|full|project] [--project=<slug>]
                                  [--include-dir=DIR] [--exclude-dir=DIR] [--ignore-file=GLOB]
USAGE
}

for arg in "$@"; do
  case "$arg" in
    --scope=platform|--scope=full|--scope=project)
      scope="${arg#--scope=}"
      ;;
    --project=*)
      target="${arg#--project=}"
      [[ -n "$target" ]] || die "--project requires a value"
      ;;
    --target=*)
      target="${arg#--target=}"
      [[ -n "$target" ]] || die "--target requires a value"
      ;;
    --include-dir=*)
      d="$(normalize_path_token "${arg#--include-dir=}")"
      d="${d%/}"
      [[ -n "$d" ]] || die "--include-dir requires a value"
      include_dirs+=("$d")
      ;;
    --exclude-dir=*)
      d="$(normalize_path_token "${arg#--exclude-dir=}")"
      d="${d%/}"
      [[ -n "$d" ]] || die "--exclude-dir requires a value"
      exclude_dirs+=("$d")
      ;;
    --ignore-file=*)
      p="${arg#--ignore-file=}"
      [[ -n "$p" ]] || die "--ignore-file requires a value"
      ignore_patterns+=("$p")
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "Unknown argument: $arg"
      ;;
  esac
done

if [[ "$scope" == "project" && -z "$target" ]]; then
  die "--scope=project requires --project=<slug>"
fi

if [[ "$scope" != "project" && -n "$target" ]]; then
  die "--project is only valid with --scope=project"
fi

if [[ -n "$target" && "$target" == */* ]]; then
  die "--project must be a project slug"
fi

if ! command -v git >/dev/null 2>&1; then
  die "git is required but was not found on PATH."
fi

if ! repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  die "git repo not found. Run from repo root."
fi
REPO_ROOT="$repo_root"

if [[ "$(pwd -P)" != "$repo_root" ]]; then
  die "Run from repo root: $repo_root"
fi

if [[ "$scope" == "project" && ! -d "projects/$target" ]]; then
  die "Project not found: projects/$target"
fi

path_in_any_dir() {
  local path="$1"
  shift
  local d
  for d in "$@"; do
    if [[ "$path" == "$d"/* || "$path" == "$d" ]]; then
      return 0
    fi
  done
  return 1
}

path_matches_any_glob() {
  local path="$1"
  shift
  local g
  for g in "$@"; do
    case "$path" in
      $g) return 0 ;;
    esac
  done
  return 1
}

include_by_scope() {
  local path="$1"
  case "$scope" in
    full)
      return 0
      ;;
    platform)
      [[ "$path" != projects/* ]]
      return $?
      ;;
    project)
      if [[ "$path" == "projects/$target/"* ]]; then
        return 0
      fi
      [[ "$path" != projects/* ]]
      return $?
      ;;
  esac
}

include_file() {
  local path="$1"

  if ! include_by_scope "$path"; then
    return 1
  fi

  if (( ${#include_dirs[@]} > 0 )); then
    if ! path_in_any_dir "$path" "${include_dirs[@]}"; then
      return 1
    fi
  fi

  if (( ${#exclude_dirs[@]} > 0 )); then
    if path_in_any_dir "$path" "${exclude_dirs[@]}"; then
      return 1
    fi
  fi

  if (( ${#ignore_patterns[@]} > 0 )); then
    if path_matches_any_glob "$path" "${ignore_patterns[@]}"; then
      return 1
    fi
  fi

  return 0
}

is_binary_file() {
  local path="$1"
  if [[ ! -s "$path" ]]; then
    return 1
  fi
  if LC_ALL=C grep -Iq . "$path" 2>/dev/null; then
    return 1
  fi
  return 0
}

selected=0
mapfile -t all_files < <(git ls-files)
for path in "${all_files[@]}"; do
  if ! include_file "$path"; then
    continue
  fi
  if is_binary_file "$path"; then
    continue
  fi
  printf '%s\n' "$path"
  selected=$((selected + 1))
done

if (( selected == 0 )); then
  die "No files selected for scope: $scope"
fi
