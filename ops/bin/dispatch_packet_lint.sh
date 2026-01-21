#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ops/bin/dispatch_packet_lint.sh [path]
USAGE
}

if (( $# > 1 )); then
  usage >&2
  exit 2
fi

if (( $# == 1 )); then
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
  esac
fi

target="${1:-ops/templates/DISPATCH_PACKET_TEMPLATE.md}"

if [[ ! -f "$target" ]]; then
  echo "FAIL: file not found: $target" >&2
  exit 2
fi

expected=(
  "### A) STATE"
  "### B) REQUEST"
  "### C) CHANGELOG"
  "### D) PATCH / DIFF"
  "### E) RECEIPT"
)

found=()
while IFS= read -r line || [[ -n "$line" ]]; do
  line="${line%$'\r'}"
  if [[ "$line" =~ ^###\ [A-E]\) ]]; then
    found+=("$line")
  fi
done < "$target"

if (( ${#found[@]} == 0 )); then
  echo "FAIL: no A-E headings found in $target" >&2
  exit 1
fi

previous=""
for i in "${!expected[@]}"; do
  expected_line="${expected[$i]}"
  if (( i >= ${#found[@]} )); then
    if [[ -n "$previous" ]]; then
      echo "FAIL: expected heading '$expected_line' after '$previous' but found end-of-file" >&2
    else
      echo "FAIL: expected heading '$expected_line' but found end-of-file" >&2
    fi
    exit 1
  fi
  if [[ "${found[$i]}" != "$expected_line" ]]; then
    if [[ -n "$previous" ]]; then
      echo "FAIL: expected heading '$expected_line' after '$previous' but found '${found[$i]}'" >&2
    else
      echo "FAIL: expected heading '$expected_line' but found '${found[$i]}'" >&2
    fi
    exit 1
  fi
  previous="$expected_line"
done

if (( ${#found[@]} != ${#expected[@]} )); then
  echo "FAIL: expected exactly ${#expected[@]} canonical A-E headings but found ${#found[@]}" >&2
  exit 1
fi

echo "OK: dispatch packet headings match canonical A-E"
exit 0
