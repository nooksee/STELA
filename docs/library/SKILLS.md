# Skills Promotion Template

> **CONTEXT HAZARD:** Skills are for production payload work only. Skills must never be added to `ops/lib/manifests/CONTEXT.md`. Skills are invoked only when a DP explicitly requests them. Logging to `docs/library/SKILLS.md` is operator-mediated and performed by worker capture during DP processing.

This file is the operator-facing promotion template for creating new S-LEARN-XX skills. Use `ops/lib/scripts/skill.sh` to append candidates and generate Promotion Packets.

## Harvest Engine workflow
- `ops/lib/scripts/skill.sh harvest` creates a draft in `storage/archives/skills/` with autonomous provenance and semantic collision checks.
- Review and refine the draft before promotion. Do not edit the Provenance block.
- `ops/lib/scripts/skill.sh promote` promotes a draft into `docs/library/skills/S-LEARN-XX.md` and registers it in `docs/library/INDEX.md`.
- `ops/lib/scripts/skill.sh check` enforces the Skills Context Hazard against `ops/lib/manifests/CONTEXT.md`.

## Promotion Packet Template
```md
### Promotion Packet: S-LEARN-XX - ENTER_SKILL_TITLE
- Candidate name: ENTER_CANDIDATE_NAME
- Proposed Skill ID: S-LEARN-XX (rule: choose the next available numeric ID not already present in docs/library/skills or registered in docs/library/INDEX.md)
- Scope: production payloads only; not platform maintenance
- Invocation guidance: ENTER_INVOCATION_GUIDANCE
- Provenance (from harvest):
  - DP-ID: ENTER_DP_ID
  - Branch: ENTER_BRANCH
  - HEAD: ENTER_HEAD
  - Objective: ENTER_OBJECTIVE
  - Friction Context: ENTER_FRICTION_CONTEXT
  - Diff Stat: ENTER_DIFF_STAT
- Drift preventers:
  - Stop conditions: ENTER_STOP_CONDITIONS
  - Anti-hallucination: Use repo files as SSOT and stop if required inputs are missing
  - Negative check: Do not add Skills to ops/lib/manifests/CONTEXT.md
- Definition of Done:
  - S-LEARN-XX created under docs/library/skills and matches scope and drift preventers
  - docs/library/INDEX.md updated with a stable topic key and correct path
  - SoP.md updated if canon or governance surfaces changed
  - Proof bundle updated in storage/handoff with diff outputs
- Verification (capture command output in RESULTS):
  - ./ops/bin/dump --scope=platform
  - bash tools/lint/context.sh
  - bash tools/lint/truth.sh (required when canon or governance surfaces change)
  - bash tools/lint/library.sh
  - bash tools/verify.sh
```

## Promotion Packets (generated from candidates)

## Candidate Log (append-only)
Append new candidates using `ops/lib/scripts/skill.sh`. Each entry must be timestamped and include Name, Context, Solution, plus a pointer to the generated Promotion Packet.

## Promotion Log (append-only)
Append entries are added by `ops/lib/scripts/skill.sh promote` and record completed promotions.
