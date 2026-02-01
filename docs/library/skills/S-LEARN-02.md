# S-LEARN-02: Project Guidelines

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP explicitly requests project-wide implementation guidance. Apply the stack and structure constraints and document any DP-approved exceptions.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Do not introduce alternate stacks unless the DP explicitly overrides these constraints.
- Anti-hallucination: confirm project paths and existing conventions in the repo before adding new structure.

## Stack constraints
- Frontend: Next.js App Router with TypeScript.
- Database: Supabase Postgres.
- Backend: FastAPI (Python).
- Cache or queue: Redis.
- Deployment notes:
  - Keep runtime configuration in environment variables and documented in deployment notes or README as required by the DP.
  - Next.js deploys as a Node-based web app; FastAPI deploys as an ASGI service behind a process manager.
  - Supabase manages Postgres; do not embed database credentials in source control.
  - Redis must be provisioned as a managed service or container in the target environment.

## Structural constraints
- Prefer many small, focused files over large monolithic files.
- Frontend directory conventions:
  - `app/` for App Router routes and layouts.
  - `components/` for reusable UI components.
  - `hooks/` for React hooks.
  - `lib/` for shared utilities and client wrappers.
  - `types/` for shared TypeScript types.
- Backend directory conventions:
  - `app/main.py` for FastAPI app entrypoint.
  - `app/routers/` for route modules.
  - `app/schemas/` for Pydantic models.
  - `app/services/` for business logic.
  - `app/db/` for database access and migrations tooling.
