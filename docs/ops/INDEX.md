# Ops Subsystem (Index)

## 0. Philosophy
**Ops is the runtime.**
The `ops/` directory contains the executable logic, binaries, and manifests that drive the platform. This index maps those subsystems.

## 1. The Binaries (Runtime Tools)
Located in `ops/bin/`. These are the primary operator interfaces.
* [`../../ops/bin/open`](../../ops/bin/open) — **Session Start.** Generates the "Open Prompt" with freshness gates.
* [`../../ops/bin/dump`](../../ops/bin/dump) — **State Capture.** Serializes the platform for agent ingestion.
* [`../../ops/bin/project`](../../ops/bin/project) — **Work Management.** Initializes and tracks project payloads.
* [`../../ops/bin/help`](../../ops/bin/help) — **Documentation Search.** Greps the `docs/` tree.

## 2. The Library (Static Assets)
Located in `ops/lib/`. These are the templates and definitions used by the binaries.
* **Manifests:** [`../../ops/lib/manifests/CONTEXT.md`](../../ops/lib/manifests/CONTEXT.md) — The context rehydration spec.
* **Project Lib:** [`../../ops/lib/project/`](../../ops/lib/project/) — Templates and logic for the project registry.

## 3. Maintenance Doctrine
* **Binary Handling:** All scripts must be executable (`chmod +x`).
* **No Logic in Docs:** If it runs, it belongs in `ops/`. If it explains, it belongs in `docs/`.
* **Registry:** New tools must be registered here to be considered part of the "Platform."