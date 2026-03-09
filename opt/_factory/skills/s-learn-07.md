# S-LEARN-07: Factory Chain Validation

## Provenance
- Captured: 2026-02-19
- Origin: Pointer-First Factory Chain Validation (DP-OPS-0074)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Factory pointer and registry synchronization
  - High Churn: Definition promotion surfaces

## Scope
Applies to platform maintenance and production payload work when factory-chain integrity is in scope.

## Method Contract
- `skill_id`: `S-LEARN-07`
- `method`: `factory chain verification` 
- `inputs`: `active DP scope and canon pointers`
- `outputs`: `bounded execution steps and verification evidence for RESULTS`
- `invariants`: `no out-of-scope edits, no disposable artifact dependence, fail closed on missing inputs`

## Invocation Guidance
Use when a packet modifies factory definitions, registry mappings, promotion pointers, or factory lint contracts.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/skills.md`
- Factory census: `docs/ops/registry/factory.md`
- Factory lint: `tools/lint/factory.sh`
- Verification stack: `tools/verify.sh`

## Guardrails
- Stop when head pointers and registry entries disagree.
- Stop when referenced factory paths are missing.
- Do not treat archive leaves as runtime authorities.

## Procedure
- Run `bash tools/lint/factory.sh` and stop on failure.
- If definitions changed, run `bash tools/verify.sh` and stop on failure.
- Record deterministic failure or pass evidence in RESULTS.
