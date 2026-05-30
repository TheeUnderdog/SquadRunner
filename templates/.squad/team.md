# Squad Charter

> Squad configuration for {{PROJECT_NAME}}

## Mission

Execute work from the GitHub backlog with consistency, quality, and minimal human intervention.

---

## Roster

| Agent | Role | Handles |
|-------|------|---------|
| lead | Lead/Architect | Triage, breakdown, design decisions |
| backend | Backend Dev | Scripts, CLI, APIs, infrastructure |
| frontend | Frontend Dev | UI, components, user-facing features |
| data | Data Engineer | Pipelines, schemas, data processing |
| scribe | Documentation | Docs, README, decision records |

---

## Operating Model

- **Backlog-driven**: All work comes from GitHub issues
- **Label-routed**: `squad:<member>` labels route to specific agents
- **Priority-ordered**: P0 > P1 > P2 (P3 is skip)
- **PR-based**: All changes via pull request
- **CI-gated**: Green CI required for merge

---

## Work Scope

| Path | Owner |
|------|-------|
| `docs/` | scribe |
| `scripts/` | backend |
| `src/api/` | backend |
| `src/ui/` | frontend |
| `src/data/` | data |
| `README.md` | scribe |
| `*.md` | scribe |

---

## Labels

### Required for Pickup

- `squad` - Gate label, marks issue as ready
- `squad:<member>` - Routes to specific agent
- `priority:P0/P1/P2` - Priority level

### Status Labels

- `blocked` - Cannot proceed
- `in-progress` - Currently being worked
- `epic` - Container issue, not directly executed

---

## Standards

This squad follows:
- [Chief of Staff Skill](/.skills/chief-of-staff.md)
- [Working Agreements](/.skills/working-agreements.md)
- [Ralph Rules](/.skills/ralph-rules.md)
- [Dev Workflow](/.skills/dev-workflow.md)

---

## Engagement State

Each engagement creates a state folder:

```
.squad/engagements/<epic-code>/
├── log.md        # Chronological activity log
├── handoffs.md   # Handoff notes between agents
├── drift.md      # Design drift notes
└── packet-toc.md # Deliverable tracking
```
