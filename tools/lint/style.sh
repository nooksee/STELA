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

SPEC_SURFACE_MARKER="<!-- SPEC-SURFACE:REQUIRED -->"
declare -a SPEC_REQUIRED_SECTIONS=(
  "First Principles Rationale"
  "Mechanics and Sequencing"
  "Anecdotal Anchor"
  "Integrity Filter Warnings"
)

declare -a MARKDOWN_FILES=()
STYLE_FAILURES=0

mark_failure() {
  echo "ERROR: $1" >&2
  STYLE_FAILURES=$((STYLE_FAILURES + 1))
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

check_spec_surface_compliance() {
  local file=""
  local section=""
  for file in "${MARKDOWN_FILES[@]}"; do
    [[ "$file" == docs/ops/specs/* ]] || continue
    if ! grep -Fq "$SPEC_SURFACE_MARKER" "$file"; then
      continue
    fi

    for section in "${SPEC_REQUIRED_SECTIONS[@]}"; do
      if file_has_h2_heading "$file" "$section"; then
        continue
      fi
      mark_failure "Spec-surface compliance failed: ${file} missing section '## ${section}'"
    done
  done
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

    if ! duplicate_report="$(awk '
      function is_header(line) {
        return line ~ /^Primary Commit Header \(plaintext\)[[:space:]]*$/ \
          || line ~ /^Pull Request Title \(plaintext\)[[:space:]]*$/ \
          || line ~ /^Pull Request Description \(markdown\)[[:space:]]*$/ \
          || line ~ /^Final Squash Stub \(plaintext\)( \(Must differ from #1\)| \(Must differ from Primary Commit Header in verb and subject\))?[[:space:]]*$/ \
          || line ~ /^Extended Technical Manifest \(plaintext\)[[:space:]]*$/ \
          || line ~ /^Review Conversation Starter \(markdown\)[[:space:]]*$/
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
    local value_record value_lineno value
    value_record="$(awk '
      /^Review Conversation Starter \(markdown\)[[:space:]]*$/ { found=1; next }
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

    local rel_file="${file#"${REPO_ROOT}/"}"
    while IFS=$'\t' read -r lineno prose_line; do
      [[ -n "$lineno" ]] || continue
      mark_failure "CLOSING BLOCK: Extended Technical Manifest contains prose on line ${lineno}: \"${prose_line}\". This field must contain file paths only."
      echo "  ${rel_file}:${lineno}" >&2
    done < <(
      awk '
        /^Extended Technical Manifest \(plaintext\)[[:space:]]*$/ { in_block=1; next }
        in_block && /^(Primary Commit Header|Pull Request Title|Pull Request Description|Final Squash Stub|Review Conversation Starter)/ { in_block=0; next }
        in_block && /[^[:space:]]/ {
          line=$0
          sub(/^[[:space:]]+/, "", line)
          n=split(line, tokens, /[[:space:]]+/)
          prose_count=0
          for (i=1; i<=n; i++) {
            t=tokens[i]
            if (t !~ /^[A-Za-z0-9]/ || t !~ /\//) {
              prose_count++
            } else {
              prose_count=0
            }
            if (prose_count >= 2) {
              printf "%d\t%s\n", NR, line
              break
            }
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
    local has_markdown
    has_markdown="$(awk '
      /^Pull Request Description \(markdown\)[[:space:]]*$/ { in_block=1; next }
      in_block && /^(Primary Commit Header|Pull Request Title|Final Squash Stub|Extended Technical Manifest|Review Conversation Starter)/ { in_block=0; next }
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
check_markdown_contractions
check_jargon_blacklist
check_spec_surface_compliance
check_closing_block_lead_words
check_closing_block_conversation_starter_question
check_closing_block_manifest_paths
check_closing_block_pr_description_markdown

if (( STYLE_FAILURES > 0 )); then
  exit 1
fi
