<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
The draft binary is required to generate canonical DP structure deterministically so worker execution is driven by a machine-validated contract rather than ad hoc manual packet formatting.

## Mechanics and Sequencing
Parse required DP arguments and slot inputs, enforce clean-state and template-hash preconditions, render the DP via ops/bin/template render dp, write intake copy, and replace the active DP block in TASK section 3.

## Anecdotal Anchor
Earlier packet preparation repeatedly drifted when DP structure was hand-authored; draft exists to remove structural variance and keep section ordering stable under task lint.

## Integrity Filter Warnings
The command fails hard on dirty tree, missing required slots, malformed TASK structure, or template-hash mismatch; do not bypass these gates except under explicit operator override for controlled recovery.