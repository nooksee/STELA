# Contractor packet (read-in)

This pack is the minimum you need to work safely in the Stela repository.

## Non-negotiables

- **No direct pushes to `main`.**
- Work on `work/*` branches → PR → gates green → merge.
- Keep donor snapshots in `upstream/` read-only posture.
- If you are unsure: stop and ask. Do not guess.

## How we review

- The maintainer reviews changes **visually in NetBeans** before merge.
- Automation (repo-gates) verifies tree structure + truth lint rules.

## Before you start

1. Read:
   - `TRUTH.md`
   - `docs/library/OPERATOR_MANUAL.md`
   - `docs/40-PROJECT_HYGIENE.md`
   - `docs/upstreams.md`

2. Confirm you can:
   - create a `work/*` branch,
   - run the gates locally,
   - open a PR and wait for CI gates.

## Output expectations

- Small PRs, clear commit messages.
- No hidden changes.
- Document provenance when importing/adapting external code.
