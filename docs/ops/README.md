# Ops Kernel (Run)

## 0. Philosophy
**Ops is the runtime kernel.**
Under the Filing Doctrine, `ops/` is Run: executable logic, manifests, and automation that enforce the Policy of Truth and the platform boundary.

## 1. Architecture
The Ops Kernel is the executable layer that turns governance into action. It owns binaries, shared scripts, and manifests that drive platform behavior. Runtime logic belongs in `ops/` and `tools/` with pointer-first documentation in `docs/ops/`.

## 2. Core Subsystems
Context Bundler (`ops/bin/llms`) compiles canonical and supporting surfaces into session bundles while enforcing context hazard exclusion rules.

Project Factory (`ops/bin/project`) orchestrates project intake and lifecycle alignment through registry-driven templates and validation helpers.

## 3. Registries
The authoritative operational registries live in `docs/ops/registry/`.

- `docs/ops/registry/PROMPTS.md`
- `docs/ops/registry/BINARIES.md`
- `docs/ops/registry/LINT.md`
- `docs/ops/registry/TEST.md`
- `docs/ops/registry/TOOLS.md`
- `docs/ops/registry/SCRIPTS.md`

## 4. Specifications
Technical specifications are pointer-first and grouped by executable surface.

- Binary specs: `docs/ops/specs/binaries/`
- Tool specs: `docs/ops/specs/tools/`
- Script specs: `docs/ops/specs/scripts/`

## 5. Interface Contract
The Ops Kernel is the executable companion to docs. Documentation explains and justifies; ops runs. New operational capability must ship as executable logic with a registry entry and spec pointer.

## 6. Help and Discovery
Use `./ops/bin/help <term>` to locate operational guidance. `./ops/bin/help` prioritizes specs and registry surfaces under `docs/ops/`.
