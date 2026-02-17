# Technical Specification: ops/bin/open

## Constitutional Anchor
`ops/bin/open` is the session freshness checkpoint for dispatch.
It binds operator intent to exact git state before work begins and preserves pointer-first governance for TASK and RESULTS workflows.

## Operator Contract
- Invocation:
  - `./ops/bin/open [--format=chatgpt|gemini] [--intent="..."] [--dp="..."] [--out=auto] [--tag=<token>]`
- Freshness Gate capture (mandatory every run):
  - `git rev-parse --abbrev-ref HEAD`
  - `git rev-parse --short HEAD`
  - `git status --porcelain`
- Trace identity:
  - `STELA_TRACE_ID` is generated locally on every invocation (`UTC timestamp + hex suffix` format).
  - The OPEN prompt includes `- STELA_TRACE_ID: <value>` so the value is persisted in `storage/handoff/OPEN-*.txt`.
- Artifact outputs:
  - `storage/handoff/OPEN-<tag>-<branch>-<short-hash>.txt`
  - Dirty state only: `storage/handoff/OPEN-PORCELAIN-<tag>-<branch>-<short-hash>.txt`
  - Clean state: stale `OPEN-PORCELAIN-*` for the same branch/hash/tag is removed.
- Required pointer checks:
  - `PoT.md`, `SoP.md`, `PoW.md`, `TASK.md`, `docs/INDEX.md`, `docs/MANUAL.md`, `docs/MAP.md`, `ops/lib/manifests/CONTEXT.md`.
- Mutation boundary:
  - Read-only with respect to tracked repository files.
  - Allowed writes are limited to OPEN artifacts in `storage/handoff/`.

## Failure States and Drift Triggers
- Unknown argument.
- Missing required canon pointer files.
- Git metadata unavailable.
- Artifact path write failure.

Freshness Gate rationale:
- Porcelain capture is mandatory because branch and hash alone do not prove clean execution state.
- Dirty-state porcelain lines preserve exact pre-work diffs for forensics and prevent hidden mutation claims.

## Mechanics and Sequencing
1. Parse args and validate mode.
2. Resolve branch and short HEAD.
3. Generate `STELA_TRACE_ID` for this OPEN session.
4. Always run porcelain capture.
5. If porcelain is non-empty:
- Mark session as dirty.
- Save normalized porcelain lines to `OPEN-PORCELAIN-*` artifact.
- Print full list when line count is within threshold; otherwise print preview.
6. If porcelain is empty, remove any stale `OPEN-PORCELAIN-*` artifact for the same branch/hash/tag.
7. Verify required canon files exist.
8. Build and emit OPEN prompt content to stdout and OPEN artifact.
9. If `--out=auto` is set, print artifact path as a terminal receipt line.

Read-only contract details:
- OPEN must not rewrite `TASK.md`, `PoT.md`, or any tracked canon/document surface.
- OPEN is a generator, not a mutator.
- Any tracked-file side effect is a contract violation and drift trigger.
- The final `OPEN saved: ...` terminal receipt line remains outside the OPEN artifact body.
- Downstream tools may resolve `STELA_TRACE_ID` from the latest OPEN artifact when the environment variable is absent.

## Forensic Insight
`ops/bin/open` creates a timestamped, hash-bound execution anchor.
It is the bridge between declared intent and verifiable state, and porcelain capture closes the common forensic gap where unstaged local drift is omitted from receipts.
