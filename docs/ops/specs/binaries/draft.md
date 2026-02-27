<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/draft` exists to prevent manual DP structure drift and to enforce PoT Section 4.2 generation rules for packet structure. It protects TASK structural invariants by generating the packet body from canonical template slots, then replacing only the active DP block in Section 3.

## Mechanics and Sequencing
The binary supports two modes. In base DP generation mode, it parses required DP identity arguments and required slot content inputs, optionally loads slot blocks from a slots file, and enforces non-empty content for each required slot. It enforces clean-tree execution unless `DRAFT_ALLOW_DIRTY_TREE=1`, reads canonical template constants from `tools/lint/dp.sh`, validates canonical DP template hash parity, and verifies TASK contains exactly one Section 3 heading and exactly one active DP heading. TASK checks and replacement logic are pointer-aware: when `TASK.md` is a single-line head pointer, `draft` resolves the archived TASK surface, checks the resolved body, and reports both the source path (`TASK.md`) and resolved surface path in guard-failure diagnostics. It renders DP content through `ops/bin/template render dp`, writes the intake packet to `storage/dp/intake/<DP>.md`, and rewrites the active DP block in `TASK.md` while preserving surrounding TASK content.

In Addendum Generation Mode, the binary activates when `--addendum=X` and `--base-dp=DP-OPS-XXXX` are both present, rejects either flag when the other is absent, requires `--slots-file=PATH`, validates `--addendum` as a single uppercase letter `A` through `Z`, and validates `--base-dp` against the `DP-OPS-XXXX` pattern. It enforces the same clean-tree rule (with the same `DRAFT_ALLOW_DIRTY_TREE=1` override), reads and verifies the canonical addendum template hash constant from `tools/lint/dp.sh`, and confirms a base packet intake artifact exists at `storage/dp/intake/DP-OPS-XXXX.md` before falling back to `storage/dp/processed/DP-OPS-XXXX.md`. It renders the addendum intake through `ops/bin/template render addendum` to `storage/dp/intake/DP-OPS-XXXX-ADDENDUM-A.md` using the provided slots file plus binary-supplied slot overrides for `BASE_DP_ID` and `ADDENDUM_ID`, renders a closing sidecar scaffold through `ops/bin/template render closing` to `storage/handoff/CLOSING-DP-OPS-XXXX-ADDENDUM-A.md`, writes the closing `DP_ID` slot as `DP-OPS-XXXX Addendum A`, and prints both output paths.

Required addendum slots-file tokens are:
- `OPERATOR_AUTHORIZATION`
- `SCOPE_DELTA`
- `ADDENDUM_OBJECTIVE`
- `ADDENDUM_RECEIPT`

## Anecdotal Anchor
During the DP-OPS-0065 immutable workflow cutover, hand-authored packet sections repeatedly diverged in ordering and required headings, which triggered packet lint failures and reruns. `ops/bin/draft` was introduced to remove packet-shape variance by forcing canonical generation before execution.

## Integrity Filter Warnings
`ops/bin/draft` exits on dirty trees, missing required arguments, malformed packet IDs, missing required slot content, missing slots file, template hash mismatch, malformed TASK Section 3 structure, or inability to locate the active DP heading for replacement. For TASK marker-count and active-heading replacement guards, failure output now includes a named guard condition plus `task_source_path` and `task_resolved_path` (and observed/expected counts where applicable) so pointer-first TASK failures are deterministic to recover. Addendum mode adds hard-stop exits for missing `--base-dp` when `--addendum` is present, missing `--addendum` when `--base-dp` is present, missing `--slots-file` in addendum mode, invalid addendum letter values, invalid base packet IDs, and missing base packet intake artifacts in both intake and processed storage. Targeted success tails now return success explicitly to avoid shell tail-status leakage; acceptance and rejection semantics are unchanged.
