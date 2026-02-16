# Template and Stance Constraints Manifest

## Section 1: Universal Template Rules
- Templates are authored as `.tpl` files and may begin with YAML frontmatter.
- Frontmatter keys are canonical and machine-read:
  - `template_type`
  - `template_id`
  - `template_version`
  - `requires_slots`
  - `includes`
- Rendered output must strip YAML frontmatter before writing output.
- Slot tokens are `\{\{TOKEN\}\}` where `TOKEN` is uppercase alphanumeric with underscores.
- Include directives are supported in template body content:
  - `\{\{@include:path\}\}`
  - `\{\{@include:path#section\}\}`
- Include resolution is deterministic and strict:
  - Missing files fail render.
  - Missing section anchors fail render.
  - Circular include graphs fail render.
- Strict mode is default for worker-facing output:
  - Every `requires_slots` token must be provided.
  - Unresolved `\{\{TOKEN\}\}` placeholders fail render.
- Non-strict mode is allowed only for linting and normalization workflows.
- Generated worker-facing surfaces must remain pointer-first and must not embed disposable artifacts.

## Section 2: Stance and Operator Prompt Rules
- Operator stances must be reference-first and avoid duplicated canon payloads.
- Prompt surfaces should reference this manifest for shared constraints instead of re-embedding rule bodies.
- Stances must preserve their output contracts (PASS/FAIL forms, DP code-block rules, and STOP behavior).
- Ambiguity, missing required inputs, or unverifiable path claims require STOP behavior.
- Prompts must not require pasting OPEN/DUMP/manifest payloads into DP content.

## Section 3: Definition-Specific Rules
- Definition templates (`agent`, `task`, `skill`) inherit Section 1 universal render rules.
- Definitions must keep canon references pointer-first (`PoT.md`, governance pointers, TASK contract pointers).
- Definitions must not duplicate constitutional prose; they reference canon instead.
- Definition drafts must remain compatible with existing harvester/promotion lint gates.
- Definitions must preserve closeout and verification routing expectations.
