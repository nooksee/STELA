# Technical Specification: ops/bin/prune

## Constitutional Anchor
`ops/bin/prune` is the retention and hygiene executor for root ledgers and storage artifacts.
It enforces proof safety before destructive actions and keeps cleanup behavior consistent with PoT filing doctrine.

## Operator Contract
- Invocation:
  - `./ops/bin/prune [--dp=DP-ID] [--target=sop|pow|both] [--dry-run] [--scrub] [--reset-task]`
- Default target: `sop`.
- Retention: keep newest `30` entries per ledger.
- Archive destinations:
  - SoP overflow: `storage/archives/root/SoP-archive-YYYY-MM.md`
  - PoW overflow: `storage/archives/root/PoW-archive-YYYY-MM.md`
- Cleanup surfaces:
  - Handoff aging cleanup (older than seven days, DP-aware keep rules).
  - DP-target artifact cleanup in `storage/handoff/` and `storage/dumps/`.
  - Optional `storage/tmp/` scrub.
- TASK reset:
  - Extracts embedded template from `docs/ops/specs/surfaces/task.md`.
  - Lints extracted template with `bash tools/lint/task.sh` before overwrite.
  - Blocks reset unless PoW already contains matching `- Packet ID: DP-OPS-XXXX`.

## Failure States and Drift Triggers
- Required ledger file missing for selected target.
- Invalid `--target` or empty `--dp` value.
- Uncommitted RESULTS guard violation.
- PoW guard violation for prune-candidate entries.
- TASK reset attempted without valid active DP ID or missing PoW packet proof.
- Template extraction failure or TASK lint failure during reset.

Results guard (hard stop):
- Before non-dry-run destructive paths, prune inspects candidate `*-RESULTS.md` artifacts.
- Fails when artifact is untracked, unstaged-dirty, or staged-dirty.
- Fatal message: `SAFETY VIOLATION: Uncommitted Results artifact detected. Commit or stash before pruning.`

PoW guard (hard stop):
- For PoW entries beyond retention threshold, every candidate entry must contain required fields and receipt pointers.
- Pointer kinds are validated by path class:
  - `RESULTS` -> `storage/handoff/*-RESULTS.md`
  - `OPEN` -> `storage/handoff/OPEN-*`
  - `DUMP` -> `storage/dumps/dump-*`
- Each pointer target must exist, be tracked, and be clean (no staged or unstaged diff).
- Guard failure aborts prune with explicit diagnostics and safety fatal banner.

## Mechanics and Sequencing
1. Parse args and validate target surfaces.
2. Resolve safety preconditions (`SoP.md`, `PoW.md`, TASK template path as needed).
3. For non-dry-run execution, run RESULTS guard before mutation.
4. Prune selected ledgers in deterministic order:
- `sop`: SoP only.
- `pow`: PoW only.
- `both`: SoP first, then PoW.
5. Compute cut line after retained threshold and archive overflow entries by month bucket.
6. Run artifact cleanup:
- `--dp`: delete artifacts matching DP token from handoff and dumps.
- no `--dp`: age-based handoff cleanup with active DP protection.
7. If requested, run `--reset-task` PoW proof gate then template reset.
8. If requested, run `--scrub` on `storage/tmp/` except `.gitignore`.
9. In `--dry-run`, print intent only and perform zero writes.

Target ledger logic:
- Ledger operations are isolated by `--target` to prevent accidental dual-prune.
- `both` is explicit and ordered, improving audit readability and rollback reasoning.
- Archive planning is deterministic and emitted in dry-run receipts.

## Forensic Insight
Prune is a deletion command guarded like a proof command.
By combining RESULTS cleanliness checks, PoW receipt validation, and deterministic target sequencing, it prevents evidence loss while still enforcing retention and hygiene discipline.
