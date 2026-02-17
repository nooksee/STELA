# Technical Specification: ops/lib/scripts/skill.sh

## Purpose
Manage skill draft harvest, promotion, and context-hazard checks for the skill lifecycle.

## Invocation
- Command forms:
  - `ops/lib/scripts/skill.sh harvest [--name "..."] [--context "..."] [--solution "..."] [--context-stdin | --solution-stdin] [--force]`
  - `ops/lib/scripts/skill.sh promote <draft_path> [--delete-draft]`
  - `ops/lib/scripts/skill.sh check`
  - Legacy: `ops/lib/scripts/skill.sh "name" "context" "solution"`
- Required flags:
  - None for harvest, but missing fields trigger prompts (TTY) or hard failures (non-TTY) unless auto-filled.
- Expected exit behavior:
  - `0` on successful command completion.
  - Non-zero for missing files, invalid options, collision checks, or validation failures.

## Inputs
- Canon and ledger files:
  - `opt/_factory/SKILLS.md`
  - `docs/ops/registry/SKILLS.md`
  - `TASK.md`
  - `ops/lib/manifests/CONTEXT.md`
- Skill directories:
  - `opt/_factory/skills/`
  - `archives/definitions/`
- Optional sourced heuristics from `ops/lib/scripts/heuristics.sh`.

## Outputs
- `harvest`: writes redacted draft to `archives/definitions/`.
- Harvested drafts include unified schema front-matter keys: `trace_id`, `packet_id`, `created_at`, `previous`.
- `promote`: writes promoted skill file under `opt/_factory/skills/`, inserts registry row in `docs/ops/registry/SKILLS.md`, and appends candidate/promotion packet logs in `opt/_factory/SKILLS.md`.
- `check`: prints context-hazard check result.

## Invariants and failure modes
- Context hazard rule forbids skill references in `ops/lib/manifests/CONTEXT.md`.
- Promotion validates required draft sections and rejects placeholder markers.
- Skill IDs are allocated as next available `S-LEARN-XX` across skill files and registry.
- Semantic-collision detection can block harvest unless overridden with `--force`.
- TraceID resolution order for harvest is strict: `STELA_TRACE_ID` environment value first, then latest OPEN artifact parse, then local fallback generation.
- `previous` points to the latest prior `archives/definitions/skill-*.md` leaf for the same slug, or `(none)` when the draft is the origin leaf.

## Related pointers
- Registry entry: `docs/ops/registry/SCRIPTS.md` (`SCRIPT-04`).
- Skill registry: `docs/ops/registry/SKILLS.md`.
- Heuristics dependency: `ops/lib/scripts/heuristics.sh`.
