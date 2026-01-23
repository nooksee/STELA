#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ops/init/pack.sh

Emit a paste-ready ICL context deck in a deterministic order.
USAGE
}

if [[ "${1-}" == "-h" || "${1-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -ne 0 ]]; then
  usage
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if [[ ! -t 1 ]]; then
  exec 2>/dev/null
fi

emit_file() {
  local rel_path="$1"
  local abs_path="${REPO_ROOT}/${rel_path}"

  printf "### %s\n\n" "${rel_path}"
  if [[ -f "${abs_path}" ]]; then
    cat "${abs_path}"
  else
    printf "[MISSING] %s\n" "${rel_path}"
  fi
  printf "\n\n"
}

printf "# ICL Context Deck\n"
printf "# Paste into a new session or IDE agent as a single block.\n\n"

emit_file "ops/init/icl/ICL_OVERVIEW.md"
emit_file "ops/init/icl/INIT_CONTRACT.md"

mapfile -t profile_files < <(find "${REPO_ROOT}/ops/init/profiles" -type f -name "*.md" -print | sort)
for file in "${profile_files[@]}"; do
  emit_file "${file#${REPO_ROOT}/}"
done

mapfile -t manifest_files < <(find "${REPO_ROOT}/ops/init/manifests" -type f -name "*.md" -print | sort)
for file in "${manifest_files[@]}"; do
  emit_file "${file#${REPO_ROOT}/}"
done

protocols=(
  "ops/init/protocols/SAVE_THIS_PROTOCOL.md"
  "ops/init/protocols/SNAPSHOT_PROTOCOL.md"
  "ops/init/protocols/UI_MODE_PROTOCOL.md"
  "ops/init/protocols/HANDOFF_PROTOCOL.md"
)

for rel in "${protocols[@]}"; do
  if [[ -f "${REPO_ROOT}/${rel}" ]]; then
    emit_file "${rel}"
  fi
done

emit_file "STATE_OF_PLAY.md"
