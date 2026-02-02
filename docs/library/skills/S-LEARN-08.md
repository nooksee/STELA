# S-LEARN-08: Advanced Git Forensics

## Scope
Production payload work and platform maintenance.

## Invocation guidance
Use this skill when debugging a high-friction task or when `ops/lib/skill/heuristics.sh` fails to identify the correct Hot Zone. Apply the solution: run the manual forensic commands and use the outputs to refine the Friction Context in a skill draft.

## Drift preventers
- Stop if the DP scope prevents shell access.
- Anti-hallucination: rely on git logs and diff output only.
- Do not edit Provenance blocks in skill drafts.

## Procedure
1) Identify the Hot Zone manually: `git diff --numstat main...HEAD | sort -nr | head -n 5`
2) Identify High Churn files: `git log --name-only --format="" main...HEAD | sort | uniq -c | sort -nr | head -n 5`
3) Use these outputs to populate the Friction Context in a skill draft when auto-harvest output is inaccurate.
