Primary Commit Header (plaintext)
DP-OPS-0074 normalize factory head chains and definition leaf promotion wiring

Pull Request Title (plaintext)
DP-OPS-0074 normalize factory head chains and definition leaf promotion wiring

Pull Request Description (markdown)
Scope Summary
Normalized opt/_factory/AGENTS.md, opt/_factory/TASKS.md, and opt/_factory/SKILLS.md into four-line pointer heads with explicit candidate and promotion entry points.
Migrated definition registry guidance into docs/ops/specs/definitions/agents.md, docs/ops/specs/definitions/tasks.md, and docs/ops/specs/definitions/skills.md, then wired discovery through docs/INDEX.md and docs/MANUAL.md.
Updated ops/lib/scripts/agent.sh, ops/lib/scripts/task.sh, and ops/lib/scripts/skill.sh to emit schema-stamped candidate and promotion leaves under archives/definitions/ and advance head pointers instead of append-only ledger sections.
Updated tools/lint/factory.sh and tools/verify.sh to enforce head shape and six-entry-point reachability checks.
Aligned script and tool specs plus script registry documentation with pointer-head behavior.

Notable Risks and Mitigations
Factory head drift risk is mitigated by strict four-line key-order validation in tools/lint/factory.sh.
Pointer rot risk is mitigated by reachability checks in both tools/lint/factory.sh and tools/verify.sh.
Leaf schema drift risk is mitigated by preserving unified front-matter keys for candidate and promotion emissions.

Follow-ups and Deferred Work
Evaluate whether a shared shell helper for head-pointer parsing should be extracted for lifecycle scripts.
Consider adding a dedicated lint for docs/ops/specs/definitions/agents.md, docs/ops/specs/definitions/tasks.md, and docs/ops/specs/definitions/skills.md pointer examples and sentinel consistency.

Operator Routing Notes
Review certify-generated RESULTS output and ensure no non-allowlisted tracked files were modified before commit.

Final Squash Stub (plaintext) (Must differ from #1)
Implement pointer-first factory chains with candidate and promotion reachability enforcement

Extended Technical Manifest (plaintext)
docs/INDEX.md
docs/MANUAL.md
docs/ops/registry/SCRIPTS.md
docs/ops/specs/scripts/agent.md
docs/ops/specs/scripts/task.md
docs/ops/specs/scripts/skill.md
docs/ops/specs/tools/lint/factory.md
docs/ops/specs/tools/verify.md
docs/ops/specs/definitions/agents.md
docs/ops/specs/definitions/tasks.md
docs/ops/specs/definitions/skills.md
ops/lib/scripts/agent.sh
ops/lib/scripts/task.sh
ops/lib/scripts/skill.sh
tools/lint/factory.sh
tools/lint/skill.sh
tools/verify.sh
storage/dp/active/allowlist.txt

Review Conversation Starter (markdown)
Do you want the factory head key-order check to stay strict and ordered, or should it allow key reordering while preserving the same four required keys
