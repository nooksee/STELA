# Technical Specification: ops/bin/certify

## Constitutional Anchor
`ops/bin/certify` is the closeout certifier for DP execution.
It enforces scope integrity, executes receipt verification commands, and generates deterministic RESULTS artifacts from the canonical template.

## Operator Contract
- Invocation:
  - `./ops/bin/certify --dp=DP-OPS-XXXX [--out=auto|path]`
- Required inputs:
  - `--dp=DP-OPS-XXXX`
  - `storage/handoff/CLOSING-DP-OPS-XXXX.md` (non-empty human-authored sidecar)
- Defaults:
  - `--out=auto` writes to `storage/handoff/DP-OPS-XXXX-RESULTS.md`.
- Extraction scope:
  - Reads Target Files allowlist pointer and Section 3.4.5 verification commands from the active DP.
  - Primary source is `TASK.md`; fallback source is `storage/dp/intake/DP-OPS-XXXX.md` when TASK does not yet contain the target DP.
  - Command extraction skips self-mutating artifact commands (`ops/bin/open`, `ops/bin/dump`, `ops/bin/certify`) and post-render RESULTS checks (`tools/lint/results.sh` and direct `*-RESULTS.md` path checks), because certify executes those gates in dedicated post-render stages.
  - Certify prepends the mandatory DP preflight proof commands to the execution plan (`bash tools/lint/dp.sh --test`, `bash tools/lint/dp.sh TASK.md`, `bash tools/lint/task.sh`) and de-duplicates identical entries.
- Trace resolution:
  - `STELA_TRACE_ID` is resolved in this priority order: environment variable first, then parse from the latest `storage/handoff/OPEN-*.txt` artifact.
- Telemetry leaf emission:
  - On successful certification, a telemetry leaf is written under `logs/` with YAML front-matter keys `trace_id`, `packet_id`, `created_at`, `previous`.
  - `previous` is sourced from a tool-local head pointer file at `logs/certify.telemetry.head` or `(none)` when no prior leaf exists.
  - After writing, `logs/certify.telemetry.head` is updated to the new leaf path.

## Hard Gates and Failure States
- Missing or malformed CLI args.
- Missing/empty Closing Block sidecar.
- Missing allowlist pointer in DP payload.
- Missing verification command list in DP Section 3.4.5.
- Integrity gate failure (`bash tools/lint/integrity.sh`).
- Any verification command non-zero exit (hard stop at first failure).
- Rendering failure via `ops/bin/template render results`.
- Post-render RESULTS lint failure (`bash tools/lint/results.sh <path>`).
- Missing TraceID when neither environment nor OPEN artifact provides `STELA_TRACE_ID`.

## Mechanics and Sequencing
1. Resolve repository root and validate executable dependencies.
2. Load DP payload (TASK first, intake fallback).
3. Extract allowlist pointer and verification commands.
4. Execute integrity lint as pre-command hard gate.
5. Execute commands in deterministic order and capture:
  - command string
  - started/finished UTC timestamps
  - duration seconds
  - exit code
  - stdout/stderr text
6. Capture `git diff --name-only` and `git diff --stat`.
7. Render `results` template in strict mode using slot sidecar data.
8. Lint generated receipt with `tools/lint/results.sh`.
9. Emit telemetry leaf in `logs/` and update `logs/certify.telemetry.head`.
10. Emit receipt pointer path.

Allowlist-sensitive lint handling:
- When `bash tools/lint/llms.sh` appears in the verification plan and llms artifacts are not allowlisted for the active DP, certify restores `llms.txt`, `llms-core.txt`, and `llms-full.txt` to `HEAD` after command execution so out-of-scope drift is not carried into final diff capture.
- The normalization step is logged in the command log with candidate discovery pattern, per-file allowlist membership, per-file drift status, and explicit command-level restore actions.
- Allowlisted llms artifacts are reported as skipped and are not normalized.
- Certify executes and logs a post-command `bash tools/lint/integrity.sh` recheck before final diff capture.
- Certify executes and logs a changed-files subset check against the active allowlist pointer after normalization and before final diff capture.
- Scope Verification includes both the initial integrity gate output and the post-command integrity recheck output.
- Scope Verification also includes RESULTS lint output and explicit pass checks for template headings, hash parity, closing block population, and unresolved slot-token scan.

## Output Contract
- Writes one RESULTS artifact:
  - `storage/handoff/DP-OPS-XXXX-RESULTS.md` (auto mode), or explicit path.
- Writes one telemetry leaf under `logs/` after RESULTS lint passes.
- Does not commit, push, merge, or mutate branch state.
- Exits non-zero on any gate failure before producing a passing certification result.
