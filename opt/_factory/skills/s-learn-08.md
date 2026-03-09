# S-LEARN-08: Bundle Profile Governance

## Provenance
- Captured: 2026-03-03
- Origin: Bundle Primitive and Profile Contract Hardening (DP-OPS-0145)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Transport profile routing and artifact naming
  - High Churn: Bundle policy and runtime contract alignment

## Scope
Applies to platform maintenance when bundle profile contract behavior or profile alias routing is in scope.

## Method Contract
- `skill_id`: `S-LEARN-08`
- `method`: `bundle profile contract governance`
- `inputs`: `active DP scope and canon pointers`
- `outputs`: `bounded execution steps and verification evidence for RESULTS`
- `invariants`: `no out-of-scope edits, no disposable artifact dependence, fail closed on missing inputs`

## Invocation Guidance
Use when validating bundle routing rules, profile alias policy behavior, architect slice transport behavior, or artifact contract parity.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/skills.md`
- Bundle policy: `ops/lib/manifests/BUNDLE.md`
- Bundle runtime: `ops/lib/scripts/bundle.sh`
- Bundle binary: `ops/bin/bundle`

## Guardrails
- Stop when profile policy keys and runtime behavior diverge.
- Stop when profile alias behavior is undocumented in specs.
- Do not expand scope into non-transport slices without addendum authorization.

## Procedure
- Run bundle-focused lint/test gates required by the active DP.
- Verify policy, runtime, and docs parity in one bounded packet.
- Record pass/fail evidence and residual risk in RESULTS.
