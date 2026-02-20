#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

emit_binary_leaf "lint-leaf" "start"
trap 'emit_binary_leaf "lint-leaf" "finish"' EXIT

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

failures=0

fail() {
  echo "FAIL: $*" >&2
  failures=1
}

# All ops/bin/ files except ops/bin/project (deprecated).
mapfile -t BINARIES < <(git ls-files ops/bin/ | grep -v 'ops/bin/project$' | sort)

# All tools/ executables in scope.
mapfile -t TOOLS < <(git ls-files tools/lint/ tools/verify.sh tools/test/ | grep '\.sh$' | sort)

check_wired() {
  local path="$1"
  if ! grep -q 'emit_binary_leaf' "$path"; then
    fail "emit_binary_leaf not found in: ${path}"
  fi
}

for f in "${BINARIES[@]}"; do
  check_wired "$f"
done

for f in "${TOOLS[@]}"; do
  check_wired "$f"
done

if (( failures == 1 )); then
  echo "leaf lint: FAIL" >&2
  exit 1
fi

echo "leaf lint: PASS"
