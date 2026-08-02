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

require_file_contains_literal() {
  local target="$1"
  local needle="$2"
  local failure_message="$3"

  [[ -f "$target" ]] || return 0
  if ! grep -Fq -- "$needle" "$target"; then
    mark_failure "$failure_message"
  fi
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
  local -a tracked_markdown=()
  local file=""
  mapfile -t tracked_markdown < <(
    git ls-files '*.md' | awk '$0 !~ /^storage\//'
  )
  MARKDOWN_FILES=()
  for file in "${tracked_markdown[@]}"; do
    [[ -f "$file" ]] || continue
    MARKDOWN_FILES+=("$file")
  done
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

collect_closing_sidecar_files() {
  local handoff_dir="$1"
  local -a files=()
  [[ -d "$handoff_dir" ]] || return 0

  shopt -s nullglob
  [[ -f "${handoff_dir}/CLOSING.md" ]] && files+=("${handoff_dir}/CLOSING.md")
  files+=("${handoff_dir}"/CLOSING-*.md)
  shopt -u nullglob

  (( ${#files[@]} > 0 )) || return 0
  printf '%s\n' "${files[@]}" | awk '!seen[$0]++'
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

check_shared_stance_contract() {
  local shared_stances="${REPO_ROOT}/ops/src/shared/stances.json"
  local required_version='"version": 2'
  local required_stance_key='"stance_shared_rules"'
  local required_fence_key='"single_fence_contract_rules"'
  local required_non_audit_key='"non_audit_role_drift_rules"'
  local required_fence_line='* Emit exactly one fenced markdown code block.'
  local required_no_outside_line='* Emit no text before or after the fenced code block.'
  local required_non_audit_line='* Do not emit audit verdict markers or Worker Execution Narrative sections.'

  [[ -f "$shared_stances" ]] || {
    mark_failure "ops/src/shared/stances.json missing for cross-stance convergence checks"
    return 0
  }

  if ! grep -Fq -- "$required_version" "$shared_stances"; then
    mark_failure "ops/src/shared/stances.json missing version 2 marker"
  fi

  if ! grep -Fq -- "$required_stance_key" "$shared_stances"; then
    mark_failure "ops/src/shared/stances.json missing stance_shared_rules key"
  fi

  if ! grep -Fq -- "$required_fence_key" "$shared_stances"; then
    mark_failure "ops/src/shared/stances.json missing single_fence_contract_rules key"
  fi

  if ! grep -Fq -- "$required_non_audit_key" "$shared_stances"; then
    mark_failure "ops/src/shared/stances.json missing non_audit_role_drift_rules key"
  fi

  if ! grep -Fq -- "$required_fence_line" "$shared_stances"; then
    mark_failure "ops/src/shared/stances.json missing shared fence contract line"
  fi

  if ! grep -Fq -- "$required_no_outside_line" "$shared_stances"; then
    mark_failure "ops/src/shared/stances.json missing shared no-outside-text line"
  fi

  if ! grep -Fq -- "$required_non_audit_line" "$shared_stances"; then
    mark_failure "ops/src/shared/stances.json missing shared non-audit role-drift line"
  fi
}

check_audit_addenda_mode_split() {
  local stance_audit="${REPO_ROOT}/ops/src/stances/audit.md.tpl"
  local stance_addenda="${REPO_ROOT}/ops/src/stances/addenda.md.tpl"
  local bundle_manifest="${REPO_ROOT}/ops/lib/manifests/BUNDLE.md"
  local -a audit_literals=(
    '`--profile=addenda` is addenda mode and is never valid for audit verdict workflows.:::audit.md.tpl missing audit-verdict stance marker'
    'If user text is empty and required attachments are present, proceed and emit only the final audit block.:::audit.md.tpl missing empty-input attach-only rule line'
    'Output only: Complete audit report.:::audit.md.tpl missing audit output contract line'
    '{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}:::audit.md.tpl missing shared fence include line'
    'First non-empty line inside the fenced block must start with `**AUDIT -`.:::audit.md.tpl missing audit first-line marker output line'
    'Do not emit citation tokens (`[cite_start]`, `[cite:`, `[/cite]`, `:contentReference[`, or `oaicite`).:::audit.md.tpl missing audit no-citations output line'
    'If interpretation conflicts with receipt command outputs, treat command outputs and lint results as authoritative and mark the interpretation as non-blocking.:::audit.md.tpl missing audit evidence-authority conflict rule line'
    'For allowlist interpretation, `tools/lint/integrity.sh` plus certify changed-file subset check are authoritative; raw `comm` output is informational.:::audit.md.tpl missing audit allowlist-authority interpretation rule line'
  )
  local -a addenda_literals=(
    'This stance is not used for audit PASS/FAIL verdicts.:::addenda.md.tpl missing addendum-authorization stance marker'
  )
  local -a manifest_literals=(
    'Canonical audit verdict profile is `audit`.:::BUNDLE.md missing canonical audit mode split line'
    'Canonical addenda profile is `addenda`.:::BUNDLE.md missing canonical addenda mode split line'
  )
  local entry needle failure_message

  [[ -f "$stance_audit" ]] || mark_failure "audit.md.tpl missing for mode split checks"
  [[ -f "$stance_addenda" ]] || mark_failure "addenda.md.tpl missing for mode split checks"
  [[ -f "$bundle_manifest" ]] || mark_failure "BUNDLE.md missing for mode split checks"

  for entry in "${audit_literals[@]}"; do
    needle="${entry%%:::*}"
    failure_message="${entry#*:::}"
    require_file_contains_literal "$stance_audit" "$needle" "$failure_message"
  done

  for entry in "${addenda_literals[@]}"; do
    needle="${entry%%:::*}"
    failure_message="${entry#*:::}"
    require_file_contains_literal "$stance_addenda" "$needle" "$failure_message"
  done

  for entry in "${manifest_literals[@]}"; do
    needle="${entry%%:::*}"
    failure_message="${entry#*:::}"
    require_file_contains_literal "$bundle_manifest" "$needle" "$failure_message"
  done
}

check_draft_mode_contract() {
  local stance_draft="${REPO_ROOT}/ops/src/stances/draft.md.tpl"
  local -a draft_literals=(
    'Output only: Full DP (starting at `### DP-...`) in one markdown code block.:::draft.md.tpl missing output contract line'
    '{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}:::draft.md.tpl missing shared fence include line'
    'First non-empty line inside the code block must start with `### DP-`.:::draft.md.tpl missing first-line marker line'
    '{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}:::draft.md.tpl missing shared non-audit include line'
    'Do not emit Worker Execution Narrative sections or receipt narrative subheadings.:::draft.md.tpl missing no-receipt-narrative line'
    'Do not expand or replace the settled plan scope in draft mode.:::draft.md.tpl missing draft scope-only line'
  )
  local entry needle failure_message

  [[ -f "$stance_draft" ]] || mark_failure "draft.md.tpl missing for mode contract checks"

  for entry in "${draft_literals[@]}"; do
    needle="${entry%%:::*}"
    failure_message="${entry#*:::}"
    require_file_contains_literal "$stance_draft" "$needle" "$failure_message"
  done
}

check_planning_mode_contract() {
  local stance_planning="${REPO_ROOT}/ops/src/stances/planning.md.tpl"
  local required_shared_non_audit_include='{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}'
  local -a core_literals=(
    'For machine-ingest planning mode: require attached `storage/handoff/TOPIC.md`; do not use inline query fallback.:::planning.md.tpl missing planning topic-source line'
    '* Use attached evidence first.:::planning.md.tpl missing planning evidence-first line'
    'For machine-ingest planning mode: do not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.:::planning.md.tpl missing planning no-unsupported-operating-detail line'
    '* If the topic spans multiple independent work families and the topic does not explicitly identify the immediate packet, ask one slicing or prioritization question before writing the final plan.:::planning.md.tpl missing planning multi-family question-first line'
    '* Treat the immediate packet as explicit only if::::planning.md.tpl missing planning explicit-packet gate line'
    '* Do not infer or choose the immediate packet unilaterally from repo context alone when multiple work families are in scope.:::planning.md.tpl missing planning no-unilateral-packet-inference line'
    '* If remaining ambiguity still materially changes the immediate packet boundary or implementation handoff, ask the minimum additional bounded clarification needed.:::planning.md.tpl missing planning follow-up ambiguity line'
    '* Do not substitute a staged queue, proposed sequencing, or assistant-chosen first packet for a missing slicing decision.:::planning.md.tpl missing planning no-staged-queue-substitute line'
    'For machine-ingest planning mode: default to question mode for multi-family topics; only skip the slicing question when the operator'\''s topic text directly names the immediate packet.:::planning.md.tpl missing machine-ingest default-question-mode line'
    'For machine-ingest planning mode: when the topic is broad, keep repo-specific claims generic and high-level rather than converting thin evidence into specific operating facts.:::planning.md.tpl missing planning broad-topic-genericity line'
    'For machine-ingest planning mode: use attached evidence first.:::planning.md.tpl missing machine-ingest evidence-first line'
  )
  local -a transport_literals=(
    'Portable question transport::::planning.md.tpl missing portable-question-transport section'
    'exactly 2 substantive, mutually exclusive options:::planning.md.tpl missing planning bounded-options invariant'
    'C. Tell Analyst to do something else instead.:::planning.md.tpl missing planning redirect-option invariant'
    'clickable choice when the host UI supports it:::planning.md.tpl missing planning click-bias invariant'
  )
  local -a question_mode_literals=(
    'For machine-ingest question mode: when clarification is needed, ask the packet-boundary question first as a short prose sentence without any retired analysis preamble or other required wrapper.:::planning.md.tpl missing planning question-first line'
    'For machine-ingest question mode: allow at most 3 questions; each question must immediately follow the prose question with exactly 3 short standalone answer lines: `A.` first substantive option, `B.` second substantive option, and `C. Tell Analyst to do something else instead.`:::planning.md.tpl missing planning question-choice-transport line'
    'For machine-ingest question mode: keep each option to one short line when possible; do not add analysis paragraphs between the question and the options.:::planning.md.tpl missing planning question-mode no-analysis-paragraphs line'
    'For machine-ingest question mode: do not use a fenced markdown code block; fenced markdown remains the final-plan output contract only.:::planning.md.tpl missing planning question-mode no-fence line'
  )
  local -a overlay_literals=(
    'Question mode (host overlay)::::planning.md.tpl missing planning host-overlay section'
    'host-provided single-select question tool is available:::planning.md.tpl missing planning host-overlay tool line'
    'Popup rendering remains host/UI behavior and cannot be guaranteed by stance text alone.:::planning.md.tpl missing planning host-overlay caveat line'
    'Question mode (Claude.ai overlay)::::planning.md.tpl missing planning Claude.ai overlay section'
    '`ask_user_input_v0` tool is available:::planning.md.tpl missing planning Claude.ai overlay line'
    'For machine-ingest host overlay: when a host-provided single-select question tool is available:::planning.md.tpl missing machine-ingest host-overlay line'
    'For machine-ingest Claude.ai overlay: when the `ask_user_input_v0` tool is available:::planning.md.tpl missing machine-ingest Claude.ai overlay line'
  )
  local -a final_plan_literals=(
    'For final plan mode: output only the complete PLAN markdown code block.:::planning.md.tpl missing planning plan-output-only line'
    'For final plan mode: emit no text before or after the fenced markdown code block.:::planning.md.tpl missing planning final-plan no-outside-text line'
    'For final plan mode: keep `Summary`, `Key Changes`, `Test Plan`, and `Assumptions` as required core sections; additional peer sections are allowed when needed to keep the handoff truthful and narrow.:::planning.md.tpl missing planning final-plan shape line'
    'For final plan mode: when additional headings are needed, make them proper peer sections rather than burying them under a required heading.:::planning.md.tpl missing planning final-plan peer-sections line'
    'For final plan mode: once the immediate packet boundary is settled, emit the final `storage/handoff/PLAN.md`.:::planning.md.tpl missing planning final-plan emit line'
  )
  local entry needle failure_message

  [[ -f "$stance_planning" ]] || mark_failure "planning.md.tpl missing for mode contract checks"

  for entry in "${core_literals[@]}" "${transport_literals[@]}" "${question_mode_literals[@]}" "${overlay_literals[@]}" "${final_plan_literals[@]}"; do
    needle="${entry%%:::*}"
    failure_message="${entry#*:::}"
    require_file_contains_literal "$stance_planning" "$needle" "$failure_message"
  done

  require_file_contains_literal \
    "$stance_planning" \
    "$required_shared_non_audit_include" \
    "planning.md.tpl missing shared non-audit include line"
}

check_addenda_mode_contract() {
  local stance_addenda="${REPO_ROOT}/ops/src/stances/addenda.md.tpl"
  local -a addenda_literals=(
    '{{@include:ops/src/shared/stances.json#single_fence_contract_rules}}:::addenda.md.tpl missing shared fence include line'
    'For machine-ingest addenda mode: first non-empty line inside the fenced body must start with `### Addendum`.:::addenda.md.tpl missing addenda first-line marker line'
    'For machine-ingest addenda mode: include addendum headings `## A.1 Authorization` through `## A.5 Addendum Receipt (Proofs to collect) - MUST RUN`.:::addenda.md.tpl missing addenda required-sections line'
    '{{@include:ops/src/shared/stances.json#non_audit_role_drift_rules}}:::addenda.md.tpl missing shared non-audit include line'
    'For machine-ingest addenda mode: if `Decision Required:` and `Decision Leaf:` lines are present, values must be coherent (`Yes` with `archives/decisions/RoR-*.md`, `No` with `None`).:::addenda.md.tpl missing addenda decision-coherence line'
  )
  local entry needle failure_message

  [[ -f "$stance_addenda" ]] || mark_failure "addenda.md.tpl missing for mode contract checks"

  for entry in "${addenda_literals[@]}"; do
    needle="${entry%%:::*}"
    failure_message="${entry#*:::}"
    require_file_contains_literal "$stance_addenda" "$needle" "$failure_message"
  done
}


check_open_marker_contract() {
  local open_binary="${REPO_ROOT}/ops/bin/open"
  local begin_marker='===== STELA OPEN PROMPT ====='
  local end_marker='===== END STELA OPEN PROMPT ====='
  local legacy_begin_marker='===== OPEN PROMPT ====='
  local legacy_standalone_title='Stela OPEN PROMPT'

  [[ -f "$open_binary" ]] || {
    mark_failure "ops/bin/open missing for OPEN marker contract checks"
    return 0
  }

  if ! grep -Fxq -- "$begin_marker" "$open_binary"; then
    mark_failure "ops/bin/open missing canonical OPEN begin marker"
  fi

  if ! grep -Fxq -- "$end_marker" "$open_binary"; then
    mark_failure "ops/bin/open missing canonical OPEN end marker"
  fi

  if grep -Fxq -- "$legacy_begin_marker" "$open_binary"; then
    mark_failure "ops/bin/open still contains legacy OPEN begin marker"
  fi

  if grep -Fxq -- "$legacy_standalone_title" "$open_binary"; then
    mark_failure "ops/bin/open still contains legacy standalone OPEN title line"
  fi
}


check_closing_block_lead_words() {
  local handoff_dir="${REPO_ROOT}/storage/handoff"
  [[ -d "$handoff_dir" ]] || return 0

  local -a closing_files=()
  mapfile -t closing_files < <(collect_closing_sidecar_files "$handoff_dir")
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
  mapfile -t closing_files < <(collect_closing_sidecar_files "$handoff_dir")
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
  mapfile -t closing_files < <(collect_closing_sidecar_files "$handoff_dir")
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
  mapfile -t closing_files < <(collect_closing_sidecar_files "$handoff_dir")
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
check_shared_stance_contract
check_audit_addenda_mode_split
check_draft_mode_contract
check_planning_mode_contract
check_addenda_mode_contract
check_open_marker_contract
check_closing_block_lead_words
check_closing_block_conversation_starter_question
check_closing_block_manifest_paths
check_closing_block_pr_description_markdown

if (( STYLE_FAILURES > 0 )); then
  exit 1
fi
