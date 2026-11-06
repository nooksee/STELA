#!/usr/bin/env bash
set -euo pipefail

SOURCE_ROOT="$(git rev-parse --show-toplevel)"
TEST_ROOT="${SOURCE_ROOT}/var/tmp/_smoke/scaffold-$$"
PASS_COUNT=0
FAIL_COUNT=0

cleanup() {
  rm -rf -- "$TEST_ROOT"
  emit_binary_leaf "test-scaffold" "finish"
}

# shellcheck source=/dev/null
source "${SOURCE_ROOT}/ops/lib/scripts/common.sh"
trap cleanup EXIT
emit_binary_leaf "test-scaffold" "start"

# Project lane contract test (DP-OPS-0273). The fixture is a copy of the
# working tree in a fresh repository, so ops/bin/scaffold, ops/bin/map, and
# tools/lint/project.sh run as they are, against a projects/ directory that
# starts empty, and the live tree is never touched.

record_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
}

record_fail() {
  echo "FAIL: $*" >&2
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

make_fixture() {
  local repo="${TEST_ROOT}/lane"
  mkdir -p "$repo"
  (cd "$SOURCE_ROOT" && { git ls-files -z; git ls-files -z --others --exclude-standard; } | tar --null -T - -cf -) \
    | tar -C "$repo" -xf -
  git -C "$repo" init -q -b main
  git -C "$repo" config user.name "STELA Fixture"
  git -C "$repo" config user.email "stela-fixture@example.invalid"
  git -C "$repo" add -A . >/dev/null
  git -C "$repo" commit -qm "fixture baseline"
  printf '%s' "$repo"
}

check() {
  local label="$1"
  shift
  if "$@"; then
    record_pass
  else
    record_fail "$label"
  fi
}

mkdir -p "$TEST_ROOT"
repo="$(make_fixture)"

# Case 1: a scaffold writes the tree, both copies with tokens resolved, and the registry row.
output=""
if ! output="$(cd "$repo" && ./ops/bin/scaffold demo-app 2>&1)"; then
  record_fail "scaffold demo-app: expected success"
  printf '%s\n' "$output" >&2
else
  record_pass
fi
check "scaffold spec copy exists" test -f "${repo}/projects/demo-app/SCAFFOLD.md"
check "project contract copy exists" test -f "${repo}/projects/demo-app/STELA.md"
for dir in upstream addons patches public_html; do
  check "optional directory ${dir}/ exists" test -d "${repo}/projects/demo-app/${dir}"
done
check "no unresolved token in SCAFFOLD.md" bash -c "! grep -q '{{' '${repo}/projects/demo-app/SCAFFOLD.md'"
check "no unresolved token in STELA.md" bash -c "! grep -q '{{' '${repo}/projects/demo-app/STELA.md'"
check "contract names the project id" grep -q '^Project ID: demo-app$' "${repo}/projects/demo-app/STELA.md"
check "contract states advisory authority" grep -q '^Authority: advisory' "${repo}/projects/demo-app/STELA.md"
check "registry row written" grep -Eq '^\| demo-app \| demo-app \| projects/demo-app \| active \|' "${repo}/docs/ops/registry/projects.md"
check "registry Current line updated" grep -q '^Current: demo-app$' "${repo}/docs/ops/registry/projects.md"
check "scaffold output names the contract copy" bash -c "printf '%s\n' \"\$1\" | grep -q '^projects/demo-app/STELA.md$'" _ "$output"

# Case 2: the generated map lists the project and the project lint accepts the contract.
check "map regenerates" bash -c "cd '$repo' && ./ops/bin/map >/dev/null"
check "map lists the project" grep -q '^1\. demo-app - `projects/demo-app/STELA.md`$' "${repo}/docs/MAP.md"
check "map check passes" bash -c "cd '$repo' && ./ops/bin/map --check >/dev/null"
check "project lint accepts the contract" bash -c "cd '$repo' && bash tools/lint/project.sh >/dev/null"

# Case 3: a second scaffold of the same name and an invalid name fail closed, with no second row.
check "duplicate scaffold fails" bash -c "cd '$repo' && ! ./ops/bin/scaffold demo-app >/dev/null 2>&1"
check "invalid name fails" bash -c "cd '$repo' && ! ./ops/bin/scaffold Bad_Name >/dev/null 2>&1"
row_count="$(grep -Ec '^\| demo-app \|' "${repo}/docs/ops/registry/projects.md" || true)"
check "one registry row after the refused scaffold" test "$row_count" = "1"

# Case 4: a name that is registered but has no directory is refused before anything is written.
printf '| ghost | ghost | projects/ghost | active | fixture |\n' >> "${repo}/docs/ops/registry/projects.md"
check "registered name without a directory is refused" bash -c "cd '$repo' && ! ./ops/bin/scaffold ghost >/dev/null 2>&1"
check "refused scaffold writes no directory" bash -c "test ! -e '${repo}/projects/ghost'"

if (( FAIL_COUNT > 0 )); then
  echo "Project lane fixture summary: pass=${PASS_COUNT} fail=${FAIL_COUNT}"
  exit 1
fi

echo "Project lane fixture summary: pass=${PASS_COUNT} fail=0"
