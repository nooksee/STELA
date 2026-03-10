# S-LEARN-09: Factory Testing Gates

## Provenance
- Captured: 2026-03-09
- Origin: Factory Testing Definitions and Execution Gates (DP-OPS-0181)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: ATS triplet test coverage and runtime assembly assertions
  - High Churn: verify stack coupling for new test surfaces

## Scope
Applies to platform maintenance and production payload work when factory testing-gate definitions or verify wiring are in scope.

## Method Contract
- `skill_id`: `S-LEARN-09`
- `method`: `factory testing gate execution`
- `inputs`: `active DP scope and canon pointers`
- `outputs`: `bounded execution steps and verification evidence for RESULTS`
- `invariants`: `no out-of-scope edits, no disposable artifact dependence, fail closed on missing inputs`

## Invocation Guidance
Use when a packet introduces or updates factory testing definitions, ATS triplet smoke checks, test registry entries, or verify invocation blocks.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/skills.md`
- Factory census: `docs/ops/registry/factory.md`
- Test registry: `docs/ops/registry/test.md`
- Factory smoke test: `tools/test/factory.sh`
- Verify stack: `tools/verify.sh`

## Guardrails
- Stop when ATS IDs in test fixtures do not resolve in the corresponding registries.
- Stop when factory census rows are missing for new definition paths.
- Stop when verify invocation diverges from test-surface registry entries.

## Procedure
- Run factory lint and test gates required by the active DP.
- Confirm assembly metadata parity for agent, skill, and task IDs.
- Record deterministic pass/fail outcomes and unresolved risks in RESULTS.
