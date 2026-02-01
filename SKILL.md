# Skills Promotion Template (Root)

> **CONTEXT HAZARD:** Skills are for production payload work only. Skills must never be added to `ops/lib/manifests/CONTEXT.md`. Skills are invoked only when a DP explicitly requests them. Logging to `SKILL.md` is operator-mediated and performed by worker capture during DP processing.

This file is the operator-facing promotion template for creating new S-LEARN-XX skills. Use `ops/lib/skill/skill_lib.sh` to append candidates and generate Promotion Packets.

## Candidate Log (append-only)
Append new candidates using `ops/lib/skill/skill_lib.sh`. Each entry must be timestamped and include Name, Context, Solution, plus a pointer to the generated Promotion Packet.

- 2026-02-01 05:29:25 UTC - [Promotion Packet](#promotion-packet-s-learn-06)
  - Name: dp-ops-0010-lesson
  - Context: Captured lesson learned from DP-OPS-0010 work
  - Solution: Concrete guidance to avoid recurrence or improve speed/quality
## Promotion Packet Template
```md
### Promotion Packet: S-LEARN-XX - ENTER_SKILL_TITLE
- Candidate name: ENTER_CANDIDATE_NAME
- Proposed Skill ID: S-LEARN-XX (rule: choose the next available numeric ID not already present in docs/library/skills or registered in docs/library/INDEX.md)
- Scope: production payloads only; not platform maintenance
- Invocation guidance: ENTER_INVOCATION_GUIDANCE
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
  - bash tools/context_lint.sh
  - bash tools/lint_truth.sh (required when canon or governance surfaces change)
  - bash tools/lint_library.sh
  - bash tools/verify_tree.sh
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
  - bash tools/context_lint.sh
  - bash tools/lint_truth.sh (required when canon or governance surfaces change)
  - bash tools/lint_library.sh
  - bash tools/verify_tree.sh
