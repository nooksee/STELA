<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Runtime Inventory Report Test

## First Principles Rationale
The runtime inventory is an evidence surface. Its regression test proves that the repository can expose current runtime, registry, specification, verification-policy, router, consumer, and metadata facts without silently assigning lifecycle meaning or changing repository state.

## Mechanics and Sequencing
1. Run `bash tools/verify.sh --inventory` twice from the repository root.
2. Require both invocations to exit successfully and produce byte-identical output.
3. Require exactly eight inventory-family summaries.
4. Assert the current known mismatch baseline for binaries, tests, and templates.
5. Assert representative registered, unregistered, unused, and metadata-incomplete evidence rows.
6. Require the report to declare lifecycle decisions `0` and repository mutations `0`.

## Invocation Modes
- `bash tools/test/inventory.sh`

The test uses only repository-local scratch below `var/tmp/_smoke/` and removes that scratch on exit.

## Integrity Filter Warnings
The asserted mismatch counts describe the current inspected baseline; they do not promote findings into retirement decisions. Any inventory change must update the implementation, this regression contract, and the relevant registry or specification through an independently authorized change. A passing test grants lifecycle, retirement, deletion, or registry-correction authority `0` times.
