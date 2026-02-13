# Context (System Rehydration)

## 0. Philosophy
**Context is file-defined state, not memory.**
Rehydration now follows a layered One Truth manifest model backed by a single synthesis engine.

## 1. Canonical Manifest Hierarchy
The canonical pointer surface remains:
- [`ops/lib/manifests/CONTEXT.md`](../ops/lib/manifests/CONTEXT.md)

Layer membership is authoritative in:
- [`ops/lib/manifests/CORE.md`](../ops/lib/manifests/CORE.md)
- [`ops/lib/manifests/OPS.md`](../ops/lib/manifests/OPS.md)
- [`ops/lib/manifests/DISCOVERY.md`](../ops/lib/manifests/DISCOVERY.md)

## 2. Default Binary Behavior
- [`./ops/bin/context`](../ops/bin/context): session stream wrapper; defaults to `OPS.md` and injects OPEN state.
- [`./ops/bin/llms`](../ops/bin/llms): static bundle wrapper; writes `llms-core.txt` from `CORE.md`, `llms-full.txt` from `DISCOVERY.md`, and refreshes `llms.txt`.

## 3. Unified Synthesis Engine
- [`ops/lib/scripts/synthesize.sh`](../ops/lib/scripts/synthesize.sh) is the single implementation for:
  - manifest parsing and inheritance expansion,
  - hazard enforcement,
  - stream emission format.

## 4. Verification
- [`tools/lint/context.sh`](../tools/lint/context.sh): validates required context pointers are present.
- [`tools/lint/llms.sh`](../tools/lint/llms.sh): enforces parity for the root llms bundle set.
