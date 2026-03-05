<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/certify` exists to enforce PoT Section 4.2 Generation Mandate at closeout time. The binary prevents a failure mode where receipt evidence is hand-assembled, scope checks are skipped, or proof surfaces diverge from recorded execution. It protects equilibrium maintenance by requiring deterministic receipt command execution, allowlist subset enforcement, and pointer-first surface emission for `PoW.md`, `SoP.md`, and `TASK.md`.

## Mechanics and Sequencing
`ops/bin/certify` parses `--dp`, enforces branch to packet parity, resolves output path, validates dependency binaries and lints, and validates the non-empty closing sidecar at `storage/handoff/CLOSING-<DP>.md`. It resolves the active TASK source, extracts the DP block, enforces required DP section headings, extracts the allowlist pointer and receipt commands, then prepends and de-duplicates the mandatory DP preflight commands. It writes a Contractor Execution Narrative scaffold to a temp file and routes narrative capture through `ops/lib/scripts/editor.sh`: interactive editor mode when `--narrative-file` is absent, or non-interactive file-ingest mode when `--narrative-file=PATH` is provided. It validates the resulting narrative for required subsections and placeholder/scaffold rejection before proceeding. It runs an integrity gate before command execution, executes the command plan in order, and inserts an internal Phase 2 step after the first three verification commands to emit schema-stamped surface leaves and rewrite `PoW.md`, `SoP.md`, and `TASK.md` to new archive pointers. During verification command execution, it tracks dump invocations and resolves the latest dump manifest pointer. For addendum draft verification commands (`ops/bin/draft --addendum=... --base-dp=...`), certify prepends `DRAFT_ALLOW_DIRTY_TREE=1` at execution time so the command can be replayed inside an intentionally dirty closeout session without relaxing `ops/bin/draft` global clean-tree enforcement. After command execution it runs post-command integrity and changed-file subset checks against the allowlist. It captures diff outputs, renders RESULTS via `ops/bin/template render results` with the `CONTRACTOR_NARRATIVE` slot populated from the collected narrative, and now appends `dump_manifest` in Scope Verification alongside the allowlist pointer (`none` when no dump command was present in the DP receipt section; value is disposable-reference sanitized before RESULTS render), lints RESULTS, verifies structural headings and hash parity, moves intake DP to processed storage when present, emits telemetry leaf output, and prints receipt paths.

### Contractor Execution Narrative Capture
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
- Both `Decision Required:` and `Decision Leaf:` lines are present.
- No absolute paths.

The validated narrative is passed as the `CONTRACTOR_NARRATIVE` slot to both template render invocations. The narrative appears in RESULTS under `## Contractor Execution Narrative`, and no closing sidecar block is embedded in RESULTS.

In Addendum Routing Mode, the binary activates when `--addendum=X` is present alongside `--dp`. It validates the addendum letter as a single uppercase character `A` through `Z` and requires `--dp` to be present. It resolves intake from `storage/dp/intake/DP-OPS-XXXX-ADDENDUM-A.md` with no fallback to the base DP intake; a missing addendum intake is a hard stop. It resolves the sidecar from `storage/handoff/CLOSING-DP-OPS-XXXX-ADDENDUM-A.md`. It calls `validate_addendum_artifact_path_consistency` in place of `validate_artifact_path_consistency` to check addendum-namespaced paths. After loading the base allowlist, it extracts the SCOPE_DELTA field from the addendum intake artifact and adds each path to the runtime allowlist entries additively; SCOPE_DELTA paths containing glob or brace expansion tokens are a hard stop. RESULTS are written to `storage/handoff/DP-OPS-XXXX-RESULTS-A.md`. On success, the addendum intake artifact is moved to `storage/dp/processed/DP-OPS-XXXX-ADDENDUM-A.md` mirroring base DP processed-move behavior. The telemetry leaf is tagged with addendum identity `DP-OPS-XXXX-ADDENDUM-A` in the `packet_id` field.

## Anecdotal Anchor
The DP-OPS-0074 enforcement-model gap exposed ambiguity between permissive receipt scanning and strict closeout parity controls. `ops/bin/certify` addresses that class by enforcing explicit command extraction rules, strict closing-sidecar validation, and strict non-zero termination on parity failures instead of allowing discretionary operator interpretation.

## Integrity Filter Warnings
Certification stops on unknown arguments, packet mismatch against work-branch naming, missing closing sidecar, empty closing sidecar, missing DP block in TASK when intake fallback is not explicitly authorized, malformed allowlist pointers, unsupported command substitution or glob tokens in receipt commands, integrity lint failure, any verification command failure, invalid Freshness Stamp format, missing trace identity, pointer resolution failure, unresolved template tokens in RESULTS, results lint failure, or changed files outside the allowlist. The binary sanitizes disposable artifact references in command logs, but it does not permit disposable artifact references inside DP or RESULTS surfaces. Contractor narrative validation stops certification when the narrative contains placeholder text or untouched scaffold prose, is missing required subsections, or is missing required Decision Leaf field lines.
In addendum mode, the binary additionally stops on: `--addendum` present without `--dp`; `--addendum` value that is not a single uppercase letter; missing addendum intake artifact with no fallback; or addendum SCOPE_DELTA entries containing glob or brace expansion tokens.

## Rerun Path

When `ops/bin/certify` has already completed at least one invocation and has moved the
intake packet from `storage/dp/intake/` to `storage/dp/processed/`, a rerun requires
the operator to restore the intake before invoking certify again.

The restore procedure is:
1. Copy the intake artifact from `storage/dp/processed/DP-OPS-XXXX.md` back to
   `storage/dp/intake/DP-OPS-XXXX.md`.
2. Move the processed copy to `var/tmp/DP-OPS-XXXX.pre-rerun-processed.md` to
   eliminate intake/processed coexistence.
3. Invoke certify normally: `./ops/bin/certify --dp=DP-OPS-XXXX --out=auto`.

The coexistence prohibition is a hard constraint: certify artifact path resolution is
indeterminate when the same packet exists in both `storage/dp/intake/` and
`storage/dp/processed/` simultaneously.

The full procedure with literal commands is documented in `docs/MANUAL.md`
under `### Certify Rerun (Post-Move Recovery)` in the Closeout Cycle section.

The `--reuse-processed-fallback` guarded flag is not implemented in this slice.
Binary-level rerun ergonomics are deferred to a future packet.
