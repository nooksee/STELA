# Continuity Map (State Persistence)

## 0. Philosophy
**The repo is stateless; the Map provides the memory.**
This document defines the specific surfaces that must be loaded to preserve governance, history, and active intent across sessions.

## 1. The Constitution (Immutable Law)
*Rules that do not change without a governance event.*
* **Policy of Truth:** [`../../PoT.md`](../../PoT.md) — Constitution, staffing, jurisdiction, and enforcement (SSOT).
* **Discovery:** [`../../llms.txt`](../../llms.txt) — The machine-readable entry point.

## 2. The Ledger (Mutable State)
*Living records of what has happened and what is happening.*
* **History:** [`../../SoP.md`](../../SoP.md) — The State of Play. (What shipped, when, why).
* **Active Contract:** [`../../TASK.md`](../../TASK.md) — The Dispatch Packet. (Current objective and work log).

## 3. The Interface (Wayfinding)
*Operator-facing manuals for navigation.*
* **Command Console:** [`MANUAL.md`](MANUAL.md) — Mechanics, cheat sheets, and top commands.
* **Curated Index:** [`INDEX.md`](INDEX.md) — The approved library of operator guidance.

## 4. The Bridge (Ingestion Tools)
*Mechanisms that move state from disk to context.*
* **Generation:** [`../../ops/bin/open`](../../ops/bin/open) — Creates the session prompt.
* **Capture:** [`../../ops/bin/dump`](../../ops/bin/dump) — Serializes the platform.
* **Validation:** [`../../ops/lib/manifests/CONTEXT.md`](../../ops/lib/manifests/CONTEXT.md) — The required context checklist.

## 5. Root Ontology
*Defines the Provider and Consumer relationship for Phase 3.*
* **Provider Root:** `docs/library/` — Canonical guidance and reference surfaces.
* **Consumer Root:** `projects/` — Project payloads that consume the library guidance.
