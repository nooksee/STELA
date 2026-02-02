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

## Invocation guidance
Use this skill when a DP explicitly requests a verification loop. The Trap: "It works on my machine" (ignoring clean-slate hygiene). Solution: Run verification from a clean git state and record exact exit codes.

## Drift preventers
- Stop if the DP scope is platform maintenance.
- Stop on the first failure. Do not proceed to subsequent steps.
- Anti-hallucination: Record actual terminal output. Do not summarize "Passed".

## Procedure
1) Clean State:
   - Run `git status --porcelain`.
   - If output is not empty, STOP. Commit or stash changes before verifying.
2) Type & Lint (Static Analysis):
   - Frontend: `npm run lint` (Ensure 0 exit code).
   - Backend: `ruff check` or `flake8` (Ensure 0 exit code).
3) Build (Compilation Gate):
   - Frontend: `npm run build`.
   - The Trap: Ignoring build warnings.
   - Solution: Inspect logs. If `WARN` appears regarding deps or types, treat as a failure.
4) Test (Logic Gate):
   - Run unit tests: `npm run test` or `pytest`.
   - Record coverage % if reported.
5) Diff Review:
   - Run `git diff --stat`.
   - Verify no files outside the DP Target Files allowlist were touched.
6) Receipt:
   - Copy/paste the summary lines of the above commands into RESULTS.
