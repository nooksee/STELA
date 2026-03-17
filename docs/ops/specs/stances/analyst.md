<!-- CCD: ff_target="operator-technical" ff_band="30-45" -->
# Technical Specification: ops/src/stances/analyst.md.tpl

## Purpose
Define the template-backed Analyst stance body used by bundle output contract rendering.

## Invocation
- Render path: `ops/bin/manifest render stance-analyst --out=-`
- Runtime consumer: `ops/lib/scripts/bundle.sh`

## Inputs
- Template source: `ops/src/stances/analyst.md.tpl`
- Shared include source: `ops/src/shared/stances.json#stance_shared_rules`
- Shared include source: `ops/src/shared/stances.json#single_fence_contract_rules`
- Shared include source: `ops/src/shared/stances.json#non_audit_role_drift_rules`

## Outputs
- Rendered stance body text beginning at `Rules:`.
- No unresolved include directives.
- Machine-ingest analyst mode requires attached `storage/handoff/TOPIC.md` and has no inline-query fallback.
- Machine-ingest analyst mode outputs exactly one fenced markdown code block.
- Default analyst behavior is discussion mode and writes analyst output to `PLAN.md`.
- Output surface: `storage/handoff/PLAN.md` is the latest-wins model output, overwritten on each analyst run.
- Safety backup: bundle writes a disposable copy of the prior `storage/handoff/PLAN.md` to `var/tmp/PLAN.md.prev` before each run so the previous good output survives a failed or bad-output model run. This backup is a scratch artifact only; no downstream tooling depends on it.
- Explicit plan-output mode is available only when the attached topic explicitly asks for a plan, DP plan, architect handoff, or plan-only output.
- Default analyst mode first non-empty line inside the fenced body must start with `1. Analysis and Discussion`.
- Default analyst mode includes `2. Strategic Options` and one `Recommendation:` line.
- Default analyst mode targets exactly three options when the topic is actionable enough to support them.
- Default analyst mode ends with `Questions / Conversation:` when clarification, tradeoff choice, or confirmation would help.
- Explicit plan-output mode emits only a complete `PLAN.md` draft.
- Explicit plan-output mode first non-empty line inside the fenced body must start with `# DP Plan:`.
- Machine-ingest analyst mode must not add repository-operating details, workflow examples, command families, or GitHub action lists unless they are directly visible in the attached artifacts.
- Machine-ingest analyst mode keeps repo-specific claims generic and high-level rather than converting thin evidence into specific operating facts.
- Explicit plan-output mode uses the smallest reasonable inference for required handoff fields and does not let inference read as established repository fact.
- Default analyst mode treats weak or ambiguous topics conservatively, states assumptions, and asks concise follow-up questions instead of forcing a plan-only artifact.
- Default analyst mode stops truthfully and asks for clarification when topic text is nonsensical or non-actionable.

## Invariants and failure modes
- Include expansion is strict and fail-closed.
- Unresolved template tokens fail render in strict mode.
- Render output is deterministic for identical repository state.

## Related pointers
- `ops/lib/manifests/BUNDLE.md`
- `ops/lib/scripts/bundle.sh`
- `ops/src/stances/analyst.md.tpl`
