#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ops/lib/skill/skill_lib.sh "name" "context" "solution"
USAGE
}

if [[ "$#" -ne 3 ]]; then
  usage >&2
  exit 1
fi

name="$1"
context="$2"
solution="$3"

if [[ "$name" == *$'\n'* || "$context" == *$'\n'* || "$solution" == *$'\n'* ]]; then
  echo "ERROR: inputs must be single-line values" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
SKILL_FILE="${REPO_ROOT}/SKILL.md"

if [[ ! -f "${SKILL_FILE}" ]]; then
  echo "ERROR: SKILL.md not found at ${SKILL_FILE}" >&2
  exit 1
fi

if [[ ! -f "${REPO_ROOT}/docs/library/INDEX.md" ]]; then
  echo "ERROR: docs/library/INDEX.md not found" >&2
  exit 1
fi

max_id=0

if [[ -d "${REPO_ROOT}/docs/library/skills" ]]; then
  while IFS= read -r file; do
    base="$(basename "$file")"
    if [[ "$base" =~ S-LEARN-([0-9]+)\.md ]]; then
      num="${BASH_REMATCH[1]}"
      if ((10#$num > max_id)); then
        max_id=$((10#$num))
      fi
    fi
  done < <(find "${REPO_ROOT}/docs/library/skills" -maxdepth 1 -type f -name 'S-LEARN-*.md')
fi

while IFS= read -r match; do
  if [[ "$match" =~ S-LEARN-([0-9]+) ]]; then
    num="${BASH_REMATCH[1]}"
    if ((10#$num > max_id)); then
      max_id=$((10#$num))
    fi
  fi
done < <(grep -oE 'S-LEARN-[0-9]+' "${REPO_ROOT}/docs/library/INDEX.md" || true)

next_id=$((max_id + 1))
next_id_fmt="$(printf '%02d' "$next_id")"
skill_id="S-LEARN-${next_id_fmt}"
anchor_id="promotion-packet-${skill_id,,}"

timestamp="$(date -u '+%Y-%m-%d %H:%M:%S UTC')"

candidate_tmp="$(mktemp)"
packet_tmp="$(mktemp)"

cat <<EOF_CANDIDATE > "${candidate_tmp}"
- ${timestamp} - [Promotion Packet](#${anchor_id})
  - Name: ${name}
  - Context: ${context}
  - Solution: ${solution}
EOF_CANDIDATE

cat <<EOF_PACKET > "${packet_tmp}"
<a id="${anchor_id}"></a>
### Promotion Packet: ${skill_id} - ${name}
- Candidate name: ${name}
- Proposed Skill ID: ${skill_id} (rule: choose the next available numeric ID not already present in docs/library/skills or registered in docs/library/INDEX.md)
- Scope: production payloads only; not platform maintenance
- Invocation guidance: Use this skill when ${context}. Apply the solution: ${solution}.
- Drift preventers:
  - Stop conditions: Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill
  - Anti-hallucination: Use repo files as SSOT and stop if required inputs are missing
  - Negative check: Do not add Skills to ops/lib/manifests/CONTEXT.md
- Definition of Done:
  - ${skill_id} created under docs/library/skills and matches scope and drift preventers
  - docs/library/INDEX.md updated with a stable topic key and correct path
  - SoP.md updated if canon or governance surfaces changed
  - Proof bundle updated in storage/handoff with diff outputs
- Verification (capture command output in RESULTS):
  - ./ops/bin/dump --scope=platform
  - bash tools/context_lint.sh
  - bash tools/lint_truth.sh (required when canon or governance surfaces change)
  - bash tools/lint_library.sh
  - bash tools/verify_tree.sh
EOF_PACKET

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
  ' "${target}" > "${tmp}"; then
    status=$?
    rm -f "${tmp}"
    if [[ "$status" -eq 2 ]]; then
      echo "ERROR: section not found: ${section}" >&2
    else
      echo "ERROR: failed to update ${target}" >&2
    fi
    return 1
  fi

  mv "${tmp}" "${target}"
}

insert_into_section "## Candidate Log (append-only)" "${candidate_tmp}" "${SKILL_FILE}"
insert_into_section "## Promotion Packets (generated from candidates)" "${packet_tmp}" "${SKILL_FILE}"

rm -f "${candidate_tmp}" "${packet_tmp}"
