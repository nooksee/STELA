# S-LEARN-03: Reference Spec Pattern (Zenith)

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
Use this skill when a DP explicitly requests the Zenith reference pattern. Apply the patterns to project payload code only and document deviations.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Treat this as a reference pattern. Do not auto-apply it to platform scripts or governance files.
- Anti-hallucination: use existing project conventions as primary evidence before applying these patterns.

## Procedure
1) Apply the API response envelope:
   - Standard shape: `ok`, `data`, `error`, `meta`.
   - Error object includes a stable `code` and human-readable `message`.
   - Meta includes request identifiers or paging details when relevant.
2) Apply the fetch or client wrapper pattern:
   - Centralize base URL, headers, auth token handling, and timeouts.
   - Normalize errors into the response envelope.
   - Keep the wrapper small and composable so it can be reused across endpoints.
3) Apply the hook-based request state pattern:
   - Provide a hook that returns `{ data, error, loading, refetch }`.
   - Ensure `loading` is true only during in-flight requests.
   - Reset or clear `error` on a successful request.
4) Document DP-approved deviations in RESULTS.
