#!/usr/bin/env bash
set -euo pipefail

# nukeCE truth lint:
# Only checks authored surfaces.
# Ignores upstream/runtime/quarantine/vendor entirely.

patterns=(
  '\bnukece_meta\b'
  'boot/_upstream_runtime'
)

forbidden_spellings=(
  Steela
  Stila
  Stella
)

scan_paths=(
  docs
  boot
  tools
  .github
)

root_files=(
  README.md
  SECURITY.md
  CONTRIBUTING.md
  CODE_OF_CONDUCT.md
)

fail=0

files="$(git ls-files "${scan_paths[@]}" 2>/dev/null || true)"
for f in "${root_files[@]}"; do
  [ -f "$f" ] && files="$files"$'\n'"$f"
done

# Prevent self-matches: this linter contains the patterns by design.
files="$(printf '%s\n' "$files" | grep -v -x 'tools/repo/lint_truth.sh' || true)"

[ -z "${files//[[:space:]]/}" ] && { echo "[lint_truth] OK (no files to scan)"; exit 0; }

for pat in "${patterns[@]}"; do
  if echo "$files" | xargs -r grep -nH -I -E "$pat" >/dev/null 2>&1; then
    echo "[lint_truth] DEPRECATED reference found: $pat"
    echo "$files" | xargs -r grep -nH -I -E "$pat" || true
    fail=1
  fi
done

for token in "${forbidden_spellings[@]}"; do
  pattern="\\<${token}\\>"
  if echo "$files" | xargs -r grep -nH -I -E "$pattern" >/dev/null 2>&1; then
    echo "[lint_truth] FORBIDDEN spelling found: $token"
    echo "$files" | xargs -r grep -nH -I -E "$pattern" || true
    fail=1
  fi
done

[ "$fail" -eq 1 ] && { echo "[lint_truth] FAIL"; exit 1; }

echo "[lint_truth] OK"
