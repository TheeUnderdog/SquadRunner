# Dev Workflow

> Development workflow from READY issue to merged PR.

This skill defines the complete lifecycle of work through the squad system: how issues become branches, branches become PRs, and PRs become merged code.

---

## Workflow Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   READY     │────▶│   BRANCH    │────▶│     PR      │
│   Issue     │     │   Created   │     │   Opened    │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   CLOSED    │◀────│   MERGED    │◀────│   REVIEW    │
│   Issue     │     │     PR      │     │   Approved  │
└─────────────┘     └─────────────┘     └─────────────┘
```

---

## Phase 1: READY Issue

### Prerequisites

Before picking up an issue, verify:

- [ ] `squad` label present (gate label)
- [ ] `squad:<member>` label matches you
- [ ] `priority:P0/P1/P2` label present (not P3)
- [ ] No `blocked` label
- [ ] Issue is `open`
- [ ] Acceptance criteria are clear

### Pickup Action

```bash
# Comment to claim the issue
gh issue comment <issue-number> --body "Picking up this issue"

# Add in-progress label (optional)
gh issue edit <issue-number> --add-label "in-progress"
```

---

## Phase 2: Branch Creation

### Branch Naming Convention

```
<issue-number>-<short-description>
```

Examples:
- `42-add-health-endpoint`
- `17-fix-auth-timeout`
- `103-update-readme`

### Rules

- Always branch from `main` (or the repo's default branch)
- Keep description short (under 50 chars)
- Use lowercase and hyphens only
- Include issue number for traceability

### Commands

```bash
# Ensure main is current
git checkout main
git pull origin main

# Create and switch to feature branch
git checkout -b 42-add-health-endpoint
```

---

## Phase 3: Development

### Commit Conventions

**Format:**
```
<type>: <subject>

[optional body]

[optional footer]
```

**Types:**
| Type | Use |
|------|-----|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that neither fixes nor adds |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks |

**Examples:**
```
feat: add health check endpoint

Implements GET /health that returns service status
and version information.

Closes #42
```

```
fix: resolve auth timeout on slow networks

Increases timeout from 5s to 30s for token refresh.

Closes #17
```

### Commit Rules

- Present tense ("Add feature" not "Added feature")
- Imperative mood ("Fix bug" not "Fixes bug")
- First line under 72 characters
- Reference issue number in footer

### Development Checklist

- [ ] Code follows existing patterns
- [ ] No linter warnings introduced
- [ ] Tests pass locally
- [ ] No secrets committed
- [ ] Changes match issue scope (no scope creep)

---

## Phase 4: Pull Request

### PR Creation

```bash
# Push branch to remote
git push -u origin 42-add-health-endpoint

# Create PR via CLI
gh pr create --title "Add health check endpoint" \
  --body "Closes #42

## Changes
- Added GET /health endpoint
- Returns version and status

## Testing
- Added unit tests
- Tested locally with curl

## Checklist
- [x] Tests pass
- [x] No linter warnings
- [x] Docs updated"
```

### PR Title

- Match commit message style
- Include type prefix if useful
- Under 72 characters

### PR Body Template

```markdown
Closes #<issue-number>

## Changes
- What was added/changed/removed

## Testing
- How this was tested

## Checklist
- [ ] Tests pass
- [ ] No linter warnings
- [ ] Docs updated (if applicable)
- [ ] Screenshots (if UI change)
```

### Linking Issues

Use GitHub keywords to auto-close issues:
- `Closes #42`
- `Fixes #42`
- `Resolves #42`

Place in PR body, not title.

---

## Phase 5: Review

### Requesting Review

```bash
# Request review from specific person
gh pr edit <pr-number> --add-reviewer <username>

# Or request from team
gh pr edit <pr-number> --add-reviewer <team-name>
```

### Responding to Feedback

1. Address all blocking comments
2. Respond to questions
3. Push fixes as new commits (don't force-push during review)
4. Re-request review when ready

### Review Approval

PR is approved when:
- At least one approval from authorized reviewer
- No unresolved blocking comments
- CI is green

---

## Phase 6: Merge

### Pre-Merge Checklist

- [ ] CI pipeline green (`gh pr checks <pr-number>`)
- [ ] At least one approval
- [ ] No merge conflicts
- [ ] Branch is up to date with main

### Merge Commands

```bash
# Verify checks pass
gh pr checks <pr-number>

# Merge (squash is common default)
gh pr merge <pr-number> --squash --delete-branch
```

### Merge Strategies

| Strategy | When to Use |
|----------|-------------|
| **Squash** | Most PRs, keeps history clean |
| **Merge** | When preserving commit history matters |
| **Rebase** | When linear history is required |

Default: **Squash merge** - combines all commits into one.

---

## Phase 7: Close Issue

### Automatic Closure

If PR body contains `Closes #42`, GitHub auto-closes when merged.

### Manual Closure

If auto-close didn't work:

```bash
gh issue close <issue-number> --comment "Completed in PR #<pr-number>"
```

### Post-Merge Cleanup

```bash
# Switch back to main
git checkout main

# Pull merged changes
git pull origin main

# Delete local branch
git branch -d 42-add-health-endpoint
```

---

## Quick Reference

### Common Commands

```bash
# Start work
gh issue comment 42 --body "Picking up this issue"
git checkout -b 42-description

# During work
git add .
git commit -m "feat: description"

# Submit work
git push -u origin 42-description
gh pr create --title "Title" --body "Closes #42"

# After approval
gh pr merge --squash --delete-branch
```

### Status Check

```bash
# Check CI status
gh pr checks <pr-number>

# View PR status
gh pr view <pr-number>

# View issue status
gh issue view <issue-number>
```

---

## Troubleshooting

### CI Fails

1. Read the error message
2. Fix locally
3. Push fix: `git push`
4. CI re-runs automatically

### Merge Conflicts

```bash
# Update your branch with main
git fetch origin main
git rebase origin/main

# Resolve conflicts
# Edit conflicted files
git add .
git rebase --continue

# Force push (safe during review)
git push --force-with-lease
```

### PR Stale

If PR sits without review for 48+ hours:
1. Ping reviewers in PR comment
2. Escalate to PO if blocked
