<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Assembly Policy Manifest

## Parse Contract
`ops/lib/scripts/bundle.sh` reads this file only when ATS triplet flags are provided.
Missing required keys or invalid values are fail-closed errors.

assembly_schema_version=1
required_fields=agent_id,skill_id,task_id

registry_agents_path=docs/ops/registry/agents.md
registry_skills_path=docs/ops/registry/skills.md
registry_tasks_path=docs/ops/registry/tasks.md

agent_id_pattern=^R-AGENT-[0-9]{2}$
skill_id_pattern=^S-LEARN-[0-9]{2}$
task_id_pattern=^B-TASK-[0-9]{2}$

advisory_input_stela_path=STELA.md
advisory_input_scaffold_path=SCAFFOLD.md
advisory_inputs_mode=optional_non_gating
advisory_minimum_clean_cycles=2

## Contract Notes
- ATS input is all-or-none at runtime: `agent_id`, `skill_id`, and `task_id` are required together.
- Validation source is registry IDs in the configured registry paths.
- `STELA.md` and `SCAFFOLD.md` are advisory-only in this phase; absence does not block bundle emission.
