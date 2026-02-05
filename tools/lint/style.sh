#!/usr/bin/env bash
set -euo pipefail

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi
cd "$REPO_ROOT" || exit 1
CONFIG="${REPO_ROOT}/.markdownlint.json"
skip_markdownlint=0

if [[ ! -f "${CONFIG}" ]]; then
  echo "ERROR: .markdownlint.json not found at ${CONFIG}" >&2
  exit 1
fi

if ! command -v markdownlint >/dev/null 2>&1; then
  if [[ "${STRICT_MARKDOWNLINT:-0}" == "1" ]]; then
    echo "ERROR: markdownlint is required when STRICT_MARKDOWNLINT=1" >&2
    exit 1
  fi
  echo "WARN: markdownlint not found; skipping markdownlint checks." >&2
  skip_markdownlint=1
fi

if ! command -v rg >/dev/null 2>&1; then
  echo "ERROR: rg is required but was not found on PATH" >&2
  exit 1
fi

contraction_pattern="\\b(don't|can't|won't|it's|shouldn't|didn't)\\b"
contraction_hits="$(rg -n -i --glob '!**/.github/**' "$contraction_pattern" "${REPO_ROOT}/docs" "${REPO_ROOT}/ops" || true)"
if [[ -n "$contraction_hits" ]]; then
  echo "ERROR: Contractions found in docs/ or ops/:" >&2
  echo "$contraction_hits" >&2
  exit 1
fi

shopt -s globstar nullglob
files=("${REPO_ROOT}"/docs/**/*.md "${REPO_ROOT}"/ops/**/*.md)

if (( ${#files[@]} == 0 )); then
  echo "WARN: No markdown files found under docs/ or ops/." >&2
  exit 0
fi

if [[ "$skip_markdownlint" -eq 1 ]]; then
  exit 0
fi

markdownlint -c "${CONFIG}" "${files[@]}"
