# Technical Specification: ops/lib/scripts/synthesize.sh

## Constitutional Anchor
`ops/lib/scripts/synthesize.sh` is the One Truth context engine defined by PoT filing doctrine and context hazard policy.
It is the runtime boundary between manifest intent and emitted context bundles.
It enforces that global context cannot include `docs/library/agents`, `docs/library/tasks`, or `docs/library/skills`.

## Operator Contract
- Invocation:
  - `ops/lib/scripts/synthesize.sh [--manifest=PATH] [--mode=stream|list]`
  - `ops/lib/scripts/synthesize.sh --list` (alias for `--mode=list`)
- Defaults:
  - Manifest: `ops/lib/manifests/OPS.md`
  - Mode: `stream`
- Inputs:
  - Manifest markdown entries enclosed in backticks.
  - Optional nested includes via `@manifest:<path>` backtick tokens.
  - Optional globs in manifest entries.
- Outputs:
  - `list` mode prints resolved relative file paths, one per line.
  - `stream` mode prints `## <path>` headers followed by file contents.
  - For `SoP.md`, stream output is truncated to the newest entries by `SYNTHESIZE_SOP_LIMIT` (default `10`).
- Exit behavior:
  - `0` on success.
  - `1` on validation, parsing, hazard, or emission failure.
  - `0` for `-h` and `--help`.
- Mutation policy:
  - No file writes.
  - No tracked file mutation.

## Failure States and Drift Triggers
- Unknown argument.
- Missing or empty manifest path.
- Manifest file missing.
- Manifest entry path missing.
- Manifest glob resolves to zero files.
- Recursive manifest resolution yields zero files.
- Context hazard hit against blacklisted paths.
- Resolved stream file disappears before emit.
These are hard failures because they indicate context drift, policy breach, or stale pointers.

## Mechanics and Sequencing
1. Resolve repository root from `PROJECT_REPO_ROOT` or script-relative path.
2. Parse CLI args and choose manifest plus mode.
3. Resolve manifest recursively:
- Extract every backticked token.
- Follow `@manifest:` includes depth-first.
- Expand glob entries with shell globbing.
- Keep first-seen insertion order and de-duplicate with associative sets.
4. Enforce context hazards against the blacklist before any output.
5. Emit output:
- `list`: resolved paths only.
- `stream`: path header, then body.
- Strip TOC sections from each file.
- Apply redaction filters for common secret token patterns.
- Apply SoP head truncation before TOC/redaction when the file is `SoP.md`.
6. Return non-zero immediately on any failed invariant.

Determinism and receipt surfaces:
- Output ordering is deterministic relative to manifest token order and include order because insertion order is preserved.
- De-duplication is deterministic because only the first sighting of a path is kept.
- Primary receipt consumers are `ops/bin/context`, `ops/bin/llms`, and dump artifacts that capture synthesized output.

## Forensic Insight
Synthesis centralizes context assembly into one auditable parser and one hazard gate.
When drift occurs, failure messages identify the exact broken pointer class (manifest missing, entry missing, empty glob, hazard path) so operators can repair canon rather than shipping guessed context.
