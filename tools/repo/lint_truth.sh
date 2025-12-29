#!/usr/bin/env bash
set -euo pipefail

# Fail if deprecated paths are referenced anywhere in tracked files
bad_patterns=(
  '_meta'
  'upstream'
)

fail=0
for pat in "${bad_patterns[@]}"; do
  if git grep -n -- "$pat" >/dev/null 2>&1; then
    echo "[lint_truth] DEPRECATED reference found: $pat"
    git grep -n -- "$pat" || true
    fail=1
  fi
done

if [ "$fail" -eq 1 ]; then
  echo "[lint_truth] FAIL"
  exit 1
fi

echo "[lint_truth] OK"
