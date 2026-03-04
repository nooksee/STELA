<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/bundle` is the deterministic transport primitive for workflow intake. It unifies OPEN freshness metadata, dump pointers, prompt contract text, and route metadata into one portable contract so operator handoffs do not depend on manual prompt copy or ad hoc artifact selection.

## Mechanics and Sequencing
Public interface:
1. `--profile=auto|analyst|architect|audit|project|hygiene|auditor`
2. `--out=auto|PATH`
3. `--project=<name>` (required only for `project`)
4. `--intent=<text>` (required only for `auditor`)

Profile intent split:
1. `audit` is the audit-verdict intake profile.
2. `auditor` is addendum-authorization intake profile.
3. `auditor` is not a substitute for `audit`.

Routing rules:
1. Explicit `analyst|architect|audit|project|hygiene|auditor` selects that profile.
2. `--profile=auto` selects `architect` only when `storage/handoff/PLAN.md` exists and `tools/lint/plan.sh` passes.
3. Otherwise auto resolves to `analyst`.

Artifact contract (written under `storage/handoff/`):
1. Bundle text artifact (`.txt`) with embedded OPEN block, dump pointers, prompt pointer, and embedded prompt contract excerpt.
2. Bundle manifest (`.manifest.json`) with `bundle_version: "2"` and structured metadata:
   - profile routing metadata
   - embedded OPEN metadata (`embedded`, `branch`, `head_short`, `trace_id`, `intent`)
   - dump pointers
   - topic/plan presence
   - addendum metadata (`required`, `decision_id`, `decision_leaf_present`)
   - package metadata (`path`, `files`)
3. Bundle package (`.tar`) containing bundle `.txt`, manifest, dump payload, dump manifest, and `TOPIC.md`/`PLAN.md` when present.
4. Canonical bundle artifact names use `BUNDLE-` prefix; profile aliases such as `AUDIT-*` or `AUDITOR-*` are non-canonical relabels.

Text artifact profile conditional block:
1. The `[HANDOFF]` block (`TOPIC.md` / `PLAN.md` presence) is emitted for non-audit profiles.
2. For `audit` and `auditor` resolved profiles, the text artifact omits `[HANDOFF]` to avoid unrelated intake noise in audit flows.

Auditor gate:
1. `--profile=auditor` requires `--intent`.
2. Intent format must be `ADDENDUM REQUIRED: <DECISION_ID> - <ONE-LINE BLOCKER>`.
3. Bundle runtime verifies `<DECISION_ID>` exists in dump payload; missing decision leaf is a hard failure.

Dump scope mapping by resolved profile:
1. `analyst|architect|hygiene` -> `ops/bin/dump --scope=full`.
2. `audit|auditor` -> `ops/bin/dump --scope=core`.
3. `project` -> `ops/bin/dump --scope=project --project=<name>`.

Bundle runtime invokes dump with explicit `.txt` output path to suppress dump auto-compression side effects during bundle orchestration.

## Anecdotal Anchor
DP-OPS-0146 hardened bundle intake after web-model architect runs looped on option menus and failed to map DP slots reliably from PLAN handoff context.

## Integrity Filter Warnings
Bundle enforces output paths under `storage/handoff/`. Project profile rejects missing or invalid slugs. PLAN lint remains a deterministic safety floor; it validates structure, not plan quality. Bundle runtime must remain deterministic and must not parse factory markdown governance files at runtime.
