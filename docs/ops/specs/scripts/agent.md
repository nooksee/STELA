# Technical Specification: ops/lib/scripts/agent.sh

## Purpose
Manage agent candidate harvesting, promotion, and guardrail checks for canon agent lifecycle workflows.

## Invocation
- Command forms:
  - `ops/lib/scripts/agent.sh harvest --name "..." --dp "DP-OPS-XXXX" [--specialization "..."] [--summary "..."] [--skill S-LEARN-01] [--skills S-LEARN-01,S-LEARN-02] [--open PATH] [--dump PATH] [--objective "..."]`
  - `ops/lib/scripts/agent.sh harvest-check`
  - `ops/lib/scripts/agent.sh promote <draft_path> [--delete-draft]`
  - `ops/lib/scripts/agent.sh check`
- Required flags:
  - `harvest` requires `--name` and `--dp`.
- Expected exit behavior:
  - `0` on successful command completion.
  - Non-zero on missing required inputs, validation failures, or unknown options.

## Inputs
- Canon and registry files:
  - `SoP.md`
  - `TASK.md`
  - `ops/lib/manifests/CONTEXT.md`
  - `docs/ops/registry/AGENTS.md`
  - `opt/_factory/AGENTS.md`
- Agent files in `opt/_factory/agents/`.
- OPEN and DUMP artifact directories for auto-selection:
  - `storage/handoff/`
  - `storage/dumps/`
- Optional heuristic functions from `ops/lib/scripts/heuristics.sh`.

## Outputs
- `harvest`: writes redacted draft under `archives/definitions/` and appends candidate log in `opt/_factory/AGENTS.md`.
- `harvest-check`: prints Pattern Density report from recent SoP entries.
- `promote`: writes canon agent file in `opt/_factory/agents/`, inserts registry row in `docs/ops/registry/AGENTS.md`, and appends promotion log in `opt/_factory/AGENTS.md`.
- `check`: prints guardrail status for scope-boundary and context-hazard checks.

## Invariants and failure modes
- Draft validation requires specific sections and required pointers (`PoT.md`, `docs/GOVERNANCE.md`, `TASK.md`, JIT skills).
- Promotion enforces context-hazard and PoT-duplication lint checks before writing canon files.
- Agent IDs are allocated as next available `R-AGENT-XX` value across files and registry.
- Auto-selected OPEN/DUMP artifacts must be unambiguous by timestamp; ties are hard failures.

## Related pointers
- Registry entry: `docs/ops/registry/SCRIPTS.md` (`SCRIPT-01`).
- Agent registry: `docs/ops/registry/AGENTS.md`.
- Heuristics dependency: `ops/lib/scripts/heuristics.sh`.
