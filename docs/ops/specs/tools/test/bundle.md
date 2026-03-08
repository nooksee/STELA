<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Technical Specification: tools/test/bundle.sh

## Purpose
Run deterministic smoke checks for the public `ops/bin/bundle` contract:
profile routing, artifact naming, manifest invariants, and foreman guard paths.

## Invocation
- Command: `bash tools/test/bundle.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when all checks pass.
  - `1` when any assertion fails.

## Inputs
- `ops/bin/bundle`
- `archives/decisions/*.md` (for foreman valid-path intent source)
- Bundle-generated manifests under `storage/handoff/`

## Outputs
- Stdout: `PASS: bundle smoke test` on success.
- Stderr: `FAIL:` lines for each failed assertion.
- Cleanup behavior: removes only bundle/dump artifacts created by this test run, using exact emitted paths.

## Invariants and failure modes
- Valid profiles `analyst`, `architect`, `audit`, `conform`, `auto` must succeed.
- Architect `--slice=T1` valid path must succeed.
- Architect `--slice=UNKNOWN` must fail.
- Architect `--slice=` (blank) must fail.
- Non-architect `--slice` usage must fail.
- Architect ad hoc run (no `--slice`) must succeed.
- Generated canonical bundle artifact path must start with `storage/handoff/<artifact_prefix>-` where `<artifact_prefix>` is policy-mapped for the resolved profile.
- Manifest must include `bundle_version: "2"`.
- Architect manifest must include `request` metadata:
  - `request.slice_id`
  - `request.slice_validated`
  - `request.plan_source`
- Non-`auto` profiles must preserve exact `resolved_profile` parity.
- Manifest dump `scope` must match policy mapping from `ops/lib/manifests/BUNDLE.md` for the resolved profile.
- Audit profile dump scope is `core`.
- Architect bundle text must include `[REQUEST]` block with slice metadata.
- Compatibility legacy artifact outputs (`BUNDLE-*`) are asserted from manifest `artifact_naming` metadata when legacy emission is enabled by policy.
- `auto` must resolve to a supported route (`analyst` or `architect`).
- Foreman must fail without `--intent`.
- Foreman must fail for malformed `--intent`.
- Foreman must pass for `ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>` and record matching `decision_id` with `decision_leaf_present: true`.
- Legacy alias `auditor` must resolve to `foreman` in manifest routing metadata.
- Legacy alias `hygiene` must resolve to `conform` in manifest routing metadata.
- Alias metadata must be emitted for compatibility routes:
  - `profile_alias.from` and `profile_alias.to` match requested and resolved values.
  - `profile_alias.deprecation_status` and `profile_alias.remove_after_dp` match policy sunset-window values in `ops/lib/manifests/BUNDLE.md`.
- ATS partial argument sets must fail (`--agent-id`/`--skill-id`/`--task-id` are all-or-none).
- ATS unknown IDs must fail with field-level errors (`unknown agent_id`, `unknown skill_id`, `unknown task_id`).
- ATS valid triplet must pass and emit manifest assembly metadata:
  - `assembly.applied: true`
  - `assembly.schema_version`
  - `assembly.policy_manifest`
  - ATS IDs with exact parity
  - `validated_against` registry pointers to agents/skills/tasks registries.
- ATS valid triplet must emit deterministic runtime pointer metadata and artifact:
  - `assembly.pointer.emitted: true`
  - `assembly.pointer.path` under `storage/handoff/`
  - `assembly.pointer.format: json`
  - emitted pointer file exists and path matches manifest.
- Non-ATS runs must not emit runtime assembly pointer artifacts:
  - `assembly.pointer.emitted: false`
  - `assembly.pointer.path: null`.
- Meta shim contract must pass deterministic checks:
  - missing project argument fails with explicit error.
  - unknown project slug fails with explicit error.
  - valid project slug succeeds and emits project-profile bundle artifacts through delegated bundle execution.
  - delegated manifest confirms `resolved_profile: project` and `project` field parity.

## Anecdotal Anchor
This test is the bundle contract tripwire: if routing, naming, or intent guards regress, the failure is immediate and deterministic.

## Related pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-02`).
- Binary under test: `ops/bin/bundle`.
- Runtime implementation: `ops/lib/scripts/bundle.sh`.
