# Technical Specification: ops/lib/scripts/heuristics.sh

## Purpose
Provide reusable git-driven heuristic functions for provenance generation and semantic-collision detection.

## Invocation
- This file is a sourced function library, not a command entrypoint.
- Source form:
  - `source ops/lib/scripts/heuristics.sh`
- Primary function forms:
  - `detect_hot_zone [base_ref] [head_ref] [repo_root]`
  - `detect_high_churn [base_ref] [head_ref] [repo_root]`
  - `generate_provenance_block <dp_id> <objective> [base_ref] [head_ref] [repo_root]`
  - `check_semantic_collision <title> <skills_dir> [drafts_dir]`
  - `check_agent_collision <title> <agents_dir> [drafts_dir]`
- Expected exit behavior:
  - Function return code communicates success/failure to caller.
  - Collision checks return non-zero when threshold matches are detected.

## Inputs
- Git history and diff output for selected refs.
- Candidate title strings.
- Existing skill or agent markdown directories for keyword overlap checks.

## Outputs
- Functions print derived data to stdout (`None`, file lists, markdown provenance blocks).
- Writes no files directly.

## Invariants and failure modes
- `detect_hot_zone` and `detect_high_churn` degrade to `None` when no data is found.
- `generate_provenance_block` always emits a markdown `## Provenance` block, including diff stat.
- Collision checks normalize titles, remove stop words, and enforce minimum keyword overlap thresholds.

## Related pointers
- Registry entry: `docs/ops/registry/SCRIPTS.md` (`SCRIPT-02`).
- Consumers: `ops/lib/scripts/agent.sh`, `ops/lib/scripts/skill.sh`, `ops/lib/scripts/task.sh`.
