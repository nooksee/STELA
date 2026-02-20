# S-LEARN-02: Project Guidelines (The Stela Stack)

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0014)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Project Scaffolding
  - High Churn: Architecture Decisions

## Scope
Production payload work only. Not platform maintenance.

## Invocation Guidance
Use when initializing or refactoring project payloads.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/skills.md`
- Project registry: `docs/ops/registry/projects.md`
- Project rules template: `ops/lib/project/STELA.md`
- Reference docs: `docs/MANUAL.md`

## Guardrails
- Do not introduce new languages or frameworks without explicit Operator override.
- Project payload code must not import from `ops/` or `docs/`.
- Project stack rules live in per-project STELA files under `projects/`.
