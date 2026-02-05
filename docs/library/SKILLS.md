# Skills Promotion Template

> **CONTEXT HAZARD:** Skills are for production payload work only. Skills must never be added to `ops/lib/manifests/CONTEXT.md`. Skills are invoked only when a DP explicitly requests them. Logging to `docs/library/SKILLS.md` is operator-mediated and performed by worker capture during DP processing.

This file is the operator-facing promotion template for creating new S-LEARN-XX skills. Use `ops/lib/scripts/skill.sh` to append candidates and generate Promotion Packets.

## Harvest Engine workflow
- `ops/lib/scripts/skill.sh harvest` creates a draft in `storage/handoff/` with autonomous provenance and semantic collision checks.
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
<a id="promotion-packet-s-learn-06"></a>
### Promotion Packet: S-LEARN-06 - dp-ops-0010-lesson
- Candidate name: dp-ops-0010-lesson
- Proposed Skill ID: S-LEARN-06 (rule: choose the next available numeric ID not already present in docs/library/skills or registered in docs/library/INDEX.md)
- Scope: production payloads only; not platform maintenance
- Invocation guidance: Use this skill when Captured lesson learned from DP-OPS-0010 work. Apply the solution: Concrete guidance to avoid recurrence or improve speed/quality.
- Drift preventers:
  - Stop conditions: Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill
  - Anti-hallucination: Use repo files as SSOT and stop if required inputs are missing
  - Negative check: Do not add Skills to ops/lib/manifests/CONTEXT.md
- Definition of Done:
  - S-LEARN-06 created under docs/library/skills and matches scope and drift preventers
  - docs/library/INDEX.md updated with a stable topic key and correct path
  - SoP.md updated if canon or governance surfaces changed
  - Proof bundle updated in storage/handoff with diff outputs
- Verification (capture command output in RESULTS):
  - ./ops/bin/dump --scope=platform
  - bash tools/lint/context.sh
  - bash tools/lint/truth.sh (required when canon or governance surfaces change)
  - bash tools/lint/library.sh
  - bash tools/verify.sh

<a id="promotion-packet-s-learn-07"></a>
### Promotion Packet: S-LEARN-07 - Harvest and Promote Skills at DP Closeout
- Candidate name: Harvest and Promote Skills at DP Closeout
- Proposed Skill ID: S-LEARN-07 (rule: choose the next available numeric ID not already present in docs/library/skills or registered in docs/library/INDEX.md)
- Scope: production payloads only; not platform maintenance
- Invocation guidance: Use this skill when a DP explicitly requests Harvest and Promote Skills at DP Closeout. Apply the solution as documented in docs/library/skills/S-LEARN-07.md.
- Drift preventers:
  - Stop conditions: Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill
  - Anti-hallucination: Use repo files as SSOT and stop if required inputs are missing
  - Negative check: Do not add Skills to ops/lib/manifests/CONTEXT.md
- Definition of Done:
  - S-LEARN-07 created under docs/library/skills and matches scope and drift preventers
  - docs/library/INDEX.md updated with a stable topic key and correct path
  - SoP.md updated if canon or governance surfaces changed
  - Proof bundle updated in storage/handoff with diff outputs
- Verification (capture command output in RESULTS):
  - ./ops/bin/dump --scope=platform
  - bash tools/lint/context.sh
  - bash tools/lint/truth.sh (required when canon or governance surfaces change)
  - bash tools/lint/library.sh
  - bash tools/verify.sh
<a id="promotion-packet-s-learn-08"></a>
### Promotion Packet: S-LEARN-08 - Prune SoP and Regenerate Context Bundles
- Candidate name: Prune SoP and Regenerate Context Bundles
- Proposed Skill ID: S-LEARN-08 (rule: choose the next available numeric ID not already present in docs/library/skills or registered in docs/library/INDEX.md)
- Scope: production payloads only; not platform maintenance
- Invocation guidance: Use this skill when a DP explicitly requests Prune SoP and Regenerate Context Bundles. Apply the solution as documented in docs/library/skills/S-LEARN-08.md.
- Drift preventers:
  - Stop conditions: Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill
  - Anti-hallucination: Use repo files as SSOT and stop if required inputs are missing
  - Negative check: Do not add Skills to ops/lib/manifests/CONTEXT.md
- Definition of Done:
  - S-LEARN-08 created under docs/library/skills and matches scope and drift preventers
  - docs/library/INDEX.md updated with a stable topic key and correct path
  - SoP.md updated if canon or governance surfaces changed
  - Proof bundle updated in storage/handoff with diff outputs
- Verification (capture command output in RESULTS):
  - ./ops/bin/dump --scope=platform
  - bash tools/lint/context.sh
  - bash tools/lint/truth.sh (required when canon or governance surfaces change)
  - bash tools/lint/library.sh
  - bash tools/verify.sh
## Candidate Log (append-only)
Append new candidates using `ops/lib/scripts/skill.sh`. Each entry must be timestamped and include Name, Context, Solution, plus a pointer to the generated Promotion Packet.

- 2026-02-01 05:29:25 UTC - [Promotion Packet](#promotion-packet-s-learn-06)
  - Name: dp-ops-0010-lesson
  - Context: Captured lesson learned from DP-OPS-0010 work
  - Solution: Concrete guidance to avoid recurrence or improve speed/quality

- 2026-02-01 16:26:48 UTC - [Promotion Packet](#promotion-packet-s-learn-07)
  - Name: Harvest and Promote Skills at DP Closeout
  - Context: a DP requires skill capture and a reusable workflow must be captured during closeout
  - Solution: run the harvest command to create a draft, refine it for accuracy, promote it into docs/library/skills, update docs/library/INDEX.md, and record proof in RESULTS
- 2026-02-04 16:37:16 UTC - [Promotion Packet](#promotion-packet-s-learn-08)
  - Name: Prune SoP and Regenerate Context Bundles
  - Context: a DP changes canon or context bundles and requires updated SoP pruning and llms bundle refresh
  - Solution: run ops/bin/prune, run ops/bin/llms, verify llms with tools/lint/llms.sh, run tools/lint/style.sh, and record results in RESULTS
## Promotion Log (append-only)
Append entries are added by `ops/lib/scripts/skill.sh promote` and record completed promotions.
- 2026-02-01 16:26:48 UTC - Promoted S-LEARN-07 - Harvest and Promote Skills at DP Closeout -> docs/library/skills/S-LEARN-07.md
- 2026-02-04 16:37:16 UTC - Promoted S-LEARN-08 - Prune SoP and Regenerate Context Bundles -> docs/library/skills/S-LEARN-08.md
