<!-- CCD: ff_target="operator-technical" ff_band="25-40" -->
# Factory Census Registry

Deterministic census and usage matrix for active factory definitions under `opt/_factory/`.
This registry classifies each definition as `keep`, `replace`, or `remove` with explicit reason codes.

## Runtime Role Naming Map
- `analyst`: topic and evidence synthesis into a reviewable plan.
- `architect`: accepted-plan translation into a Dispatch Packet.
- `worker`: bounded execution under an active task contract.
- `supervisor`: blocker analysis and addendum proposal preparation.

## Reason Codes
- `K-ACTIVE-CONTRACT`: active definition is registry-bound and satisfies the baseline contract.
- `R-SCHEMA-NORMALIZE`: active definition remains in service but requires follow-on schema normalization.
- `X-UNUSED-LEGACY`: definition has no live runtime path and is eligible for retirement after replacement coverage is proven.
- `X-IMPORTED-PROTOTYPE`: imported prototype was never validated as a STELA-derived active definition.

## Disposition Summary
| Disposition | Count |
| --- | ---: |
| keep | 4 |
| replace | 0 |
| remove | 0 |

## Definition Matrix
| Kind | ID | Path | Disposition | Reason Code | Path Refs (ops/tools/docs) | ID Refs (ops/tools/docs) | Registry Refs (id/path) |
| --- | --- | --- | --- | --- | ---: | ---: | ---: |
| agent | R-AGENT-13 | opt/_factory/agents/r-agent-13.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/1 | 1/0 |
| agent | R-AGENT-12 | opt/_factory/agents/r-agent-12.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 1/0/1 | 1/0 |
| agent | R-AGENT-11 | opt/_factory/agents/r-agent-11.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/1 | 1/0 |
| agent | R-AGENT-10 | opt/_factory/agents/r-agent-10.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/2 | 1/0 |

## Scope Notes
- Active Agent cards describe temporary workflow roles and grant constitutional authority `0` times.
- Retired prototypes and development definitions are preserved in Git history and listed below, not retained as active definitions.
- Active Tasks and Skills are both `0`; future definitions require evidence-backed promotion.
- Factory runtime orchestration and broader Task and Skill harvesting remain deferred.
- Any runtime reference to `opt/_factory/agents/*.md`, `opt/_factory/skills/*.md`, or `opt/_factory/tasks/*.md` must resolve to a matrix row above.

## Retired Definitions
Permanently retired definition IDs. Any re-creation of a path listed here without explicit addendum authorization is a hard lint gate failure.

| Kind | ID | Former Path | Retired In | Reason |
| --- | --- | --- | --- | --- |
| agent | R-AGENT-01 | opt/_factory/agents/r-agent-01.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| agent | R-AGENT-02 | opt/_factory/agents/r-agent-02.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| agent | R-AGENT-03 | opt/_factory/agents/r-agent-03.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| agent | R-AGENT-04 | opt/_factory/agents/r-agent-04.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| agent | R-AGENT-05 | opt/_factory/agents/r-agent-05.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| agent | R-AGENT-06 | opt/_factory/agents/r-agent-06.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| task | B-TASK-01 | opt/_factory/tasks/b-task-01.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| task | B-TASK-02 | opt/_factory/tasks/b-task-02.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| task | B-TASK-03 | opt/_factory/tasks/b-task-03.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| task | B-TASK-04 | opt/_factory/tasks/b-task-04.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| task | B-TASK-05 | opt/_factory/tasks/b-task-05.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| task | B-TASK-06 | opt/_factory/tasks/b-task-06.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| skill | S-LEARN-01 | opt/_factory/skills/s-learn-01.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| skill | S-LEARN-02 | opt/_factory/skills/s-learn-02.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| skill | S-LEARN-03 | opt/_factory/skills/s-learn-03.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| skill | S-LEARN-04 | opt/_factory/skills/s-learn-04.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| skill | S-LEARN-05 | opt/_factory/skills/s-learn-05.md | NON-DP-CONSULTING-2026-08-02 | Imported prototype retired during workflow-role vocabulary reset. |
| agent | R-AGENT-07 | opt/_factory/agents/r-agent-07.md | NON-DP-CONSULTING-2026-08-02 | Development validation card retired from active canon; history preserved. |
| agent | R-AGENT-08 | opt/_factory/agents/r-agent-08.md | NON-DP-CONSULTING-2026-08-02 | Development bundle-coordination card retired from active canon; history preserved. |
| agent | R-AGENT-09 | opt/_factory/agents/r-agent-09.md | NON-DP-CONSULTING-2026-08-02 | Test-only gatekeeper card retired from active canon; history preserved. |
| task | B-TASK-07 | opt/_factory/tasks/b-task-07.md | NON-DP-CONSULTING-2026-08-02 | Development validation Task retired from active canon; history preserved. |
| task | B-TASK-08 | opt/_factory/tasks/b-task-08.md | NON-DP-CONSULTING-2026-08-02 | Development bundle-orchestration Task retired from active canon; history preserved. |
| task | B-TASK-09 | opt/_factory/tasks/b-task-09.md | NON-DP-CONSULTING-2026-08-02 | Test-only Factory gate Task retired from active canon; history preserved. |
| skill | S-LEARN-06 | opt/_factory/skills/s-learn-06.md | NON-DP-CONSULTING-2026-08-02 | Experimental harvest result retired pending evidence-backed reharvest. |
| skill | S-LEARN-07 | opt/_factory/skills/s-learn-07.md | NON-DP-CONSULTING-2026-08-02 | Development validation Skill retired from active canon; history preserved. |
| skill | S-LEARN-08 | opt/_factory/skills/s-learn-08.md | NON-DP-CONSULTING-2026-08-02 | Development bundle-governance Skill retired from active canon; history preserved. |
| skill | S-LEARN-09 | opt/_factory/skills/s-learn-09.md | NON-DP-CONSULTING-2026-08-02 | Test-only Factory gate Skill retired from active canon; history preserved. |
