# S-LEARN-06: Hot Zone Forensics

## Provenance
- Captured: 2026-02-10
- Origin: Task System Certification (DP-OPS-0039)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Risky Logic Surfaces
  - High Churn: Repeated Change Paths

## Scope
Applies to platform maintenance and production payload work.
Use when a change touches security, data access, build pipelines, or frequently edited subsystems.

## Invocation Guidance
Use when a diff includes hot zones or high churn files.

## Pointers
- Constitution: `PoT.md`
- Governance: `docs/GOVERNANCE.md`
- Contract: `TASK.md`
- Registry: `docs/ops/registry/SKILLS.md`
- Reference docs: `docs/MANUAL.md`

## Forensics Requirements
- Identify hot zones in auth, permissions, data access, migrations, payment flows, and build or deploy scripts.
- Treat changes in `ops/`, `tools/`, or governance surfaces as hot zones by default.
- Measure churn with `git log` scoped to touched files and record repeat edits.
- Record churn signals and verification evidence in RESULTS with file paths and counts.
- Escalate risk when hot zone changes lack owners or verification evidence.
