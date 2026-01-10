# Lessons learned (pre-coding, governance era)

We’re starting fresh publicly, while keeping private lessons intact.

## What we keep (the “team discipline” wins)
- **Governance beats heroics:** PR-only merges, required gates, no admin bypass.
- **Structure beats memory:** docs + launch pack are the source of continuity, not the chat.
- **Small PRs beat big merges:** easier review, easier rollback, clearer provenance.
- **Explainability-first:** decisions should be traceable (what, why, and provenance).

## What we avoid (entropy traps)
- Untracked “magic” changes.
- Local-machine assumptions (absolute paths, hostnames, personal identifiers).
- Version-noise everywhere (history belongs in an archive, not in the front door).
