# Technical Specification: ops/bin/template

## Constitutional Anchor
`ops/bin/template` is the canonical renderer for `.tpl` surfaces and definitions.
It enforces metadata-aware rendering, include safety, and strict slot validation for worker-facing outputs.

## Operator Contract
- Invocation:
  - `./ops/bin/template render <dp|results|task-surface|agent|task|skill> --out=PATH [options]`
- Template lookup map:
  - `dp` -> `ops/src/surfaces/dp.md.tpl`
  - `results` -> `ops/src/surfaces/results.md.tpl`
  - `task-surface` -> `ops/src/surfaces/task.md.tpl`
  - `agent` -> `ops/src/definitions/agent.md.tpl`
  - `task` -> `ops/src/definitions/task.md.tpl`
  - `skill` -> `ops/src/definitions/skill.md.tpl`
- YAML frontmatter support:
  - Parses metadata keys: `template_type`, `template_id`, `template_version`, `requires_slots`, `includes`.
  - Frontmatter is stripped from render output.
- Slot inputs:
  - `--slots-file=PATH` with `[TOKEN]` block sections.
  - `--slot=TOKEN=VALUE` repeatable overrides.
  - DP convenience flags (`--id`, `--title`, `--base-branch`, `--work-branch`, `--base-head`, `--freshness-stamp`).
- Include directives:
  - `{{@include:path}}` for full file include.
  - `{{@include:path#section}}` for heading-scoped include extraction.
- Output:
  - `--out=PATH` required.
  - `--out=-` writes to stdout.

## Validation Modes
- Strict mode (default):
  - Every `requires_slots` entry must be present and non-empty.
  - Unresolved `{{TOKEN}}` placeholders fail render.
- Non-strict mode (`--non-strict`):
  - Allows unresolved placeholders.
  - Still enforces include resolution, file existence checks, section validity, and cycle safety.

## Failure States and Drift Triggers
- Unknown render target key.
- Missing template file.
- Unclosed or malformed frontmatter.
- Missing slots file or invalid slot token names.
- Missing include target file.
- Missing include section anchor.
- Circular include dependency graph.
- Missing required slots in strict mode.
- Unresolved token placeholders in strict mode.

## Mechanics and Sequencing
1. Resolve template key to canonical `.tpl` path.
2. Parse YAML frontmatter and strip it from output body.
3. Validate metadata-declared include references.
4. Expand in-body include directives recursively.
5. Load slots (`--slots-file`, then explicit `--slot` overrides).
6. Apply token substitution across rendered body.
7. Enforce strict/non-strict unresolved-token policy.
8. Write deterministic output to the requested destination.
