# S-LEARN-05: Security Protocols

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0014)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Auth & Data Access
  - High Churn: Permission Logic

## Scope
Production payload work only.
Not platform maintenance.

## Invocation guidance
Use this skill when configuring database access, API surfaces, or auth flows.
**The Trap:** "Service Role" usage in client-side code.
**Solution:** Never expose service keys. Use RLS.

## Drift preventers
- Stop if a secret is found in code (even commented out).
- Stop if an API route allows `*` CORS in production configuration.

## Procedure
1) **Supabase RLS (Row Level Security):**
   - **Mandate:** RLS must be enabled on ALL public tables.
   - **Policy:** Explicitly define `SELECT`, `INSERT`, `UPDATE`, `DELETE` policies.
   - **Trap:** `USING (true)` (Public access).
   - **Solution:** `USING (auth.uid() = user_id)`.
2) **FastAPI CORS:**
   - Define `allow_origins` from environment variables.
   - **Negative Check:** Do not allow `allow_origins=["*"]` unless explicitly scoped to a development-only branch logic.
3) **Input Validation:**
   - **Frontend:** Validate forms with Zod before submission.
   - **Backend:** Validate payloads with Pydantic. Relying on frontend validation is a security failure.
4) **Dependency Hygiene:**
   - Pin versions in `package.json` / `requirements.txt`.
   - Run `npm audit` / `pip-audit` if available.
