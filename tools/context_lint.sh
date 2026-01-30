#!/usr/bin/env bash
set -euo pipefail

# Stela Context Linter (Manifest Supremacy)
# Purpose: Verify that EVERY artifact listed in the Context Manifest exists.
# Logic: If the Manifest claims it is context, it must be present.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
MANIFEST_PATH="${REPO_ROOT}/ops/lib/manifests/CONTEXT_MANIFEST.md"

echo "Stela Context Verification"
echo "Manifest: ops/lib/manifests/CONTEXT_MANIFEST.md"
echo "------------------------"

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

# 1. Manifest Check
if [[ ! -f "${MANIFEST_PATH}" ]]; then
  echo "CRITICAL: Manifest not found at ${MANIFEST_PATH}"
  exit 2
fi

# 2. Extraction (Grab everything inside backticks)
# We do not filter by directory. If it is backticked in the Manifest, we check it.
mapfile -t required_artifacts < <(awk -F'`' 'NF >= 3 { for (i = 2; i <= NF; i += 2) print $i }' "${MANIFEST_PATH}" | grep -v "^$")

if (( ${#required_artifacts[@]} == 0 )); then
  warn "Manifest appears empty (no backticked paths found)."
else
  echo "Verifying ${#required_artifacts[@]} artifacts..."
fi

# 3. Verification Loop
for relative_path in "${required_artifacts[@]}"; do
  # Handle special cases or command snippets if necessary.
  # For now, we assume the Manifest strictly lists file paths in backticks.
  
  target="${REPO_ROOT}/${relative_path}"
  
  if [[ ! -e "${target}" ]]; then
    fail "Missing required context: '${relative_path}'"
  fi
done

echo "------------------------"
if [[ $errors -eq 0 ]]; then
  if [[ $warnings -eq 0 ]]; then
    echo "OK: Context Complete."
  else
    echo "PASS (with $warnings warnings)."
  fi
  exit 0
else
  echo "FAILED: $errors missing artifact(s)."
  exit 1
fi