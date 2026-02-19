# Technical Specification: ops/lib/scripts/agent.sh

## Purpose
Manage agent candidate harvesting, promotion, and guardrail checks while advancing factory pointer heads.

## Invocation
- Command forms:
  - `ops/lib/scripts/agent.sh harvest --name "..." --dp "DP-OPS-XXXX" [--specialization "..."] [--summary "..."] [--skill S-LEARN-01] [--skills S-LEARN-01,S-LEARN-02] [--open PATH] [--dump PATH] [--objective "..."]`
  - `ops/lib/scripts/agent.sh harvest-check`
  - `ops/lib/scripts/agent.sh promote <draft_path> [--delete-draft]`
  - `ops/lib/scripts/agent.sh check`
- Required flags:
  - `harvest` requires `--name`.
  - `harvest` requires DP provenance via `--dp` or `STELA_PACKET_ID`.
- Exit behavior:
  - `0` on success.
  - Non-zero on missing inputs, validation failures, or pointer-head rewrite errors.

## Inputs
- `opt/_factory/AGENTS.md` pointer head.
- `docs/ops/registry/AGENTS.md` registry table.
- `ops/src/definitions/agent.md.tpl` definition template.
- `TASK.md`, `SoP.md`, and `ops/lib/manifests/CONTEXT.md`.

## Outputs
- `harvest` emits candidate leaf at `archives/definitions/agent-candidate-YYYY-MM-DD-<suffix>.md` and rewrites `candidate:` in `opt/_factory/AGENTS.md`.
- `promote` writes canonical agent file in `opt/_factory/agents/`, updates `docs/ops/registry/AGENTS.md`, emits promotion leaf at `archives/definitions/agent-promotion-YYYY-MM-DD-<suffix>.md`, and rewrites `promotion:` in `opt/_factory/AGENTS.md`.
- `harvest-check` prints Pattern Density clusters.
- `check` prints scope-boundary and context-hazard results.

## Invariants and failure modes
- Candidate and promotion leaves always include unified schema front-matter keys: `trace_id`, `packet_id`, `created_at`, `previous`.
- `previous` is `(none)` when prior head value ends with `-(origin)`; otherwise it is the prior head pointer path.
- `trace_id` uses `STELA_TRACE_ID` when provided and falls back to local generation.
- `packet_id` uses `STELA_PACKET_ID` when provided and falls back to DP input.
- Promotion enforces draft validation, context hazard checks, and PoT duplication linting before writes.
- Pointer-head rewrite is a hard gate; missing `candidate:` or `promotion:` lines fail the command.

## Related pointers
- Factory head spec: `docs/ops/specs/definitions/agents.md`.
- Registry entry: `docs/ops/registry/SCRIPTS.md` (`SCRIPT-01`).
- Agent registry: `docs/ops/registry/AGENTS.md`.
