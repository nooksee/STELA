# Skills Promotion Template

This file is the operator-facing promotion template for creating new S-LEARN-XX skills. Use `ops/lib/scripts/skill.sh` to append candidates and generate Promotion Packets.

## Harvest Engine workflow
- `ops/lib/scripts/skill.sh harvest` creates a draft in `storage/archives/skills/` with autonomous provenance and semantic collision checks.
- Review and refine the draft before promotion. Do not edit the Provenance block.
- `ops/lib/scripts/skill.sh promote` promotes a draft into `opt/_factory/skills/S-LEARN-XX.md` and registers it in `opt/_factory/INDEX.md`.
- `ops/lib/scripts/skill.sh check` enforces the Skills Context Hazard against `ops/lib/manifests/CONTEXT.md`.

## Promotion Packet Template
- SSOT template: `ops/src/definitions/skill.md.tpl`
- Rendered by: `ops/lib/scripts/skill.sh harvest`
- This ledger is pointer-only; executable template bodies live under `ops/src/definitions/`.

## Promotion Packets (generated from candidates)

## Candidate Log (append-only)
Append new candidates using `ops/lib/scripts/skill.sh`. Each entry must be timestamped and include Name, Context, Solution, plus a pointer to the generated Promotion Packet.

## Promotion Log (append-only)
Append entries are added by `ops/lib/scripts/skill.sh promote` and record completed promotions.
