#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
GEN_BIN="${REPO_ROOT}/ops/bin/llms"

if [[ ! -x "${GEN_BIN}" ]]; then
  echo "ERROR: llms not found or not executable at ${GEN_BIN}" >&2
  exit 1
fi

if [[ ! -f "${REPO_ROOT}/llms-small.txt" || ! -f "${REPO_ROOT}/llms-full.txt" ]]; then
  echo "ERROR: llms-small.txt or llms-full.txt missing in repo root" >&2
  exit 1
fi

work_dir="$(mktemp -d)"
cleanup() {
  rm -rf "${work_dir}"
}
trap cleanup EXIT

"${GEN_BIN}" --out-dir="${work_dir}"

diff -u "${REPO_ROOT}/llms-small.txt" "${work_dir}/llms-small.txt"
diff -u "${REPO_ROOT}/llms-full.txt" "${work_dir}/llms-full.txt"

echo "OK: llms bundles match generated output."
