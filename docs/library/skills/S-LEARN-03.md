# S-LEARN-03: Reference Spec Pattern (Zenith)

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP explicitly requests the Zenith reference pattern. Apply the patterns to project payload code only and document deviations.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Treat this as a reference pattern. Do not auto-apply it to platform scripts or governance files.
- Anti-hallucination: use existing project conventions as primary evidence before applying these patterns.

## Canonical reference patterns
### API response envelope
- Standard shape: `ok`, `data`, `error`, `meta`.
- Error object should include a stable `code` and human-readable `message`.
- Meta should include request identifiers or paging details when relevant.

### Fetch or client wrapper
- Centralize base URL, headers, auth token handling, and timeouts.
- Normalize errors into the response envelope.
- Keep the wrapper small and composable so it can be reused across endpoints.

### Hook-based request state pattern
- Provide a hook that returns `{ data, error, loading, refetch }`.
- Ensure `loading` is true only during in-flight requests.
- Reset or clear `error` on a successful request.
