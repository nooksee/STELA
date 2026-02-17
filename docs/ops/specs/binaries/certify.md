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

## Hard Gates and Failure States
- Missing or malformed CLI args.
- Missing/empty Closing Block sidecar.
- Missing allowlist pointer in DP payload.
- Missing verification command list in DP Section 3.4.5.
- Integrity gate failure (`bash tools/lint/integrity.sh`).
- Any verification command non-zero exit (hard stop at first failure).
- Rendering failure via `ops/bin/template render results`.
- Post-render RESULTS lint failure (`bash tools/lint/results.sh <path>`).

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
9. Emit receipt pointer path.

## Output Contract
- Writes one RESULTS artifact:
  - `storage/handoff/DP-OPS-XXXX-RESULTS.md` (auto mode), or explicit path.
- Does not commit, push, merge, or mutate branch state.
- Exits non-zero on any gate failure before producing a passing certification result.
