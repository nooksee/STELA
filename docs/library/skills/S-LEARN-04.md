# S-LEARN-04: Coding Standards

## Provenance
- Captured: 2026-02-01
- Origin: Legacy Migration (DP-OPS-0013)
- Source: Operator Institutional Knowledge
- Friction Context:
  - Hot Zone: Universal / Platform Root
  - High Churn: Historical Aggregate

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP explicitly requests coding standards. Apply these rules to payload code and document any DP-approved exceptions.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: follow repository conventions when they are more specific than this skill.

## Procedure
1) Apply readability-first constraints:
   - Prefer explicit control flow over clever abstractions.
   - Keep functions focused on a single responsibility.
   - Use descriptive names for variables, functions, and types.
2) Apply immutability emphasis:
   - Prefer immutable data structures and pure functions where possible.
   - Avoid mutating shared state unless the DP explicitly requires it.
3) Apply naming conventions:
   - Components: PascalCase.
   - Hooks: camelCase with a `use` prefix.
   - Types and interfaces: PascalCase.
   - Functions and variables: camelCase verbs for actions, nouns for data.
4) Apply React anti-pattern guardrails:
   - Avoid deeply nested conditional rendering; extract helpers or early returns.
   - Avoid deep component nesting; refactor into smaller components.
5) Apply size constraints:
   - If the DP defines a function size limit, refactor when functions exceed that limit.
   - When no limit is defined, refactor functions that become difficult to scan in one screen.
6) Document DP-approved exceptions in RESULTS.
