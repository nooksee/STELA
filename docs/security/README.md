# Security (Stela)

This document expands on the repo-level policy in `SECURITY.md`.

## Security philosophy

- Clarity over obscurity.
- Explainable ops and provenance over guesswork.
- Minimize blast radius and keep changes auditable.

## Roles and access expectations

Jurisdictions for human and AI agents are defined in AGENTS.md.

## Secrets management

- Do not store secrets in the repo.
- Use environment variables or a local secrets manager for sensitive values.
- Rotate and document remediation if exposure occurs.

## AI usage policy

- AI assistance is allowed with human oversight.
- Human review is required before merge.
- External claims must include sources or provenance.

## Reporting vulnerabilities

Preferred:
- GitHub Security Advisory for this repository.

Fallback:
- Contact repo owners via GitHub and request a private channel.

Please include:
- Clear description of the issue.
- Minimal reproduction steps.
- Affected files/versions (if known).
- Suggested mitigation (optional).

## Handling and disclosure

- We acknowledge reports as soon as practical.
- Fixes prioritize impact, exploitability, and clarity.
- We aim for coordinated, responsible disclosure.

## Cross-links

- `SECURITY.md` (repo root)
