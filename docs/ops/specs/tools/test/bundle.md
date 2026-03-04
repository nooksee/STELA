<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Technical Specification: tools/test/bundle.sh

## Purpose
Run deterministic smoke checks for the public `ops/bin/bundle` contract:
profile routing, artifact naming, manifest invariants, and auditor guard paths.

## Invocation
- Command: `bash tools/test/bundle.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when all checks pass.
  - `1` when any assertion fails.

## Inputs
- `ops/bin/bundle`
- `archives/decisions/*.md` (for auditor valid-path intent source)
- Bundle-generated manifests under `storage/handoff/`

## Outputs
- Stdout: `PASS: bundle smoke test` on success.
- Stderr: `FAIL:` lines for each failed assertion.
- Cleanup behavior: removes only bundle/dump artifacts created by this test run, using exact emitted paths.

## Invariants and failure modes
- Valid profiles `analyst`, `architect`, `audit`, `hygiene`, `auto` must succeed.
- Generated bundle artifact path must start with `storage/handoff/BUNDLE-`.
- Manifest must include `bundle_version: "2"`.
- Non-`auto` profiles must preserve exact `resolved_profile` parity.
- `auto` must resolve to a supported route (`analyst` or `architect`).
- Auditor must fail without `--intent`.
- Auditor must fail for malformed `--intent`.
- Auditor must pass for `ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>` and record matching `decision_id` with `decision_leaf_present: true`.

## Anecdotal Anchor
This test is the bundle contract tripwire: if routing, naming, or intent guards regress, the failure is immediate and deterministic.

## Related pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-02`).
- Binary under test: `ops/bin/bundle`.
- Runtime implementation: `ops/lib/scripts/bundle.sh`.
