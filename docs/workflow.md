# Workflow Guide

This guide covers day-to-day operation of SquadRunner: from grooming issues to merging PRs.

## Daily Workflow Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Morning Routine                         │
├─────────────────────────────────────────────────────────────┤
│  1. Check VM status (sitrep)                                │
│  2. Review open PRs                                         │
│  3. Groom backlog                                           │
│  4. Dispatch new work                                       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      During the Day                          │
├─────────────────────────────────────────────────────────────┤
│  • Squad picks up issues automatically                      │
│  • CUA reviews and merges PRs                               │
│  • Handle blockers as they arise                            │
│  • Monitor progress                                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      End of Day                              │
├─────────────────────────────────────────────────────────────┤
│  • Final sitrep                                             │
│  • Review tomorrow's priorities                             │
│  • (Optional) Stop VM to save costs                         │
└─────────────────────────────────────────────────────────────┘
```

## Starting the Day

### Check VM Status

```bash
# Quick status check
ssh squadrunner "squad status"

# Full sitrep
ssh -t squadrunner "tmux attach -t squad"
# Type: sitrep<Enter>
# Detach: Ctrl-a d
```

Or ask the CUA:

```
"Give me a sitrep on the squad"
```

### Review Open PRs

```bash
gh pr list -R owner/repo --state open
```

For each PR:
1. Check CI status: `gh pr checks <number>`
2. Review changes: `gh pr diff <number>`
3. Merge if ready: `gh pr merge <number> --squash`

### Check Backlog State

```bash
# Open issues ready for pickup
gh issue list -R owner/repo --label "squad" --state open

# Issues in progress
gh issue list -R owner/repo --label "in-progress" --state open

# Blocked issues
gh issue list -R owner/repo --label "blocked" --state open
```

## Grooming Issues

### Definition of Ready Checklist

Before an issue can be picked up:

- [ ] Clear title (one line)
- [ ] Goal/problem statement
- [ ] Scope defined
- [ ] Out of scope defined
- [ ] Acceptance criteria (checkboxes)
- [ ] `squad` label
- [ ] `squad:<member>` label
- [ ] `priority:P0/P1/P2` label

### Creating a Squad-Ready Issue

```bash
gh issue create \
  --title "Add user authentication" \
  --body "## Goal
Enable users to log in securely.

## Scope
- Login endpoint
- Logout endpoint
- Token refresh

## Out of Scope
- Password reset
- OAuth providers

## Acceptance
- [ ] POST /login returns JWT token
- [ ] POST /logout invalidates token
- [ ] Token refresh works before expiry" \
  --label "squad,squad:basher,priority:P1" \
  -R owner/repo
```

### Assigning Priority

| Priority | Use When |
|----------|----------|
| P0 | Production down, security issue |
| P1 | Important feature, deadline approaching |
| P2 | Normal work, standard priority |
| P3 | Nice to have, needs human review |

### Routing to Members

| Work Type | Route To |
|-----------|----------|
| Triage needed | `squad:lead` |
| Backend/API/scripts | `squad:backend` |
| UI/frontend | `squad:frontend` |
| Data/pipelines | `squad:data` |
| Documentation | `squad:scribe` |

## Dispatching Work

### From CUA

```
"Create an issue for adding a health check endpoint and assign to backend"
```

CUA will:
1. Create the issue with proper format
2. Add `squad`, `squad:backend`, `priority:P1` labels
3. Confirm with issue URL

### Manual Dispatch

```bash
# Add labels to existing issue
gh issue edit <number> --add-label "squad,squad:basher,priority:P1"
```

## Monitoring Progress

### Watch Squad Activity

```bash
# Attach to tmux session
ssh -t squadrunner "tmux attach -t squad"

# In session, check logs
tail -f ~/.squad/logs/squad.log

# Detach
Ctrl-a d
```

### Check Issue Status

```bash
# View issue details
gh issue view <number> -R owner/repo

# View with comments
gh issue view <number> -R owner/repo --comments
```

### Check PR Status

```bash
# View PR
gh pr view <number> -R owner/repo

# Check CI
gh pr checks <number> -R owner/repo
```

## Handling Blockers

### When Issue is Blocked

1. Add `blocked` label
2. Add comment explaining blocker
3. Remove `squad:<member>` label (returns to triage)

```bash
gh issue edit <number> --add-label "blocked" --remove-label "squad:basher"
gh issue comment <number> --body "Blocked: Waiting on API spec from external team"
```

### When Blocker is Resolved

1. Remove `blocked` label
2. Re-add routing label
3. Comment that blocker is resolved

```bash
gh issue edit <number> --remove-label "blocked" --add-label "squad:basher"
gh issue comment <number> --body "Blocker resolved. Ready for pickup."
```

## Reviewing and Merging PRs

### PR Review Checklist

Before merging:

- [ ] CI is green
- [ ] Acceptance criteria met
- [ ] Code follows patterns
- [ ] No new warnings
- [ ] Documentation updated (if needed)

### Merge Commands

```bash
# Check PR is ready
gh pr checks <number>

# Review diff
gh pr diff <number>

# Merge with squash
gh pr merge <number> --squash --delete-branch

# Or merge preserving commits
gh pr merge <number> --merge --delete-branch
```

### Handling Failed CI

1. Review failure in CI logs
2. Comment on PR with findings
3. Either:
   - Fix yourself and push
   - Assign back to squad member
   - Close PR and reopen issue

## Sitrep Command

The sitrep gives a quick status summary:

```
"sitrep"
```

Output includes:
- Issues in progress
- Open PRs
- Recently closed
- Any blockers
- VM health

### Manual Sitrep

```bash
echo "=== SITREP ==="
echo "Issues in progress:"
gh issue list -R owner/repo --label "in-progress" --limit 5
echo ""
echo "Open PRs:"
gh pr list -R owner/repo --limit 5
echo ""
echo "Blocked:"
gh issue list -R owner/repo --label "blocked" --limit 5
```

## Common Tasks

### Reprioritize Issue

```bash
gh issue edit <number> \
  --remove-label "priority:P2" \
  --add-label "priority:P1"
```

### Reassign to Different Member

```bash
gh issue edit <number> \
  --remove-label "squad:backend" \
  --add-label "squad:frontend"
```

### Close Issue Without PR

```bash
gh issue close <number> --comment "Closed: Not needed, superseded by #123"
```

### Reopen Closed Issue

```bash
gh issue reopen <number>
gh issue comment <number> --body "Reopening: Feature not working as expected"
```

## End of Day

### Final Status Check

```bash
# What's still in progress?
gh issue list -R owner/repo --label "in-progress"

# Any PRs waiting?
gh pr list -R owner/repo --state open
```

### Stop VM (Optional)

To save costs when not in use:

```bash
# Stop but keep allocated
az vm stop --resource-group squadrunner-rg --name squadrunner

# Or deallocate completely
az vm deallocate --resource-group squadrunner-rg --name squadrunner
```

### Start VM Next Day

```bash
az vm start --resource-group squadrunner-rg --name squadrunner
```

## Troubleshooting

### Squad Not Picking Up Issues

1. Check labels: Must have `squad` + `squad:<member>` + `priority:P*`
2. Check VM is running: `ssh squadrunner "echo ok"`
3. Check squad watch is running: `ssh squadrunner "tmux list-sessions"`
4. Check logs: `ssh squadrunner "tail -20 ~/.squad/logs/squad.log"`

### PR Won't Merge

1. Check CI: `gh pr checks <number>`
2. Check for conflicts: `gh pr view <number>`
3. Update branch: Author needs to rebase

### VM Unresponsive

1. Check VM status in Azure portal
2. Try restart: `az vm restart -g squadrunner-rg -n squadrunner`
3. Check networking/firewall

## Quick Reference

```bash
# Sitrep
ssh squadrunner "squad status"

# Create issue
gh issue create --title "..." --body "..." --label "squad,squad:basher,priority:P1"

# List ready issues
gh issue list -R owner/repo --label "squad" --state open

# Merge PR
gh pr merge <number> --squash --delete-branch

# Start squad watch
ssh squadrunner "tmux send-keys -t squad 'squad watch' Enter"
```

