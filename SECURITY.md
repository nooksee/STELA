# Security Policy (Stela)

This repo values clarity over obscurity and explainable ops. Security work should be
traceable, auditable, and easy to reason about.

For extended guidance, see `docs/security/README.md`.

## Roles and access expectations

For jurisdiction definitions and behavioral logic standards for the Operator,
Integrator, and Contractor, see the canonical constitution in AGENTS.md.

## Secrets management

- Never commit secrets, API keys, or credentials to the repo.
- Use environment variables or a local secrets manager for sensitive values.
- If a secret is exposed, rotate it and document the remediation.

## AI usage policy

- AI assistance is allowed with human oversight.
- All AI-proposed changes must be reviewed by a human operator.
- Provide citations/provenance for external sources or non-trivial claims.

## Reporting vulnerabilities

Preferred:
- Use a GitHub Security Advisory for this repository.

If you cannot use GitHub Security Advisories:
- Contact the repository owners via GitHub and request a private channel.
- Do not disclose details publicly until coordinated.

When reporting, include:
- A clear description of the issue.
- Minimal reproduction steps or proof-of-concept.
- Affected files/versions (if known).
- Suggested mitigations (optional, appreciated).

## Handling and disclosure

- We will acknowledge reports as soon as practical.
- Fixes are prioritized by impact, exploitability, and clarity.
- We aim for coordinated, responsible disclosure.

## Known issues and future improvements

- Legacy code paths include MD5 hashing that should be upgraded.

## Related docs

- `docs/security/README.md`
- `TASK.md`
