# S-LEARN-02: Project Guidelines

## Provenance
- Captured: 2026-02-01
- Origin: Legacy Migration (DP-OPS-0013)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Universal / Platform Root
  - High Churn: Historical Aggregate

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP explicitly requests project-wide implementation guidance. Apply the stack and structure constraints and document any DP-approved exceptions.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Do not introduce alternate stacks unless the DP explicitly overrides these constraints.
- Anti-hallucination: confirm project paths and existing conventions in the repo before adding new structure.

## Procedure
1) Confirm stack constraints:
   - Frontend: Next.js App Router with TypeScript.
   - Database: Supabase Postgres.
   - Backend: FastAPI (Python).
   - Cache or queue: Redis.
2) Confirm deployment notes:
   - Keep runtime configuration in environment variables and document deployment notes or README as required by the DP.
   - Next.js deploys as a Node-based web app; FastAPI deploys as an ASGI service behind a process manager.
   - Supabase manages Postgres; do not embed database credentials in source control.
   - Redis must be provisioned as a managed service or container in the target environment.
3) Confirm structural constraints:
   - Prefer many small, focused files over large monolithic files.
   - Frontend directory conventions: `app/`, `components/`, `hooks/`, `lib/`, `types/`.
   - Backend directory conventions: `app/main.py`, `app/routers/`, `app/schemas/`, `app/services/`, `app/db/`.
4) Document DP-approved exceptions in RESULTS.
