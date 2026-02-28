#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi
cd "$REPO_ROOT" || exit 1
trap 'emit_binary_leaf "lint-style" "finish"' EXIT
emit_binary_leaf "lint-style" "start"

declare -a JARGON_BLACKLIST=(
  "synergy"
  "leverage"
  "best-in-class"
  "world-class"
  "cutting-edge"
  "thought leader"
  "north star"
  "game changer"
  "single pane of glass"
)

declare -a MARKDOWN_FILES=()
STYLE_FAILURES=0
CLOSING_LABELS_MANIFEST_PATH="${REPO_ROOT}/ops/lib/manifests/CLOSING.md"
declare -a CURRENT_CLOSING_LABELS=()
CLOSING_SCHEMA_LABELS_BLOB=""
CLOSING_LABELS_LOADED=0

mark_failure() {
  echo "ERROR: $1" >&2
  STYLE_FAILURES=$((STYLE_FAILURES + 1))
}

load_current_closing_labels() {
  local label
  if (( CLOSING_LABELS_LOADED )); then
    return 0
  fi

  [[ -f "$CLOSING_LABELS_MANIFEST_PATH" ]] || die "closing labels manifest missing: ${CLOSING_LABELS_MANIFEST_PATH#${REPO_ROOT}/}"
  if ! grep -Eq '^##[[:space:]]+Section 1:[[:space:]]+Current Closeout Labels[[:space:]]*$' "$CLOSING_LABELS_MANIFEST_PATH"; then
    die "closing labels manifest missing required SSOT section heading"
  fi

  mapfile -t CURRENT_CLOSING_LABELS < <(
    awk '
      /^##[[:space:]]+Section 1:[[:space:]]+Current Closeout Labels[[:space:]]*$/ { in_section=1; next }
      in_section && /^##[[:space:]]+/ { exit }
      in_section && /[^[:space:]]/ { print }
    ' "$CLOSING_LABELS_MANIFEST_PATH"
  )

  if [[ "${#CURRENT_CLOSING_LABELS[@]}" -ne 6 ]]; then
    die "closing labels manifest must define exactly six current labels (found ${#CURRENT_CLOSING_LABELS[@]})"
  fi

  CLOSING_SCHEMA_LABELS_BLOB=""
  for label in "${CURRENT_CLOSING_LABELS[@]}"; do
    if [[ -n "$CLOSING_SCHEMA_LABELS_BLOB" ]]; then
      CLOSING_SCHEMA_LABELS_BLOB+=$'\n'
    fi
    CLOSING_SCHEMA_LABELS_BLOB+="$label"
  done
  CLOSING_LABELS_LOADED=1
}

collect_markdown_files() {
  mapfile -t MARKDOWN_FILES < <(
    git ls-files '*.md' | awk '$0 !~ /^storage\//'
  )
  if (( ${#MARKDOWN_FILES[@]} == 0 )); then
    echo "ERROR: no markdown files discovered for style lint." >&2
    exit 1
  fi
}

search_markdown_matches() {
  local pattern="$1"
  local mode="${2:-regex}"

  if command -v rg >/dev/null 2>&1; then
    if [[ "$mode" == "fixed" ]]; then
      rg -n -i -F -- "$pattern" "${MARKDOWN_FILES[@]}" || true
    else
      rg -n -i -e "$pattern" "${MARKDOWN_FILES[@]}" || true
    fi
    return 0
  fi

  if command -v grep >/dev/null 2>&1; then
    if [[ "$mode" == "fixed" ]]; then
      grep -n -i -F -- "$pattern" "${MARKDOWN_FILES[@]}" 2>/dev/null || true
      return 0
    fi
    if grep -E 'a' <<< 'a' >/dev/null 2>&1; then
      grep -n -i -E -- "$pattern" "${MARKDOWN_FILES[@]}" 2>/dev/null || true
      return 0
    fi
  fi

  echo "ERROR: neither rg nor grep -E is available on PATH" >&2
  exit 1
}

file_has_h2_heading() {
  local file="$1"
  local heading="$2"
  awk -v heading="$heading" '
    /^##[[:space:]]+/ {
      line=$0
      sub(/^##[[:space:]]+/, "", line)
      sub(/[[:space:]]+$/, "", line)
      if (line == heading) {
        found=1
        exit
      }
    }
    END { exit(found ? 0 : 1) }
  ' "$file"
}

detect_closing_sidecar_schema_kind() {
  local file="$1"
  local label
  load_current_closing_labels
  for label in "${CURRENT_CLOSING_LABELS[@]}"; do
    if ! grep -Fxq "$label" "$file"; then
      printf 'unknown'
      return 0
    fi
  done
  printf 'current'
}

check_markdown_contractions() {
  # Contraction prohibition uses ASCII and unicode apostrophe variants.
  local apostrophe="['\\x{2019}]"
  local contraction_pattern="\\b(ain${apostrophe}t|aren${apostrophe}t|can${apostrophe}t|couldn${apostrophe}t|didn${apostrophe}t|doesn${apostrophe}t|don${apostrophe}t|hadn${apostrophe}t|hasn${apostrophe}t|haven${apostrophe}t|isn${apostrophe}t|mightn${apostrophe}t|mustn${apostrophe}t|needn${apostrophe}t|shan${apostrophe}t|shouldn${apostrophe}t|wasn${apostrophe}t|weren${apostrophe}t|won${apostrophe}t|wouldn${apostrophe}t|it${apostrophe}s|that${apostrophe}s|there${apostrophe}s|here${apostrophe}s|who${apostrophe}s|what${apostrophe}s|where${apostrophe}s|when${apostrophe}s|why${apostrophe}s|how${apostrophe}s|let${apostrophe}s|i${apostrophe}m|you${apostrophe}re|we${apostrophe}re|they${apostrophe}re|i${apostrophe}ve|you${apostrophe}ve|we${apostrophe}ve|they${apostrophe}ve|i${apostrophe}ll|you${apostrophe}ll|we${apostrophe}ll|they${apostrophe}ll|i${apostrophe}d|you${apostrophe}d|we${apostrophe}d|they${apostrophe}d)\\b"
  local contraction_hits
  contraction_hits="$(search_markdown_matches "$contraction_pattern" regex)"
  if [[ -n "$contraction_hits" ]]; then
    mark_failure "Contractions found in markdown files:"
    echo "$contraction_hits" >&2
  fi
}

check_jargon_blacklist() {
  local term=""
  for term in "${JARGON_BLACKLIST[@]}"; do
    local term_hits
    term_hits="$(search_markdown_matches "$term" fixed)"
    if [[ -z "$term_hits" ]]; then
      continue
    fi
    mark_failure "Jargon blacklist term matched: '${term}'"
    while IFS= read -r hit || [[ -n "$hit" ]]; do
      [[ -n "$hit" ]] || continue
      echo "  ${hit}" >&2
    done <<< "$term_hits"
  done
}

check_contractor_notes_decision_record() {
  local notes_rel="storage/dp/active/notes.md"
  local notes_path="${REPO_ROOT}/${notes_rel}"

  if [[ ! -f "$notes_path" ]]; then
    mark_failure "${notes_rel}: missing file."
    return 0
  fi

  local parsed_record
  parsed_record="$(awk '
    BEGIN {
      in_section=0
      section_count=0
      required_count=0
      pointer_count=0
      required_line=0
      pointer_line=0
      required_value=""
      pointer_value=""
    }

    /^##[[:space:]]+Execution Decision Record[[:space:]]*$/ {
      section_count++
      in_section=1
      next
    }

    /^##[[:space:]]+/ {
      if (in_section) {
        in_section=0
      }
    }

    in_section && /^Decision Required:[[:space:]]*/ {
      required_count++
      if (required_line == 0) {
        required_line=NR
        line=$0
        sub(/^Decision Required:[[:space:]]*/, "", line)
        sub(/^[[:space:]]+/, "", line)
        sub(/[[:space:]]+$/, "", line)
        required_value=line
      }
      next
    }

    in_section && /^Decision Pointer:[[:space:]]*/ {
      pointer_count++
      if (pointer_line == 0) {
        pointer_line=NR
        line=$0
        sub(/^Decision Pointer:[[:space:]]*/, "", line)
        sub(/^[[:space:]]+/, "", line)
        sub(/[[:space:]]+$/, "", line)
        pointer_value=line
      }
      next
    }

    END {
      printf "%d\t%d\t%d\t%d\t%d\t%s\t%s\n", section_count, required_count, pointer_count, required_line, pointer_line, required_value, pointer_value
    }
  ' "$notes_path")"

  local section_count required_count pointer_count required_line pointer_line decision_required decision_pointer
  IFS=$'\t' read -r section_count required_count pointer_count required_line pointer_line decision_required decision_pointer <<< "$parsed_record"

  if (( section_count == 0 )); then
    mark_failure "${notes_rel}: missing '## Execution Decision Record' section."
    return 0
  fi

  if (( section_count > 1 )); then
    mark_failure "${notes_rel}: duplicate '## Execution Decision Record' section headings found (${section_count})."
  fi

  if (( required_count == 0 )); then
    mark_failure "${notes_rel}: missing 'Decision Required:' field in Execution Decision Record."
  elif (( required_count > 1 )); then
    mark_failure "${notes_rel}: duplicate 'Decision Required:' fields in Execution Decision Record."
  fi

  if (( pointer_count == 0 )); then
    mark_failure "${notes_rel}: missing 'Decision Pointer:' field in Execution Decision Record."
  elif (( pointer_count > 1 )); then
    mark_failure "${notes_rel}: duplicate 'Decision Pointer:' fields in Execution Decision Record."
  fi

  if (( required_count == 0 || pointer_count == 0 )); then
    return 0
  fi

  if [[ "$decision_required" != "Yes" && "$decision_required" != "No" ]]; then
    mark_failure "${notes_rel}:${required_line}: Decision Required must be Yes or No (found '${decision_required}')."
    return 0
  fi

  if [[ "$decision_required" == "No" ]]; then
    return 0
  fi

  if [[ -z "$decision_pointer" ]]; then
    mark_failure "${notes_rel}:${pointer_line}: Decision Pointer must be non-empty when Decision Required is Yes."
    return 0
  fi

  if [[ "$decision_pointer" == "None" ]]; then
    mark_failure "${notes_rel}:${pointer_line}: Decision Pointer must not be None when Decision Required is Yes."
    return 0
  fi

  if [[ "$decision_pointer" == /* || "$decision_pointer" == *".."* || "$decision_pointer" =~ [[:space:]] ]]; then
    mark_failure "${notes_rel}:${pointer_line}: Decision Pointer must be a repo-relative literal path when Decision Required is Yes (found '${decision_pointer}')."
    return 0
  fi

  if [[ "$decision_pointer" != archives/decisions/* ]]; then
    mark_failure "${notes_rel}:${pointer_line}: Decision Pointer must begin with archives/decisions/ when Decision Required is Yes (found '${decision_pointer}')."
    return 0
  fi

  if [[ "$decision_pointer" != *.md ]]; then
    mark_failure "${notes_rel}:${pointer_line}: Decision Pointer must end with .md when Decision Required is Yes (found '${decision_pointer}')."
    return 0
  fi

  if [[ ! -f "${REPO_ROOT}/${decision_pointer}" ]]; then
    mark_failure "${notes_rel}:${pointer_line}: Decision Pointer does not resolve to an existing file when Decision Required is Yes (missing '${decision_pointer}')."
  fi
}

check_closing_block_lead_words() {
  local handoff_dir="${REPO_ROOT}/storage/handoff"
  [[ -d "$handoff_dir" ]] || return 0

  local -a closing_files=()
  shopt -s nullglob
  closing_files=("$handoff_dir"/CLOSING-*.md)
  shopt -u nullglob
  (( ${#closing_files[@]} > 0 )) || return 0

  local file
  local base_name
  local dp_number
  local duplicate_report
  for file in "${closing_files[@]}"; do
    base_name="$(basename "$file")"
    if [[ "$base_name" =~ ^CLOSING-DP-OPS-([0-9]+)\.md$ ]]; then
      dp_number=$((10#${BASH_REMATCH[1]}))
      if (( dp_number < 80 )); then
        continue
      fi
    fi

    if ! duplicate_report="$(awk -v labels_blob="$CLOSING_SCHEMA_LABELS_BLOB" '
      BEGIN {
        n=split(labels_blob, labels, /\n/)
        for (i=1; i<=n; i++) {
          if (labels[i] != "") {
            header[labels[i]]=1
          }
        }
      }
      function is_header(line) {
        return (line in header)
      }

      {
        if (is_header($0)) {
          awaiting_entry=1
          next
        }

        if (awaiting_entry && $0 ~ /[^[:space:]]/) {
          line=$0
          sub(/^[[:space:]]+/, "", line)
          split(line, fields, /[[:space:]]+/)
          lead=fields[1]
          gsub(/^[^[:alnum:]]+/, "", lead)
          gsub(/[^[:alnum:]-]+$/, "", lead)
          lead_key=tolower(lead)
          if (lead_key == "") {
            lead_key="(empty)"
          }
          lead_count[lead_key]++
          lead_lines[lead_key]=lead_lines[lead_key] sprintf("%d:%s\n", NR, $0)
          awaiting_entry=0
        }
      }

      END {
        duplicate_total=0
        for (k in lead_count) {
          if (lead_count[k] > 1) {
            duplicate_total++
            printf "Duplicate opening word [%s]:\n%s", k, lead_lines[k]
          }
        }
        if (duplicate_total > 0) {
          exit 2
        }
      }
    ' "$file")"; then
      echo "ERROR: Closing block lead-word repetition found in ${file#"${REPO_ROOT}/"}:" >&2
      if [[ -n "$duplicate_report" ]]; then
        echo "$duplicate_report" >&2
      fi
      exit 1
    fi
  done
}

check_closing_block_conversation_starter_question() {
  local handoff_dir="${REPO_ROOT}/storage/handoff"
  [[ -d "$handoff_dir" ]] || return 0

  local -a closing_files=()
  shopt -s nullglob
  closing_files=("$handoff_dir"/CLOSING-*.md)
  shopt -u nullglob
  (( ${#closing_files[@]} > 0 )) || return 0

  local file base_name dp_number
  local conversation_label="${CURRENT_CLOSING_LABELS[5]}"
  for file in "${closing_files[@]}"; do
    base_name="$(basename "$file")"
    if [[ "$base_name" =~ ^CLOSING-DP-OPS-([0-9]+)\.md$ ]]; then
      dp_number=$((10#${BASH_REMATCH[1]}))
      if (( dp_number < 80 )); then
        continue
      fi
      if (( dp_number < 94 )); then
        continue
      fi
    fi

    local schema_kind
    schema_kind="$(detect_closing_sidecar_schema_kind "$file")"
    if [[ "$schema_kind" == "unknown" ]]; then
      continue
    fi

    local rel_file="${file#"${REPO_ROOT}/"}"
    local value_record value_lineno value
    value_record="$(awk -v target_label="$conversation_label" '
      $0 == target_label { found=1; next }
      found && /[^[:space:]]/ {
        line=$0
        sub(/^[[:space:]]+/, "", line)
        printf "%d\t%s\n", NR, line
        exit
      }
    ' "$file")"

    if [[ -z "$value_record" ]]; then
      continue
    fi

    IFS=$'\t' read -r value_lineno value <<< "$value_record"
    local trimmed="${value%"${value##*[![:space:]]}"}"
    if [[ "$trimmed" != *\? ]]; then
      mark_failure "CLOSING BLOCK: Conversation Starter does not end in '?'. This field must be a genuine question."
      echo "  ${rel_file}:${value_lineno}" >&2
    fi
  done
}

check_closing_block_manifest_paths() {
  local handoff_dir="${REPO_ROOT}/storage/handoff"
  [[ -d "$handoff_dir" ]] || return 0

  local -a closing_files=()
  shopt -s nullglob
  closing_files=("$handoff_dir"/CLOSING-*.md)
  shopt -u nullglob
  (( ${#closing_files[@]} > 0 )) || return 0

  local file base_name dp_number
  for file in "${closing_files[@]}"; do
    base_name="$(basename "$file")"
    if [[ "$base_name" =~ ^CLOSING-DP-OPS-([0-9]+)\.md$ ]]; then
      dp_number=$((10#${BASH_REMATCH[1]}))
      if (( dp_number < 80 )); then
        continue
      fi
      if (( dp_number < 94 )); then
        continue
      fi
    fi

    local schema_kind
    local manifest_start_label="${CURRENT_CLOSING_LABELS[4]}"
    local manifest_field_name="${CURRENT_CLOSING_LABELS[4]}"
    schema_kind="$(detect_closing_sidecar_schema_kind "$file")"
    if [[ "$schema_kind" != "current" ]]; then
      continue
    fi

    local rel_file="${file#"${REPO_ROOT}/"}"
    while IFS=$'\t' read -r lineno invalid_line reason; do
      [[ -n "$lineno" ]] || continue
      mark_failure "CLOSING BLOCK: ${manifest_field_name} invalid path entry on line ${lineno}: \"${invalid_line}\" (${reason}). This field must contain repository-relative file paths only."
      echo "  ${rel_file}:${lineno}" >&2
    done < <(
      awk -v start_label="$manifest_start_label" -v labels_blob="$CLOSING_SCHEMA_LABELS_BLOB" '
        BEGIN {
          n=split(labels_blob, labels, /\n/)
          for (i=1; i<=n; i++) {
            if (labels[i] != "") {
              header[labels[i]]=1
            }
          }
        }
        function is_header(line) {
          return (line in header)
        }
        function report(reason, line) {
          printf "%d\t%s\t%s\n", NR, line, reason
        }
        $0 == start_label { in_block=1; next }
        in_block && is_header($0) { in_block=0; next }
        in_block && /[^[:space:]]/ {
          line=$0
          if (line ~ /^[[:space:]]/ || line ~ /[[:space:]]$/) {
            report("leading or trailing whitespace", line)
            next
          }
          if (line ~ /[[:space:]]/) {
            report("internal whitespace", line)
            next
          }
          if (line ~ /^#{1,6}([[:space:]]|$)/) {
            report("markdown heading marker", line)
            next
          }
          if (line ~ /^(\.\/|\/)/) {
            report("must not begin with ./ or /", line)
            next
          }
          if (line !~ /^[A-Za-z0-9][A-Za-z0-9._\/-]*$/) {
            report("must match ^[A-Za-z0-9][A-Za-z0-9._/-]*$", line)
            next
          }
        }
      ' "$file"
    )
  done
}

check_closing_block_pr_description_markdown() {
  local handoff_dir="${REPO_ROOT}/storage/handoff"
  [[ -d "$handoff_dir" ]] || return 0

  local -a closing_files=()
  shopt -s nullglob
  closing_files=("$handoff_dir"/CLOSING-*.md)
  shopt -u nullglob
  (( ${#closing_files[@]} > 0 )) || return 0

  local file base_name dp_number
  local pr_description_label="${CURRENT_CLOSING_LABELS[2]}"
  for file in "${closing_files[@]}"; do
    base_name="$(basename "$file")"
    if [[ "$base_name" =~ ^CLOSING-DP-OPS-([0-9]+)\.md$ ]]; then
      dp_number=$((10#${BASH_REMATCH[1]}))
      if (( dp_number < 80 )); then
        continue
      fi
      if (( dp_number < 94 )); then
        continue
      fi
    fi

    local rel_file="${file#"${REPO_ROOT}/"}"
    local schema_kind
    schema_kind="$(detect_closing_sidecar_schema_kind "$file")"
    if [[ "$schema_kind" == "unknown" ]]; then
      continue
    fi
    local has_markdown
    has_markdown="$(awk -v start_label="$pr_description_label" -v labels_blob="$CLOSING_SCHEMA_LABELS_BLOB" '
      BEGIN {
        n=split(labels_blob, labels, /\n/)
        for (i=1; i<=n; i++) {
          if (labels[i] != "") {
            header[labels[i]]=1
          }
        }
      }
      function is_header(line) {
        return (line in header)
      }
      $0 == start_label { in_block=1; next }
      in_block && is_header($0) { in_block=0; next }
      in_block && /^##[[:space:]]/ { print "heading"; exit }
      in_block && /^[-*][[:space:]]/ { print "list"; exit }
      in_block && /^[0-9]+\.[[:space:]]/ { print "ordered"; exit }
      in_block && /\*\*/ { print "bold"; exit }
    ' "$file")"

    if [[ -z "$has_markdown" ]]; then
      mark_failure "CLOSING BLOCK: PR Description contains no markdown constructs. Use at least one heading (##), list item (- or 1.), or bold (**) to serve the reviewer interface."
      echo "  ${rel_file}" >&2
    fi
  done
}

collect_markdown_files
load_current_closing_labels
check_markdown_contractions
check_jargon_blacklist
check_contractor_notes_decision_record
check_closing_block_lead_words
check_closing_block_conversation_starter_question
check_closing_block_manifest_paths
check_closing_block_pr_description_markdown

if (( STYLE_FAILURES > 0 )); then
  exit 1
fi
