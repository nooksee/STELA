<!-- SPEC-SURFACE:REQUIRED -->
# Technical Specification

## First Principles Rationale
Factory provides deterministic rendering for definition surfaces so agent/task/skill artifacts are generated from canonical templates with enforceable slot contracts.

## Mechanics and Sequencing
Resolve template key, parse and strip frontmatter, load slots from file and CLI overrides, expand includes with cycle protection, apply slot replacement, and enforce strict unresolved-token rejection by default.

## Anecdotal Anchor
Definition promotion workflows previously incurred formatting drift from copied markdown; factory centralizes rendering semantics so downstream linters validate stable structure.

## Integrity Filter Warnings
Unknown template keys, missing include files/sections, circular includes, invalid slot tokens, and unresolved required tokens terminate rendering with non-zero exit.