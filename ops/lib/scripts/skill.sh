#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
SKILL_FILE="${REPO_ROOT}/docs/library/SKILLS.md"
SKILLS_REGISTRY="${REPO_ROOT}/docs/ops/registry/SKILLS.md"
TASK_FILE="${REPO_ROOT}/TASK.md"
CONTEXT_MANIFEST="${REPO_ROOT}/ops/lib/manifests/CONTEXT.md"
SKILLS_DIR="${REPO_ROOT}/docs/library/skills"
HANDOFF_DIR="${REPO_ROOT}/storage/handoff"
HEURISTICS_LIB="${SCRIPT_DIR}/heuristics.sh"

if [[ -f "$HEURISTICS_LIB" ]]; then
  # shellcheck source=/dev/null
  source "$HEURISTICS_LIB"
else
  detect_hot_zone() { echo "None"; }
  detect_high_churn() { echo "None"; }
  generate_provenance_block() { echo "## Provenance"; }
  check_semantic_collision() { return 0; }
fi

usage() {
  cat <<'USAGE'
Usage:
  ops/lib/scripts/skill.sh harvest|--harvest [--name "..."] [--context "..."] [--solution "..."] [--context-stdin | --solution-stdin] [--force]
  ops/lib/scripts/skill.sh promote|--promote <draft_path> [--delete-draft]
  ops/lib/scripts/skill.sh check|--check

Legacy (append-only candidate + promotion packet):
  ops/lib/scripts/skill.sh "name" "context" "solution"

Notes:
- Use --context-stdin or --solution-stdin to read multi-line content from stdin (heredoc-safe). Only one stdin field is allowed per invocation.
- Harvest auto-detects provenance and can suggest name or context when omitted.
- Promote without a draft path uses the most recent draft when unambiguous.
USAGE
}

die() {
  echo "ERROR: $*" >&2
  exit 1
}

require_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    die "Required file missing: $path"
  fi
}

require_repo_root() {
  require_file "$SKILL_FILE"
  require_file "$SKILLS_REGISTRY"
  require_file "$TASK_FILE"
  require_file "$CONTEXT_MANIFEST"
}

ensure_handoff_dir() {
  mkdir -p "$HANDOFF_DIR"
}

redact_stream() {
  sed -E \
    -e 's/AKIA[0-9A-Z]{16}/[REDACTED]/g' \
    -e 's/ASIA[0-9A-Z]{16}/[REDACTED]/g' \
    -e 's/AIza[0-9A-Za-z_-]{35}/[REDACTED]/g' \
    -e 's/xox[baprs]-[0-9A-Za-z-]{10,48}/[REDACTED]/g' \
    -e 's/ghp_[0-9A-Za-z]{36}/[REDACTED]/g' \
    -e 's/ghs_[0-9A-Za-z]{36}/[REDACTED]/g' \
    -e 's/-----BEGIN [A-Z ]+ PRIVATE KEY-----/[REDACTED PRIVATE KEY]/g'
}

trim() {
  local value="$1"
  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s' "$value"
}

is_placeholder_value() {
  local value="$1"
  if [[ -z "$value" ]]; then
    return 0
  fi
  case "$value" in
    *"["*|*"]"*|*"TBD"*|*"TODO"*|*"ENTER_"*|*"REPLACE_"*)
      return 0
      ;;
  esac
  return 1
}

read_task_field() {
  local label="$1"
  local value
  value="$(awk -v label="$label" '
    $0 ~ "\\*\\*" label "\\*\\*" {
      sub(/.*\\*\\*[^*]+\\*\\*:[[:space:]]*/, "", $0);
      print $0;
      exit
    }
  ' "$TASK_FILE")"
  value="$(trim "$value")"
  if is_placeholder_value "$value"; then
    echo "Not provided"
  else
    echo "$value"
  fi
}

slugify() {
  local value="$1"
  value="$(printf '%s' "$value" | tr '[:upper:]' '[:lower:]')"
  value="$(printf '%s' "$value" | tr -cs 'a-z0-9' '-')"
  value="${value#-}"
  value="${value%-}"
  if [[ -z "$value" ]]; then
    value="skill"
  fi
  printf '%s' "$value"
}

read_multiline_from_tty() {
  local lines=()
  local line
  while IFS= read -r line; do
    if [[ "$line" == "EOF" ]]; then
      break
    fi
    lines+=("$line")
  done
  printf '%s\n' "${lines[@]}"
}

collect_harvest_inputs() {
  local -n out_name=$1
  local -n out_context=$2
  local -n out_solution=$3
  local -n out_force=$4
  local allow_empty="${5:-0}"
  shift 5

  local context_from_stdin=0
  local solution_from_stdin=0
  out_force=0
  local positional=()

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --name)
        out_name="$2"
        shift 2
        ;;
      --context)
        out_context="$2"
        shift 2
        ;;
      --solution)
        out_solution="$2"
        shift 2
        ;;
      --context-stdin)
        context_from_stdin=1
        shift
        ;;
      --solution-stdin)
        solution_from_stdin=1
        shift
        ;;
      --force)
        out_force=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        while [[ $# -gt 0 ]]; do
          positional+=("$1")
          shift
        done
        ;;
      -*)
        die "Unknown option: $1"
        ;;
      *)
        positional+=("$1")
        shift
        ;;
    esac
  done

  if (( context_from_stdin + solution_from_stdin > 1 )); then
    die "Only one of --context-stdin or --solution-stdin is allowed"
  fi

  if (( ${#positional[@]} > 0 )); then
    if [[ -z "$out_name" ]]; then
      out_name="${positional[0]:-}"
    fi
    if [[ -z "$out_context" ]]; then
      out_context="${positional[1]:-}"
    fi
    if [[ -z "$out_solution" ]]; then
      out_solution="${positional[2]:-}"
    fi
    if (( ${#positional[@]} > 3 )); then
      die "Too many positional arguments"
    fi
  fi

  if [[ $context_from_stdin -eq 1 ]]; then
    out_context="$(cat)"
  elif [[ $solution_from_stdin -eq 1 ]]; then
    out_solution="$(cat)"
  fi

  if [[ -z "$out_name" && "$allow_empty" -eq 0 ]]; then
    if [[ -t 0 ]]; then
      read -r -p "Name: " out_name
    else
      die "Name is required (use --name)"
    fi
  fi

  if [[ -z "$out_context" && "$allow_empty" -eq 0 ]]; then
    if [[ -t 0 ]]; then
      echo "Enter context. End with a single line containing EOF."
      out_context="$(read_multiline_from_tty)"
    else
      die "Context is required (use --context or --context-stdin)"
    fi
  fi

  if [[ -z "$out_solution" && "$allow_empty" -eq 0 ]]; then
    if [[ -t 0 ]]; then
      echo "Enter solution. End with a single line containing EOF."
      out_solution="$(read_multiline_from_tty)"
    else
      die "Solution is required (use --solution or --solution-stdin)"
    fi
  fi
}

context_hazard_check() {
  if grep -nE 'docs/library/skills/|S-LEARN-' "$CONTEXT_MANIFEST" >/dev/null; then
    echo "FAIL: Skills are referenced in ops/lib/manifests/CONTEXT.md. Remove skills from the context manifest." >&2
    return 1
  fi
  return 0
}

next_skill_id() {
  local max_id=0

  if [[ -d "$SKILLS_DIR" ]]; then
    while IFS= read -r file; do
      local base
      base="$(basename "$file")"
      if [[ "$base" =~ S-LEARN-([0-9]+)\.md ]]; then
        local num="${BASH_REMATCH[1]}"
        if ((10#$num > max_id)); then
          max_id=$((10#$num))
        fi
      fi
    done < <(find "$SKILLS_DIR" -maxdepth 1 -type f -name 'S-LEARN-*.md')
  fi

  while IFS= read -r match; do
    if [[ "$match" =~ S-LEARN-([0-9]+) ]]; then
      local num="${BASH_REMATCH[1]}"
      if ((10#$num > max_id)); then
        max_id=$((10#$num))
      fi
    fi
  done < <(grep -oE 'S-LEARN-[0-9]+' "$SKILLS_REGISTRY" 2>/dev/null || true)

  local next_id=$((max_id + 1))
  local next_id_fmt
  next_id_fmt="$(printf '%02d' "$next_id")"
  printf 'S-LEARN-%s' "$next_id_fmt"
}

insert_into_section() {
  local section="$1"
  local insert_file="$2"
  local target="$3"
  local tmp
  tmp="$(mktemp)"

  if ! awk -v section="$section" -v insert_file="$insert_file" '
    BEGIN {
      found=0; inserted=0; in_section=0; insert="";
      while ((getline line < insert_file) > 0) {
        insert = insert line "\n";
      }
      close(insert_file);
      if (insert != "") { sub(/\n$/, "", insert) }
    }
    {
      if ($0 == section) { found=1; in_section=1; print; next }
      if (in_section && $0 ~ /^## /) {
        if (!inserted) { print insert; inserted=1 }
        in_section=0
      }
      print
    }
    END {
      if (!found) { exit 2 }
      if (in_section && !inserted) { print insert; inserted=1 }
    }
  ' "$target" > "$tmp"; then
    status=$?
    rm -f "$tmp"
    if [[ "$status" -eq 2 ]]; then
      die "Section not found: $section"
    fi
    die "Failed to update $target"
  fi

  mv "$tmp" "$target"
}

insert_skill_registry_entry() {
  local row="$1"
  local tmp
  tmp="$(mktemp)"

  if ! awk -v row="$row" '
    BEGIN { inserted=0 }
    {
      print
      if (!inserted && $0 ~ /^\|[[:space:]]*---/) {
        print row
        inserted=1
      }
    }
    END { if (!inserted) exit 2 }
  ' "$SKILLS_REGISTRY" > "$tmp"; then
    status=$?
    rm -f "$tmp"
    if [[ "$status" -eq 2 ]]; then
      die "Skills registry table not found in docs/ops/registry/SKILLS.md"
    fi
    die "Failed to update docs/ops/registry/SKILLS.md"
  fi

  mv "$tmp" "$SKILLS_REGISTRY"
}

validate_candidate() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    die "Draft not found: $path"
  fi

  if grep -nE '\bTODO\b|\bTBD\b|ENTER_|REPLACE_|\[ID\]|\[TITLE\]' "$path" >/dev/null; then
    die "Draft contains placeholder markers. Clean the draft before promotion."
  fi

  local required_sections=(
    "## Provenance"
    "## Scope"
    "## Invocation guidance"
    "## Drift preventers"
  )

  local section
  for section in "${required_sections[@]}"; do
    if ! awk -v section="$section" '
      BEGIN { in_section=0; found=0; has_content=0 }
      $0 == section { in_section=1; found=1; next }
      in_section {
        if ($0 ~ /^## /) { exit }
        if ($0 ~ /[^[:space:]]/) { has_content=1; exit }
      }
      END { if (!found || !has_content) exit 1 }
    ' "$path"; then
      die "Draft section missing or empty: $section"
    fi
  done

  if ! head -n 1 "$path" | grep -qE '^# Skill Draft: .+'; then
    die "Draft header missing or invalid. Expected '# Skill Draft: <title>'."
  fi
}

cmd_check() {
  require_repo_root
  if context_hazard_check; then
    echo "PASS: Skills Context Hazard check clean."
  else
    echo "FAIL: Skills Context Hazard check failed."
    exit 1
  fi
}

cmd_harvest() {
  require_repo_root
  ensure_handoff_dir

  local name=""
  local context=""
  local solution=""
  local force=0

  collect_harvest_inputs name context solution force 1 "$@"

  local base_ref="main"
  local head_ref="HEAD"

  local hot_zone
  hot_zone="$(detect_hot_zone "$base_ref" "$head_ref" "$REPO_ROOT")"
  if [[ -z "$hot_zone" ]]; then
    hot_zone="None"
  fi

  local high_churn
  high_churn="$(detect_high_churn "$base_ref" "$head_ref" "$REPO_ROOT")"
  if [[ -z "$high_churn" ]]; then
    high_churn="None"
  fi

  if [[ -z "$name" ]]; then
    if [[ "$hot_zone" != "None" ]]; then
      name="Hot Zone: ${hot_zone}"
    else
      name="Skill Draft"
    fi
  fi

  if [[ -z "$context" ]]; then
    if [[ "$hot_zone" != "None" ]]; then
      context="the hot zone ${hot_zone}"
    else
      context="capturing a reusable lesson from recent work"
    fi
    if [[ "$high_churn" != "None" ]]; then
      local churn_inline
      churn_inline="$(printf '%s\n' "$high_churn" | awk 'NF {printf "%s%s", sep, $0; sep="; "}')"
      context="${context}; high churn: ${churn_inline}"
    fi
  fi

  local solution_placeholder=0
  if [[ -z "$solution" ]]; then
    solution="REPLACE_SOLUTION"
    solution_placeholder=1
  fi

  if ! check_semantic_collision "$name" "$SKILLS_DIR" "$HANDOFF_DIR"; then
    if [[ $force -eq 0 ]]; then
      die "Semantic collision detected. Use --force to override."
    else
      echo "WARN: Semantic collision override enabled." >&2
    fi
  fi

  local dp_id
  local objective
  dp_id="$(read_task_field "Current DP")"
  objective="$(read_task_field "Goal")"

  local slug
  slug="$(slugify "$name")"
  local draft_path
  local counter=0

  while :; do
    if [[ $counter -eq 0 ]]; then
      draft_path="${HANDOFF_DIR}/skill-draft-$(date -u '+%Y%m%d-%H%M%S')-${slug}.md"
    else
      draft_path="${HANDOFF_DIR}/skill-draft-$(date -u '+%Y%m%d-%H%M%S')-${slug}-${counter}.md"
    fi
    if [[ ! -e "$draft_path" ]]; then
      break
    fi
    counter=$((counter + 1))
  done

  local tmp
  tmp="$(mktemp)"

  local provenance_block
  provenance_block="$(generate_provenance_block "$dp_id" "$objective" "$base_ref" "$head_ref" "$REPO_ROOT")"

  cat <<EOF > "$tmp"
# Skill Draft: ${name}

${provenance_block}

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when ${context}. Apply the solution: ${solution}.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: use repository files as SSOT and stop if required inputs are missing.
- Negative check: do not add Skills to ops/lib/manifests/CONTEXT.md.

## Procedure
1) Review the context and desired outcome.
2) Apply the solution steps captured in this skill.
3) Verify results and record required evidence in RESULTS.
EOF

  redact_stream < "$tmp" > "$draft_path"
  rm -f "$tmp"

  if [[ $solution_placeholder -eq 1 ]]; then
    echo "WARN: Solution placeholder present. Refine the draft before promotion." >&2
  fi

  echo "$draft_path"
}

select_latest_draft() {
  local draft_path=""
  mapfile -t drafts < <(find "$HANDOFF_DIR" -maxdepth 1 -type f -name 'skill-draft-*.md' | sort)
  if (( ${#drafts[@]} == 0 )); then
    die "No draft found in storage/handoff"
  fi
  if (( ${#drafts[@]} == 1 )); then
    echo "${drafts[0]}"
    return 0
  fi

  draft_path="$(ls -t "${drafts[@]}" | head -n 1)"
  local newest_time
  newest_time="$(stat -c %Y "$draft_path")"

  local same_time=0
  local path
  for path in "${drafts[@]}"; do
    if [[ "$(stat -c %Y "$path")" == "$newest_time" ]]; then
      same_time=$((same_time + 1))
    fi
  done

  if (( same_time > 1 )); then
    die "Multiple drafts share the same timestamp. Provide an explicit draft path."
  fi

  echo "$draft_path"
}

cmd_promote() {
  require_repo_root
  ensure_handoff_dir

  local delete_draft=0
  local draft_path=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --delete-draft)
        delete_draft=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --*)
        die "Unknown option: $1"
        ;;
      *)
        if [[ -z "$draft_path" ]]; then
          draft_path="$1"
          shift
        else
          die "Unexpected extra argument: $1"
        fi
        ;;
    esac
  done

  if [[ -z "$draft_path" ]]; then
    draft_path="$(select_latest_draft)"
  fi

  validate_candidate "$draft_path"

  if ! context_hazard_check; then
    exit 1
  fi

  local title
  title="$(head -n 1 "$draft_path" | sed -E 's/^# Skill Draft: //')"
  title="$(trim "$title")"
  if [[ -z "$title" ]]; then
    die "Draft title is empty"
  fi

  local skill_id
  skill_id="$(next_skill_id)"
  local skill_path
  skill_path="${SKILLS_DIR}/${skill_id}.md"

  if [[ -e "$skill_path" ]]; then
    die "Skill file already exists: $skill_path"
  fi

  mkdir -p "$SKILLS_DIR"

  local tmp_skill
  tmp_skill="$(mktemp)"
  awk -v header="# ${skill_id}: ${title}" 'NR==1 { print header; next } { print }' "$draft_path" > "$tmp_skill"
  mv "$tmp_skill" "$skill_path"

  if grep -Fq "| ${skill_id} |" "$SKILLS_REGISTRY"; then
    die "docs/ops/registry/SKILLS.md already contains ${skill_id}"
  fi

  local registry_row
  registry_row="| ${skill_id} | Skill: ${title} | docs/library/skills/${skill_id}.md | |"
  insert_skill_registry_entry "$registry_row"

  local timestamp
  timestamp="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  local anchor_id
  anchor_id="promotion-packet-${skill_id,,}"

  local invocation_line
  invocation_line="$(awk 'found {print; exit} $0=="## Invocation guidance" {found=1}' "$draft_path")"
  local candidate_context="See docs/library/skills/${skill_id}.md"
  local candidate_solution="See docs/library/skills/${skill_id}.md"
  if [[ "$invocation_line" =~ ^Use[[:space:]]this[[:space:]]skill[[:space:]]when[[:space:]](.+)\.[[:space:]]Apply[[:space:]]the[[:space:]]solution:[[:space:]](.+)\.$ ]]; then
    candidate_context="${BASH_REMATCH[1]}"
    candidate_solution="${BASH_REMATCH[2]}"
  fi

  local candidate_tmp
  candidate_tmp="$(mktemp)"
  cat <<EOF > "$candidate_tmp"
- ${timestamp} - [Promotion Packet](#${anchor_id})
  - Name: ${title}
  - Context: ${candidate_context}
  - Solution: ${candidate_solution}
EOF

  local packet_tmp
  packet_tmp="$(mktemp)"
  cat <<EOF > "$packet_tmp"
<a id="${anchor_id}"></a>
### Promotion Packet: ${skill_id} - ${title}
- Candidate name: ${title}
  - Proposed Skill ID: ${skill_id} (rule: choose the next available numeric ID not already present in docs/library/skills or registered in docs/ops/registry/SKILLS.md)
- Scope: production payloads only; not platform maintenance
- Invocation guidance: Use this skill when a DP explicitly requests ${title}. Apply the solution as documented in docs/library/skills/${skill_id}.md.
- Drift preventers:
  - Stop conditions: Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill
  - Anti-hallucination: Use repo files as SSOT and stop if required inputs are missing
  - Negative check: Do not add Skills to ops/lib/manifests/CONTEXT.md
- Definition of Done:
  - ${skill_id} created under docs/library/skills and matches scope and drift preventers
  - docs/ops/registry/SKILLS.md updated with the new skill entry
  - SoP.md updated if canon or governance surfaces changed
  - Proof bundle updated in storage/handoff with diff outputs
- Verification (capture command output in RESULTS):
  - ./ops/bin/dump --scope=platform
  - bash tools/lint/context.sh
  - bash tools/lint/truth.sh (required when canon or governance surfaces change)
  - bash tools/lint/library.sh
  - bash tools/verify.sh
EOF

  insert_into_section "## Candidate Log (append-only)" "$candidate_tmp" "$SKILL_FILE"
  insert_into_section "## Promotion Packets (generated from candidates)" "$packet_tmp" "$SKILL_FILE"

  rm -f "$candidate_tmp" "$packet_tmp"

  local log_tmp
  log_tmp="$(mktemp)"
  cat <<EOF > "$log_tmp"
- ${timestamp} - Promoted ${skill_id} - ${title} -> docs/library/skills/${skill_id}.md
EOF
  insert_into_section "## Promotion Log (append-only)" "$log_tmp" "$SKILL_FILE"
  rm -f "$log_tmp"

  if (( delete_draft == 1 )); then
    rm -f "$draft_path"
  fi

  echo "${skill_path}"
}

cmd_legacy() {
  require_repo_root

  if [[ "$#" -ne 3 ]]; then
    usage >&2
    exit 1
  fi

  local name="$1"
  local context="$2"
  local solution="$3"

  if [[ "$name" == *$'\n'* || "$context" == *$'\n'* || "$solution" == *$'\n'* ]]; then
    die "Legacy inputs must be single-line values"
  fi

  local skill_id
  skill_id="$(next_skill_id)"
  local anchor_id
  anchor_id="promotion-packet-${skill_id,,}"
  local timestamp
  timestamp="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

  local candidate_tmp
  candidate_tmp="$(mktemp)"
  cat <<EOF > "$candidate_tmp"
- ${timestamp} - [Promotion Packet](#${anchor_id})
  - Name: ${name}
  - Context: ${context}
  - Solution: ${solution}
EOF

  local packet_tmp
  packet_tmp="$(mktemp)"
  cat <<EOF > "$packet_tmp"
<a id="${anchor_id}"></a>
### Promotion Packet: ${skill_id} - ${name}
- Candidate name: ${name}
  - Proposed Skill ID: ${skill_id} (rule: choose the next available numeric ID not already present in docs/library/skills or registered in docs/ops/registry/SKILLS.md)
- Scope: production payloads only; not platform maintenance
- Invocation guidance: Use this skill when ${context}. Apply the solution: ${solution}.
- Drift preventers:
  - Stop conditions: Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill
  - Anti-hallucination: Use repo files as SSOT and stop if required inputs are missing
  - Negative check: Do not add Skills to ops/lib/manifests/CONTEXT.md
- Definition of Done:
  - ${skill_id} created under docs/library/skills and matches scope and drift preventers
  - docs/ops/registry/SKILLS.md updated with the new skill entry
  - SoP.md updated if canon or governance surfaces changed
  - Proof bundle updated in storage/handoff with diff outputs
- Verification (capture command output in RESULTS):
  - ./ops/bin/dump --scope=platform
  - bash tools/lint/context.sh
  - bash tools/lint/truth.sh (required when canon or governance surfaces change)
  - bash tools/lint/library.sh
  - bash tools/verify.sh
EOF

  insert_into_section "## Candidate Log (append-only)" "$candidate_tmp" "$SKILL_FILE"
  insert_into_section "## Promotion Packets (generated from candidates)" "$packet_tmp" "$SKILL_FILE"

  rm -f "$candidate_tmp" "$packet_tmp"
}

main() {
  if [[ "$#" -eq 0 ]]; then
    usage >&2
    exit 1
  fi

  case "$1" in
    harvest|--harvest)
      shift
      cmd_harvest "$@"
      ;;
    promote|--promote)
      shift
      cmd_promote "$@"
      ;;
    check|--check)
      shift
      cmd_check "$@"
      ;;
    -h|--help)
      usage
      ;;
    *)
      cmd_legacy "$@"
      ;;
  esac
}

main "$@"
