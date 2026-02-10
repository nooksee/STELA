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

## Invocation guidance
Use this skill when a diff includes hot zones or high churn files.
**The Trap:** Reviewing the diff in isolation and missing volatility signals.
**Solution:** Identify hot zones, measure churn, and flag unstable areas explicitly.

## Drift preventers
- Stop if a hot zone change lacks a clear owner or verification evidence.
- Stop if churn indicators are present and RESULTS does not include the evidence trail.

## Procedure
1) Hot Zone Identification:
   - Flag auth, permissions, data access, migrations, payment flows, and build or deploy scripts.
   - Treat changes in `ops/`, `tools/`, or governance surfaces as hot zones by default.
2) Churn Detection:
   - Run `git log --name-only -n 20 -- <path>` for touched files.
   - Look for repeated edits, reversals, or frequent reverts in the recent history.
3) Forensic Notes:
   - Record churn signals and repeated hotspots in RESULTS with file paths and counts.
   - If churn is high, require additional verification or review.
4) Risk Elevation:
   - Escalate severity for hot zone changes with weak tests or missing validation output.
