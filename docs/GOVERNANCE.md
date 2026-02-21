<!-- CCD: ff_target="governance-narrative" ff_band="50-65" -->
# Governance (Pointer-First)

## 0. Purpose
This file is a pointer. Canonical governance lives in PoT.md.

## 1. Canon Pointers
PoT.md is the constitutional source for staffing, jurisdiction, and enforcement rules.
SoP.md records operational history and the reason each governance move was taken.
TASK.md defines the active contract that constrains current execution scope and proofs.
docs/MAP.md provides continuity routing so state reload remains stable across sessions.

## 2. Enforcement Pointers
Governance is enforced by binaries and linters, not narrative text.
`ops/bin/open` establishes session freshness and branch state before work starts.
`tools/lint/context.sh` enforces required context membership and hazard exclusions.
`tools/lint/style.sh` and `tools/lint/truth.sh` keep language precision and canon spelling stable.
`tools/verify.sh` enforces filing doctrine boundaries so structural drift fails immediately.
This enforcement chain keeps governance measurable, because tooling emits hard evidence for each pass or fail state.

## 3. Reader Orientation
This surface is for the operator who needs a fast and reliable governance check.
The reader should confirm what is true, what is proven, and what is unresolved.
If a claim is in prose but not in receipts, the claim does not pass review.
If a path is changed and scope is unclear, the change does not pass review.
When scope, proof, and policy agree, the reviewer can close with confidence.
This pattern keeps governance practical because each rule maps to a visible check.

## 4. Drift Resolution
If this file conflicts with PoT.md, stop and follow PoT.md.
