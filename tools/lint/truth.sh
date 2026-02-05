#!/usr/bin/env bash
set -euo pipefail

# Stela Truth Linter (PoT Guard)
# Purpose: Enforce canon spelling, catch legacy drift, and police governance terminology.
# Scope: Authored surfaces only (ops/, docs/, tools/, .github/, and root Canon).
# Ignores: projects/ (Work), storage/ (Trash), public_html/ (Runtime).

# 1. Forbidden Spellings (Hard Fail)
# Typos of the platform name "Stela".
forbidden_spellings=(
  "Steela"
  "Stila"
  "Stella"
  "Sheriff"
  "Colonies"
  "Crown"
)

# 2. Scope Definition (Expanded)
# We now scan ops/ and the root Canon files, which were previously ignored.
scan_dirs=(
  "docs"
  "tools"
  ".github"
  "ops"
)

root_files=(
  "PoT.md"
  "TASK.md"
  "README.md"
  "SECURITY.md"
  "CONTRIBUTING.md"
  "llms.txt"
)

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

echo "Stela Truth Verification"
echo "------------------------"

failures=0
warnings=0

fail() {
  echo "FAIL: $1" >&2
  echo "      $2" >&2
  failures=$((failures+1))
}

warn() {
  echo "WARN: $1" >&2
  echo "      $2" >&2
  warnings=$((warnings+1))
}

mapfile -t tracked_files < <(git ls-files "${scan_dirs[@]}" 2>/dev/null || true)
files=()
for file in "${tracked_files[@]}"; do
  # Ignore unstaged deletions and other non-file tracked entries.
  if [[ ! -f "$file" ]]; then
    continue
  fi
  if [[ "$file" == "tools/lint/truth.sh" ]]; then
    continue
  fi
  files+=("$file")
done

for file in "${root_files[@]}"; do
  if [[ -f "$file" ]]; then
    files+=("$file")
  fi
done

if (( ${#files[@]} == 0 )); then
  echo "OK (No files to scan)"
  exit 0
fi

# Check 1: Forbidden Spellings (Hard Fail)
echo "Scanning for typos (Stela)..."
for token in "${forbidden_spellings[@]}"; do
  # grep word boundary, ignore case
  matches="$(grep -nH -I -E "\b${token}\b" "${files[@]}" 2>/dev/null || true)"
  if [[ -n "$matches" ]]; then
    fail "Forbidden spelling found: '$token'" "$matches"
  fi
done

echo "------------------------"
if [[ $failures -eq 0 ]]; then
  if [[ $warnings -eq 0 ]]; then
    echo "OK: Truth Integrity Verified."
  else
    echo "PASS (with $warnings warnings)."
  fi
  exit 0
else
  echo "FAILED: $failures error(s) detected."
  exit 1
fi
