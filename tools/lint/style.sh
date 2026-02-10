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

# Contraction prohibition uses ASCII and unicode apostrophe variants.
apostrophe="['\\x{2019}]"
contraction_pattern="\\b(ain${apostrophe}t|aren${apostrophe}t|can${apostrophe}t|couldn${apostrophe}t|didn${apostrophe}t|doesn${apostrophe}t|don${apostrophe}t|hadn${apostrophe}t|hasn${apostrophe}t|haven${apostrophe}t|isn${apostrophe}t|mightn${apostrophe}t|mustn${apostrophe}t|needn${apostrophe}t|shan${apostrophe}t|shouldn${apostrophe}t|wasn${apostrophe}t|weren${apostrophe}t|won${apostrophe}t|wouldn${apostrophe}t|it${apostrophe}s|that${apostrophe}s|there${apostrophe}s|here${apostrophe}s|who${apostrophe}s|what${apostrophe}s|where${apostrophe}s|when${apostrophe}s|why${apostrophe}s|how${apostrophe}s|let${apostrophe}s|i${apostrophe}m|you${apostrophe}re|we${apostrophe}re|they${apostrophe}re|i${apostrophe}ve|you${apostrophe}ve|we${apostrophe}ve|they${apostrophe}ve|i${apostrophe}ll|you${apostrophe}ll|we${apostrophe}ll|they${apostrophe}ll|i${apostrophe}d|you${apostrophe}d|we${apostrophe}d|they${apostrophe}d)\\b"
contraction_hits="$(rg -n -i --glob '*.md' --glob '!**/storage/**' --glob '!**/.git/**' "$contraction_pattern" "${REPO_ROOT}" || true)"
if [[ -n "$contraction_hits" ]]; then
  echo "ERROR: Contractions found in markdown files:" >&2
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
