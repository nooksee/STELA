<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: tools/test/factory.sh

## Purpose
Run deterministic smoke checks for Factory ATS triplet execution using disposable registry fixtures. The test proves assembly mechanics without requiring test-only Agent, Skill, or Task definitions in active canon.

## Invocation
- Command: `bash tools/test/factory.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when ATS triplet smoke assertions pass.
  - `1` when bundle invocation, manifest assertions, or artifact assertions fail.

## Inputs
- `ops/bin/bundle`
- `ops/lib/manifests/ASSEMBLY.md` copied into an isolated test policy
- disposable Agent, Skill, and Task registries under `var/tmp/_smoke/factory-fixture-<pid>/`
- transient `TOPIC.md` under the isolated handoff root
- bundle-generated smoke artifacts under `var/tmp/_smoke/handoff/` and `var/tmp/_smoke/dumps/`

## Outputs
- Stdout: `PASS: factory smoke test; isolated ATS fixture 1/1; isolation guards 2/2; live registry parity 3/3` on success.
- Stderr: `FAIL:` lines for each failed assertion.
- Cleanup behavior: removes only generated smoke artifacts, manifests, packages, assembly pointer artifacts, and dump payload/manifest files emitted during the test run.

## Invariants and failure modes
- The test invokes `ops/bin/bundle --profile=auto` with disposable IDs `R-AGENT-90`, `S-LEARN-90`, and `B-TASK-90`.
- `BUNDLE_TEST_HANDOFF_ROOT` redirects all input surfaces away from live `storage/handoff/`.
- `BUNDLE_TEST_ASSEMBLY_POLICY_PATH` is accepted only when handoff isolation is active and only when the policy resolves beneath repository-local `var/tmp/`.
- The test proves both isolation guards reject misuse before artifact emission.
- The isolated policy redirects Agent, Skill, and Task registry validation to disposable fixture registries.
- The test provisions a disposable `TOPIC.md` and leaves `PLAN.md` absent so auto routing resolves deterministically to planning.
- Fixture IDs must be absent from all three live Factory registries.
- Live Factory registry hashes must remain unchanged across the test.
- Tracked and untracked repository state must match exactly before and after cleanup.
- Explicit smoke bundle output must land under `var/tmp/_smoke/handoff/`.
- Explicit smoke dump output must land under `var/tmp/_smoke/dumps/`.
- Bundle output must include non-empty artifact/manifest/package paths.
- Bundle invocation failure is terminal for the smoke test; path-parsing assertions must not run on failed output.
- Emitted artifact, manifest, package, dump payload, dump manifest, and assembly pointer files must exist.
- Manifest `resolved_profile` must be `planning`.
- Manifest must include ATS assembly assertions:
  - `assembly.applied: true`
  - `assembly.agent_id: R-AGENT-90`
  - `assembly.skill_id: S-LEARN-90`
  - `assembly.task_id: B-TASK-90`
  - `assembly.pointer.emitted: true`
  - `assembly.pointer.path` under `var/tmp/_smoke/handoff/`
- Bundle text artifact must include `[ASSEMBLY]` block and the ATS triplet IDs.

## Anecdotal Anchor
This test is the Factory ATS mechanics tripwire. It validates registry binding and assembly emission while keeping development fixtures outside active canon.

## Related pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-05`).
- Companion lint: `tools/lint/factory.sh`.
- Verify stack entrypoint: `tools/verify.sh`.
