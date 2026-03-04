<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/bin/addendum` exists to prevent hand-authored addendum intake drift and to preserve addendum issuance authority boundaries during post-work audit. It renders addendum artifacts from the canonical `ops/src/stances/addendum.md.tpl` template, assigns the next addendum letter automatically, and rejects incomplete or placeholder slot content before writing to `storage/dp/intake/`.

## Mechanics and Sequencing
1. Parse required arguments `--base-dp=DP-OPS-XXXX` and `--slots-file=PATH`, reject unknown arguments, and validate `--base-dp` against the canonical packet ID pattern.
2. Verify the slots file exists and is readable, then read canonical addendum template path and hash constants from `tools/lint/dp.sh` and fail on hash-parity mismatch.
3. Confirm the base DP exists in `storage/dp/processed/` by matching at least one file with the prefix `storage/dp/processed/<BASE_DP_ID>*.md`.
4. Scan `storage/dp/intake/` for existing addenda matching `<BASE_DP_ID>-ADDENDUM-[A-Z].md` and select the first available letter from `A` through `Z`.
5. Render the addendum through `ops/bin/template render addendum` using the provided slots file and binary-supplied slot overrides for `BASE_DP_ID` and `ADDENDUM_ID`.
6. Validate the rendered output before write: `BASE_DP_ID` and `ADDENDUM_ID` must match the computed values, required addendum sections must be non-empty and non-placeholder, and command substitution tokens (`$(`) are rejected.
7. Emit the rendered artifact to stdout as the preview, then write the identical content to `storage/dp/intake/<BASE_DP_ID>-ADDENDUM-<LETTER>.md` and print the output path.

### Invocation Syntax
~~~bash
./ops/bin/addendum --base-dp=DP-OPS-XXXX --slots-file=<path>
~~~

### Arguments
- `--base-dp`: Canonical base packet identifier. Must match `^DP-OPS-[0-9]{4}$`.
- `--slots-file`: Path to a slots sidecar consumed by `ops/bin/template render addendum`. The file must exist and be readable.

### Output Path Schema
`storage/dp/intake/<BASE_DP_ID>-ADDENDUM-<LETTER>.md`

### Required Slots
The rendered output must contain populated, non-placeholder content for:
- `BASE_DP_ID`
- `ADDENDUM_ID`
- `OPERATOR_AUTHORIZATION`
- `SCOPE_DELTA`
- `ADDENDUM_OBJECTIVE`
- `ADDENDUM_RECEIPT`

### Slot Validation Rules
`BASE_DP_ID` and `ADDENDUM_ID` are enforced from the binary's computed values and must round-trip in the rendered artifact. The remaining required sections are extracted from rendered addendum labels/blocks and rejected when blank or when placeholder tokens are detected (for example `TODO`, `TBD`, `{{...}}`, or replacement markers).

### Next-Letter Auto-Assignment Logic
The binary checks `storage/dp/intake/` for existing addenda for the base packet and assigns the first unused uppercase letter in lexical order (`A` to `Z`). If all letters are exhausted, the binary exits with an error and writes nothing.

### Error Conditions
Hard-stop errors include: missing required arguments, malformed `--base-dp`, unreadable or missing slots file, missing canonical template or template hash mismatch, base DP absent from `storage/dp/processed/`, no addendum letters available, required rendered slot content missing or placeholder, rendered identity mismatch, command substitution tokens in output, and write failures.

### Role Restriction and Manual Relationship
`ops/bin/addendum` is an Integrator/foreman issuance tool used during the `docs/MANUAL.md` Closeout Cycle Post-Work Audit step when an authorized addendum is required. The Contractor does not invoke this binary and does not author addendum content.

## Anecdotal Anchor
Repeated certify-compatibility remediations in consecutive DPs showed that late-session structural fixes need an auditable intake-generation path that does not depend on hand-authored markdown. `ops/bin/addendum` applies the same template-first discipline used by `ops/bin/draft` to the addendum issuance path.

## Integrity Filter Warnings
The binary relies on the addendum template hash constant in `tools/lint/dp.sh`; legitimate template edits require synchronized constant updates. It intentionally writes only to `storage/dp/intake/` and rejects command substitution text in the rendered output to preserve certify literal replay compatibility.
