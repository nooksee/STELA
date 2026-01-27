#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST_PATH="${REPO_ROOT}/ops/lib/manifests/CONTEXT_MANIFEST.md"
SoP_PATH="${REPO_ROOT}/SoP.md"

errors=0
warnings=0

note() {
  printf "[context_lint] %s\n" "$1"
}

warn() {
  printf "[context_lint] WARN: %s\n" "$1"
  warnings=1
}

error() {
  printf "[context_lint] ERROR: %s\n" "$1"
  errors=1
}

extract_backticks() {
  awk -F'`' 'NF >= 3 { for (i = 2; i <= NF; i += 2) print $i }' "$1"
}

is_known_path() {
  local entry="$1"
  case "$entry" in
    ops/init/*)
      return 1
      ;;
    ops/*|docs/*|tools/*|public_html/*|upstream/*|storage/*|tests/*|scripts/*|addons/*|patches/*|nbproject/*|.github/*|README.md|SECURITY.md|CONTRIBUTING.md|SoP.md|TRUTH.md|CHANGELOG.md)
      return 0
      ;;
  esac
  return 1
}

if [[ ! -f "${MANIFEST_PATH}" ]]; then
  error "Missing manifest: ops/lib/manifests/CONTEXT_MANIFEST.md"
else
  manifest_entries=$(extract_backticks "${MANIFEST_PATH}" | awk 'NF')
  if [[ -z "${manifest_entries}" ]]; then
    error "No canonical entries found in ops/lib/manifests/CONTEXT_MANIFEST.md"
  else
    while IFS= read -r entry; do
      case "${entry}" in
        ops/*|docs/*|tools/*|SoP.md|TRUTH.md|AGENTS.md|llms.txt)
          target="${REPO_ROOT}/${entry}"
          if [[ ! -f "${target}" ]]; then
            error "Missing canonical file: ${entry}"
          fi
          ;;
      esac
    done <<< "${manifest_entries}"
  fi
fi

if [[ -f "${SoP_PATH}" ]]; then
  note "Skipping SoP.md referenced-path enforcement (historical log)."
else
  warn "Missing SoP.md"
fi

if [[ ${errors} -ne 0 ]]; then
  note "Result: errors detected"
  exit 2
fi

if [[ ${warnings} -ne 0 ]]; then
  note "Result: warnings detected"
  exit 1
fi

note "Result: clean"
exit 0
