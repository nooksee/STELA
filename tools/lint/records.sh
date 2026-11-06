#!/usr/bin/env bash
set -euo pipefail

if ! REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"; then
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi
# shellcheck source=/dev/null
source "${REPO_ROOT}/ops/lib/scripts/common.sh"

cd "$REPO_ROOT"
trap 'emit_binary_leaf "lint-records" "finish"' EXIT
emit_binary_leaf "lint-records" "start"

# Records Lint (DP-OPS-0270)
# Purpose: prove that a records directory and its digest list agree, so a
# corrupted, missing, or unlisted record fails the gates and not only a packet
# receipt. The digest list is SHA256SUMS in the directory, one line per record
# in sha256sum format: 64 hex characters, two spaces, a bare file name.
# Default directory: opt/_research (the research records class admitted by
# tools/verify.sh in DP-OPS-0268).

usage() {
  cat <<'USAGE'
Usage: bash tools/lint/records.sh [--test] [directory]
Default directory: opt/_research
USAGE
}

DIGEST_FILE_NAME="SHA256SUMS"
RECORD_SUFFIX=".pdf"

lint_records_dir() {
  local dir="$1"
  local failures=0
  local digest_path="${dir}/${DIGEST_FILE_NAME}"
  local line_no=0
  local line hash name
  local listed=()
  local present=()

  if [[ ! -d "$dir" ]]; then
    echo "FAIL: records directory missing: ${dir}" >&2
    return 1
  fi
  if [[ ! -f "$digest_path" ]]; then
    echo "FAIL: digest list missing: ${digest_path}" >&2
    return 1
  fi

  while IFS= read -r line || [[ -n "$line" ]]; do
    line_no=$((line_no + 1))
    if [[ ! "$line" =~ ^([0-9a-f]{64})\ \ ([^/[:space:]]+)$ ]]; then
      echo "FAIL: malformed digest line ${line_no}: ${line}" >&2
      failures=$((failures + 1))
      continue
    fi
    hash="${BASH_REMATCH[1]}"
    name="${BASH_REMATCH[2]}"
    if [[ "$name" != *"$RECORD_SUFFIX" ]]; then
      echo "FAIL: digest line ${line_no} names a non-record file: ${name}" >&2
      failures=$((failures + 1))
      continue
    fi
    local seen
    for seen in "${listed[@]:-}"; do
      if [[ "$seen" == "$name" ]]; then
        echo "FAIL: duplicate digest entry: ${name}" >&2
        failures=$((failures + 1))
      fi
    done
    listed+=("$name")
    if [[ ! -f "${dir}/${name}" ]]; then
      echo "FAIL: listed record missing: ${dir}/${name}" >&2
      failures=$((failures + 1))
    fi
  done < "$digest_path"

  local path
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    name="${path##*/}"
    present+=("$name")
    local found=0
    for seen in "${listed[@]:-}"; do
      if [[ "$seen" == "$name" ]]; then
        found=1
        break
      fi
    done
    if (( found == 0 )); then
      echo "FAIL: record not in digest list: ${path}" >&2
      failures=$((failures + 1))
    fi
  done < <(find "$dir" -maxdepth 1 -type f -name "*${RECORD_SUFFIX}" | sort)

  if (( failures == 0 )); then
    if ! (cd "$dir" && sha256sum -c --quiet "$DIGEST_FILE_NAME" >/dev/null 2>&1); then
      echo "FAIL: digest mismatch in ${dir} (sha256sum -c reports at least one record changed)" >&2
      (cd "$dir" && sha256sum -c "$DIGEST_FILE_NAME" 2>/dev/null | grep -v ': OK$' >&2 || true)
      failures=$((failures + 1))
    fi
  fi

  if (( failures > 0 )); then
    echo "records lint: FAIL (${failures} finding(s) in ${dir})" >&2
    return 1
  fi
  echo "OK: records lint passed (${#listed[@]} record(s) listed, ${#present[@]} present, digests verified in ${dir})."
  return 0
}

run_self_test() {
  local tmp
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' RETURN
  local failures=0

  make_fixture() {
    local dir="$1"
    mkdir -p "$dir"
    printf 'alpha\n' > "${dir}/alpha-report.pdf"
    printf 'beta\n' > "${dir}/beta-report.pdf"
    (cd "$dir" && sha256sum alpha-report.pdf beta-report.pdf > "$DIGEST_FILE_NAME")
  }

  expect() {
    local label="$1" want="$2" dir="$3"
    local got="PASS"
    if ! lint_records_dir "$dir" >/dev/null 2>&1; then
      got="FAIL"
    fi
    if [[ "$got" == "$want" ]]; then
      echo "PASS: ${label} (${want})"
    else
      echo "FAIL: ${label}: expected ${want}, got ${got}" >&2
      failures=$((failures + 1))
    fi
  }

  make_fixture "${tmp}/clean"
  expect "clean set" PASS "${tmp}/clean"

  make_fixture "${tmp}/tampered"
  printf 'changed\n' > "${tmp}/tampered/alpha-report.pdf"
  expect "tampered record" FAIL "${tmp}/tampered"

  make_fixture "${tmp}/unlisted"
  printf 'gamma\n' > "${tmp}/unlisted/gamma-report.pdf"
  expect "unlisted record" FAIL "${tmp}/unlisted"

  make_fixture "${tmp}/missing"
  rm -f "${tmp}/missing/beta-report.pdf"
  expect "listed record missing" FAIL "${tmp}/missing"

  make_fixture "${tmp}/malformed"
  printf 'not-a-digest  alpha-report.pdf\n' >> "${tmp}/malformed/${DIGEST_FILE_NAME}"
  expect "malformed digest line" FAIL "${tmp}/malformed"

  make_fixture "${tmp}/nodigest"
  rm -f "${tmp}/nodigest/${DIGEST_FILE_NAME}"
  expect "digest list missing" FAIL "${tmp}/nodigest"

  if (( failures > 0 )); then
    echo "records lint self-test: FAIL (${failures})" >&2
    return 1
  fi
  echo "OK: --test passed (6 fixtures)"
  return 0
}

mode="lint"
target="opt/_research"
for arg in "$@"; do
  case "$arg" in
    --test)
      mode="test"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --*)
      echo "ERROR: unknown argument: ${arg}" >&2
      usage >&2
      exit 1
      ;;
    *)
      target="$arg"
      ;;
  esac
done

if [[ "$mode" == "test" ]]; then
  run_self_test
  exit $?
fi

lint_records_dir "$target"
