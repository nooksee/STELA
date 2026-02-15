# S-LEARN-01: Verification Loop

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0014)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Universal / Payload Verification
  - High Churn: CI/CD Gates

## Scope
Production payload work only. Not platform maintenance.

## Invocation Guidance
Use when a DP explicitly requests a verification loop or when payload verification gates are required.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/SKILLS.md`
- Verification task: `opt/_factory/tasks/B-TASK-02.md`
- Toolchain: `tools/verify.sh`, `tools/lint/style.sh`, `tools/lint/context.sh`, `tools/lint/truth.sh`, `tools/lint/library.sh`
- Reference docs: `docs/MANUAL.md`

## Guardrails
- Stop on the first failing gate.
- Record raw command output in RESULTS for each verification command.
