# Context (System Rehydration)

## 0. Philosophy
**Context is not memory; it is a file.**
In a stateless system, "Context" is the precise set of artifacts required to rehydrate an agent (Human or AI) from zero to full operational awareness.
* **If it is not in the Context, it does not exist.**
* **If it is in the Context, it must be true.**

## 1. The Manifest (SSOT)
The authoritative list of required artifacts lives in:
* [`ops/lib/manifests/CONTEXT.md`](../ops/lib/manifests/CONTEXT.md)

**[REMOVED] (Must Load):**
* `PoT.md` (Policy of Truth)
* `SoP.md` (History)
* `TASK.md` (Active Objective)

**Negative Constraints (Must Not Be In The Manifest):**
* `docs/library/agents` (Library agents are JIT-only)
* `docs/library/tasks` (Library tasks are JIT-only)
* `docs/library/skills` (Library skills are JIT-only)

## 2. Ingestion Mechanics
Context is not read casually; it is injected via tooling.
* **Generation:** [`./ops/bin/open`](../ops/bin/open)
  * Automatically assembles the "Open Prompt" with freshness gates and git state.
* **Capture:** [`./ops/bin/dump`](../ops/bin/dump)
  * Captures the platform state (file contents) for agent ingestion.

## 3. Verification (The Linter)
We do not guess if context is complete. We prove it.
* **Tool:** [`tools/lint/context.sh`](../tools/lint/context.sh)
* **Rule:** This script verifies that every path listed in the Manifest actually exists on disk.
* **Usage:** Run before every session to prevent "blind" operations.

## 4. Maintenance Doctrine
**Update the Manifest when:**
* A canonical file is renamed or moved.
* A new high-level governance surface is created.
* **Never** clutter the context with temporary project files or logs.
