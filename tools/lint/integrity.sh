#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

usage() {
  cat <<'USAGE'
Usage: tools/lint/integrity.sh
USAGE
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
trap 'emit_binary_leaf "lint-integrity" "finish"' EXIT
emit_binary_leaf "lint-integrity" "start"

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

normalize_path() {
  local value
  value="$(trim "$1")"
  value="${value#\`}"
  value="${value%\`}"
  value="${value#./}"
  if [[ "$value" == "${REPO_ROOT}/"* ]]; then
    value="${value#${REPO_ROOT}/}"
  fi
  printf '%s' "$value"
}

resolve_task_surface_path() {
  local task_path="$1"
  [[ -f "$task_path" ]] || die "TASK surface missing: ${task_path#${REPO_ROOT}/}"

  local line_count
  line_count="$(awk 'END { print NR }' "$task_path")"
  if [[ "$line_count" != "1" ]]; then
    printf '%s' "$task_path"
    return 0
  fi

  local pointer_path
  pointer_path="$(trim "$(cat "$task_path")")"
  pointer_path="$(normalize_path "$pointer_path")"
  if [[ "$pointer_path" =~ ^archives/surfaces/[A-Za-z0-9._/-]+\.md$ ]]; then
    local target_path="${REPO_ROOT}/${pointer_path}"
    [[ -f "$target_path" ]] || die "TASK pointer target missing: ${pointer_path}"
    printf '%s' "$target_path"
    return 0
  fi

  die "TASK is single-line but not a valid archives/surfaces pointer: ${pointer_path}"
}

extract_allowlist_pointer() {
  local source_path="$1"
  awk '
    BEGIN { in_block=0 }
    /^Target Files allowlist [(]hard gate[)]:[[:space:]]*$/ { in_block=1; next }
    in_block && /^[[:space:]]*-[[:space:]]+/ { print; exit }
    in_block && /^##[[:space:]]*3[.]4([.]|[[:space:]])/ { exit }
  ' "$source_path"
}

TASK_SOURCE_PATH="$(resolve_task_surface_path "${REPO_ROOT}/TASK.md")"

pointer_line="$(extract_allowlist_pointer "$TASK_SOURCE_PATH")"
[[ -n "$pointer_line" ]] || die "failed to find Target Files allowlist pointer in ${TASK_SOURCE_PATH#${REPO_ROOT}/}"

pointer_path="$(printf '%s' "$pointer_line" | sed -E 's/^[[:space:]]*-[[:space:]]+//')"
pointer_path="$(normalize_path "$pointer_path")"
[[ -n "$pointer_path" ]] || die "resolved allowlist pointer is empty"

if [[ "$pointer_path" != /* ]]; then
  pointer_path="${REPO_ROOT}/${pointer_path}"
fi
[[ -f "$pointer_path" ]] || die "allowlist pointer file missing: ${pointer_path#${REPO_ROOT}/}"

declare -A allowlisted=()
declare -a allowlist_patterns=()
while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  entry="$(normalize_path "$raw_line")"
  [[ -n "$entry" ]] || continue
  if [[ "$entry" == \#* ]]; then
    continue
  fi
  case "$entry" in
    storage/handoff/CLOSING-DP-OPS-*.md)
      ;;
    storage/dp/intake/DP-OPS-0094.md)
      ;;
    storage/handoff/*|storage/dumps/*|storage/dp/intake/*|storage/dp/processed/*)
      die "allowlist entry must be persistent repo state (runtime artifact prefix forbidden): ${entry}"
      ;;
  esac
  if [[ "$entry" == *"*"* || "$entry" == *"?"* || "$entry" == *"["* ]]; then
    allowlist_patterns+=("$entry")
    continue
  fi
  allowlisted["$entry"]=1
done < "$pointer_path"

if [[ "${#allowlisted[@]}" -eq 0 && "${#allowlist_patterns[@]}" -eq 0 ]]; then
  die "allowlist pointer file is empty: ${pointer_path#${REPO_ROOT}/}"
fi

mapfile -t changed_paths < <(
  {
    git diff --name-only --cached
    git diff --name-only
  } | sed '/^[[:space:]]*$/d' | sort -u
)

mapfile -t untracked_paths < <(
  git ls-files --others --exclude-standard | sed '/^[[:space:]]*$/d' | sort -u
)

declare -A observed=()
path=""
for path in "${changed_paths[@]}"; do
  normalized="$(normalize_path "$path")"
  [[ -n "$normalized" ]] || continue
  observed["$normalized"]=1
done
for path in "${untracked_paths[@]}"; do
  normalized="$(normalize_path "$path")"
  [[ -n "$normalized" ]] || continue
  observed["$normalized"]=1
done

path_is_allowlisted() {
  local path="$1"
  if [[ -n "${allowlisted[$path]+set}" ]]; then
    return 0
  fi

  local pattern=""
  for pattern in "${allowlist_patterns[@]}"; do
    if [[ "$path" == $pattern ]]; then
      return 0
    fi
  done

  return 1
}

unauthorized=()
for path in "${!observed[@]}"; do
  if path_is_allowlisted "$path"; then
    continue
  fi
  unauthorized+=("$path")
done

if [[ "${#unauthorized[@]}" -gt 0 ]]; then
  {
    echo "FAIL: unauthorized path(s) not present in allowlist:"
    printf '%s\n' "${unauthorized[@]}" | sort
  } >&2
  exit 1
fi

echo "OK: integrity lint passed (${#observed[@]} observed paths)."
