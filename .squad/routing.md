# Routing Rules

## Definition of Ready (DOR)

For Squad to pick up an issue:
- `squad` label (required)
- `priority:P{N}` label (required)
  - P0 = Critical
  - P1 = High  
  - P2 = Normal
  - P3 = Skip (human review required)

## Routing

| Label | Routes to |
|-------|-----------|
| `squad:scribe` | Scribe (docs) |
| `squad:basher` | Basher (scripts) |
| `squad:danny` | Danny (triage/breakdown) |
| No routing label | Danny triages |

## Priority Order

Squad processes in order: P0 -> P1 -> P2

P3 issues are visible but skipped until human removes P3 or changes priority.

## Epic Handling

Issues with `epic` label are tracked but not directly executed. Sub-issues linked via task lists are the executable work.
