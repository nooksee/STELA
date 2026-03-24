<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Technical Specification: tools/test/open.sh

## Purpose
Run deterministic checks for OPEN de-dup policy in `ops/bin/open`: OPEN must include porcelain summary and pointer fields only, while OPEN-PORCELAIN retains detailed porcelain payload content. The test also exercises the internal `OPEN_HANDOFF_BASE` override used by smoke/runtime helpers so OPEN can be materialized under an alternate repo-relative handoff root without touching live `storage/handoff/`.

## Invocation
- Command: `bash tools/test/open.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when all checks pass.
  - `1` when any assertion fails.

## Inputs
- `ops/bin/open`
- repository git status from current working tree

## Outputs
- Stdout: `PASS: open de-dup test` on success.
- Stderr: `FAIL:` lines for each failed assertion.
- Cleanup behavior: removes only artifacts created by this test run under `var/tmp/_smoke/open-<pid>/` and its temporary dirty-state file.

## Invariants and failure modes
- Dirty-state run is deterministic: test creates a temporary untracked file and executes `OPEN_HANDOFF_BASE=<repo-relative-smoke-root> ./ops/bin/open --out=auto --tag=open-test`.
- OPEN must include porcelain summary lines:
  - `Porcelain entries`
  - `Porcelain artifact`
  - `Porcelain saved`
- OPEN must not include inline porcelain payload sections:
  - `- Porcelain (git status --porcelain):`
  - `- Porcelain preview (truncated to 50 lines):`
- OPEN must reference an emitted OPEN-PORCELAIN path for dirty-state runs.
- Referenced OPEN-PORCELAIN artifact must exist and be non-empty.
- Emitted OPEN and OPEN-PORCELAIN paths must remain under the smoke root provided through `OPEN_HANDOFF_BASE`; the test must not touch live `storage/handoff/`.

## Anecdotal Anchor
This test is the S5 payload-duplication tripwire. If OPEN starts inlining full porcelain data again, the test fails before certify.

## Related pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-03`).
- Binary under test: `ops/bin/open`.
