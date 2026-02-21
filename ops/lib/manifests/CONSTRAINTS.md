<!-- CCD: ff_target="machine-dense" ff_band="10-20" -->
# Constraints Manifest

## Section 1: Universal Template Rules
- Template source uses `tpl` files with optional YAML frontmatter
- Canon frontmatter keys: `template_type` `template_id` `template_version` `requires_slots` `includes`
- Renderer strips frontmatter before output write
- Slot token form `\{\{TOKEN\}\}` with uppercase alphanumeric underscore
- Include forms `\{\{@include:path\}\}` and `\{\{@include:path#section\}\}`
- Include resolution is strict: missing file fail missing section fail circular graph fail
- Strict mode default: every required slot value present and no unresolved token
- Non strict mode allowed only for lint and normalization workflows
- Worker facing generated surfaces remain pointer first and exclude disposable artifacts

## Section 2: Stance and Operator Prompt Rules
- Operator stances are reference first
- Shared constraints use manifest pointers and avoid canon duplication
- PASS FAIL outputs DP code block rules and STOP behavior are preserved
- Ambiguity missing required inputs or unverifiable paths require STOP
- Prompt surfaces do not require OPEN DUMP or manifest payload paste

## Section 3: Definition-Specific Rules
- `agent` `task` and `skill` templates inherit Section 1 rules
- Definitions keep canonical pointers and avoid constitutional prose duplication
- Definition drafts remain compatible with harvest and promotion lint gates
- Definitions preserve closeout and verification routing requirements
