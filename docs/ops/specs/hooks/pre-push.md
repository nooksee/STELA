<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`.github/hooks/pre-push` exists to block direct pushes to `main` at the last local gate before remote update. It keeps the work-branch and pull-request discipline enforceable even when a local clone has hooks enabled.

## Mechanics and Sequencing
The hook reads the refs provided on stdin by git push. For each ref update, it inspects the remote ref and fails immediately when the destination is `refs/heads/main`. It does not modify tracked files, stage content, or invoke refresh tooling.

## Bypass and Limits
`git push --no-verify` bypasses this hook. The hook does not authorize pushes on its own; it only blocks the forbidden `main` destination and leaves all other policy enforcement to the broader Stela workflow.
