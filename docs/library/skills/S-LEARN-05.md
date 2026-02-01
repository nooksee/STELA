# S-LEARN-05: Security Protocols

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP explicitly requests security protocols. Apply the checklist to payload code and record any DP-approved exceptions.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: confirm security requirements in repo docs before assuming policies.

## Security checklist (ten domains)
- Secrets
  - Do: store secrets in environment variables or a secret manager.
  - Do not: commit secrets to source control or print them in logs.
- Input validation
  - Do: validate inputs on the server with allowlists and schema validation.
  - Do not: trust client-side validation alone.
- SQL injection prevention
  - Do: use parameterized queries or an ORM with bound parameters.
  - Do not: concatenate user input into SQL strings.
- Auth storage
  - Do: store session tokens in HttpOnly cookies for browser apps when feasible.
  - Do not: store long-lived tokens in localStorage.
- XSS
  - Do: escape untrusted content and use safe rendering utilities.
  - Do not: render untrusted HTML or use dangerous HTML injection.
- CSRF
  - Do: use SameSite cookies and CSRF tokens for state-changing requests.
  - Do not: expose state-changing endpoints without CSRF protection.
- Rate limiting
  - Do: rate limit authentication and write-heavy endpoints.
  - Do not: allow unlimited requests to public endpoints.
- Data exposure
  - Do: return only required fields and apply least-privilege access.
  - Do not: expose sensitive fields or internal identifiers to clients.
- Blockchain safety
  - Do: validate chain ID, contract addresses, and user intent before signing.
  - Do not: sign transactions automatically or without explicit user consent.
- Dependency hygiene
  - Do: pin versions and run dependency audits.
  - Do not: ignore critical security advisories.
