<!-- CCD: ff_target="operator-technical" ff_band="45-60" -->
<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
`ops/lib/scripts/factory.sh` enforces shared lifecycle behavior for definition candidate/promotion flows. Agent, task, and skill scripts all write canonical leaves and pointer heads; the shared library keeps attribution, frontmatter shape, redaction, and pointer rewrites deterministic across chains.

## Mechanics and Sequencing
1. `redact_stream` scrubs common credential signatures from stdin before artifact writes.
2. Trace/packet helpers derive canonical metadata tokens for deterministic leaf naming.
3. Head-pointer helpers read and rewrite `candidate:` and `promotion:` pointers and fail hard if keys are absent.
4. `emit_head_leaf_from_source` builds frontmatter (`trace_id`, `packet_id`, `created_at`, `previous`), strips source frontmatter, redacts output, writes archive leaf, and rewrites the selected head pointer.
5. `slugify`, placeholder checks, and task field readers normalize identifiers and reject unresolved placeholders before render.
6. `render_definition_template` maps template paths to renderer keys (`agent`, `task`, `skill`), writes slot tokens, calls `ops/bin/template render`, and aborts on render failure.

## F2 Contract Baseline Interaction
Factory lifecycle helpers are schema-agnostic at render time. F2 baseline conformance is enforced post-render by `tools/lint/factory.sh` and reflected in definition specs/registries.

## Integrity Filter Warnings
- `FACTORY_HEAD_FILE`, `REPO_ROOT`, and `TEMPLATE_BIN` must be initialized by caller; missing values hard-fail.
- Head rewrites and leaf writes are not transactional; interruption can leave partially advanced lifecycle state.
- Leaf filename collisions abort execution and require operator intervention before retry.
