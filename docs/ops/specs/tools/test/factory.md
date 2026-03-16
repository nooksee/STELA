<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# Technical Specification: tools/test/factory.sh

## Purpose
Run deterministic smoke checks for factory ATS triplet execution using canon testing definitions.

## Invocation
- Command: `bash tools/test/factory.sh`
- Required flags: none.
- Positional arguments: none.
- Expected exit behavior:
  - `0` when ATS triplet smoke assertions pass.
  - `1` when bundle invocation, manifest assertions, or artifact assertions fail.

## Inputs
- `ops/bin/bundle`
- `opt/_factory/agents/r-agent-09.md`
- `opt/_factory/skills/s-learn-09.md`
- `opt/_factory/tasks/b-task-09.md`
- transient `storage/handoff/TOPIC.md` fixture when the resolved auto profile requires analyst input
- bundle-generated artifacts under `storage/handoff/` and `storage/dumps/`

## Outputs
- Stdout: `PASS: factory smoke test` on success.
- Stderr: `FAIL:` lines for each failed assertion.
- Cleanup behavior: removes only generated bundle artifacts, manifests, packages, assembly pointer artifacts, and dump payload/manifest files emitted during the test run.

## Invariants and failure modes
- `./ops/bin/bundle --profile=auto --agent-id=R-AGENT-09 --skill-id=S-LEARN-09 --task-id=B-TASK-09 --out=<explicit-test-path>` must succeed.
- The test suppresses live `storage/handoff/PLAN.md` so auto routing is deterministic and resolves to analyst.
- The test provisions a disposable `storage/handoff/TOPIC.md` fixture before bundle invocation.
- Bundle output must include non-empty artifact/manifest/package paths.
- Bundle invocation failure is terminal for the smoke test; path-parsing assertions must not run on failed output.
- Emitted artifact, manifest, package, dump payload, dump manifest, and assembly pointer files must exist.
- Manifest `resolved_profile` must be `analyst`.
- Manifest must include ATS assembly assertions:
  - `assembly.applied: true`
  - `assembly.agent_id: R-AGENT-09`
  - `assembly.skill_id: S-LEARN-09`
  - `assembly.task_id: B-TASK-09`
  - `assembly.pointer.emitted: true`
  - `assembly.pointer.path` under `storage/handoff/`
- Bundle text artifact must include `[ASSEMBLY]` block and the ATS triplet IDs.

## Anecdotal Anchor
This test is the factory ATS gate tripwire. If definition registration or assembly emission drifts, the packet fails immediately with deterministic evidence.

## Related pointers
- Registry entry: `docs/ops/registry/test.md` (`TEST-05`).
- Companion lint: `tools/lint/factory.sh`.
- Verify stack entrypoint: `tools/verify.sh`.
