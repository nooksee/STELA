#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/lint/integrity.sh
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
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

extract_allowlist_pointer() {
  awk '
    BEGIN { in_block=0 }
    /^Target Files allowlist [(]hard gate[)]:[[:space:]]*$/ { in_block=1; next }
    in_block && /^[[:space:]]*-[[:space:]]+/ { print; exit }
    in_block && /^##[[:space:]]*3[.]4([.]|[[:space:]])/ { exit }
  ' TASK.md
}

pointer_line="$(extract_allowlist_pointer)"
[[ -n "$pointer_line" ]] || die "failed to find Target Files allowlist pointer in TASK.md"

pointer_path="$(printf '%s' "$pointer_line" | sed -E 's/^[[:space:]]*-[[:space:]]+//')"
pointer_path="$(normalize_path "$pointer_path")"
[[ -n "$pointer_path" ]] || die "resolved allowlist pointer is empty"

if [[ "$pointer_path" != /* ]]; then
  pointer_path="${REPO_ROOT}/${pointer_path}"
fi
[[ -f "$pointer_path" ]] || die "allowlist pointer file missing: ${pointer_path#${REPO_ROOT}/}"

declare -A allowlisted=()
while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
  entry="$(normalize_path "$raw_line")"
  [[ -n "$entry" ]] || continue
  allowlisted["$entry"]=1
done < "$pointer_path"

if [[ "${#allowlisted[@]}" -eq 0 ]]; then
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

unauthorized=()
for path in "${!observed[@]}"; do
  if [[ -z "${allowlisted[$path]+set}" ]]; then
    unauthorized+=("$path")
  fi
done

if [[ "${#unauthorized[@]}" -gt 0 ]]; then
  {
    echo "FAIL: unauthorized path(s) not present in allowlist:"
    printf '%s\n' "${unauthorized[@]}" | sort
  } >&2
  exit 1
fi

echo "OK: integrity lint passed (${#observed[@]} observed paths)."
