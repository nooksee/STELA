#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WEBROOT="${ROOT_DIR}/public_html"
echo "Stela Tree Verification Report"
echo "Webroot: ${WEBROOT}"
echo
problem_count=0
warn(){ echo "WARN: $1"; problem_count=$((problem_count+1)); }
for d in modules admin includes themes; do
  [[ -d "${WEBROOT}/${d}" ]] || warn "Missing expected directory: ${d}/"
done
for d in boot patches tools storage releases _meta _meta; do
  [[ -d "${WEBROOT}/${d}" ]] && warn "Webroot leak: '${d}/' exists inside public_html (should be repo root)."
done
echo
if [[ ${problem_count} -eq 0 ]]; then echo "OK"; else echo "${problem_count} issue(s)"; fi
