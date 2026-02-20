<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/factory.sh` exists to enforce PoT.md Section 1.2 Reuse-first and Drift axioms for definition lifecycle operations. Agent, task, and skill scripts all write canonical leaves and pointer heads; a shared library is required so packet attribution, frontmatter shape, redaction rules, and pointer rewrite behavior stay coherent across all promotion paths.

## Mechanics and Sequencing
1. `redact_stream` scrubs common credential signatures from stdin before any artifact write path commits content to disk.
2. Trace and packet helpers (`generate_trace_id`, `resolve_trace_id`, `trace_suffix_from_id`, `resolve_packet_id`) derive canonical metadata tokens for deterministic leaf naming.
3. Head-pointer helpers (`read_factory_head_value`, `normalize_previous_head_value`, `update_factory_head_value`) read and rewrite `candidate:` and `promotion:` pointers in factory ledger files and fail hard if keys are absent.
4. `emit_head_leaf_from_source` builds YAML frontmatter (`trace_id`, `packet_id`, `created_at`, `previous`), strips leading frontmatter from source content, redacts output, writes a new archive leaf, then rewrites the selected head pointer.
5. `slugify`, `is_placeholder_value`, and `read_task_field` normalize identifiers and detect unresolved placeholder tokens before templating steps.
6. `render_definition_template` maps template paths to renderer keys (`agent`, `task`, `skill`), writes slot tokens to a temp file, calls `ops/bin/template render`, and aborts on render failure.

## Anecdotal Anchor
PoW entry `2026-02-20 01:49:20 UTC — DP-OPS-0077 Structured Fission of Tier 1 Binaries` records a split where factory and template routing were centralized and then checked with parity and lint gates. That history matches the exact risk this script contains: without one shared lifecycle implementation, formatting and state drift appears across promotion flows and later requires cross-surface repair work.

## Integrity Filter Warnings
- `FACTORY_HEAD_FILE`, `REPO_ROOT`, and `TEMPLATE_BIN` must be initialized by the caller; missing values trigger hard exits.
- Head rewrites and leaf writes are not wrapped in a transaction, so an interrupted run can leave partially advanced lifecycle state.
- Leaf filenames include trace-derived suffixes; collisions abort execution and require operator intervention before retry.
- `read_task_field` returns `Not provided` when placeholder tokens are present, so callers that assume real values can emit weak provenance text unless they revalidate inputs.
