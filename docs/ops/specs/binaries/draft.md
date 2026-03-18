<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/draft` exists to prevent manual DP structure drift and to enforce PoT Section 4.2 generation rules for packet structure. It protects TASK structural invariants by generating the packet body from canonical template slots, then replacing only the active DP block in Section 3.

## Mechanics and Sequencing
The binary supports three modes.

In base DP generation mode, it parses required DP identity arguments and required slot content inputs, optionally loads slot blocks from a slots file, and enforces non-empty content for each required slot. It enforces clean-tree execution unless `DRAFT_ALLOW_DIRTY_TREE=1`, reads canonical template constants from `tools/lint/dp.sh`, validates canonical DP template hash parity, and verifies TASK contains exactly one Section 3 heading and exactly one active DP heading. TASK checks and replacement logic are pointer-aware: when `TASK.md` is a single-line head pointer, `draft` resolves the archived TASK surface, checks the resolved body, and reports both the source path (`TASK.md`) and resolved surface path in guard-failure diagnostics. It renders DP content through `ops/bin/template render dp`, refreshes the operator-facing latest-wins draft surface at `storage/dp/intake/DP.md`, and rewrites the active DP block in `TASK.md` while preserving surrounding TASK content.

In Addendum Generation Mode, the binary activates when `--addendum=X` and `--base-dp=DP-OPS-XXXX` are both present, rejects either flag when the other is absent, requires `--slots-file=PATH`, validates `--addendum` as a single uppercase letter `A` through `Z`, and validates `--base-dp` against the `DP-OPS-XXXX` pattern. It enforces the same clean-tree rule (with the same `DRAFT_ALLOW_DIRTY_TREE=1` override), reads and verifies the canonical addendum template hash constant from `tools/lint/dp.sh`, and confirms the requested base packet is available either from the active draft surface (`storage/dp/intake/DP.md` with matching heading) or from `storage/dp/processed/DP-OPS-XXXX.md`. It renders the addendum intake through `ops/bin/template render addendum` to `storage/dp/intake/ADDENDUM.md` using the provided slots file plus binary-supplied slot overrides for `BASE_DP_ID` and `ADDENDUM_ID`, renders a closing sidecar scaffold through `ops/bin/template render closing` to `storage/handoff/CLOSING.md`, writes the closing `DP_ID` slot as `DP-OPS-XXXX Addendum A`, and prints both output paths.

In scaffold assist mode, the binary activates when any scaffold flags are present:
- `--emit-plan-scaffold=PATH`
- `--emit-dp-slots-scaffold=PATH`
- `--edit-scaffold`
- `--load-scaffold-file=PATH`
- `--scaffold-editor=COMMAND`
- `--validate-plan-scaffold=PATH`
- `--validate-dp-slots-scaffold=PATH`

Assist mode is mutually exclusive with base DP and addendum generation flags. It uses helper functions from `ops/lib/scripts/editor.sh` to emit canonical scaffolds, optionally ingest edited scaffold content non-interactively, optionally invoke an editor interactively, and validate scaffold content deterministically. Validation enforces required headings/blocks, placeholder rejection, untouched-instruction-line rejection, and repo-relative path policy. Assist mode is additive and does not mutate `TASK.md` or DP surfaces.

Required addendum slots-file tokens are:
- `OPERATOR_AUTHORIZATION`
- `SCOPE_DELTA`
- `ADDENDUM_OBJECTIVE`
- `ADDENDUM_RECEIPT`

## Anecdotal Anchor
During the DP-OPS-0065 immutable workflow cutover, hand-authored packet sections repeatedly diverged in ordering and required headings, which triggered packet lint failures and reruns. `ops/bin/draft` was introduced to remove packet-shape variance by forcing canonical generation before execution.

## Integrity Filter Warnings
`ops/bin/draft` exits on dirty trees, missing required arguments, malformed packet IDs, missing required slot content, missing slots file, template hash mismatch, malformed TASK Section 3 structure, or inability to locate the active DP heading for replacement. For TASK marker-count and active-heading replacement guards, failure output now includes a named guard condition plus `task_source_path` and `task_resolved_path` (and observed/expected counts where applicable) so pointer-first TASK failures are deterministic to recover.

Addendum mode adds hard-stop exits for missing `--base-dp` when `--addendum` is present, missing `--addendum` when `--base-dp` is present, missing `--slots-file` in addendum mode, invalid addendum letter values, invalid base packet IDs, and missing base packet intake artifacts in both intake and processed storage.

Assist mode adds hard-stop exits for mixed mode usage, ambiguous edit/ingest target selection, missing emit target when `--edit-scaffold` or `--load-scaffold-file` is provided, and any scaffold validation failure (including untouched scaffold instruction prose). Assist mode validates content deterministically and leaves TASK untouched.
