<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Technical Specification: tools/test/bundle.sh

## Purpose
Run deterministic smoke checks for the public `ops/bin/bundle` contract:
profile routing, artifact naming, manifest invariants, and foreman guard paths.

## Invocation
- Command: `bash tools/test/bundle.sh`
- Alternate bounded command: `bash tools/test/bundle.sh --mode=certify-critical`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when all checks pass.
  - `1` when any assertion fails.

## Inputs
- `ops/bin/bundle`
- `archives/decisions/*.md` (for foreman valid-path intent source)
- Bundle-generated smoke manifests under `storage/_smoke/handoff/`

## Outputs
- Stdout: `PASS: bundle smoke test` on success.
- Stderr: `FAIL:` lines for each failed assertion.
- Cleanup behavior: removes only bundle and dump artifacts created by this test run, using exact emitted paths under `storage/_smoke/` plus temporary runtime fixtures under `storage/`.

## Invariants and failure modes
- Valid profiles `analyst`, `architect`, `audit`, `conform`, `auto` must succeed.
- Architect `--slice=T1` valid path must succeed.
- Architect `--slice=UNKNOWN` must fail.
- Architect `--slice=` (blank) must fail.
- Non-architect `--slice` usage must fail.
- Architect ad hoc run (no `--slice`) must succeed.
- Generated quarantined smoke bundle artifact path must start with `storage/_smoke/handoff/<artifact_prefix>-` where `<artifact_prefix>` is policy-mapped for the resolved profile.
- Manifest must include `bundle_version: "2"`.
- Architect manifest must include `request` metadata:
  - `request.slice_id`
  - `request.slice_validated`
  - `request.plan_source`
  - `request.packet_id`
  - `request.closing_sidecar`
  - `request.title_suffix`
- Analyst manifest must include `request.topic_source` and `request.output_surface`.
- Non-`auto` profiles must preserve exact `resolved_profile` parity.
- Manifest dump `scope` must match policy mapping from `ops/lib/manifests/BUNDLE.md` for the resolved profile.
- Audit profile dump scope is `core`.
- Analyst requires `storage/handoff/TOPIC.md`; bundle must fail closed when it is missing.
- Analyst bundle text must include `[REQUEST]` with `topic_source` and `output_surface`.
- Analyst bundle text `[HANDOFF]` must report `TOPIC.md` only.
- Analyst bundle text must advertise discussion mode as the analyst default.
- Analyst bundle text must advertise a `Recommendation:` line in default analyst mode.
- Analyst bundle text must advertise explicit plan-output mode separately from default discussion mode.
- Analyst dump payload must contain `<<< FILE BEGIN: storage/handoff/TOPIC.md`.
- Analyst dump manifest must report `History profile: analyst`.
- Analyst dump payload must contain explicit `[history metadata-only]` blocks for cold archive history.
- Analyst dump manifest must record explicit include provenance for `storage/handoff/TOPIC.md`.
- Analyst package must include `storage/handoff/TOPIC.md` and omit `storage/handoff/PLAN.md`.
- Architect bundle text must include `[REQUEST]` block with slice and packet metadata.
- Architect bundle text `[HANDOFF]` must report `PLAN.md` only when present.
- Architect dump payload must contain `<<< FILE BEGIN: storage/handoff/PLAN.md` when `PLAN.md` is present.
- Architect dump manifest must report `History profile: architect`.
- Architect dump manifest must record explicit include provenance for `storage/handoff/PLAN.md` when present.
- Architect package must include `storage/handoff/PLAN.md` when present and must not include `storage/handoff/TOPIC.md` unless architect transport explicitly requires it in a future DP.
- Validated architect slice output must include `[ACTIVE SLICE PROJECTION]` with active-slice handoff data only.
- Architect ad hoc output must not emit `[ACTIVE SLICE PROJECTION]`.
- Audit requires current `storage/handoff/<DP_ID>-RESULTS.md` and `storage/handoff/CLOSING-<DP_ID>.md`; bundle must fail closed when either is missing or current DP resolution is unavailable.
- Audit requires the active packet source file at `storage/dp/processed/<DP_ID>.md` or `storage/dp/intake/<DP_ID>.md`; bundle must fail closed when packet source is ambiguous or unavailable.
- Audit smoke may use live current packet state only when current `RESULTS dp_source` agrees with the resolved current packet-source path; mixed intake-versus-processed rerun state must fall back to the deterministic fixture instead of treating transient closeout state as the contract under test.
- Audit dump payload must contain file blocks for the current `RESULTS` and `CLOSING` files.
- Audit dump payload must contain the current active TASK leaf file block resolved through `TASK.md`, not only the one-line `TASK.md` pointer.
- Audit dump payload must contain the current packet source file block for the active packet id.
- Audit dump manifest must report `History profile: audit`.
- Audit dump manifest must record explicit include provenance for the current `RESULTS`, `CLOSING`, and packet-source files.
- Audit package must include the current `RESULTS`, `CLOSING`, and packet-source files and omit unrelated disposable inputs such as `TOPIC.md` and `PLAN.md`.
- Compatibility legacy artifact outputs (`BUNDLE-*`) are asserted from manifest `artifact_naming` metadata when legacy emission is enabled by policy.
- `auto` must resolve to a supported route (`analyst` or `architect`).
- Foreman must fail without `--intent`.
- Foreman must fail for malformed `--intent`.
- Foreman must pass for `ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>` and record matching `decision_id` with `decision_leaf_present: true`.
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
  - `assembly.pointer.path` under `storage/_smoke/handoff/`
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
- `--mode=certify-critical` is a bounded closeout-safety subset. It must run:
  - manifest fail-closed assertions,
  - stance template render determinism,
  - architect validated-slice bundle generation.
- Architect slice smoke must install its own deterministic `storage/handoff/PLAN.md` fixture and must not depend on whatever live handoff `PLAN.md` currently contains.
- Auto-route smoke must control `storage/handoff/PLAN.md` state explicitly instead of inheriting incidental local residue.
- Synthetic audit TASK fallback must live under `archives/surfaces/` so dump active-pointer inclusion sees the same path class as production.
- Smoke bundle invocations use explicit unique output paths under `storage/_smoke/handoff/` so concurrent local gate runs do not reuse shared branch/head artifact paths or pollute operator-facing handoff roots.
- `--mode=certify-critical` must not run the full analyst/profile/ATS/meta matrix.

## Anecdotal Anchor
This test is the bundle contract tripwire: if routing, naming, or intent guards regress, the failure is immediate and deterministic.

## Related pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-02`).
- Binary under test: `ops/bin/bundle`.
- Runtime implementation: `ops/lib/scripts/bundle.sh`.
