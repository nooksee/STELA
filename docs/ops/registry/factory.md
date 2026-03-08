<!-- CCD: ff_target="operator-technical" ff_band="25-40" -->
# Factory Census Registry

Deterministic census and usage matrix for active factory definitions under `opt/_factory/`.
This registry classifies each definition as `keep`, `replace`, or `remove` with explicit reason codes.

## Reason Codes
- `K-ACTIVE-CONTRACT`: active definition is registry-bound and passes current lint/schema gates.
- `R-SKILL-BINDING-NORMALIZE`: definition remains active but should migrate to normalized skill-binding schema in a follow-on packet.
- `X-UNUSED-LEGACY`: definition has no live runtime path and is eligible for retirement after replacement coverage is proven.

## Disposition Summary
| Disposition | Count |
| --- | ---: |
| keep | 16 |
| replace | 8 |
| remove | 0 |

## Definition Matrix
| Kind | ID | Path | Disposition | Reason Code | Path Refs (ops/tools/docs) | ID Refs (ops/tools/docs) | Registry Refs (id/path) |
| --- | --- | --- | --- | --- | ---: | ---: | ---: |
| agent | R-AGENT-01 | opt/_factory/agents/r-agent-01.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 1/1/2 | 1/0 |
| agent | R-AGENT-02 | opt/_factory/agents/r-agent-02.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/1 | 1/0 |
| agent | R-AGENT-03 | opt/_factory/agents/r-agent-03.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/1 | 1/0 |
| agent | R-AGENT-04 | opt/_factory/agents/r-agent-04.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/1 | 1/0 |
| agent | R-AGENT-05 | opt/_factory/agents/r-agent-05.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/1 | 1/0 |
| agent | R-AGENT-06 | opt/_factory/agents/r-agent-06.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/1 | 1/0 |
| agent | R-AGENT-07 | opt/_factory/agents/r-agent-07.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/1 | 1/0 |
| agent | R-AGENT-08 | opt/_factory/agents/r-agent-08.md | keep | K-ACTIVE-CONTRACT | 0/0/0 | 0/0/1 | 1/0 |
| skill | S-LEARN-01 | opt/_factory/skills/s-learn-01.md | keep | K-ACTIVE-CONTRACT | 0/0/1 | 1/2/2 | 1/1 |
| skill | S-LEARN-02 | opt/_factory/skills/s-learn-02.md | keep | K-ACTIVE-CONTRACT | 0/0/1 | 1/0/1 | 1/1 |
| skill | S-LEARN-03 | opt/_factory/skills/s-learn-03.md | keep | K-ACTIVE-CONTRACT | 0/0/1 | 0/0/1 | 1/1 |
| skill | S-LEARN-04 | opt/_factory/skills/s-learn-04.md | keep | K-ACTIVE-CONTRACT | 0/0/1 | 0/0/1 | 1/1 |
| skill | S-LEARN-05 | opt/_factory/skills/s-learn-05.md | keep | K-ACTIVE-CONTRACT | 0/0/1 | 0/0/1 | 1/1 |
| skill | S-LEARN-06 | opt/_factory/skills/s-learn-06.md | keep | K-ACTIVE-CONTRACT | 0/0/1 | 0/0/1 | 1/1 |
| skill | S-LEARN-07 | opt/_factory/skills/s-learn-07.md | keep | K-ACTIVE-CONTRACT | 0/0/1 | 0/0/1 | 1/1 |
| skill | S-LEARN-08 | opt/_factory/skills/s-learn-08.md | keep | K-ACTIVE-CONTRACT | 0/0/1 | 0/0/2 | 1/1 |
| task | B-TASK-01 | opt/_factory/tasks/b-task-01.md | replace | R-SKILL-BINDING-NORMALIZE | 0/0/1 | 0/0/3 | 1/1 |
| task | B-TASK-02 | opt/_factory/tasks/b-task-02.md | replace | R-SKILL-BINDING-NORMALIZE | 0/0/1 | 0/0/1 | 1/1 |
| task | B-TASK-03 | opt/_factory/tasks/b-task-03.md | replace | R-SKILL-BINDING-NORMALIZE | 0/0/1 | 0/0/1 | 1/1 |
| task | B-TASK-04 | opt/_factory/tasks/b-task-04.md | replace | R-SKILL-BINDING-NORMALIZE | 0/0/1 | 0/0/1 | 1/1 |
| task | B-TASK-05 | opt/_factory/tasks/b-task-05.md | replace | R-SKILL-BINDING-NORMALIZE | 0/0/1 | 0/0/1 | 1/1 |
| task | B-TASK-06 | opt/_factory/tasks/b-task-06.md | replace | R-SKILL-BINDING-NORMALIZE | 0/0/1 | 0/0/1 | 1/1 |
| task | B-TASK-07 | opt/_factory/tasks/b-task-07.md | replace | R-SKILL-BINDING-NORMALIZE | 0/0/1 | 0/0/1 | 1/1 |
| task | B-TASK-08 | opt/_factory/tasks/b-task-08.md | replace | R-SKILL-BINDING-NORMALIZE | 0/0/1 | 0/0/2 | 1/1 |

## Scope Notes
- This packet is inventory and classification only; no definition removal is performed here.
- `replace` rows remain active and lint-valid in this phase; normalization lands in follow-on packets.
- Any runtime reference to `opt/_factory/agents/*.md`, `opt/_factory/skills/*.md`, or `opt/_factory/tasks/*.md` must resolve to a matrix row above.
