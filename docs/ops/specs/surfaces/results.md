<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Surface Specification: RESULTS

## Constitutional Anchor
`storage/handoff/DP-OPS-XXXX-RESULTS.md` is a generated audit receipt, not a hand-authored narrative.
It records certification execution details, verification command output, git impact, and the Mandatory Closing Block.

## Operator Contract
- Surface generator: `ops/bin/certify`.
- Rendering pipeline: `ops/bin/template render results` (strict mode).
- Canonical template: `ops/src/surfaces/results.md.tpl`.
- Required sections and order:
  - `## Certification Metadata`
  - `## Scope Verification`
  - `### Integrity Lint Output`
  - `## Verification Command Log`
  - `## Git State Impact`
  - `### git diff --name-only`
  - `### git diff --stat`
  - `## Mandatory Closing Block`
- Mandatory fields:
  - DP ID, UTC certification timestamp, work branch, and git hash.
  - Target Files allowlist pointer and integrity-lint output.
  - Per-command verification logs with exit outcomes.
  - Closing Block content supplied from `storage/handoff/CLOSING-DP-OPS-XXXX.md`.

## Failure States and Drift Triggers
- Manual edits to generated RESULTS artifacts.
- Missing required section headings or reordered schema.
- Template drift between `tools/lint/results.sh` hash constant and `ops/src/surfaces/results.md.tpl`.
- Git hash mismatch between receipt content and `git rev-parse HEAD`.
- Missing or placeholder Closing Block values.

Enforcement linkage:
- `tools/lint/results.sh` validates template hash, schema headings, git hash parity, and Closing Block content.
- `ops/bin/certify` runs `tools/lint/results.sh` as a hard gate after rendering.

## Mechanics and Sequencing
1. Maintain a human-authored closing sidecar at `storage/handoff/CLOSING-DP-OPS-XXXX.md`.
2. Run `ops/bin/certify --dp=DP-OPS-XXXX --out=auto`.
3. Certifier runs integrity and verification gates, captures outputs, then renders RESULTS from template slots.
4. Certifier lints the generated RESULTS artifact and exits non-zero on any failure.

## Forensic Insight
RESULTS is the executable evidence receipt for DP closeout.
It keeps verification outputs deterministic and replayable while separating human narrative input to a single controlled sidecar.
Think of RESULTS like a flight recorder that captures what actually ran and what failed before a merge decision is made.
