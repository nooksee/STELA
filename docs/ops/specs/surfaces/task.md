<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
# TASK Surface Contract

## Purpose
`TASK.md` is the canonical task-routing and DP contract surface.
Think of `TASK.md` like the control desk card that shows which packet is active and which checks must run before closeout.

## Surface Roles
- `TASK.md`: Dispatch contract template and active thread routing surface.
- DP body (`TASK.md` Section 3): Worker-facing executable assignment.
- `storage/handoff/DP-OPS-XXXX-RESULTS.md`: Pointer-first execution receipt with pasted proofs and verification outputs.
- `OPEN` and `DUMP` artifacts: Generated state artifacts used for refresh and receipt pointers.

## Enforcement
- `tools/lint/task.sh`: Enforces TASK surface schema and TASK-only container rules.
- `tools/lint/dp.sh`: Enforces DP transaction rules in Section 3 and validates RESULTS Mandatory Closing Block artifacts.
- `ops/bin/draft`: Generates canonical DP structure from `ops/src/surfaces/dp.md.tpl` and updates `TASK.md`.
- Separation of concerns is strict: DP lint does not duplicate TASK container validation.

## Prune Sequencing
- Run verification gates first.
- Author RESULTS after verification gates pass.
- Operator commits before any prune step.
- Run prune last:
  - `./ops/bin/prune --dry-run` and `./ops/bin/prune --target=pow --dry-run` before destructive paths.
  - `./ops/bin/prune --scrub` for hygiene cleanup.

## TASK Template Source of Truth
- SSOT: `ops/src/surfaces/task.md.tpl`
- Template content must remain valid `TASK.md` and must pass `bash tools/lint/task.sh`.
- This spec is Explain-only and must not embed executable template bodies.

## DP Generation Contract
- DP structure is immutable and generated from `ops/src/surfaces/dp.md.tpl`.
- Standard generation flow is `./ops/bin/open` then `./ops/bin/draft`.
- Manual edits after generation are limited to slot content only; structural heading/label edits are prohibited.
- `tools/lint/dp.sh` enforces canonical template hash and normalized structure-hash parity.

## §3.5.1 Closing Block Schema Contract

`tools/lint/task.sh` accepts two §3.5.1 closing block formats in `check_task_dashboard()`.

**Certify-routed format (standard for active packets):** A TASK head leaf generated from `ops/src/surfaces/dp.md.tpl` carries a §3.5.1 block containing these exact list items, one per line:
- Primary Commit Header
- Pull Request Title
- Pull Request Description
- Final Squash Stub
- Extended Technical Manifest
- Review Conversation Starter

When all six list items are present, `task.sh` accepts the TASK head via the `list_format_present` path and returns without further closing block checks.

**Legacy label format (grandfathered for historical leaves):** Historical TASK leaves carry the plaintext-label form: `Primary Commit Header (plaintext)`, `Pull Request Title (plaintext)`, `Pull Request Description (markdown)`, `Final Squash Stub (plaintext) (Must differ from #1)`, `Extended Technical Manifest (plaintext)`, `Review Conversation Starter (markdown)`. This format is accepted via the legacy label fallback loop. No historical leaf is retroactively reformatted.

**Certify DP resolution order:** `ops/bin/certify` resolves the target DP from the TASK head leaf by default. Intake fallback fires only when the TASK head leaf is absent, fails container validation, or does not contain the target DP block. For standard closeout, the TASK head leaf must be structurally valid and contain the live current DP before `ops/bin/certify` is run. Intake fallback is a recovery path only, not the standard path.
