# Dispatch Packet Protocol

## Purpose
Canonize the Dispatch Packet (DP) as the operator-facing Work Order for ICL.

## Scope
Applies to all worker assignments that require a formal work order.

## Verification
- Not run (operator): confirm DP requirements and metadata surfaces.

## Risk+Rollback
- Risk: inconsistent work orders or missing metadata.
- Rollback: revert to the previous dispatch format.

## Canon Links
- ops/templates/DISPATCH_PACKET_TEMPLATE.md
- ops/init/manifests/OUTPUT_MANIFEST.md
- ops/contracts/OUTPUT_FORMAT_CONTRACT.md

## Definition
A DP (Dispatch Packet) is the authoritative, operator-authored work order delivered to a Worker.
It defines scope, constraints, and outputs so the Worker can execute without guessing.

## Required sections
- Branch
- Role + non-negotiables
- Scope + forbidden zones
- Objective
- Tasks
- Verification (commands to run)
- Required outputs back to operator
- No commit/push

## Required delivery format
- The DP must be delivered inside a fenced code block for copy/paste safety.

## Required metadata surfaces
Every DP must include all metadata surfaces:
- IDE commit subject line
- PR title
- PR markdown description
- Merge commit subject
- Merge commit extended description
- Merge-note comment
