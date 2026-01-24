#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: ops/bin/dispatch_packet_lint.sh [--test] [path|-]
USAGE
}

die() {
  echo "FAIL: $*" >&2
  exit 1
}

lint_file() {
  local path="$1"
  if [[ ! -f "$path" ]]; then
    die "Missing file: $path"
  fi

  awk \
    -v header_a="### A) STATE" \
    -v header_b="### B) REQUEST" \
    -v header_c="### C) CHANGELOG" \
    -v header_d="### D) PATCH / DIFF" \
    -v header_e="### E) RECEIPT" \
    '
    {
      if (!line_a && $0 == header_a) { line_a = NR }
      if (!line_b && $0 == header_b) { line_b = NR }
      if (!line_c && $0 == header_c) { line_c = NR }
      if (!line_d && $0 == header_d) { line_d = NR }
      if (!line_e && $0 == header_e) { line_e = NR; in_receipt = 1 }
      if (in_receipt && $0 ~ /Target Directory: storage\/handoff\//) { handoff = 1 }
    }
    END {
      if (!line_a) { print "FAIL: missing header " header_a; exit 1 }
      if (!line_b) { print "FAIL: missing header " header_b; exit 1 }
      if (!line_c) { print "FAIL: missing header " header_c; exit 1 }
      if (!line_d) { print "FAIL: missing header " header_d; exit 1 }
      if (!line_e) { print "FAIL: missing header " header_e; exit 1 }
      if (!(line_a < line_b && line_b < line_c && line_c < line_d && line_d < line_e)) {
        print "FAIL: headers out of order"
        exit 1
      }
      if (!handoff) {
        print "FAIL: missing Target Directory: storage/handoff/ under RECEIPT"
        exit 1
      }
      print "OK: headers present and ordered"
    }
  ' "$path"
}

run_test() {
  local tmp
  tmp="$(mktemp)"
  cat <<'EOF' > "$tmp"
### A) STATE
Example
### B) REQUEST
Example
### C) CHANGELOG
Example
### D) PATCH / DIFF
Example
### E) RECEIPT
Target Directory: storage/handoff/
EOF
  lint_file "$tmp"
  rm -f "$tmp"
}

if (( $# > 1 )); then
  usage >&2
  die "Too many arguments"
fi

case "${1:-}" in
  --test)
    run_test
    exit 0
    ;;
  "" )
    if [[ -t 0 ]]; then
      usage >&2
      die "No input provided"
    fi
    tmp_stdin="$(mktemp)"
    cat > "$tmp_stdin"
    lint_file "$tmp_stdin"
    rm -f "$tmp_stdin"
    ;;
  - )
    tmp_stdin="$(mktemp)"
    cat > "$tmp_stdin"
    lint_file "$tmp_stdin"
    rm -f "$tmp_stdin"
    ;;
  * )
    lint_file "$1"
    ;;
esac
