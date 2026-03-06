<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Surface Specification: ASSEMBLY Manifest

## Constitutional Anchor
`ops/lib/manifests/ASSEMBLY.md` is the ATS schema SSOT for bundle-runtime validation when ATS triplet flags are provided.
It defines required ATS fields, validation sources, and advisory-input status for `STELA.md` and `SCAFFOLD.md`.

## Operator Contract
- Surface path: `ops/lib/manifests/ASSEMBLY.md`.
- Runtime consumer: `ops/lib/scripts/bundle.sh`.
- Linked from bundle policy via `assembly_policy_manifest` key in `ops/lib/manifests/BUNDLE.md`.
- Required keys:
  - `assembly_schema_version`
  - `required_fields`
  - `registry_agents_path`
  - `registry_skills_path`
  - `registry_tasks_path`
  - `agent_id_pattern`
  - `skill_id_pattern`
  - `task_id_pattern`
  - `advisory_input_stela_path`
  - `advisory_input_scaffold_path`
  - `advisory_inputs_mode`
  - `advisory_minimum_clean_cycles`

## Mechanics and Sequencing
1. Bundle runtime loads `ops/lib/manifests/BUNDLE.md`.
2. Bundle runtime resolves `assembly_policy_manifest` and loads `ops/lib/manifests/ASSEMBLY.md`.
3. When ATS flags are provided, runtime enforces:
   - all-or-none ATS flags,
   - field pattern checks,
   - canonical ID existence checks against registry IDs.
4. On ATS success, bundle manifest emits `assembly` metadata with schema version, IDs, validation sources, and advisory-input status.
5. On ATS failure, runtime exits non-zero before artifact emission.

## Failure States and Drift Triggers
- Missing required assembly policy keys.
- Invalid ATS regex patterns or malformed numeric schema keys.
- Missing registry source files.
- Runtime accepting partial ATS flag sets.
- Runtime emitting bundle artifacts when ATS validation fails.
- Promotion of advisory inputs (`STELA.md`, `SCAFFOLD.md`) to hard gates in this phase.

## Integrity Filter Warnings
`STELA.md` and `SCAFFOLD.md` are advisory-only in this phase and must remain non-gating. Their presence status may be emitted in bundle manifest metadata, but absence must not block bundle generation.
