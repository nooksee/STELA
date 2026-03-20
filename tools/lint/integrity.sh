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

current_generated_surface_pointer() {
  local surface_path="$1"
  local surface_name
  surface_name="$(basename "$surface_path")"
  local pointer_regex=""

  case "$surface_name" in
    PoW.md)
      pointer_regex='^archives/surfaces/PoW-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$'
      ;;
    SoP.md)
      pointer_regex='^archives/surfaces/SoP-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9a-f]{7,}\.md$'
      ;;
    TASK.md)
      pointer_regex='^archives/surfaces/TASK-DP-[A-Z]+-[0-9]{4,}(-ADDENDUM-[A-Z])?-[0-9a-f]{7,}\.md$'
      ;;
    *)
      return 1
      ;;
  esac

  [[ -f "$surface_path" ]] || return 1
  local line_count
  line_count="$(awk 'END { print NR }' "$surface_path")"
  [[ "$line_count" == "1" ]] || return 1

  local pointer_path
  pointer_path="$(trim "$(cat "$surface_path")")"
  pointer_path="$(normalize_path "$pointer_path")"
  [[ "$pointer_path" =~ $pointer_regex ]] || return 1
  [[ -f "${REPO_ROOT}/${pointer_path}" ]] || return 1
  printf '%s' "$pointer_path"
}

path_is_generated_surface_owned() {
  local path="$1"
  local normalized
  normalized="$(normalize_path "$path")"

  local surface_rel pointer_rel
  for surface_rel in PoW.md SoP.md TASK.md; do
    pointer_rel="$(current_generated_surface_pointer "${REPO_ROOT}/${surface_rel}" || true)"
    if [[ -z "$pointer_rel" ]]; then
      continue
    fi
    if [[ "$normalized" == "$surface_rel" || "$normalized" == "$pointer_rel" ]]; then
      return 0
    fi
  done

  return 1
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

extract_in_scope_block() {
  local source_path="$1"
  awk '
    BEGIN { in_block=0 }
    /^In scope:[[:space:]]*$/ { in_block=1; next }
    in_block && /^Out of scope:[[:space:]]*$/ { exit }
    in_block { print }
  ' "$source_path"
}

extract_changelog_update_block() {
  local source_path="$1"
  awk '
    BEGIN { in_changelog=0; in_update=0 }
    /^### 3[.]4[.]3[[:space:]]+Changelog[[:space:]]*$/ { in_changelog=1; next }
    in_changelog && /^### 3[.]4[.]4([[:space:]]|$)/ { exit }
    in_changelog && /^UPDATE:[[:space:]]*$/ { in_update=1; next }
    in_changelog && /^NEW:[[:space:]]*$/ { if (in_update) exit }
    in_changelog && /^NO-CHANGE:[[:space:]]*$/ { if (in_update) exit }
    in_changelog && in_update { print }
  ' "$source_path"
}

is_pot_change_authorized() {
  local source_path="$1"
  local in_scope_block
  local changelog_update_block
  local pot_pattern='^[[:space:]]*-[[:space:]]*`?PoT[.]md`?([[:space:]]|[(]|$)'

  in_scope_block="$(extract_in_scope_block "$source_path")"
  if grep -Eq "$pot_pattern" <<< "$in_scope_block"; then
    return 0
  fi

  changelog_update_block="$(extract_changelog_update_block "$source_path")"
  if grep -Eq "$pot_pattern" <<< "$changelog_update_block"; then
    return 0
  fi

  return 1
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
    storage/dp/intake/DP.md)
      ;;
    storage/dp/intake/*-ADDENDUM-*.md)
      ;;
    storage/handoff/CLOSING-*.md)
      ;;
    storage/dp/intake/DP-*.md)
      ;;
    storage/handoff/*|storage/dumps/*|storage/dp/intake/*)
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
  if path_is_generated_surface_owned "$path"; then
    return 0
  fi
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

if [[ -n "${observed[PoT.md]+set}" ]]; then
  if ! is_pot_change_authorized "$TASK_SOURCE_PATH"; then
    {
      echo "FAIL: PoT.md changed without explicit governance-surface authorization in active DP."
      echo "  task_source_path: ${TASK_SOURCE_PATH#${REPO_ROOT}/}"
      echo "  Add '- PoT.md' under either:"
      echo "  - In scope:"
      echo "  - 3.4.3 Changelog UPDATE:"
      echo "  Then re-run tools/lint/integrity.sh."
    } >&2
    exit 1
  fi
fi

# CbC Design Discipline Preflight enforcement
# Fail when the CbC preflight is applicable (slot content does not start with
# "Not applicable") and the allowlist contains no cbc decision leaf entry or
# pattern under archives/decisions/ with "-cbc-" in the name.

extract_cbc_preflight_first_line() {
  local source_path="$1"
  awk '
    BEGIN { in_section=0; past_boilerplate=0 }
    /^### CbC Design Discipline Preflight/ { in_section=1; next }
    in_section && /^###/ { exit }
    in_section && /^##/ { exit }
    in_section && /^Required when the DP objective/ { next }
    in_section && /^For non-tooling DPs:/ { past_boilerplate=1; next }
    in_section && past_boilerplate && /^[[:space:]]*$/ { next }
    in_section && past_boilerplate && /[^[:space:]]/ { print; exit }
  ' "$source_path"
}

cbc_first_line="$(extract_cbc_preflight_first_line "$TASK_SOURCE_PATH")"

cbc_applicable=1
if [[ -z "$cbc_first_line" ]]; then
  cbc_applicable=0
elif [[ "$cbc_first_line" == "Not applicable"* ]]; then
  cbc_applicable=0
fi

if [[ "$cbc_applicable" -eq 1 ]]; then
  cbc_covered=0
  for entry in "${!allowlisted[@]}"; do
    if [[ "$entry" == archives/decisions/*-cbc-* ]]; then
      cbc_covered=1
      break
    fi
  done
  if [[ "$cbc_covered" -eq 0 ]]; then
    for pat in "${allowlist_patterns[@]}"; do
      if [[ "$pat" == archives/decisions/*-cbc-* ]]; then
        cbc_covered=1
        break
      fi
    done
  fi
  if [[ "$cbc_covered" -eq 0 ]]; then
    {
      echo "FAIL: CbC preflight is applicable but no cbc decision leaf entry or pattern"
      echo "  (archives/decisions/*-cbc-*) found in the allowlist."
      echo "  Run: ./ops/bin/decision create --dp=<DP-ID> --type=cbc --status=accepted --out=auto"
      echo "  Then add the generated leaf path to storage/dp/active/allowlist.txt."
    } >&2
    exit 1
  fi
fi

echo "OK: integrity lint passed (${#observed[@]} observed paths)."
