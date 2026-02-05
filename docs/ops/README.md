# Ops Kernel (Run)

## 0. Philosophy
**Ops is the runtime kernel.**
Under the Filing Doctrine, `ops/` is Run: executable logic, manifests, and automation that enforce the Policy of Truth and the platform boundary.

## 1. Architecture
The Ops Kernel is the executable layer that turns governance into action. It owns the binaries, shared scripts, and manifests that drive platform behavior. It is the only place runtime logic belongs.

## 2. Core Subsystems
Context Bundler (`ops/bin/llms`) compiles the canonical and supporting surfaces into session bundles, applying context hazard exclusion rules and scope selection. It is the bridge between canon and the live session.

Project Factory (`ops/bin/project`) orchestrates project intake and lifecycle alignment. It reads the project registry and templates in `ops/lib/` to generate or validate project payloads while keeping project work within platform governance.

## 3. Interface Contract
The Ops Kernel is the executable companion to docs. Documentation explains and justifies; ops runs. Any new platform capability must ship as an ops binary or script with a corresponding doc pointer, not as procedural text in docs.
