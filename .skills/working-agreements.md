# Working Agreements

> Team conventions, standards, and quality gates for squad operation.

This skill defines the shared agreements that govern how work flows through the squad system. These are the rules everyone follows.

---

## Definition of Ready (DoR)

An issue is ready for squad pickup when ALL of the following are true:

### Required Elements

| Element | Description | Example |
|---------|-------------|---------|
| **Title** | One-line change description | `Add user authentication endpoint` |
| **Goal** | What problem this solves | `Users cannot log in without this` |
| **Scope** | What's included | `Login, logout, token refresh` |
| **Out of scope** | What's explicitly excluded | `Password reset, OAuth providers` |
| **Acceptance criteria** | Checkboxes for user-visible behavior | `[ ] User can log in with email/password` |
| **Priority label** | `priority:P0/P1/P2/P3` | `priority:P1` |
| **Squad label** | `squad:<member>` for routing | `squad:basher` |

### Priority Definitions

| Priority | Meaning | Response |
|----------|---------|----------|
| `P0` | Critical blocker | Drop everything |
| `P1` | High priority | Next in queue |
| `P2` | Normal | Standard queue |
| `P3` | Low/Skip | Human review required before pickup |

### Not Ready Indicators

- Missing acceptance criteria
- Vague scope ("improve performance")
- No routing label
- Dependencies not linked
- Blocked by unresolved questions

---

## Definition of Done (DoD)

Work is done when ALL of the following are true:

### PR Requirements

- [ ] PR references the issue it closes (`Closes #123`)
- [ ] All acceptance criteria checkboxes are ticked
- [ ] CI pipeline is green (verified via `gh pr checks`)
- [ ] PR description lists affected surfaces
- [ ] No unresolved review comments
- [ ] PO assigned as reviewer (for significant changes)

### Code Requirements

- [ ] Code follows existing patterns in the codebase
- [ ] No new linter warnings introduced
- [ ] Tests pass (existing and new)
- [ ] No secrets or credentials committed

### Documentation Requirements

- [ ] README updated if behavior changes
- [ ] ADR filed if architectural decision made
- [ ] Inline comments for non-obvious logic only

### Verification

- [ ] Feature works on the target surface (not just in tests)
- [ ] Edge cases handled or explicitly out of scope

---

## ADR Conventions

Architectural Decision Records capture significant technical decisions.

### When to Write an ADR

- Choosing between competing approaches
- Adopting a new technology or pattern
- Deprecating existing functionality
- Changing a previously-documented decision

### ADR Format

```markdown
# ADR-NNN: Title

## Status
Proposed | Accepted | Deprecated | Superseded by ADR-XXX

## Context
What is the issue we're facing? What forces are at play?

## Decision
What is the change we're making?

## Consequences
What are the results? Both positive and negative.
```

### ADR Location

Store ADRs in `docs/adr/` with filenames like `adr-001-use-typescript.md`.

### ADR Numbering

Sequential, zero-padded to 3 digits. Never reuse numbers.

---

## General Documentation Requirements

### README.md (Required)

Every repo must have a README with:
- One-sentence description
- Prerequisites
- Setup instructions
- How to run
- How to test

### docs/ Folder Structure

```
docs/
├── architecture.md    # System design
├── adr/               # Decision records
│   ├── adr-001-*.md
│   └── adr-002-*.md
├── runbooks/          # Operational procedures
└── api/               # API documentation (if applicable)
```

### Inline Documentation

- Comment non-obvious logic only
- No "what" comments (the code says what)
- Yes "why" comments (the code doesn't say why)
- No commented-out code in main branch

---

## Code Review Standards

### Reviewer Responsibilities

- Review within 24 hours (P1) or 48 hours (P2)
- Focus on correctness, not style (linters handle style)
- Ask questions, don't demand
- Approve when "good enough," not "perfect"

### Author Responsibilities

- Keep PRs small (under 400 lines preferred)
- Self-review before requesting review
- Respond to feedback within 24 hours
- Don't merge your own PR without approval

### Review Comments

- **Blocking**: Must fix before merge (prefix with `blocking:`)
- **Non-blocking**: Suggestions for consideration (prefix with `nit:` or `suggestion:`)
- **Question**: Seeking understanding (prefix with `question:`)

---

## House Style

### Writing

- No em-dashes or double-dashes
- No "not just X but Y" antithesis patterns
- Active voice preferred
- Short sentences
- Plain headings (no emoji)

### Code

- Follow existing patterns in the codebase
- Consistency over personal preference
- When in doubt, match what's already there

### Commits

- Present tense ("Add feature" not "Added feature")
- Imperative mood ("Fix bug" not "Fixes bug")
- Under 72 characters for first line
- Reference issue number when applicable

---

## Meeting Conventions

### Stand-ups (if applicable)

- What did you complete?
- What are you working on?
- Any blockers?

### Retrospectives

- What went well?
- What could improve?
- Action items with owners

---

## Escalation Path

1. **Blocked on technical question**: Ask in PR comment or issue
2. **Blocked on scope/priority**: Escalate to PO
3. **Blocked on external dependency**: Document in issue, label as blocked
4. **Conflict between team members**: PO mediates
