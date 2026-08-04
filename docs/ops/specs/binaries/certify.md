<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/certify` exists to enforce PoT Section 4.2 Generation Mandate at closeout time. The binary prevents a failure mode where receipt evidence is hand-assembled, scope checks are skipped, or proof surfaces diverge from recorded execution. It protects equilibrium maintenance by requiring deterministic receipt command execution, allowlist subset enforcement, structurally owned pointer-first surface emission for `PoW.md`, `SoP.md`, and `TASK.md`, and packet-consistent TASK archival.

Certification also closes the present-state transition. Before snapshotting SoP, it requires the six durable orientation fields and one shipment entry for the packet being certified. Before emitting the TASK leaf, it rewrites routing to `IDLE`, packet state to `COMPLETED`, and packet identity to the certified DP. The immutable TASK body remains available for lineage and next-packet derivation, but it no longer claims to be active work.

## Mechanics and Sequencing
`ops/bin/certify` now runs in explicit phases:
1. `startup`: parse arguments, enforce branch to packet parity, resolve output path, and validate required binaries/lints.
2. `preflight`: validate the non-empty closing sidecar at `storage/handoff/CLOSING.md`; resolve the active TASK source and DP block; enforce required DP section headings; extract the allowlist pointer and receipt commands; prepend and de-duplicate mandatory DP preflight commands; validate trace / OPEN prerequisites; run the negative closing-validator self-check; run the pre-command integrity gate; and write, ingest, and validate the Worker Execution Narrative scaffold before any long replay begins. Narrative validation requires the `### Preflight State` subsection to carry the three freshness-gate command strings captured before edits began.
3. `replay`: execute the assembled receipt command plan in order. Certify computes a repo-relative changed-path set under its run-local `var/tmp/certify.*` directory from tracked diff plus untracked packet files. It rewrites any receipt `tools/verify.sh` invocation, including explicit `--mode=full`, to `bash tools/verify.sh --mode=certify-critical --paths-file=<repo-relative-temp-file>` so certify replays only closeout-critical and packet-local lanes instead of broad full-repo hygiene. Repo-local receipt commands authored as literal `ops/bin/*` or `./ops/bin/*` entries are replayable. Unsupported first tokens, inline backticks, command substitution, or non-`grep`/`rg` glob patterns are hard failures; receipt commands are never silently skipped. The LLMS lint is read-only, and certify records its result without restoring fresh bundle output to `HEAD`. During verification command execution, certify tracks dump invocations and resolves the latest dump manifest pointer. For addendum draft verification commands (`ops/bin/draft --addendum=... --base-dp=...`), certify prepends `DRAFT_ALLOW_DIRTY_TREE=1` at execution time so the command can be replayed inside an intentionally dirty closeout session without relaxing `ops/bin/draft` global clean-tree enforcement.
4. `verify`: nested phase label used when the replayed command is `tools/verify.sh --mode=certify-critical`; failures in that command report as verify-phase failures instead of generic replay failures.
5. `postflight`: run post-command integrity, active TASK packet-consistency verification, a dual changed-file scope check, and a dump-visible prune pressure report. Every ordinary changed path must appear in the base packet or active addendum exact scope and in persistent policy. A declared deletion may use committed `HEAD` policy coverage when the same change retires its current policy entry.
6. `results`: capture diff outputs, render RESULTS via `ops/bin/template render results` with the `WORKER_NARRATIVE` slot populated from the collected narrative, append authoritative delivered `dp_source` and `dump_manifest` in Scope Verification alongside the allowlist pointer (`dump_manifest` is `none` when no dump command was present in the DP receipt section; values are disposable-reference sanitized before RESULTS render), lint RESULTS, verify structural headings and hash parity, keep base packet authority on the TASK leaf chain, emit addendum lineage under `archives/surfaces/ADDENDUM-DP-OPS-XXXX-<git-short-hash>.md` when applicable, archive the final byte-identical RESULTS receipt under `archives/surfaces/`, verify archive parity and final PoW reachability, emit telemetry leaf output, and print receipt paths. `dp_source` must record the delivered TASK/addendum lineage path so RESULTS and audit evidence agree.

Before replay begins, certify computes the exact certify-owned generated surface set for the current packet:
- `PoW.md`
- `SoP.md`
- `TASK.md`
- `archives/surfaces/PoW-<freshness>-<short-hash>.md`
- `archives/surfaces/SoP-<freshness>-<short-hash>.md`
- `archives/surfaces/TASK-<packet-id>-<short-hash>.md`
- `archives/surfaces/RESULTS-<packet-id>[-ADDENDUM-<letter>]-<short-hash>.md`

These paths are structurally owned by certify for the active run and therefore do not require packet-specific mutation or policy entries. Every unrelated changed path remains subject to both gates.
For base DP runs, certify materializes the archived `TASK` leaf body from the current active DP block before writing the new pointer head so prior-packet body text cannot be carried forward by an old TASK pointer target.
When `PoW.md` or `SoP.md` has been authored as a multi-line pre-certify current-entry head, certify preserves archive chain linkage by deriving `previous:` from the committed HEAD pointer for that surface while snapshotting the current working-tree body into the new leaf.
The PoW snapshot replaces transport-only receipt pointers with the deterministic archived RESULTS path and authoritative TASK or addendum lineage path. Its frontmatter records `proof_model: durable-v1` and `proof_state: complete`. During replay the future archive path is allowed only as an in-progress PoW transition; final certification publishes and validates the target before success.
When `--allow-intake-fallback` is explicitly enabled and `TASK.md` is a pointer-only head while the matching intake packet is present, certify prefers the intake packet as the active DP source for rerun recovery instead of reusing a stale packet body embedded in the current TASK leaf.

Certify emits `Certify phase: <phase>` when the active phase changes, and all hard-fail exits are tagged as `ERROR [<phase>]` so closeout failures are phase-local without requiring transcript archaeology.
At completion, certify also emits two stable summary blocks to stdout:
- `CERTIFY-PHASE: name=<phase> duration_seconds=<N>`
- `CERTIFY-LONG-POLE: rank=<N> phase=<phase> command_id=<id> duration_seconds=<N> command=<sanitized-command>`

The certify telemetry leaf includes:
- `total_duration_seconds`
- the phase summary block
- the long-pole summary block

After surface emission, certify verifies that the active `TASK` pointer target is packet-consistent:
- frontmatter `packet_id` must equal the first `### DP-...` body heading
- the body `Work Branch:` must equal the current work branch

This postflight check is fail-closed and is recorded in the command log.

### Worker Execution Narrative Capture
At certify start, after integrity initialization and before command execution, certify writes a scaffold block to `${TMP_DIR}/narrative.md` with the following subsection structure:
- `### Preflight State`
- `### Implemented Changes`
- `### Closeout Notes`
- `### Decision Leaf`
  - `Decision Required: Yes|No`
  - `Decision Leaf: archives/decisions/... or None`

Certify delegates scaffold orchestration to `ops/lib/scripts/editor.sh`. In interactive mode, the helper resolves editor command in order (`STELA_EDITOR`, `EDITOR`, fallback) and opens the scaffold. In non-interactive mode, certify reads `--narrative-file=PATH` into the scaffold target and runs the same validation checks. Certify validates:
- No placeholder tokens (`{{`, `}}`, TBD, TODO, PLACEHOLDER, ENTER_, REPLACE_, `populate during execution`, `do not pre-fill`, `DP-XXXX`).
- No untouched scaffold instruction lines (exact scaffold prose must be replaced).
- All four required subsection headings are present.
- `### Preflight State` contains the three freshness-gate command strings:
  - `git rev-parse --abbrev-ref HEAD`
  - `git rev-parse --short HEAD`
  - `git status --porcelain`
- Both `Decision Required:` and `Decision Leaf:` lines are present.
- No absolute paths.

The validated narrative is passed as the `WORKER_NARRATIVE` slot to both template render invocations. The narrative appears in RESULTS under `## Worker Execution Narrative`, and no closing sidecar block is embedded in RESULTS. This proof belongs in the narrative, not in the replayed command log, because replay happens at certify time against the current closeout tree rather than the pre-edit tree.

In Addendum Routing Mode, the binary activates when `--addendum=X` is present alongside `--dp`. It validates the letter, resolves the fixed addendum intake and closing sidecar, and checks addendum artifact consistency. The base packet Changelog remains the initial exact scope. The addendum contributes only its validated exact path delta; it does not enlarge persistent policy. Every combined path must still satisfy persistent policy during postflight. RESULTS use the normal current surface and successful lineage is archived under `archives/surfaces/`.

## Anecdotal Anchor
The DP-OPS-0074 enforcement-model gap exposed ambiguity between permissive receipt scanning and strict closeout parity controls. `ops/bin/certify` addresses that class by enforcing explicit command extraction rules, strict closing-sidecar validation, and strict non-zero termination on parity failures instead of allowing discretionary operator interpretation.

## Integrity Filter Warnings
Certification stops on unknown arguments, packet mismatch against work-branch naming, missing closeout inputs, malformed packet or addendum scope, malformed persistent policy pointers, integrity failure, receipt-command failure, verification failure, invalid freshness or trace identity, unresolved template tokens, results-lint failure, or a changed path missing either required scope gate. Missing trace identity is an explicit OPEN-anchor failure. Worker narrative and surface consistency remain fail-closed. A deletion has no packet-scope bypass; only its persistent-policy check may consult committed `HEAD` while that deletion is visible.
In addendum mode, the binary additionally stops on: `--addendum` present without `--dp`; `--addendum` value that is not a single uppercase letter; missing addendum intake artifact with no fallback; or addendum SCOPE_DELTA entries containing glob or brace expansion tokens.
Certify also runs `./ops/bin/prune --target=dump --phase=report --dry-run` during postflight and appends the report to receipt evidence. This is observational closeout intelligence only; it does not authorize deletion of canonical dump-visible history.

Phase and long-pole summaries are observational only. They do not alter pass/fail semantics. Replay order and lane selection are controlled by `ops/etc/verification.manifest` plus the certify-generated changed-path file.

## Rerun Path

When `ops/bin/certify` has already completed once, reruns operate against the active draft surface `storage/dp/intake/DP.md` while preserving authoritative base packet lineage on the TASK leaf chain and authoritative addendum lineage in `archives/surfaces/ADDENDUM-DP-OPS-XXXX-<git-short-hash>.md`.

The rerun procedure is:
1. Confirm `storage/dp/intake/DP.md` exists and contains the requested `### DP-OPS-XXXX:` heading.
2. Invoke certify with fallback enabled so pointer-only TASK recovery can use the active draft source when needed: `./ops/bin/certify --dp=DP-OPS-XXXX --allow-intake-fallback --out=auto`.
3. If the active draft surface is missing or no longer matches the target packet, restore `storage/dp/intake/DP.md` first, then rerun certify.

The TASK leaf chain remains the authoritative base-packet copy, addendum leaves remain the authoritative addendum copy, and rerun ergonomics are driven by the active latest-wins draft surface rather than a packet-scoped intake filename.

No additional guarded fallback flag is implemented in this slice.
Binary-level rerun ergonomics are deferred to a future packet.
