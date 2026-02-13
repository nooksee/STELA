# Technical Specification: tools/lint/dp.sh

## Purpose
Validate Dispatch Packet schema contracts, receipt requirements, and DP-specific safety rules.

## Invocation
- Command forms:
  - `bash tools/lint/dp.sh --test`
  - `bash tools/lint/dp.sh TASK.md`
  - `bash tools/lint/dp.sh <path>`
  - `cat <dp.md> | bash tools/lint/dp.sh -`
- Required flags: none.
- Positional arguments: at most one (`path` or `-`).
- Expected exit behavior:
  - `0` when lint passes or self-tests pass.
  - `1` for lint failures, invalid argument count, or missing input.

## Inputs
- Input payload from file argument or stdin.
- When given `TASK.md`, extracts Section 3 DP payload (`## 3. Current Dispatch Packet (DP)` to `## 4.`).
- DP content fields and headings for Sections 3.1 through 3.4.5.

## Outputs
- Writes no tracked files.
- Stdout:
  - `OK: DP lint passed` for successful payload lint.
  - `OK: --test passed` for successful self-test fixtures.
- Stderr:
  - `FAIL:` details for schema, receipt contract, allowlist, and hazard violations.
  - `WARN:` when llms invocation is present but `ops/bin/llms` is missing from allowlist.

## Invariants and failure modes
- Heading order and required DP blocks are mandatory.
- Freshness fields (`Base Branch`, `Required Work Branch`, `Base HEAD`) must be concrete in non-template payloads.
- Preflight gate must include:
  - `bash tools/lint/dp.sh --test`
  - `bash tools/lint/dp.sh TASK.md`
  - `bash tools/lint/task.sh`
- Canon load order must contain exactly six required entries.
- Context-load hardening:
  - `llms-full.txt` is prohibited in DP context load surfaces and fails lint.
  - `llms-core.txt` is allowed only when explicitly marked as lightweight alignment usage.
- Receipt block must include OPEN, DUMP, gate commands, diff proofs, and mandatory closing block requirement.
- Disposable artifact input references and pasted OPEN/DUMP payload markers are rejected.

## Related pointers
- Registry entry: `docs/ops/registry/LINT.md` (`LINT-03`).
- TASK schema companion: `tools/lint/task.sh` (`docs/ops/specs/tools/lint/task.md`).
- DP contract surface: `TASK.md` Section 3.
