<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/agent.sh` enforces a single lifecycle path for agent definitions so role creation, validation, and promotion stay aligned with PoT.md Section 4.1 staffing boundaries and Section 1.2 SSOT drift controls. The script exists to prevent direct edits to agent definitions and registries that bypass lint gates, pointer ledgers, and provenance metadata.

## Mechanics and Sequencing
1. Entry dispatch:
   - `harvest`: create candidate agent leaf.
   - `harvest-check`: print Pattern Density clusters from recent SoP history.
   - `promote`: validate candidate and materialize canonical agent.
   - `check`: run guardrail checks on existing agent canon.
2. `harvest` sequence:
   - Require `--name` and `--dp`.
   - Resolve OPEN and dump paths from most recent artifacts unless explicit `--open` or `--dump` is provided.
   - Derive objective from `TASK.md` when omitted.
   - Build provenance block through `heuristics.sh`.
   - Resolve `packet_id` and `trace_id`, read current `candidate:` pointer, compute `previous`, and derive candidate leaf path.
   - Normalize `--skill` and `--skills` values into canonical `opt/_factory/skills/S-LEARN-XX.md` pointers.
   - Render `ops/src/definitions/agent.md.tpl` through `ops/bin/template`, redact output, write archive leaf, and rewrite `candidate:` pointer in `opt/_factory/AGENTS.md`.
3. `harvest-check` sequence:
   - Read recent SoP entries.
   - Extract verification-tool and pointer tokens per entry.
   - Cluster by tool/pointer sets and require at least three distinct DPs per cluster.
   - Propose name and specialization strings, then run semantic collision checks against existing/draft agents.
4. `promote` sequence:
   - Resolve draft path explicitly or by latest timestamp.
   - Enforce draft schema sections, required pointers, non-placeholder specialization, and valid DP-ID.
   - Apply `context_hazard_check` and `pot_duplication_linter`.
   - Allocate next `R-AGENT-XX` identifier from canon files plus registry state.
   - Rewrite draft into promoted agent form (header rewrite, `Context Sources` strip), write canonical file, insert registry row, emit promotion leaf, and rewrite `promotion:` pointer.
5. `check` sequence:
   - Verify each canonical agent includes `## Scope Boundary`.
   - Reject any agent that points into agent-definition directories, which would create recursive context hazards.

## Anecdotal Anchor
SoP entry `2026-02-10 16:52:29 UTC — DP-OPS-0042 Agent System Certification and Harvester Hardening` documents a recertification pass that synchronized registry state and hardened the harvester for Pattern Density role emergence. That historical remediation reflects the same drift pattern this script now blocks: manual lifecycle edits produced role and registry skew before promotion and validation logic was centralized.

## Integrity Filter Warnings
- Concurrent `promote` executions can race on `next_agent_id` and registry insertion because no lock file is used.
- Promotion has no rollback transaction; if failure occurs after canonical agent write but before leaf or pointer rewrite, partial state remains.
- Auto-selection of OPEN and dump artifacts fails hard when multiple files share identical newest timestamps.
- `context_hazard_check` only enforces run-length limits for list items outside selected sections; semantic quality of those lists remains caller-dependent.
