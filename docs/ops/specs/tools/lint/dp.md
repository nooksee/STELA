# Technical Specification: tools/lint/dp.sh

## Purpose
Validate Dispatch Packet structure integrity via canonical template hashing, enforce required slot content, validate allowlist pointer integrity, and lint RESULTS closing blocks.

## Invocation
- Command forms:
  - `bash tools/lint/dp.sh --test`
  - `bash tools/lint/dp.sh` (defaults to `TASK.md` when stdin is empty)
  - `bash tools/lint/dp.sh TASK.md`
  - `bash tools/lint/dp.sh <path>`
  - `cat <dp.md> | bash tools/lint/dp.sh -`
- Required flags: none.
- Positional arguments: at most one (`path` or `-`).
- Exit behavior:
  - `0` for pass.
  - `1` for validation failures or invalid usage.

## Inputs
- Input payload from file argument or stdin.
- For `TASK.md`, extracts the active DP block from `### DP-...` through Section `3.5.1` content.
- Canonical DP template: `ops/src/surfaces/DP.md.tpl`.
- Canonical template hash constant from `tools/lint/dp.sh`.
- Allowlist pointer file from DP Section 3.3 (`storage/dp/active/allowlist.txt` by default).

## Outputs
- No tracked files are written.
- Stdout:
  - `OK: DP lint passed`
  - `OK: DP RESULTS lint passed`
  - `OK: --test passed`
- Stderr:
  - `FAIL:` diagnostics for hash mismatches, schema extraction errors, missing required slot content, allowlist integrity failures, and RESULTS block violations.

## Enforcement Model
1. Canonical template hash preflight:
- Computes sha256 for `ops/src/surfaces/DP.md.tpl`.
- Fails if hash does not equal `CANONICAL_DP_TEMPLATE_SHA256` constant.

2. Structure-hash validation:
- Normalizes both canonical template and DP payload by replacing variable slots with fixed placeholders.
- Computes sha256 for normalized template and normalized payload.
- Fails on mismatch.

3. Required-field validation:
- Enforces non-empty and non-placeholder values for:
  - DP heading id/title.
  - `Base Branch`, `Required Work Branch`, `Base HEAD`, `Freshness Stamp`.
  - DP-scoped load order.
  - Objective/In scope/Out of scope/Safety sections.
  - Plan body sections (3.4.1 through 3.4.4).
  - Receipt section body (3.4.5).

4. Allowlist pointer integrity:
- DP allowlist block must contain exactly one pointer entry.
- Pointer must match canonical pointer path.
- Pointer file must exist and be non-empty.
- Each allowlist line must be a plain path that exists in repository scope.

5. RESULTS lint path:
- Validates Mandatory Closing Block labels.
- Enforces strict plaintext fields and placeholder rejection.
- Ensures Final Squash Stub differs from Primary Commit Header.

## Self-test coverage (`--test`)
- Canonical template hash mismatch failure.
- DP structure hash mismatch failure.
- Allowlist pointer mismatch and allowlist file path validation failures.
- RESULTS closing block pass/fail fixtures.

## Related pointers
- Canonical DP generator: `ops/bin/draft`.
- DP template source: `ops/src/surfaces/DP.md.tpl`.
- TASK schema companion: `docs/ops/specs/surfaces/task.md`.
