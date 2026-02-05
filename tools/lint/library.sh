#!/usr/bin/env bash
set -euo pipefail

# Stela Library Guard (Registry Enforcement)
# Purpose: Ensure docs/library/INDEX.md is the exclusive SSOT for the library.
# Logic:
# 1. No Dead Ends: All paths in INDEX.md must exist on disk.
# 2. No Ghosts: All .md files in docs/library/ must be listed in INDEX.md.

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1
LIBRARY_INDEX="docs/library/INDEX.md"
LIBRARY_DIR="docs/library"

echo "Stela Library Verification"
echo "Registry: docs/library/INDEX.md"
echo "------------------------"

failures=0

fail() {
  echo "FAIL: $1" >&2
  failures=$((failures+1))
}

# 1. Parse Registry (Get all registered paths)
if [[ ! -f "${LIBRARY_INDEX}" ]]; then
  echo "CRITICAL: Registry file missing at ${REPO_ROOT}/${LIBRARY_INDEX}"
  exit 2
fi

# Extract the 3rd column (path), stripping comments and whitespace
mapfile -t registered_paths < <(awk -F'|' '
  /^[[:space:]]*#/ { next }
  /^[[:space:]]*$/ { next }
  NF >= 3 {
    # Trim whitespace from the 3rd column
    path = $3
    sub(/^[[:space:]]+/, "", path)
    sub(/[[:space:]]+$/, "", path)
    print path
  }
' "${LIBRARY_INDEX}")

# 2. Check for Dead Ends (Registry -> Disk)
# Does every file claimed by the Index actually exist?
for path in "${registered_paths[@]}"; do
  if [[ ! -f "${path}" ]]; then
    fail "Dead End: Registry points to missing file '${path}'"
  fi
done

# 3. Check for Ghosts (Disk -> Registry)
# Does every file in the library directory appear in the Index?
while IFS= read -r file; do
  # Get repo-relative path for comparison
  rel_path="${file#${REPO_ROOT}/}"
  
  # The Registry itself is exempt from registration
  if [[ "$rel_path" == "docs/library/INDEX.md" ]]; then
    continue
  fi

  # Check if rel_path exists in our registered_paths array
  found=0
  for registered in "${registered_paths[@]}"; do
    if [[ "$registered" == "$rel_path" ]]; then
      found=1
      break
    fi
  done

  if [[ $found -eq 0 ]]; then
    fail "Ghost Artifact: '${rel_path}' exists but is not registered in INDEX.md"
  fi

done < <(find "${LIBRARY_DIR}" -type f -name "*.md")

echo "------------------------"
if [[ $failures -eq 0 ]]; then
  echo "OK: Library Integrity Verified."
  exit 0
else
  echo "FAILED: $failures error(s) detected."
  exit 1
fi
