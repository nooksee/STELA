# S-LEARN-03: Reference Spec Pattern (Zenith)

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0014)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: API Integration
  - High Churn: Data Fetching Logic

## Scope
Production payload work only. Not platform maintenance.

## Invocation Guidance
Use when implementing API surfaces or data fetching hooks.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/skills.md`
- Reference docs: `docs/MANUAL.md`

## Specification
- Server responses use the Zenith envelope fields `ok`, `data`, `error`, and `meta`.
- Error responses set `ok` to `false`, `data` to `null`, and populate `error.code` and `error.message`.
- Client hooks expose normalized state keys `data`, `loading`, `error`, and `refresh`.
- Client wrappers normalize non-200 responses into the Zenith error envelope before UI consumption.
