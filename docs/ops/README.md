<!-- CCD: ff_target="operator-technical" ff_band="30-40" -->
# Ops Kernel (Run)

## 0. Philosophy
**Ops is the runtime kernel.**
Under the Filing Doctrine, `ops/` is Run: executable logic, manifests, and automation that enforce the Policy of Truth and the platform boundary.

## 1. Architecture
The Ops Kernel is the executable layer that turns governance into action. It owns binaries, shared scripts, and manifests that drive platform behavior. Runtime logic belongs in `ops/` and `tools/` with pointer-first documentation in `docs/ops/`.

## 2. Core Subsystems
Context Bundler (`ops/bin/llms`) compiles canonical and supporting surfaces into session bundles while enforcing context hazard exclusion rules.

Workflow Bundler (`ops/bin/bundle`) emits deterministic handoff artifacts that bind OPEN freshness state, dump pointers, prompt stance text, and routing metadata for Analyst, Architect, Audit, and Project profiles.

## 3. Registries
The authoritative operational registries live in `docs/ops/registry/`.

- `docs/ops/registry/prompts.md`
- `docs/ops/registry/binaries.md`
- `docs/ops/registry/lint.md`
- `docs/ops/registry/test.md`
- `docs/ops/registry/tools.md`
- `docs/ops/registry/scripts.md`
- `docs/ops/registry/hooks.md`

## 4. Specifications
Technical specifications are pointer-first and grouped by executable surface.

- Binary specs: `docs/ops/specs/binaries/`
- Tool specs: `docs/ops/specs/tools/`
- Script specs: `docs/ops/specs/scripts/`
- Hook specs: `docs/ops/specs/hooks/`

## 5. Interface Contract
The Ops Kernel is the executable companion to docs. Documentation explains and justifies; ops runs. New operational capability must ship as executable logic with a registry entry and spec pointer.

## 6. Help and Discovery
Use `./ops/bin/help <term>` to locate operational guidance. `./ops/bin/help` prioritizes specs and registry surfaces under `docs/ops/`.
