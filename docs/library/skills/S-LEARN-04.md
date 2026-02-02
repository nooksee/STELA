# S-LEARN-04: Coding Standards

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0014)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Code Review
  - High Churn: Syntax Formatting

## Scope
Production payload work only.
Not platform maintenance.

## Invocation guidance
Use this skill when writing or reviewing payload code.
**The Trap:** "It runs, so it is fine."
**Solution:** Code must be readable, typed, and formatted.

## Drift preventers
- Stop if `any` is used in TypeScript.
- Stop if Python code is not formatted by Black.

## Procedure
1) **TypeScript (Frontend):**
   - **Strict Mode:** `strict: true` in `tsconfig.json`.
   - **No Any:** Use `unknown` or specific interfaces.
   - **Named Exports:** Prefer named exports over default exports for components.
   - **Naming:** `PascalCase` for Components/Interfaces. `camelCase` for vars/hooks.
2) **Python (Backend):**
   - **Type Hints:** Mandatory for all function arguments and returns.
   - **Pydantic:** Use Pydantic models for all data exchange (Schemas), not raw dicts.
   - **Formatter:** Code must pass `black --check`.
   - **Imports:** Sort with `isort`.
3) **Comments & Docs:**
   - **Why, not What:** Comment complex logic reasoning, not syntax.
   - **Docstrings:** Required for public API endpoints (FastAPI uses these for Swagger UI).
