# Ralph Rules

> Backlog pickup, priority ordering, and squad execution protocol.

Ralph is the dispatcher pattern that governs how squad agents pick up and execute work from the GitHub backlog. These rules ensure consistent, predictable behavior across all squads.

---

## The Ralph Loop

Every squad agent runs a continuous pickup loop:

```
1. Poll the backlog for ready issues
2. Pick the highest-priority issue in my lane
3. Execute the work
4. Open PR, close issue
5. Return to step 1
```

This is the "Ralph Loop" - named after the pattern, not a specific agent.

---

## Pickup Algorithm

### Step 1: Filter to Ready Issues

An issue is ready for pickup when it has:
- `squad` label (the gate label)
- `squad:<member>` label matching this agent
- `priority:P0`, `priority:P1`, or `priority:P2` label
- No `blocked` label
- State is `open`

### Step 2: Sort by Priority

```
P0 > P1 > P2
```

Within the same priority, sort by:
1. Issue number (ascending) - older issues first

### Step 3: Check Dependencies

Before picking up an issue, verify:
- No linked issues are still open (unless explicitly parallel-safe)
- No blocking comments from PO
- Required inputs exist (files, APIs, etc.)

### Step 4: Self-Assign

When picking up an issue:
1. Add a comment: `Picking up this issue`
2. Assign yourself (if GitHub permissions allow)
3. Begin work immediately

---

## Label Requirements

### Gate Labels

| Label | Purpose |
|-------|---------|
| `squad` | Marks issue as ready for any squad pickup |
| `squad:<member>` | Routes to specific squad member |

Both labels are required. `squad` alone means "ready but unrouted."

### Priority Labels

| Label | Behavior |
|-------|----------|
| `priority:P0` | Pick up immediately, drop other work |
| `priority:P1` | Pick up next |
| `priority:P2` | Standard queue |
| `priority:P3` | **Skip** - requires human intervention |

**P3 is special**: Squad agents do not pick up P3 issues. They require explicit human assignment or promotion to P2+.

### Routing Labels

Each squad defines its member labels:

```
squad:danny    - Lead/Architect (triage, breakdown)
squad:basher   - Backend (scripts, CLI, infra)
squad:linus    - Frontend (UI, components)
squad:saul     - Data (pipelines, schemas)
squad:scribe   - Documentation (docs, README)
```

### Status Labels

| Label | Meaning |
|-------|---------|
| `blocked` | Cannot proceed, waiting on external |
| `in-progress` | Currently being worked |
| `needs-review` | PR ready for review |

---

## Epic vs Executable Issues

### Epics

- Have `epic` label
- Contain task lists linking to sub-issues
- Are **never picked up directly**
- Track completion via sub-issue closure

### Executable Issues

- Have `squad` + `squad:<member>` + `priority:P*` labels
- Contain acceptance criteria
- Are picked up and worked
- Result in PRs

**Rule**: If an issue has `epic` label, skip it regardless of other labels.

---

## Blocked Issue Handling

When an issue cannot proceed:

1. Add `blocked` label
2. Add comment explaining the blocker
3. Remove `squad:<member>` label (returns to triage)
4. Pick up next available issue

When a blocker is resolved:

1. Remove `blocked` label
2. Add appropriate `squad:<member>` label
3. Issue re-enters the queue

---

## Parallel Work

### Default: Sequential

By default, an agent works one issue at a time. Complete or block before picking up another.

### Exception: Parallel-Safe

Some issues are marked parallel-safe in their body:

```markdown
<!-- parallel-safe -->
```

These can be worked alongside other issues if:
- They touch different files
- They have no data dependencies
- The agent can context-switch cleanly

---

## Handoff Protocol

When an issue requires multiple agents:

1. First agent completes their portion
2. Adds comment: `Handing off to @<next-agent> for <reason>`
3. Removes their `squad:<member>` label
4. Adds next agent's `squad:<member>` label
5. Next agent picks up via normal polling

---

## Stale Issue Detection

Issues are considered stale if:
- `in-progress` label but no commits in 48 hours
- `needs-review` label but no review activity in 48 hours
- Assigned but no activity in 72 hours

Stale issues are flagged for PO review.

---

## Failure Modes

### Issue Cannot Be Completed

1. Add detailed comment explaining why
2. Add `blocked` label
3. Mention PO in comment for triage
4. Move to next issue

### PR Fails CI

1. Fix the issue in the same PR
2. If unfixable, add comment and request help
3. Do not merge failing PRs

### Scope Creep Discovered

1. Complete original scope only
2. Add comment noting additional work needed
3. PO files follow-up issue

---

## Polling Behavior

### Frequency

- Active hours: Poll every 60 seconds
- Idle detection: If no issues for 5 minutes, reduce to every 5 minutes
- Wake on: New issue notification (if webhook available)

### Distributed Locking

When multiple agents could pick the same issue:
- First to comment "Picking up" wins
- Others skip and pick next
- No race condition retries needed (comment is atomic)

---

## Examples

### Good Issue for Pickup

```
Title: Add health check endpoint
Labels: squad, squad:basher, priority:P1
State: open

Body:
## Goal
Add /health endpoint for monitoring.

## Acceptance
- [ ] GET /health returns 200 OK
- [ ] Response includes version number
- [ ] Response time under 100ms
```

### Issue to Skip

```
Title: Improve overall system performance
Labels: squad, priority:P3
State: open

# Reason: P3 (skip), no squad:<member> routing, vague scope
```

### Epic to Skip

```
Title: [SR20] Provisioning Scripts
Labels: epic
State: open

# Reason: Has epic label, not directly executable
```
