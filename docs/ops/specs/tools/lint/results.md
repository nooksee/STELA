# Technical Specification: tools/lint/results.sh

## Purpose
Validate generated RESULTS receipts against the certification template contract.

## Invocation
- Command forms:
  - `bash tools/lint/results.sh`
  - `bash tools/lint/results.sh storage/handoff/DP-OPS-XXXX-RESULTS.md`
- Required flags: none.
- Positional arguments:
  - Optional receipt path. When omitted, scans `storage/handoff/DP-OPS-*-RESULTS.md`.
- Exit behavior:
  - `0` when all checked receipts pass.
  - `1` for usage errors, template drift, or receipt validation failures.

## Inputs
- Canonical template: `ops/src/surfaces/results.md.tpl`.
- Template hash constant in lint script.
- RESULTS receipt(s) from explicit path or naming scan.
- Current repository hash from `git rev-parse HEAD`.

## Outputs
- No file writes.
- Stdout:
  - `OK: RESULTS lint passed (<count> file(s) checked).`
  - `SKIP: legacy RESULTS format: <path>` for non-certification legacy receipts.
- Stderr:
  - template drift diagnostics.
  - missing heading/field failures.
  - git hash mismatch diagnostics.
  - missing/placeholder Closing Block failures.

## Enforcement Model
1. Verify `ops/src/surfaces/results.md.tpl` matches expected sha256 constant.
2. Resolve target receipt set (explicit path or naming scan).
3. Skip legacy receipts not matching certification heading schema.
4. For certification receipts, enforce:
  - required headings/sections.
  - recorded `Git Hash` equals `git rev-parse HEAD`.
  - Mandatory Closing Block labels present.
  - Closing Block values are non-empty and placeholder-free.

## Related pointers
- Certification renderer: `ops/bin/certify`.
- Surface contract: `docs/ops/specs/surfaces/results.md`.
