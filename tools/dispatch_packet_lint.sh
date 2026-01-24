#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: tools/dispatch_packet_lint.sh [--test] [path|-]
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
    -v header_fresh="[FRESHNESS GATE]" \
    -v header_purpose="[PURPOSE]" \
    -v header_scope="[SCOPE]" \
    -v header_files="[FILES]" \
    -v header_tasks="[TASKS]" \
    -v header_verify="[VERIFICATION]" \
    '
    {
      if (!line_fresh && $0 == header_fresh) { line_fresh = NR }
      if (!line_purpose && $0 == header_purpose) { line_purpose = NR }
      if (!line_scope && $0 == header_scope) { line_scope = NR }
      if (!line_files && $0 == header_files) { line_files = NR }
      if (!line_tasks && $0 == header_tasks) { line_tasks = NR }
      if (!line_verify && $0 == header_verify) { line_verify = NR }
    }
    END {
      if (!line_fresh) { print "FAIL: missing header " header_fresh; exit 1 }
      if (!line_purpose) { print "FAIL: missing header " header_purpose; exit 1 }
      if (!line_scope) { print "FAIL: missing header " header_scope; exit 1 }
      if (!line_files) { print "FAIL: missing header " header_files; exit 1 }
      if (!line_tasks) { print "FAIL: missing header " header_tasks; exit 1 }
      if (!line_verify) { print "FAIL: missing header " header_verify; exit 1 }
      if (!(line_fresh < line_purpose && line_purpose < line_scope && line_scope < line_files && line_files < line_tasks && line_tasks < line_verify)) {
        print "FAIL: headers out of order"
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
[FRESHNESS GATE]
Example
[PURPOSE]
Example
[SCOPE]
Example
[FILES]
Example
[TASKS]
Example
[VERIFICATION]
Example
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
