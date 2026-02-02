# S-LEARN-05: Security Protocols

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
Use this skill when a DP explicitly requests security protocols. **The Trap:** Treating the checklist as optional or generic allows silent exposure. **Solution:** Apply each domain check to the actual code and record evidence in RESULTS.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: confirm security requirements in repo docs before assuming policies.

## Procedure
1) Secrets:
   - The Trap: logging or committing secrets for quick tests leaks credentials.
   - Solution: store secrets in environment variables or a secret manager and scrub logs.
2) Input validation:
   - The Trap: trusting client validation allows malformed input to reach the server.
   - Solution: enforce server-side allowlists and schema validation.
3) SQL injection prevention:
   - The Trap: string concatenation allows input leakage.
   - Solution: use parameterized queries or ORM bindings (for example, pg-promise variable binding).
4) Auth storage:
   - The Trap: storing long-lived tokens in localStorage enables theft.
   - Solution: store session tokens in HttpOnly cookies when feasible.
5) XSS:
   - The Trap: rendering untrusted HTML enables script injection.
   - Solution: escape untrusted content and use safe rendering utilities.
6) CSRF:
   - The Trap: state-changing endpoints without CSRF protection allow cross-site actions.
   - Solution: use SameSite cookies and CSRF tokens for state-changing requests.
7) Rate limiting:
   - The Trap: unlimited requests allow brute-force attacks.
   - Solution: rate limit authentication and write-heavy endpoints.
8) Data exposure:
   - The Trap: returning internal fields leaks sensitive data.
   - Solution: return only required fields and apply least-privilege access.
9) Blockchain safety:
   - The Trap: signing without validating chain ID or contract address enables fraud.
   - Solution: validate chain ID, contract addresses, and user intent before signing.
10) Dependency hygiene:
   - The Trap: unpinned dependencies drift into vulnerable versions.
   - Solution: pin versions and run dependency audits.
11) Record any DP-approved exceptions and evidence in RESULTS.
