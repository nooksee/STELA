#!/usr/bin/env bash
set -euo pipefail

# Stela Repo Hygiene Verification
# Purpose: Ensure repo root contains only Platform artifacts and CMS payloads are contained in projects/.

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

echo "Stela Repo Hygiene Verification"
echo "Root: $REPO_ROOT"
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
# Allowed: README.md, .gitignore, handoff, dumps, dp, _scratch, archives
for item in storage/*; do
  name="$(basename "$item")"
  case "$name" in
    README.md|.gitignore|handoff|dumps|dp|_scratch|archives)
      ;;
    *)
      warn "Storage drift: unexpected item 'storage/$name'. Keep storage/ clean."
      ;;
  esac
done

# 3. Filing Doctrine Checks
if ! command -v file >/dev/null 2>&1; then
  fail "Missing dependency: file (required for binary checks)"
else
  doc_binaries=()
  while IFS= read -r -d '' doc_path; do
    encoding="$(file -b --mime-encoding "$doc_path")"
    if [[ "$encoding" == "binary" ]]; then
      doc_binaries+=("$doc_path")
    fi
  done < <(find docs -type f -print0)

  if (( ${#doc_binaries[@]} > 0 )); then
    for doc_path in "${doc_binaries[@]}"; do
      fail "Filing Doctrine violation: binary file in docs/: $doc_path"
    done
  fi
fi

doc_non_markdown=()
while IFS= read -r -d '' doc_path; do
  doc_non_markdown+=("$doc_path")
done < <(find docs -type f ! -name '*.md' -print0)

if (( ${#doc_non_markdown[@]} > 0 )); then
  for doc_path in "${doc_non_markdown[@]}"; do
    fail "Filing Doctrine violation: non-markdown file in docs/: $doc_path"
  done
fi

ops_markdown=()
while IFS= read -r -d '' ops_path; do
  ops_markdown+=("$ops_path")
done < <(find ops -type f -name '*.md' -print0)

if (( ${#ops_markdown[@]} > 0 )); then
  for ops_path in "${ops_markdown[@]}"; do
    case "$ops_path" in
      ops/lib/manifests/*|ops/lib/project/*)
        ;;
      *)
        fail "Filing Doctrine violation: loose markdown in ops/: $ops_path"
        ;;
    esac
  done
fi

# 4. Project Structure Check
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
