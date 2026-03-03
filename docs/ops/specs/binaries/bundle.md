<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/bundle` is the deterministic transport primitive for workflow intake. It unifies OPEN freshness state, dump pointers, prompt stance text, and route metadata into one portable artifact contract. This prevents operator drift caused by ad hoc combinations of OPEN, dump payloads, and copied prompt text.

## Mechanics and Sequencing
The binary parses `--profile=auto|analyst|architect|audit|project`, `--out=auto|PATH`, and `--project=<name>` (required for profile `project`). It emits lifecycle leaves, then delegates to `ops/lib/scripts/bundle.sh`.

Bundle routing rules:
1. Explicit `analyst|architect|audit|project` selects that profile directly.
2. `--profile=auto` selects `architect` only when `storage/handoff/PLAN.md` exists and `tools/lint/plan.sh` passes on that file.
3. If PLAN is missing or PLAN lint fails, `auto` resolves to `analyst`.

Artifact contract (written under `storage/handoff/`):
1. Text bundle artifact containing OPEN freshness metadata and OPEN path pointer.
2. Dump payload and dump manifest path pointers (payload content is never inlined).
3. Embedded prompt stance text loaded verbatim from canonical prompt files under `docs/ops/prompts/` plus prompt path pointer.
4. Presence status of `storage/handoff/TOPIC.md` and `storage/handoff/PLAN.md`.
5. PLAN lint status when auto-routing decisions use PLAN gating.
6. Machine-readable sidecar manifest (`.manifest.json`) with routing and pointer metadata.

Dump scope mapping by resolved profile:
1. `analyst` and `architect` use `ops/bin/dump --scope=full`.
2. `audit` uses `ops/bin/dump --scope=core`.
3. `project` uses `ops/bin/dump --scope=project --project=<name>`.

## Anecdotal Anchor
DP-OPS-0145 replaced fragmented intake assembly with bundle routing after repeated packet handoffs required manual prompt-copy steps and inconsistent OPEN/dump attachment combinations.

## Integrity Filter Warnings
Bundle enforces output paths under `storage/handoff/`. For project profile, invalid or missing `--project` values are hard failures. Auto routing does not assess PLAN quality beyond the deterministic safety-floor lint; malformed but syntactically valid plans can still require operator judgment.
