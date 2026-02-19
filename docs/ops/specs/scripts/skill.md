# Technical Specification: ops/lib/scripts/skill.sh

## Purpose
Manage skill candidate harvesting, promotion, and context hazard checks while advancing factory pointer heads.

## Invocation
- Command forms:
  - `ops/lib/scripts/skill.sh harvest [--name "..."] [--context "..."] [--solution "..."] [--context-stdin | --solution-stdin] [--force]`
  - `ops/lib/scripts/skill.sh promote <draft_path> [--delete-draft]`
  - `ops/lib/scripts/skill.sh check`
  - Legacy positional alias: `ops/lib/scripts/skill.sh "name" "context" "solution"`.
- Exit behavior:
  - `0` on success.
  - Non-zero on collisions, validation failures, pointer rewrite failures, or registry update failures.

## Inputs
- `opt/_factory/SKILLS.md` pointer head.
- `docs/ops/registry/SKILLS.md` registry table.
- `ops/src/definitions/skill.md.tpl` definition template.
- `TASK.md` and `ops/lib/manifests/CONTEXT.md`.

## Outputs
- `harvest` emits candidate leaf at `archives/definitions/skill-candidate-YYYY-MM-DD-<suffix>.md` and rewrites `candidate:` in `opt/_factory/SKILLS.md`.
- `promote` writes canonical skill file in `opt/_factory/skills/`, updates `docs/ops/registry/SKILLS.md`, emits promotion leaf at `archives/definitions/skill-promotion-YYYY-MM-DD-<suffix>.md`, and rewrites `promotion:` in `opt/_factory/SKILLS.md`.
- `check` enforces the Skills Context Hazard rule.

## Invariants and failure modes
- Candidate and promotion leaves always include unified schema front-matter keys: `trace_id`, `packet_id`, `created_at`, `previous`.
- `previous` is `(none)` when prior head value ends with `-(origin)`; otherwise it is the prior head pointer path.
- `trace_id` uses `STELA_TRACE_ID` when provided and falls back to local generation.
- `packet_id` uses `STELA_PACKET_ID` when provided and falls back to current DP detection from `TASK.md`.
- Promotion validates required draft sections and placeholder guards before writes.
- Legacy positional invocation routes through harvest behavior and does not append packet logs into `opt/_factory/SKILLS.md`.

## Related pointers
- Factory head spec: `docs/ops/specs/definitions/skills.md`.
- Registry entry: `docs/ops/registry/SCRIPTS.md` (`SCRIPT-05`).
- Skill registry: `docs/ops/registry/SKILLS.md`.
