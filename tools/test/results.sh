#!/usr/bin/env bash
set -euo pipefail

source "$(git rev-parse --show-toplevel)/ops/lib/scripts/common.sh"

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  REPO_ROOT="$(git rev-parse --show-toplevel)"
else
  echo "ERROR: Must be run inside a git repository." >&2
  exit 1
fi

cd "$REPO_ROOT" || exit 1

FAILURES=0
RESULTS_TEST_ROOT="var/tmp/_smoke/results-$$"
RESULTS_TEST_ROOT_ABS="${REPO_ROOT}/${RESULTS_TEST_ROOT}"

cleanup_generated() {
  rm -rf -- "$RESULTS_TEST_ROOT_ABS"
}

trap 'cleanup_generated; emit_binary_leaf "test-results" "finish"' EXIT
emit_binary_leaf "test-results" "start"

fail() {
  echo "FAIL: $*" >&2
  FAILURES=$((FAILURES + 1))
}

assert_output_contains() {
  local output="$1"
  local needle="$2"
  local label="$3"
  if [[ "$output" != *"$needle"* ]]; then
    fail "${label}: expected output to contain '${needle}'"
  fi
}

write_valid_results_fixture() {
  local path="$1"
  local git_hash
  git_hash="$(git rev-parse HEAD)"

  cat > "$path" <<EOF
# DP-OPS-9999 RESULTS

## Certification Metadata
- DP ID: DP-OPS-9999
- Certified At (UTC): 2026-04-09T00:00:00Z
- Branch: work/dp-ops-9999-2026-04-09
- Git Hash: ${git_hash}

## Scope Verification
- Target Files allowlist pointer: storage/dp/active/allowlist.txt

### Integrity Lint Output
~~~text
OK: integrity lint passed (1 observed paths).
~~~

## Verification Command Log
### Command 01
- Command: \`bash tools/lint/task.sh\`
- Started (UTC): 2026-04-09T00:00:00Z
- Finished (UTC): 2026-04-09T00:00:00Z
- Duration Seconds: 0
- Exit Code: 0

#### STDOUT
~~~text
OK: Task lint checks passed.
~~~

#### STDERR
~~~text
(empty)
~~~

## Git State Impact
### git diff --name-only
~~~text
(empty)
~~~

### git diff --stat
~~~text
(empty)
~~~

## Worker Execution Narrative
### Preflight State
git rev-parse --abbrev-ref HEAD
work/dp-ops-9999-2026-04-09

git rev-parse --short HEAD
296404e6

git status --porcelain
(empty)

Short preflight lint status: fixture baseline only.

### Implemented Changes
No repository changes. This fixture exercises strict RESULTS lint behavior only.

### Closeout Notes
None.

### Decision Leaf
Decision Required: No
Decision Leaf: None
EOF
}

run_expect_pass() {
  local label="$1"
  local path="$2"
  local output=""

  if ! output="$(bash tools/lint/results.sh "$path" 2>&1)"; then
    fail "${label}: expected pass"
    printf '%s\n' "$output" >&2
    return
  fi

  assert_output_contains "$output" "OK: RESULTS lint passed" "$label"
}

run_expect_fail() {
  local label="$1"
  local path="$2"
  local expected="$3"
  local output=""

  if output="$(bash tools/lint/results.sh "$path" 2>&1)"; then
    fail "${label}: expected failure"
    printf '%s\n' "$output" >&2
    return
  fi

  assert_output_contains "$output" "$expected" "$label"
}

mkdir -p "$RESULTS_TEST_ROOT_ABS"

valid_fixture="${RESULTS_TEST_ROOT_ABS}/valid-RESULTS.md"
write_valid_results_fixture "$valid_fixture"
run_expect_pass "valid fixture" "$valid_fixture"

fused_fence_fixture="${RESULTS_TEST_ROOT_ABS}/fused-fence-RESULTS.md"
cp "$valid_fixture" "$fused_fence_fixture"
python3 - "$fused_fence_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("### Command 01", "~~~### Command 01", 1)
path.write_text(text)
PY
run_expect_fail "fused fence fixture" "$fused_fence_fixture" "fused fence/heading boundary"

missing_subheading_fixture="${RESULTS_TEST_ROOT_ABS}/missing-subheading-RESULTS.md"
cp "$valid_fixture" "$missing_subheading_fixture"
python3 - "$missing_subheading_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
lines = path.read_text().splitlines()
filtered = []
skip = False
for line in lines:
    if line == "### Closeout Notes":
        skip = True
        continue
    if skip and line == "### Decision Leaf":
        skip = False
    if not skip:
        filtered.append(line)
path.write_text("\n".join(filtered) + "\n")
PY
run_expect_fail "missing narrative subheading fixture" "$missing_subheading_fixture" "missing required narrative subheading matching ^### Closeout Notes$"

missing_preflight_fixture="${RESULTS_TEST_ROOT_ABS}/missing-preflight-RESULTS.md"
cp "$valid_fixture" "$missing_preflight_fixture"
python3 - "$missing_preflight_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("git status --porcelain\n(empty)\n\n", "", 1)
path.write_text(text)
PY
run_expect_fail "missing preflight proof fixture" "$missing_preflight_fixture" "missing required execution-start command output: git status --porcelain"

decision_leaf_fixture="${RESULTS_TEST_ROOT_ABS}/decision-leaf-RESULTS.md"
cp "$valid_fixture" "$decision_leaf_fixture"
python3 - "$decision_leaf_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("Decision Leaf: None", "Decision Leaf: archives/decisions/RoR-test.md", 1)
path.write_text(text)
PY
run_expect_fail "decision leaf coherence fixture" "$decision_leaf_fixture" "Decision Required is 'No' but Decision Leaf is not 'None'"

clickable_link_fixture="${RESULTS_TEST_ROOT_ABS}/clickable-link-RESULTS.md"
cp "$valid_fixture" "$clickable_link_fixture"
python3 - "$clickable_link_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace(
    "No repository changes. This fixture exercises strict RESULTS lint behavior only.",
    "[results lint spec](docs/ops/specs/tools/lint/results.md) was cited directly in the narrative.",
    1,
)
path.write_text(text)
PY
run_expect_fail "clickable markdown link fixture" "$clickable_link_fixture" "Worker Execution Narrative contains clickable markdown links"

absolute_path_fixture="${RESULTS_TEST_ROOT_ABS}/absolute-path-RESULTS.md"
cp "$valid_fixture" "$absolute_path_fixture"
python3 - "$absolute_path_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace(
    "No repository changes. This fixture exercises strict RESULTS lint behavior only.",
    "Touched /home/nos4r2/dev/stela/tools/test/results.sh directly in the narrative.",
    1,
)
path.write_text(text)
PY
run_expect_fail "absolute filesystem path fixture" "$absolute_path_fixture" "Worker Execution Narrative contains an absolute filesystem path"

scaffold_fixture="${RESULTS_TEST_ROOT_ABS}/scaffold-RESULTS.md"
cp "$valid_fixture" "$scaffold_fixture"
python3 - "$scaffold_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace(
    "No repository changes. This fixture exercises strict RESULTS lint behavior only.",
    "Describe each change made: what was modified, created, or removed, and why.",
    1,
)
path.write_text(text)
PY
run_expect_fail "untouched scaffold fixture" "$scaffold_fixture" "Worker Execution Narrative contains untouched scaffold instruction prose"

missing_decision_required_fixture="${RESULTS_TEST_ROOT_ABS}/missing-decision-required-RESULTS.md"
cp "$valid_fixture" "$missing_decision_required_fixture"
python3 - "$missing_decision_required_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("Decision Required: No\n", "", 1)
path.write_text(text)
PY
run_expect_fail "missing decision required fixture" "$missing_decision_required_fixture" "Worker Execution Narrative Decision Leaf subsection missing 'Decision Required:' line"

missing_decision_leaf_fixture="${RESULTS_TEST_ROOT_ABS}/missing-decision-leaf-RESULTS.md"
cp "$valid_fixture" "$missing_decision_leaf_fixture"
python3 - "$missing_decision_leaf_fixture" <<'PY'
from pathlib import Path
import sys
path = Path(sys.argv[1])
text = path.read_text()
text = text.replace("Decision Leaf: None\n", "", 1)
path.write_text(text)
PY
run_expect_fail "missing decision leaf fixture" "$missing_decision_leaf_fixture" "Worker Execution Narrative Decision Leaf subsection missing 'Decision Leaf:' line"

if (( FAILURES > 0 )); then
  exit 1
fi

echo "PASS: results lint synthetic-fixture tests"
