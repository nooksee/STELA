<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Technical Specification: tools/test/editor.sh

## Purpose
Run deterministic checks for editor-backed scaffold authoring support in `ops/bin/draft`: emit, untouched-line rejection, file-ingest success, and interactive-simulated success.

## Invocation
- Command: `bash tools/test/editor.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when all checks pass.
  - `1` when any assertion fails.

## Inputs
- `ops/bin/draft`
- `ops/lib/scripts/editor.sh`

## Outputs
- Stdout: `PASS: editor scaffold test` on success.
- Stderr: `FAIL:` lines for each failed assertion.
- Cleanup behavior: removes only fixture files created by the test run under `var/tmp/`.

## Invariants and failure modes
- Plan scaffold emit path (`--emit-plan-scaffold=PATH`) writes required heading structure.
- DP slots scaffold emit path (`--emit-dp-slots-scaffold=PATH`) writes required slot blocks.
- Untouched plan scaffold text fails validation with an `untouched scaffold line` error.
- Untouched DP slots scaffold text fails validation with an `untouched scaffold line` error.
- Non-interactive ingest path (`--load-scaffold-file=PATH`) succeeds for both scaffold types when fixture content is filled.
- Interactive-simulated path (`--edit-scaffold --scaffold-editor="cp <fixture>"`) succeeds for both scaffold types when fixture content is filled.
- Explicit validation modes (`--validate-plan-scaffold=PATH`, `--validate-dp-slots-scaffold=PATH`) succeed for filled fixtures.

## Anecdotal Anchor
S7 hardening adds deterministic author-input checks to avoid unchanged scaffold prose silently entering plan or draft slot handoff files.

## Related pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-04`).
- Binary under test: `ops/bin/draft`.
- Script helper: `ops/lib/scripts/editor.sh`.
