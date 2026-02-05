#!/usr/bin/env bash
set -euo pipefail

# Stela Context Linter (Manifest Supremacy)
# Purpose: Verify that EVERY artifact listed in the Context Manifest exists.
# Logic: If the Manifest claims it is context, it must be present.

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1
MANIFEST_PATH="ops/lib/manifests/CONTEXT.md"

echo "Stela Context Verification"
echo "Manifest: ops/lib/manifests/CONTEXT.md"
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
  echo "CRITICAL: Manifest not found at ${REPO_ROOT}/${MANIFEST_PATH}"
  exit 2
fi

# 1.1 Context Hazard Guard (library directories must not be in the manifest)
hazard_patterns=(
  "docs/library/agents"
  "docs/library/tasks"
  "docs/library/skills"
)

hazard_found=0
for pattern in "${hazard_patterns[@]}"; do
  if grep -n -F "${pattern}" "${MANIFEST_PATH}" >/dev/null; then
    hazard_found=1
    break
  fi
done

if [[ $hazard_found -eq 1 ]]; then
  fail "CONTEXT HAZARD: must not be in the global context."
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
