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

## Invocation guidance
Use this skill when initializing or refactoring project payloads. The Trap: Mixing paradigms (e.g., using Django patterns in FastAPI, or Pages Router in App Router). Solution: Adhere strictly to the Stela Stack definitions below.

## Drift preventers
- Stop if the DP attempts to introduce a new language or framework (e.g., Go, Vue, NestJS) without explicit Operator override.
- Strict Isolation: Project code must not import from ops/ or docs/.

## Procedure
1) Directory Authority:
   - Frontend code lives under `src/`.
   - Backend code lives under `app/`.
2) Frontend Stack (Web):
   - Framework: Next.js 14+ (App Router).
   - Language: TypeScript (Strict).
   - UI: Tailwind CSS + Shadcn/UI (Copy-paste component ownership).
   - Structure: `src/app`, `src/components`, `src/lib`.
3) Backend Stack (API):
   - Framework: FastAPI (Python 3.11+).
   - Interface: REST (JSON) + OpenAPI (Auto-generated).
   - Structure: `app/main.py`, `app/routers/`, `app/schemas/` (Pydantic).
4) Data & State:
   - Database: Supabase (Postgres).
   - Auth: Supabase Auth.
   - Caching: Redis (if required).
5) Deployment Contract:
   - Config: Environment variables ONLY (Read from `process.env` or `os.environ`).
   - Secrets: Never committed.
   - Docker: Multi-stage builds required for production artifacts.
