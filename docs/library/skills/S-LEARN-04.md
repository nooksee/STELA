# S-LEARN-04: Coding Standards

## Scope
Production payload work only. Not platform maintenance.

## Invocation guidance
Use this skill when a DP explicitly requests coding standards. Apply these rules to payload code and document any DP-approved exceptions.

## Drift preventers
- Stop if the DP scope is platform maintenance or if the DP does not explicitly request this skill.
- Anti-hallucination: follow repository conventions when they are more specific than this skill.

## Readability-first constraints
- Prefer explicit control flow over clever abstractions.
- Keep functions focused on a single responsibility.
- Use descriptive names for variables, functions, and types.

## Immutability emphasis
- Prefer immutable data structures and pure functions where possible.
- Avoid mutating shared state unless the DP explicitly requires it.

## Naming conventions
- Components: PascalCase.
- Hooks: camelCase with a `use` prefix.
- Types and interfaces: PascalCase.
- Functions and variables: camelCase verbs for actions, nouns for data.

## React anti-pattern guardrails
- Avoid deeply nested conditional rendering; extract helpers or early returns.
- Avoid deep component nesting; refactor into smaller components.

## Size constraints
- If the DP defines a function size limit, refactor when functions exceed that limit.
- When no limit is defined, refactor functions that become difficult to scan in one screen.
