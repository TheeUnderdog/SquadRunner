# Routing Rules

> Label-based routing for squad agents

## Default Routing

When an issue has no `squad:<member>` label but has the `squad` gate label:
- Route to **lead** for triage
- Lead assigns appropriate `squad:<member>` label

## Member Routes

| Label | Routes To | Handles |
|-------|-----------|---------|
| `squad:lead` | lead | Triage, architecture, complex issues |
| `squad:backend` | backend | Scripts, CLI, APIs, infrastructure |
| `squad:frontend` | frontend | UI, components, styling |
| `squad:data` | data | Pipelines, schemas, transformations |
| `squad:scribe` | scribe | Documentation, README, ADRs |

## Priority Order

Within each member's queue:

```
priority:P0 > priority:P1 > priority:P2
```

- **P0**: Drop everything, handle immediately
- **P1**: Next in queue
- **P2**: Standard queue order
- **P3**: Skip - requires human intervention

## Skip Conditions

Do not pick up issues that:
- Have `epic` label (container issues)
- Have `blocked` label
- Have `priority:P3` label
- Are in `closed` state
- Lack `squad` gate label

## Handoff Rules

When handing off between agents:

1. Complete your portion of work
2. Add comment: `Handing off to @<agent> for <reason>`
3. Remove your `squad:<member>` label
4. Add recipient's `squad:<member>` label
5. Recipient picks up via normal polling

## Multi-Agent Issues

Some issues require multiple agents:

```markdown
<!-- requires: backend, scribe -->
```

- First listed agent picks up
- Handoff to next when ready
- Last agent closes the issue
