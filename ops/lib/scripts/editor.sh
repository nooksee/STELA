#!/usr/bin/env bash
set -euo pipefail

editor_write_narrative_scaffold() {
  local target_path="$1"
  cat > "$target_path" <<'EOF'
### Preflight State
State the preflight outcome: branch, Base HEAD, clean working tree, and preflight lint results.

### Implemented Changes
Describe each change made: what was modified, created, or removed, and why.

### Closeout Notes
Describe any anomalies, open items, or residue. State None. if all items are resolved.

### Decision Leaf
Decision Required: Yes|No
Decision Leaf: archives/decisions/... or None
EOF
}

editor_resolve_command() {
  local explicit_command="${1:-}"
  if [[ -n "$explicit_command" ]]; then
    printf '%s' "$explicit_command"
    return 0
  fi
  if [[ -n "${STELA_EDITOR:-}" ]]; then
    printf '%s' "$STELA_EDITOR"
    return 0
  fi
  if [[ -n "${EDITOR:-}" ]]; then
    printf '%s' "$EDITOR"
    return 0
  fi
  if command -v vi >/dev/null 2>&1; then
    printf 'vi'
    return 0
  fi
  if command -v vim >/dev/null 2>&1; then
    printf 'vim'
    return 0
  fi
  if command -v nano >/dev/null 2>&1; then
    printf 'nano'
    return 0
  fi
  die "failed to resolve editor command (set STELA_EDITOR or EDITOR)"
}

editor_invoke_command() {
  local editor_command="$1"
  local target_path="$2"
  [[ -n "$editor_command" ]] || die "editor command is empty"
  [[ -n "$target_path" ]] || die "editor target path is empty"
  bash -lc "$editor_command \"$target_path\""
}

editor_capture_narrative_interactive() {
  local scaffold_path="$1"
  local explicit_editor_command="${2:-}"
  local editor_command
  editor_command="$(editor_resolve_command "$explicit_editor_command")"

  echo ""
  echo "CONTRACTOR EXECUTION NARRATIVE:"
  echo "Edit the narrative scaffold now. Save and exit when complete."
  echo "File: ${scaffold_path}"
  echo ""
  editor_invoke_command "$editor_command" "$scaffold_path"
}

editor_load_narrative_from_file() {
  local source_path="$1"
  local target_path="$2"
  local resolved_source="$source_path"

  [[ -n "$source_path" ]] || die "--narrative-file path is empty"
  if [[ "$resolved_source" != /* ]]; then
    resolved_source="${REPO_ROOT}/${resolved_source}"
  fi
  [[ -f "$resolved_source" ]] || die "narrative file missing: ${resolved_source#${REPO_ROOT}/}"

  cp "$resolved_source" "$target_path"
  if [[ -z "$(sed '/^[[:space:]]*$/d' "$target_path")" ]]; then
    die "contractor narrative file is empty: ${resolved_source#${REPO_ROOT}/}"
  fi
}

editor_validate_narrative_file() {
  local narrative_path="$1"
  [[ -f "$narrative_path" ]] || die "contractor narrative file missing: ${narrative_path#${REPO_ROOT}/}"

  local narrative_content
  narrative_content="$(cat "$narrative_path")"

  [[ -n "$(printf '%s\n' "$narrative_content" | sed '/^[[:space:]]*$/d')" ]] \
    || die "contractor narrative is empty"

  if printf '%s\n' "$narrative_content" | grep -Eiq '\{\{|}}|\bTBD\b|\bTODO\b|PLACEHOLDER|ENTER_|REPLACE_|populate during execution|do not pre-fill|DP-XXXX'; then
    die "contractor narrative contains placeholder text; fill in all fields before certifying"
  fi

  local scaffold_line=""
  local -a scaffold_lines=(
    "State the preflight outcome: branch, Base HEAD, clean working tree, and preflight lint results."
    "Describe each change made: what was modified, created, or removed, and why."
    "Describe any anomalies, open items, or residue. State None. if all items are resolved."
    "Decision Required: Yes|No"
    "Decision Leaf: archives/decisions/... or None"
  )
  for scaffold_line in "${scaffold_lines[@]}"; do
    if printf '%s\n' "$narrative_content" | grep -Fqx "$scaffold_line"; then
      die "contractor narrative contains untouched scaffold line: ${scaffold_line}"
    fi
  done

  local narrative_subheading=""
  for narrative_subheading in "^### Preflight State$" "^### Implemented Changes$" "^### Closeout Notes$" "^### Decision Leaf$"; do
    if ! printf '%s\n' "$narrative_content" | grep -Eq "$narrative_subheading"; then
      die "contractor narrative missing required subheading (pattern: ${narrative_subheading})"
    fi
  done

  if ! printf '%s\n' "$narrative_content" | grep -Eq '^Decision Required:'; then
    die "contractor narrative Decision Leaf subsection missing 'Decision Required:' line"
  fi
  if ! printf '%s\n' "$narrative_content" | grep -Eq '^Decision Leaf:'; then
    die "contractor narrative Decision Leaf subsection missing 'Decision Leaf:' line"
  fi
  if printf '%s\n' "$narrative_content" | grep -Eq '^/|[[:space:]]/[A-Za-z]'; then
    die "contractor narrative contains absolute path; use repo-relative paths only"
  fi
}
