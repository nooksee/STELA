<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/task.sh` enforces canonical task lifecycle control so task definitions enter and leave canon through template-driven gates with provenance, scope boundaries, and registry continuity. This aligns with PoT.md Section 1.3 contract authority for `TASK.md` and Section 1.2 drift prevention by blocking ad hoc task-definition writes.

## Mechanics and Sequencing
1. Entry dispatch accepts `harvest`, `promote`, and `check`.
2. `harvest` sequence:
   - Require `--id` and `--name`; derive objective and DP-ID from `TASK.md` when not explicitly provided.
   - Enforce task ID pattern `B-TASK-[0-9]{2,}` and reject registry collisions.
   - Build provenance block through `heuristics.sh`.
   - Resolve packet and trace metadata, render `ops/src/definitions/task.md.tpl`, hydrate required default orchestration fields, redact output, write candidate leaf, and rewrite `candidate:` pointer in `opt/_factory/TASKS.md`.
3. `promote` sequence:
   - Resolve explicit or latest draft path.
   - Validate header shape, required sections, required field values, pointer presence, and closeout step reference to `TASK.md` Section 3.5.
   - Derive task ID from draft filename token, rewrite draft header into canonical task header, write canonical task file, upsert registry row, emit promotion leaf, and rewrite `promotion:` pointer.
   - Optional `--delete-draft` removes the candidate leaf after successful promotion.
4. `check` sequence:
   - Enforce task context hazard rule by rejecting task references in `ops/lib/manifests/CONTEXT.md`.
   - Delegate deep schema and workflow checks to `tools/lint/task.sh`.

## Anecdotal Anchor
SoP and PoW entries for `2026-02-15 01:55:45 UTC — DP-OPS-0065 Immutable Workflow Adoption and Closeout Remediation` record the cutover to template-driven DP and task-governance execution with stronger lint gating. SoP entry `2026-02-10 18:03:22 UTC — DP-OPS-0043` also documents hardening for placeholder drift and missing closeout pointers. Together these entries show the exact defect class this script addresses: unmediated task writes caused structural drift and weak closeout routing.

## Integrity Filter Warnings
- Promotion has no rollback transaction; failure after canonical file or registry row write can leave partial promotion state.
- Promotion requires a `B-TASK-XX` token in the draft filename; malformed draft filenames are rejected even when body content is valid.
- The script carries local helper copies of lifecycle primitives that also exist in `factory.sh`; divergence risk remains if one side changes first.
- `check` relies on external lint execution (`tools/lint/task.sh`); missing or failing external tooling blocks command completion.
