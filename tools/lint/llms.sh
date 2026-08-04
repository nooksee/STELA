#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
GEN_BIN="${REPO_ROOT}/ops/bin/llms"

usage() {
  cat <<'USAGE'
Usage: tools/lint/llms.sh [--test]
USAGE
}

mode="--check"
case "${1:-}" in
  "")
    ;;
  --test)
    mode="--test"
    ;;
  -h|--help)
    usage
    exit 0
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

[[ "$#" -le 1 ]] || {
  usage >&2
  exit 1
}
[[ -x "$GEN_BIN" ]] || die "llms generator is missing or not executable: ops/bin/llms"

trap 'emit_binary_leaf "lint-llms" "finish"' EXIT
emit_binary_leaf "lint-llms" "start"

"$GEN_BIN" "$mode"
