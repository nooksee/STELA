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

search_markdown_contractions() {
  local pattern="$1"

  if command -v rg >/dev/null 2>&1; then
    rg -n -i --glob '*.md' --glob '!**/storage/**' --glob '!**/.git/**' "$pattern" "${REPO_ROOT}" || true
    return 0
  fi

  if command -v grep >/dev/null 2>&1 && grep -P 'a' <<< 'a' >/dev/null 2>&1; then
    grep -R -n -i -P \
      --include='*.md' \
      --exclude-dir='storage' \
      --exclude-dir='.git' \
      "$pattern" "${REPO_ROOT}" || true
    return 0
  fi

  echo "ERROR: neither rg nor grep -P is available on PATH" >&2
  exit 1
}

# Contraction prohibition uses ASCII and unicode apostrophe variants.
apostrophe="['\\x{2019}]"
contraction_pattern="\\b(ain${apostrophe}t|aren${apostrophe}t|can${apostrophe}t|couldn${apostrophe}t|didn${apostrophe}t|doesn${apostrophe}t|don${apostrophe}t|hadn${apostrophe}t|hasn${apostrophe}t|haven${apostrophe}t|isn${apostrophe}t|mightn${apostrophe}t|mustn${apostrophe}t|needn${apostrophe}t|shan${apostrophe}t|shouldn${apostrophe}t|wasn${apostrophe}t|weren${apostrophe}t|won${apostrophe}t|wouldn${apostrophe}t|it${apostrophe}s|that${apostrophe}s|there${apostrophe}s|here${apostrophe}s|who${apostrophe}s|what${apostrophe}s|where${apostrophe}s|when${apostrophe}s|why${apostrophe}s|how${apostrophe}s|let${apostrophe}s|i${apostrophe}m|you${apostrophe}re|we${apostrophe}re|they${apostrophe}re|i${apostrophe}ve|you${apostrophe}ve|we${apostrophe}ve|they${apostrophe}ve|i${apostrophe}ll|you${apostrophe}ll|we${apostrophe}ll|they${apostrophe}ll|i${apostrophe}d|you${apostrophe}d|we${apostrophe}d|they${apostrophe}d)\\b"
contraction_hits="$(search_markdown_contractions "$contraction_pattern")"
if [[ -n "$contraction_hits" ]]; then
  echo "ERROR: Contractions found in markdown files:" >&2
  echo "$contraction_hits" >&2
  exit 1
fi
