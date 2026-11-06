<!-- CCD: ff_target="discovery" ff_band="30-50" -->
# Ops Kernel (Run)

## Purpose
Under the Filing Doctrine, `ops/` is Run: the executable logic, manifests, and automation that turn the Policy of Truth into action and hold the platform boundary. Documentation explains and justifies; ops runs.

## Structure
- `ops/bin/`: the binaries. The Context Bundler (`ops/bin/llms`) compiles canonical and supporting surfaces into session bundles under the context hazard rules; the Workflow Bundler (`ops/bin/bundle`) emits handoff artifacts that bind OPEN freshness, dump pointers, stance text, and routing for the planning, draft, audit, addenda, and project profiles.
- `ops/lib/scripts/`: shared shell libraries; `ops/lib/manifests/`: compiled context manifests; `ops/src/`: templates, stances, and runbook adapters; `ops/etc/`: policy manifests.
- `ops/src/runbook/`: Operator-deployed external runtime adapters. They are deployment assets, not constitutional canon and not repo-executed binaries.

## Entry Point
`./ops/bin/help <term>` locates operational guidance and prioritizes the specs and registries under `docs/ops/`; `./ops/bin/help --test` proves the help surfaces resolve.

## Constraints
New operational capability ships as executable logic with a registry entry and a spec pointer. External runtime adapters are the exception: they are Operator-deployed runbook assets, they still carry a registry entry and a spec pointer, and they never redefine repository correctness.

## Canonical Pointer
The registries under `docs/ops/registry/` are the record of what exists: `binaries.md`, `lint.md`, `test.md`, `tools.md`, `scripts.md`, `hooks.md`, `workflows.md`, `runbook.md`, `templates.md`, and `decisions.md`. The specifications under `docs/ops/specs/` are grouped by executable surface: `binaries/`, `tools/lint/`, `tools/test/`, `scripts/`, `hooks/`, `workflows/`, `runbook/`, plus `definitions/`, `surfaces/`, `manifests/`, and `stances/`.

## Where to Look Next
- `docs/MANUAL.md` for the operator workflow that drives these binaries.
- `docs/CONTEXT.md` for the context engine and its hazard rules.
- `docs/DESIGN.md` for the Correct-by-Construction discipline every tool change answers to.
