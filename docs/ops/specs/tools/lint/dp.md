<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`tools/lint/dp.sh` enforces DP transaction immutability so a packet cannot drift from canonical structure, allowlist contract, or closeout routing requirements. The gate protects PoT Section 1.2 axioms, especially Drift and SSOT, by proving that a packet is structurally equivalent to the canonical DP template and that declared scope pointers are valid before certification.

## Mechanics and Sequencing
1. Resolve repository root, emit telemetry, and enforce canonical template hash parity for `ops/src/surfaces/dp.md.tpl`.
2. Resolve input mode (`--test`, explicit path, stdin, or default `TASK.md`), including TASK pointer-head resolution and DP block extraction when the source is a TASK surface. Explicit addendum intake artifacts (`DP-OPS-XXXX-ADDENDUM-A.md`) dispatch to `lint_addendum_intake()` instead of DP structure hashing.
3. For DP payloads, run a provisional-marker `PROPOSED` scan as the first `lint_payload()` check before template-hash verification and structural validation. The scan normalizes each line to a candidate value (trimmed line, bullet value, or field value suffix after `:`), reports each matching line number and full offending line to stderr, and exits non-zero only when the candidate matches a provisional-marker form (`^PROPOSED-[A-Za-z0-9/._-]+$`) or begins with a bare provisional prefix (`^PROPOSED `). The scan must not fail when the word `PROPOSED` appears only as prose that describes the feature.
4. Run foreign citation contamination scan against DP body text. Reject the first line containing `:contentReference[` with a deterministic line-number failure.
5. Render canonical DP in non-strict mode, normalize both canonical and payload structures, hash both normalized forms, and fail on mismatch.
6. Validate required fields and section blocks, including heading ID/title shape, base branch metadata, scoped load-order content, plan slots, and receipt slot non-placeholder content.
7. Enforce receipt dump-selection scoping in Section 3.4.5: packets `DP-OPS-0095` and newer fail if any `ops/bin/dump` command omits `--selection=dp` or `--selection=dp+allowlist`; older packets emit a grandfathered warning only.
8. Enforce allowlist pointer integrity: exactly one pointer entry, canonical pointer path match, allowlist file existence, entry normalization, runtime-prefix restrictions, wildcard policy constraints, and repository reachability checks.
9. For RESULTS paths, delegate validation to `tools/lint/results.sh` and propagate its exit code. RESULTS schema enforcement is sourced from the canonical template plus narrative field checks.
10. In `--test` mode, execute fixture-driven negative and positive checks that exercise template-hash drift, structure mismatch, allowlist-pointer mismatch, allowlist-file invalidity, narrowed `PROPOSED` provisional-marker detection, foreign citation contamination detection, and delegated RESULTS validation coverage (valid fixture and deterministic invalid fixture).
11. Enforce mandatory receipt-command shape in `3.4.5`: verify canonical mandatory command lines are present and fail deterministically when missing.
12. Enforce closing-sidecar non-prepopulation in `3.5.1`: reject architect payloads that provide non-empty values for canonical sidecar fields.
13. Enforce include-metadata leakage guard in DP payload bodies: fail on first line containing `<!-- CCD:` or a raw frontmatter delimiter line `---`.

### PROPOSED Provisional-Marker Scan Fixtures (`--test`)
`dp.sh --test` must cover all three `PROPOSED` scan outcome classes introduced by DP-OPS-0112 addendum ADD-DP-OPS-0112-001:

1. **Clean fixture (PASS):** no provisional-marker forms are present.
2. **Real provisional marker (FAIL):** a fixture line contains an unfinalized branch-style value such as `PROPOSED-work/...`, which must fail.
3. **Prose-only `PROPOSED` (PASS):** a fixture line contains the word `PROPOSED` as feature-description prose without a provisional-marker form, which must pass.

### Closeout and Coherence Fixtures (`--test`)
`dp.sh --test` must include deterministic fixtures for contract-shape hardening:

1. **Non-canonical closeout phrase (FAIL):** inject `- Route to contractor ...` into §3.5 and require failure.
2. **Work-branch coherence mismatch (FAIL):** heading id and `Required Work Branch` id fragment disagree and must fail.
3. **Closing-sidecar coherence mismatch (FAIL):** heading id and §3.5.1 `CLOSING-DP-OPS-XXXX.md` id fragment disagree and must fail.

### Mandatory Receipt Command Shape and Sidecar Pre-population Fixtures (`--test`)
`dp.sh --test` must include deterministic fixtures for residual T1.1 hardening:

1. **Missing mandatory receipt command (FAIL):** a `3.4.5` fixture omits a canonical mandatory command and must fail.
2. **Pre-populated `3.5.1` sidecar field (FAIL):** a fixture sets `Commit Message: <value>` and must fail.
3. **Canonical pass path (PASS):** canonical fixture with full mandatory command set and blank sidecar fields must pass both checks.

### Include Metadata Leakage Fixtures (`--test`)
`dp.sh --test` must include deterministic leakage fixtures for T1.2 include-boundary hygiene:

1. **CCD header leakage (FAIL):** appending `<!-- CCD: ... -->` to a canonical fixture must fail full `lint_path` invocation.
2. **Frontmatter delimiter leakage (FAIL):** appending raw delimiter line `---` to a canonical fixture must fail full `lint_path` invocation.
3. **Canonical clean payload (PASS):** canonical fixture with no leaked metadata must pass contamination and include-metadata checks.

### Freshness Stamp and Receipt Command Substitution Checks
`lint_payload()` runs two certify-compatibility checks immediately after `check_dump_selection_scope()`:

1. `check_freshness_stamp_format()`: extracts `Freshness Stamp`, trims and dequotes it, skips blank or placeholder values (handled by existing required-field checks), and fails unless the value matches `^[0-9]{4}-[0-9]{2}-[0-9]{2}$`.
2. `check_receipt_command_substitution()`: extracts Section `3.4.5`, scans receipt command bullet lines, and fails on any command line containing the `$(` token because certify replay requires literal commands.

### Packet Coherence and Closeout Shape Checks
`lint_payload()` runs two deterministic contract checks after freshness and receipt-command checks:

1. `check_dp_packet_coherence()`:
   - derives heading packet id from the first `### DP-...:` line,
   - requires `Required Work Branch` to include the lowercase packet-id fragment (for example `DP-OPS-0176` -> `dp-ops-0176`),
   - requires a canonical closing-sidecar path token in §3.5.1 (`storage/handoff/CLOSING-DP-OPS-XXXX.md`),
   - fails when heading id and closing-sidecar id disagree.
2. `check_closeout_section_shape()`:
   - extracts §3.5 body content (between `## 3.5` and `### 3.5.1`),
   - fails when §3.5 is empty,
   - fails on non-canonical role-routing shortcut phrases such as `Route to ...`, `Hand off to ...`, `Pass to ...`, or `Send to ...`.

## Foreign Citation Contamination Guard

### Trigger token
`dp.sh` scans DP payload lines for the substring `:contentReference[`.

### Runtime behavior
- On first match:
  - Emit `FAIL: dp: contamination: line <N>: <line content>`.
  - Exit non-zero for the payload lint run.
- On clean payload:
  - Emit `PASS: dp: contamination: no foreign citation tokens detected`.

### `--test` fixture requirements
- Contaminated fixture includes `:contentReference[oaicite:0]{index=0}` and must fail both direct guard invocation and full `lint_path` invocation.
- Clean fixture with no contamination token must pass direct guard invocation and full `lint_path` invocation.

## Anecdotal Anchor
DP-OPS-0074 exposed an enforcement-model gap where no-argument receipt scanning and explicit certification mode did not share identical hash-parity behavior. That gap allowed a RESULTS artifact to pass without full parity enforcement, and the repair cycle introduced explicit mode-sensitive parity logic plus stricter RESULTS schema checks.

## Integrity Filter Warnings
Template hash constants are hard-coded; any legitimate template change requires synchronized constant updates or lint will fail every packet. Delegated results lint behavior in `tools/lint/results.sh` is mode-sensitive by design: explicit path mode enforces strict `Git Hash` parity, while historical scan modes report parity skips without blocking. Dump-selection scope enforcement is grandfathered for packets before `DP-OPS-0095`, so warning-only output on older archived packets is expected until a separate migration rewrites legacy receipt commands. Allowlist validation accepts selected generated-surface wildcard families and closing-sidecar patterns, so policy expansion mistakes in that branch can widen scope unintentionally.

## Addendum Intake

### Validation Rules (`lint_addendum_intake()`)
`lint_addendum_intake()` validates a standalone addendum intake artifact. It enforces the following rules in order:

1. **Required slots present:** `BASE_DP_ID`, `ADDENDUM_ID`, `OPERATOR_AUTHORIZATION`, `SCOPE_DELTA`, `ADDENDUM_OBJECTIVE`, and `ADDENDUM_RECEIPT` must each resolve to a non-empty value from the rendered addendum intake labels and sections. A missing or blank slot is a hard failure.
2. **OPERATOR_AUTHORIZATION is not a placeholder:** The value is tested with the existing `contains_placeholder()` helper. Any value matching the placeholder pattern (TBD, TODO, XXXX, `{{`, and related forms) is a hard failure.
3. **BASE_DP_ID matches the canonical pattern:** The value must match `^DP-OPS-[0-9]{4}$` exactly. Any deviation is a hard failure.
4. **ADDENDUM_ID matches the canonical pattern:** The value must match `^[A-Z]$` exactly. Any deviation is a hard failure.
5. **SCOPE_DELTA contains only exact paths:** Each non-blank line in the `SCOPE_DELTA` block must contain no glob characters (`*`, `?`, `[`, `]`), no brace expansion characters (`{`, `}`), and no internal whitespace. Any violation is a hard failure.

### Operator Authorization Incantation Format
The canonical operator authorization statement used in an addendum session must follow this exact phrase structure:

> Operator authorizes Addendum A to DP-OPS-XXXX. Scope expansion delta: [exact paths]. Generate addendum intake with `./ops/bin/draft --addendum=A --base-dp=DP-OPS-XXXX`.

The verbatim text of this statement, as it appears in the session record, is the value placed in the `OPERATOR_AUTHORIZATION` slot. A contractor must not proceed with addendum execution until this authorization line exists in the session.

### `--test` Mode Addendum Hash Emission
`dp.sh --test` emits the `CANONICAL_ADDENDUM_TEMPLATE_SHA256` constant value on a labeled line immediately after the base DP hash constant line. Both constants must be present and match the on-disk template files for `--test` to pass.
