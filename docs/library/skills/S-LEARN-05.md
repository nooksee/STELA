# S-LEARN-05: Security Protocols

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0014)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Auth & Data Access
  - High Churn: Permission Logic

## Scope
Production payload work only. Not platform maintenance.

## Invocation Guidance
Use when configuring database access, API surfaces, or auth flows.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/SKILLS.md`
- Reference docs: `docs/MANUAL.md`

## Requirements
- RLS must be enabled on all public tables with explicit `SELECT`, `INSERT`, `UPDATE`, and `DELETE` policies.
- Do not use permissive RLS policies like `USING (true)` on public data.
- CORS `allow_origins` must be environment-driven and must not be `*` for production.
- Validate inputs in the frontend with Zod and in the backend with Pydantic.
- Pin dependency versions and run `npm audit` or `pip-audit` when available.
- Never store secrets in code or comments.
