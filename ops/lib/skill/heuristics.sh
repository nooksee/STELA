#!/usr/bin/env bash
set -euo pipefail

# Stela Skill Heuristics Engine
# Functions are sourced by ops/lib/skill/skill_lib.sh

detect_hot_zone() {
  local base_ref="${1:-main}"
  local head_ref="${2:-HEAD}"
  local repo_root="${3:-.}"

  local result
  result="$(git -C "$repo_root" diff --numstat "$base_ref...$head_ref" 2>/dev/null | \
    awk -F '\t' '{
      ins=$1; del=$2; file=$3;
      if (ins == "-") { ins = 0 }
      if (del == "-") { del = 0 }
      changes = ins + del
      if (file != "" && changes > 0) { print changes "\t" file }
    }' | sort -nr | head -n 1)"

  if [[ -z "$result" ]]; then
    echo "None"
    return 0
  fi

  printf '%s\n' "${result#*$'\t'}"
}

detect_high_churn() {
  local base_ref="${1:-main}"
  local head_ref="${2:-HEAD}"
  local repo_root="${3:-.}"

  local output
  output="$(git -C "$repo_root" log --name-only --format="" "$base_ref...$head_ref" 2>/dev/null | \
    awk 'NF { counts[$0]++ } END { for (file in counts) if (counts[file] > 1) print counts[file] "\t" file }' | \
    sort -nr | head -n 3)"

  if [[ -z "$output" ]]; then
    echo "None"
    return 0
  fi

  local lines=()
  while IFS=$'\t' read -r count file; do
    if [[ -n "$file" ]]; then
      lines+=("${file} (${count} commits)")
    fi
  done <<< "$output"

  if (( ${#lines[@]} == 0 )); then
    echo "None"
    return 0
  fi

  printf '%s\n' "${lines[@]}"
}

generate_provenance_block() {
  local dp_id="$1"
  local objective="$2"
  local base_ref="${3:-main}"
  local head_ref="${4:-HEAD}"
  local repo_root="${5:-.}"

  local branch
  branch="$(git -C "$repo_root" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "Unknown")"
  local head_hash
  head_hash="$(git -C "$repo_root" rev-parse HEAD 2>/dev/null || echo "Unknown")"
  local timestamp
  timestamp="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"
  local diff_stat
  diff_stat="$(git -C "$repo_root" diff --stat "$base_ref...$head_ref" 2>/dev/null || true)"
  if [[ -z "$diff_stat" ]]; then
    diff_stat="(no changes)"
  fi

  local hot_zone
  hot_zone="$(detect_hot_zone "$base_ref" "$head_ref" "$repo_root")"
  if [[ -z "$hot_zone" ]]; then
    hot_zone="None"
  fi

  local high_churn
  high_churn="$(detect_high_churn "$base_ref" "$head_ref" "$repo_root")"
  if [[ -z "$high_churn" ]]; then
    high_churn="None"
  fi

  cat <<EOF
## Provenance
- **Captured:** ${timestamp}
- **DP-ID:** ${dp_id:-Not provided}
- **Branch:** ${branch}
- **HEAD:** ${head_hash}
- **Objective:** ${objective:-Not provided}
- **Friction Context:**
  - Hot Zone: ${hot_zone}
  - High Churn: ${high_churn}
- **Diff Stat:**
\`\`\`text
${diff_stat}
\`\`\`
EOF
}

check_semantic_collision() {
  local title="$1"
  local skills_dir="$2"
  local drafts_dir="${3:-}"

  if [[ -z "$title" ]]; then
    return 0
  fi

  if [[ ! -d "$skills_dir" && ( -z "$drafts_dir" || ! -d "$drafts_dir" ) ]]; then
    return 0
  fi

  local clean_title
  clean_title="$(printf '%s' "$title" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9 ' ' ')"

  read -r -a raw_words <<< "$clean_title"
  local words=()
  local word
  for word in "${raw_words[@]}"; do
    if [[ "$word" =~ ^(the|and|for|with|use|how|to|skill|skills|learn|learning|guide|guidance|overview|practice|best)$ ]]; then
      continue
    fi
    if (( ${#word} < 3 )); then
      continue
    fi
    words+=("$word")
  done

  if (( ${#words[@]} == 0 )); then
    return 0
  fi

  local collision_count=0
  local threshold=2
  local file
  for file in "$skills_dir"/*.md "$drafts_dir"/skill-draft-*.md; do
    if [[ ! -f "$file" ]]; then
      continue
    fi

    local match_count=0
    local content
    content="$(tr '[:upper:]' '[:lower:]' < "$file")"

    for word in "${words[@]}"; do
      if grep -qF "$word" <<< "$content"; then
        match_count=$((match_count + 1))
      fi
    done

    if (( match_count >= threshold )); then
      echo "WARN: Potential collision in $(basename "$file") (${match_count} keyword matches)" >&2
      collision_count=$((collision_count + 1))
    fi
  done

  if (( collision_count > 0 )); then
    echo "WARN: Found ${collision_count} existing skills with similar keywords." >&2
    echo "WARN: Use --force to proceed if this is a distinct concept." >&2
    return 1
  fi

  return 0
}
