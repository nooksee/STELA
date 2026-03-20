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
  editor_capture_scaffold_interactive "CONTRACTOR EXECUTION NARRATIVE" "$scaffold_path" "$explicit_editor_command"
}

editor_load_narrative_from_file() {
  local source_path="$1"
  local target_path="$2"
  editor_load_scaffold_from_file "$source_path" "$target_path"
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
    if printf '%s\n' "$narrative_content" | grep -Fqx -- "$scaffold_line"; then
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

editor_capture_scaffold_interactive() {
  local label="$1"
  local scaffold_path="$2"
  local explicit_editor_command="${3:-}"
  local editor_command
  editor_command="$(editor_resolve_command "$explicit_editor_command")"

  echo ""
  echo "${label}:"
  echo "Edit the scaffold now. Save and exit when complete."
  echo "File: ${scaffold_path}"
  echo ""
  editor_invoke_command "$editor_command" "$scaffold_path"
}

editor_load_scaffold_from_file() {
  local source_path="$1"
  local target_path="$2"
  local resolved_source="$source_path"

  [[ -n "$source_path" ]] || die "scaffold source path is empty"
  if [[ "$resolved_source" != /* ]]; then
    resolved_source="${REPO_ROOT}/${resolved_source}"
  fi
  [[ -f "$resolved_source" ]] || die "scaffold source file missing: ${resolved_source#${REPO_ROOT}/}"

  cp "$resolved_source" "$target_path"
  if [[ -z "$(sed '/^[[:space:]]*$/d' "$target_path")" ]]; then
    die "scaffold source file is empty: ${resolved_source#${REPO_ROOT}/}"
  fi
}

editor_write_plan_scaffold() {
  local target_path="$1"
  cat > "$target_path" <<'EOF'
# Plan Title

## Summary
Write one to three lines stating the objective and expected outcome.

## Key Changes
List the concrete contract changes as concise bullets.

## Test Plan
List the validation commands and route proofs.

## Assumptions
State the bounded assumptions that keep the plan usable.
EOF
}

editor_write_draft_slots_scaffold() {
  local target_path="$1"
  cat > "$target_path" <<'EOF'
[DP_SCOPED_LOAD_ORDER]
- List required context files in strict read order.

[OBJECTIVE]
- Describe target outcome in one to three lines.

[IN_SCOPE]
- Enumerate exact files and bounded change intent.

[OUT_OF_SCOPE]
- Enumerate explicit exclusions.

[SAFETY_INVARIANTS]
- List hard safety constraints and no-edit zones.

[PLAN_STATE]
- Capture current state and known baseline facts.

[PLAN_REQUEST]
- Translate selected slices into deterministic requests.

[PLAN_CHANGELOG]
- List UPDATE and NEW files only.

[PLAN_PATCH]
- Provide linear numbered patch steps with exact files.

[RECEIPT_EXTRA]
- List DP-specific receipt commands with literal paths.

[CBC_PREFLIGHT]
- State applicability and bounded CbC rationale.
EOF
}

editor_validate_plan_scaffold_file() {
  local plan_path="$1"
  [[ -f "$plan_path" ]] || die "plan scaffold file missing: ${plan_path#${REPO_ROOT}/}"

  local content
  content="$(cat "$plan_path")"
  [[ -n "$(printf '%s\n' "$content" | sed '/^[[:space:]]*$/d')" ]] || die "plan scaffold is empty"

  if printf '%s\n' "$content" | grep -Eiq '\{\{|}}|\bTBD\b|\bTODO\b|PLACEHOLDER|ENTER_|REPLACE_|populate during execution|do not pre-fill'; then
    die "plan scaffold contains placeholder text; replace instruction text before validating"
  fi

  local required_heading
  for required_heading in '^# .+$' '^## Summary$' '^## Key Changes$' '^## Test Plan$' '^## Assumptions$'; do
    if ! printf '%s\n' "$content" | grep -Eq "$required_heading"; then
      die "plan scaffold missing required heading (pattern: ${required_heading})"
    fi
  done

  local untouched_line
  local -a untouched_lines=(
    "Write one to three lines stating the objective and expected outcome."
    "List the concrete contract changes as concise bullets."
    "List the validation commands and route proofs."
    "State the bounded assumptions that keep the plan usable."
  )
  for untouched_line in "${untouched_lines[@]}"; do
    if printf '%s\n' "$content" | grep -Fqx -- "$untouched_line"; then
      die "plan scaffold contains untouched scaffold line: ${untouched_line}"
    fi
  done

  if printf '%s\n' "$content" | grep -Eq '^/|[[:space:]]/[A-Za-z]'; then
    die "plan scaffold contains absolute path; use repo-relative paths only"
  fi
}

editor_validate_draft_slots_scaffold_file() {
  local slots_path="$1"
  [[ -f "$slots_path" ]] || die "draft slots scaffold file missing: ${slots_path#${REPO_ROOT}/}"

  local content
  content="$(cat "$slots_path")"
  [[ -n "$(printf '%s\n' "$content" | sed '/^[[:space:]]*$/d')" ]] || die "draft slots scaffold is empty"

  if printf '%s\n' "$content" | grep -Eiq '\{\{|}}|\bTBD\b|\bTODO\b|PLACEHOLDER|ENTER_|REPLACE_|populate during execution|do not pre-fill'; then
    die "draft slots scaffold contains placeholder text; replace instruction text before validating"
  fi

  local required_block
  local -a required_blocks=(
    "DP_SCOPED_LOAD_ORDER"
    "OBJECTIVE"
    "IN_SCOPE"
    "OUT_OF_SCOPE"
    "SAFETY_INVARIANTS"
    "PLAN_STATE"
    "PLAN_REQUEST"
    "PLAN_CHANGELOG"
    "PLAN_PATCH"
    "RECEIPT_EXTRA"
    "CBC_PREFLIGHT"
  )
  for required_block in "${required_blocks[@]}"; do
    if ! printf '%s\n' "$content" | grep -Fqx "[${required_block}]"; then
      die "draft slots scaffold missing required block: ${required_block}"
    fi
  done

  local untouched_line
  local -a untouched_lines=(
    "- List required context files in strict read order."
    "- Describe target outcome in one to three lines."
    "- Enumerate exact files and bounded change intent."
    "- Enumerate explicit exclusions."
    "- List hard safety constraints and no-edit zones."
    "- Capture current state and known baseline facts."
    "- Translate selected slices into deterministic requests."
    "- List UPDATE and NEW files only."
    "- Provide linear numbered patch steps with exact files."
    "- List DP-specific receipt commands with literal paths."
    "- State applicability and bounded CbC rationale."
  )
  for untouched_line in "${untouched_lines[@]}"; do
    if printf '%s\n' "$content" | grep -Fqx -- "$untouched_line"; then
      die "draft slots scaffold contains untouched scaffold line: ${untouched_line}"
    fi
  done

  if printf '%s\n' "$content" | grep -Eq '^/|[[:space:]]/[A-Za-z]'; then
    die "draft slots scaffold contains absolute path; use repo-relative paths only"
  fi
}
