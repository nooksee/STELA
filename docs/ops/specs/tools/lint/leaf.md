<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
leaf lint enforces telemetry wiring consistency so in-scope binaries and lint/test scripts emit lifecycle leaves required for traceable execution history.

## Mechanics and Sequencing
Enumerate tracked ops/bin files (excluding deprecated project binary) and tracked shell tools under tools/lint and tools/test, then fail if any target lacks an emit_binary_leaf invocation.

## Anecdotal Anchor
Execution trace gaps repeatedly complicated incident reconstruction; this lint exists to prevent new scripts from bypassing telemetry emission patterns.

## Integrity Filter Warnings
Coverage scope is path-based and string-match based; refactors that rename or indirect telemetry calls can trigger false negatives unless lint logic is updated in lockstep.