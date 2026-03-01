---
decision_id: RoR-2026-02-28-002
trace_id: stela-20260228T162305Z-4b23293a
packet_id: DP-OPS-0135
decision_type: scope-correction
---

## Context
Two session-environment anomalies were identified during initial assessment of the working tree state for DP-OPS-0135.

Anomaly 1 (scope correction): A line was found appended to the Integrity Filter Warnings section of `docs/ops/specs/binaries/dump.md` that was not specified in DP Step 7. The line read: "Not implemented scope aliases are rejected by argument parsing as unknown values." The DP Step 7 patch specifies only the replacement of the factory scope annotation text; no additional lines were authorized for that file.

Anomaly 2 (tool environment): `.claude/settings.json` was an untracked file not covered by `.gitignore`, causing `tools/lint/integrity.sh` to fail the allowlist hard gate. The `.claude/` directory is a Claude Code tool-local settings directory analogous to `.vscode/` and `.idea/`, which are already excluded in `.gitignore`.

## Decision
For Anomaly 1: Remove the out-of-scope line from `docs/ops/specs/binaries/dump.md`. The DP scope definition and Step 7 patch are the authoritative source; any addition not specified in the patch is out of scope and must be reverted. No formal operator authorization is required for this correction since it restores the file to the exact state mandated by the DP patch.

For Anomaly 2: Add `.claude/` to `.gitignore` (alongside existing `.vscode/` and `.idea/` entries) and add `.gitignore` to the DP allowlist. This eliminates the untracked path that was blocking the integrity gate. No behavioral change to any DP target file.

## Consequence
The dump.md diff matches exactly the specification in Step 7. The `.claude/` directory is excluded from git tracking, resolving the integrity gate failure. The `.gitignore` change is minimal (one line) and consistent with existing IDE/editor noise exclusion policy.

## Status
Resolved. Both corrections applied during assessment before receipt commands were run.

## Pointer
archives/decisions/RoR-2026-02-28-002-dump-md-extra-line-0135.md
