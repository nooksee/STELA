# S-LEARN-06: Advanced Git Forensics

## Provenance
- Captured: 2026-02-01
- Origin: System Hardening (DP-OPS-0015)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Debugging / Friction Analysis
  - High Churn: Legacy Code

## Scope
Production payload work and platform maintenance.

## Invocation guidance
Use this skill when ops/lib/skill/heuristics.sh fails to identify the correct Hot Zone, or when debugging complex regressions. The Trap: "I remember where the bug is." (Human memory is faulty). Solution: Let the git logs prove the location of friction.

## Drift preventers
- Stop if the DP scope prevents shell access.
- Anti-hallucination: Rely on git outputs, not intuition.

## Procedure
1) Hot Zone Detection (Volume):
   - Run: `git diff --numstat main...HEAD | sort -nr | head -n 5`
   - Goal: Identify where the most lines are changing.
2) High Churn Detection (Frequency):
   - Run: `git log --name-only --format="" main...HEAD | sort | uniq -c | sort -nr | head -n 5`
   - Goal: Identify files touched most often (instability).
3) Blame Analysis (Context):
   - Run: `git blame -w -C -L <start>,<end> <file>`
   - Trap: Ignoring whitespace changes.
   - Solution: Use -w to ignore whitespace and focus on logic changes.
4) Topology Mapping:
   - Use `find . -maxdepth 2 -not -path '*/.*'` to map directory structures before refactoring.
