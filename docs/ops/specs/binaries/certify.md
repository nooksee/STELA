# Technical Specification: ops/bin/certify

## Constitutional Anchor
`ops/bin/certify` is the closeout certifier for DP execution.
It enforces scope integrity, executes receipt verification commands, and generates deterministic RESULTS artifacts from the canonical template.

## Operator Contract
- Invocation:
  - `./ops/bin/certify --dp=DP-OPS-XXXX [--out=auto|path] [--allow-intake-fallback]`
- Required inputs:
  - `--dp=DP-OPS-XXXX`
  - `storage/handoff/CLOSING-DP-OPS-XXXX.md` (non-empty human-authored sidecar)
- Defaults:
  - `--out=auto` writes to `storage/handoff/DP-OPS-XXXX-RESULTS.md`.
- Extraction scope:
  - Reads Target Files allowlist pointer and Section 3.4.5 verification commands from the active DP.
  - Primary source is `TASK.md`; when `TASK.md` is pointer-first, certify resolves its single-line `archives/surfaces/*` pointer to the leaf file before DP extraction.
  - Intake fallback source (`storage/dp/intake/DP-OPS-XXXX.md`) is disabled by default and only enabled when `--allow-intake-fallback` is provided.
  - On `work/dp-...` branches, `--dp` must match the packet encoded in branch naming.
  - Command extraction executes DP-provided receipt commands literally, except it skips recursive certify invocations (`ops/bin/certify`) and post-render RESULTS checks (`tools/lint/results.sh` and direct `*-RESULTS.md` path checks), because certify executes those gates in dedicated post-render stages.
  - Certify prepends the mandatory DP preflight proof commands to the execution plan (`bash tools/lint/dp.sh --test`, `bash tools/lint/dp.sh TASK.md`, `bash tools/lint/task.sh`) and de-duplicates identical entries.
- Phase 2 surface emission:
  - Certify emits three schema-stamped surface leaves in `archives/surfaces/`:
    - `PoW-<FreshnessStamp>-<shortHEAD>.md`
    - `SoP-<FreshnessStamp>-<shortHEAD>.md`
    - `TASK-<DP_ID>-<shortHEAD>.md`
  - Leaf front-matter keys are `trace_id`, `packet_id`, `created_at`, `previous`.
  - `previous` is `(none)` on first emission or the prior head pointer path when a surface is already pointer-first.
  - Snapshot bodies are full surface bodies; when a surface is pointer-first, certify snapshots the resolved leaf body (front-matter stripped) rather than the pointer line.
  - After leaf writes, certify rewrites `PoW.md`, `SoP.md`, and `TASK.md` to single-line repo-relative HEAD pointers to those emitted leaves.
- Trace resolution:
  - `STELA_TRACE_ID` is resolved in this priority order: environment variable first, then parse from the latest `storage/handoff/OPEN-*.txt` artifact.
- Telemetry leaf emission:
  - On successful certification, a telemetry leaf is written under `logs/` with YAML front-matter keys `trace_id`, `packet_id`, `created_at`, `previous`.
  - `previous` is sourced from a tool-local head pointer file at `logs/certify.telemetry.head` or `(none)` when no prior leaf exists.
  - After writing, `logs/certify.telemetry.head` is updated to the new leaf path.

## Hard Gates and Failure States
- Missing or malformed CLI args.
- `--dp` value mismatch against `work/dp-...` branch packet naming.
- Missing/empty Closing Block sidecar.
- Missing allowlist pointer in DP payload.
- Missing verification command list in DP Section 3.4.5.
- DP section missing from `TASK.md` while intake fallback override is not enabled.
- Intake fallback override requested while non-target DP packets are present in `storage/dp/intake/`.
- Integrity gate failure (`bash tools/lint/integrity.sh`).
- Any verification command non-zero exit (hard stop at first failure).
- Invalid or missing DP `Freshness Stamp` required for deterministic surface leaf naming.
- Surface pointer target missing when resolving pointer-first surfaces.
- Rendering failure via `ops/bin/template render results`.
- Post-render RESULTS lint failure (`bash tools/lint/results.sh <path>`).
- Missing TraceID when neither environment nor OPEN artifact provides `STELA_TRACE_ID`.

## Mechanics and Sequencing
1. Resolve repository root and validate executable dependencies.
2. Load DP payload (TASK first with pointer resolution; intake fallback only when explicitly enabled).
3. Extract allowlist pointer, verification commands, and DP `Freshness Stamp`.
4. Execute integrity lint as pre-command hard gate.
5. Execute the first three mandatory preflight commands and capture logs.
6. Execute Phase 2 surface leaf emission and rewrite `PoW.md`, `SoP.md`, `TASK.md` to HEAD pointers.
7. Execute remaining verification commands in deterministic order and capture:
  - command string
  - started/finished UTC timestamps
  - duration seconds
  - exit code
  - stdout/stderr text
8. Run post-command integrity recheck and changed-files subset gate against the active allowlist pointer.
9. Capture `git diff --name-only` and `git diff --stat` (including Phase 2 leaf/pointer mutations).
10. Render `results` template in strict mode using slot sidecar data.
11. Lint generated receipt with `tools/lint/results.sh`.
12. Emit telemetry leaf in `logs/` and update `logs/certify.telemetry.head`.
13. Emit receipt pointer path.

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
- Writes three tracked surface leaves under `archives/surfaces/` and rewrites `PoW.md`, `SoP.md`, and `TASK.md` to single-line HEAD pointers.
- Writes one telemetry leaf under `logs/` after RESULTS lint passes.
- Does not commit, push, merge, or mutate branch state.
- Exits non-zero on any gate failure before producing a passing certification result.
