# S-LEARN-03: Reference Spec Pattern (Zenith)

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0014)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: API Integration
  - High Churn: Data Fetching Logic

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when implementing API surfaces or data fetching hooks. The Trap: Inconsistent error parsing causes frontend crashes. Solution: Enforce the Zenith Envelope on the server and the Zenith Hook on the client.

## Drift preventers
- Stop if endpoints return raw arrays or bare primitives.
- Stop if hooks expose raw fetch states without normalization.

## Procedure
1) The Zenith Envelope (Server Response):
   - Envelope type: `{ ok: boolean, data: T, error: { code, message }, meta: any }`.
   - All JSON responses must match:
```json
{ "ok": true, "data": {"...": "..."}, "error": null, "meta": { "trace_id": "..." } }
```
   - On Error: `"ok": false, "data": null, "error": { "code": "E_...", "message": "Human readable" }`.
2) The Zenith Hook (Client State):
   - Custom hooks must return:
```ts
{
  data: T | null;
  loading: boolean;
  error: string | null;
  refresh: () => Promise<void>;
}
```
   - Define the Fetch Hook Pattern: `useZenithQuery<T>`.
   - The Trap: isLoading sticking to true on failure.
   - Solution: Ensure `finally { loading = false }` block.
3) Normalization:
   - The Client Wrapper must intercept non-200 HTTP statuses and convert them into the Zenith Error format before the component sees them.
