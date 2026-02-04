#!/usr/bin/env bash
set -euo pipefail

# Stela Repo Hygiene Verification
# Purpose: Ensure repo root contains only Platform artifacts and CMS payloads are contained in projects/.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Stela Repo Hygiene Verification"
echo "Root: $ROOT_DIR"
echo

errors=0
warnings=0

fail() {
  echo "FAIL: $1" >&2
  errors=$((errors+1))
}

warn() {
  echo "WARN: $1" >&2
  warnings=$((warnings+1))
}

# 1. Platform Skeleton Check (Must exist)
required_dirs=(
  "ops"
  "docs"
  "tools"
  "projects"
  ".github"
)

for d in "${required_dirs[@]}"; do
  if [[ ! -d "$d" ]]; then
    fail "Missing platform directory: '$d/'"
  fi
done

# 2. Storage Hygiene Check
# Required storage subdirs
if [[ ! -d "storage/handoff" ]]; then
  fail "Missing required storage: 'storage/handoff/'"
fi
if [[ ! -d "storage/dumps" ]]; then
  fail "Missing required storage: 'storage/dumps/'"
fi

# Drift check: warn on unexpected clutter in storage/
# Allowed: README.md, .gitignore, handoff, dumps, dp, _scratch
for item in storage/*; do
  name="$(basename "$item")"
  case "$name" in
    README.md|.gitignore|handoff|dumps|dp|_scratch)
      ;;
    *)
      warn "Storage drift: unexpected item 'storage/$name'. Keep storage/ clean."
      ;;
  esac
done

# 3. Project Structure Check
# Every project folder must have a README.md (minimal valid artifact)
if [[ -d "projects" ]]; then
  for proj in projects/*; do
    if [[ -d "$proj" ]]; then
      if [[ ! -f "$proj/README.md" ]]; then
        warn "Project invalid: '$proj' missing README.md."
      fi
    fi
  done
fi

echo
if [[ $errors -eq 0 ]]; then
  if [[ $warnings -eq 0 ]]; then
    echo "OK: Clean Platform State."
  else
    echo "PASS (with $warnings warnings)."
  fi
  exit 0
else
  echo "FAILED: $errors error(s) detected."
  exit 1
fi