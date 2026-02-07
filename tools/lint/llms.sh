#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
GEN_BIN="${REPO_ROOT}/ops/bin/llms"

if [[ ! -x "${GEN_BIN}" ]]; then
  echo "ERROR: llms not found or not executable at ${GEN_BIN}" >&2
  exit 1
fi

required_files=(
  "llms-small.txt"
  "llms-full.txt"
  "llms-ops.txt"
  "llms-governance.txt"
  "llms.txt"
)

missing=0
for file in "${required_files[@]}"; do
  if [[ ! -f "${REPO_ROOT}/${file}" ]]; then
    echo "ERROR: missing ${file} in repo root" >&2
    missing=1
  fi
done

if (( missing > 0 )); then
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
diff -u "${REPO_ROOT}/llms-ops.txt" "${work_dir}/llms-ops.txt"
diff -u "${REPO_ROOT}/llms-governance.txt" "${work_dir}/llms-governance.txt"
diff -u "${REPO_ROOT}/llms.txt" "${work_dir}/llms.txt"

echo "OK: llms bundles match generated output."
