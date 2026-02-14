# S-LEARN-04: Coding Standards

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0014)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Code Review
  - High Churn: Syntax Formatting

## Scope
Production payload work only. Not platform maintenance.

## Invocation Guidance
Use when writing or reviewing payload code.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/SKILLS.md`
- Project rules template: `ops/lib/project/STELA.md`
- Reference docs: `docs/MANUAL.md`

## Standards
- TypeScript requires `strict: true` in `tsconfig.json`.
- TypeScript must not use `any`. Prefer explicit types or `unknown`.
- Prefer named exports for components.
- Naming uses `PascalCase` for components and interfaces, and `camelCase` for variables and hooks.
- Python functions require type hints for arguments and returns.
- Pydantic models are required for data exchange.
- Code must pass `black --check` and import order must pass `isort`.
- Docstrings are required for public API endpoints.
- Comments explain rationale, not syntax.
