# Stelae

## What Stelae Are
Stelae are short operator-facing reminders that improve reliability and reduce friction, especially around mode switching and phase errors.

## What Stelae Are Not
- Not a general quote wall.
- Not a diary.
- Not a dumping ground for process notes.
- Not a substitute for canonical contracts or templates.

## Spelling Policy
- "Stela" is the singular project / platform name.
- "Stelae" is the plural / collection label.
Examples:
- Correct: "Stela is the platform name."
- Correct: "These Stelae keep operator guidance consistent."

## Entry Format
Each Stela must be a short, durable, reusable line or micro-paragraph.

- **ID:** `STELAE-####` (4 digits, zero-padded, monotonically increasing)
- **Text:** the Stela itself
- **Intent:** what behavior it nudges (one line)
- **When:** trigger condition (one line)
- **Notes:** optional, 1-2 lines max

Example skeleton (also the first library entry):
- **STELAE-0001**
  - **Text:** DISCUSS-ONLY means discuss only.
  - **Intent:** Prevents accidental execution during ideation.
  - **When:** Use when you want talk-only in the next exchange.
Remaining library entries are listed below.

## Governance Rules (keep it small)
- Hard cap: target 12-25 total Stelae; prune before growing.
- Add rule: once above the cap, adding a new Stela requires deleting or merging an existing one.
- Rewrite rule: prefer rewriting an existing Stela over adding a new one.
- Rotation rule: if Stelae are not referenced for 30+ days, consider pruning or merging.
- No duplicates: new Stelae must be meaningfully distinct.

## Quality Bar
- Short.
- Non-situational (no dates, no "today", no one-off incidents).
- Actionable.
- Not condescending.
- Written for the operator (not the worker, not the repo).

## How Stelae Relate to Mementos
Stelae and Mementos share the same mission (reliability + behavioral nudges). Stelae are operator-facing reminders, while Mementos can be system or internal nudges.

## Stelae Library
- **STELAE-0002**
  - **Text:** One request per message.
  - **Intent:** Keeps scope tight and prevents ballooning.
  - **When:** You are about to bundle multiple asks together.
- **STELAE-0003**
  - **Text:** Say what you want now, not what happened earlier.
  - **Intent:** Keeps the next action explicit.
  - **When:** You start recounting prior context instead of the request.
- **STELAE-0004**
  - **Text:** If you want action, say so; if you want talk, say so.
  - **Intent:** Removes mode ambiguity.
  - **When:** The request could be interpreted as DISCUSS or EXECUTE.
- **STELAE-0005**
  - **Text:** Provide constraints first; details second.
  - **Intent:** Keeps responses aligned to the right guardrails.
  - **When:** You have limits, scope, or preferences that matter.
- **STELAE-0006**
  - **Text:** When unsure, refresh the platform snapshot.
  - **Intent:** Reduces guesswork and stale context.
  - **When:** Context feels fuzzy or outdated.
- **STELAE-0007**
  - **Text:** Keep receipts clean: attach artifacts; keep chat minimal.
  - **Intent:** Preserves handoff hygiene.
  - **When:** Delivering results or approvals.
- **STELAE-0008**
  - **Text:** Tighten the instruction; do not punish the tool.
  - **Intent:** Keeps feedback constructive and specific.
  - **When:** You are frustrated with a response.
- **STELAE-0009**
  - **Text:** Creativity is free-form; execution is structured; memory lives in the repo.
  - **Intent:** Prevents mode drift and memory confusion.
  - **When:** Switching between ideation and execution.
- **STELAE-0010**
  - **Text:** If you are heated, pause and rephrase in work language.
  - **Intent:** Lowers friction and improves clarity.
  - **When:** You are angry or rushing.
