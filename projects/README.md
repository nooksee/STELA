# projects/

This directory holds project payloads.

- Registered projects are tracked in `ops/lib/manifests/PROJECTS.md`.
- Use `./ops/bin/project init <name> --dry-run` to preview creation.
- Use `./ops/bin/project init <name> --confirm` to create a minimal README-first scaffold.
- Do not edit project payloads unless a DP explicitly includes them.

# Common Patterns

## Repository Pattern

```typescript
interface Repository<T> {
  findAll(filters?: Filters): Promise<T[]>
  findById(id: string): Promise<T | null>
  create(data: CreateDto): Promise<T>
  update(id: string, data: UpdateDto): Promise<T>
  delete(id: string): Promise<void>
}
```

## Skeleton Projects

When implementing new functionality:
1. Search for battle-tested skeleton projects
2. Use parallel agents to evaluate options:
   - Security assessment
   - Extensibility analysis
   - Relevance scoring
   - Implementation planning
3. Clone best match as foundation
4. Iterate within proven structure
