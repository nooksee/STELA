#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG="${REPO_ROOT}/.markdownlint.json"

if [[ ! -f "${CONFIG}" ]]; then
  echo "ERROR: .markdownlint.json not found at ${CONFIG}" >&2
  exit 1
fi

if ! command -v markdownlint >/dev/null 2>&1; then
  echo "ERROR: markdownlint is not installed or not in PATH" >&2
  exit 1
fi

shopt -s globstar nullglob
files=("${REPO_ROOT}"/docs/**/*.md "${REPO_ROOT}"/ops/**/*.md)

if (( ${#files[@]} == 0 )); then
  echo "WARN: No markdown files found under docs/ or ops/." >&2
  exit 0
fi

markdownlint -c "${CONFIG}" "${files[@]}"
