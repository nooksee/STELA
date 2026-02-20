#!/usr/bin/env bash
set -euo pipefail
source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
GEN_BIN="${REPO_ROOT}/ops/bin/llms"

if [[ ! -x "${GEN_BIN}" ]]; then
  echo "ERROR: llms not found or not executable at ${GEN_BIN}" >&2
  exit 1
fi

required_files=(
  "llms.txt"
  "llms-core.txt"
  "llms-full.txt"
)

deprecated_files=(
  "llms-small.txt"
  "llms-ops.txt"
  "llms-governance.txt"
)

missing=0
for file in "${required_files[@]}"; do
  if [[ ! -f "${REPO_ROOT}/${file}" ]]; then
    echo "ERROR: missing ${file} in repo root" >&2
    missing=1
  fi
done

for file in "${deprecated_files[@]}"; do
  if [[ -e "${REPO_ROOT}/${file}" ]]; then
    echo "ERROR: deprecated llms slice must not exist: ${file}" >&2
    missing=1
  fi
done

if (( missing > 0 )); then
  exit 1
fi

work_dir=""
cleanup() {
  emit_binary_leaf "lint-llms" "finish"
  [[ -n "$work_dir" ]] && rm -rf "${work_dir}"
}
trap cleanup EXIT
emit_binary_leaf "lint-llms" "start"
work_dir="$(mktemp -d)"

gen_output="$("${GEN_BIN}" --out-dir="${work_dir}")"
printf '%s\n' "${gen_output}"

for file in "${deprecated_files[@]}"; do
  if grep -Fq "${file}" <<< "${gen_output}"; then
    echo "ERROR: generator still references deprecated output: ${file}" >&2
    exit 1
  fi
done

if grep -Eq '(^|[^[:alnum:]_-])(llms-small[.]txt|llms-ops[.]txt|llms-governance[.]txt)([^[:alnum:]_-]|$)' "${REPO_ROOT}/llms.txt"; then
  echo "ERROR: llms.txt still references deprecated llms slice outputs" >&2
  exit 1
fi
if grep -Eq '(^|[^[:alnum:]_-])(llms-small[.]txt|llms-ops[.]txt|llms-governance[.]txt)([^[:alnum:]_-]|$)' "${work_dir}/llms.txt"; then
  echo "ERROR: generated llms.txt still references deprecated llms slice outputs" >&2
  exit 1
fi

diff -u "${REPO_ROOT}/llms-core.txt" "${work_dir}/llms-core.txt"
diff -u "${REPO_ROOT}/llms-full.txt" "${work_dir}/llms-full.txt"
diff -u "${REPO_ROOT}/llms.txt" "${work_dir}/llms.txt"

echo "OK: llms bundles match generated output."
