# Context Manifest

## Purpose
Canonical pointer surface for One Truth context layering.

## Layer Hierarchy
- Layer 0 (Immutable Core): `ops/lib/manifests/CORE.md`
- Layer 1 (Session Ops): `ops/lib/manifests/OPS.md`
- Layer 2 (Discovery): `ops/lib/manifests/DISCOVERY.md`

## Canonical Membership Sources
- `ops/lib/manifests/CORE.md`
- `ops/lib/manifests/OPS.md`
- `ops/lib/manifests/DISCOVERY.md`

## Runtime Surfaces
- `ops/lib/scripts/synthesize.sh`
- `ops/bin/context`
- `ops/bin/llms`

## Root Artifacts
- `llms.txt`
- `llms-core.txt`
- `llms-full.txt`

## Verification Tools
- `tools/lint/context.sh`
- `tools/lint/truth.sh`
