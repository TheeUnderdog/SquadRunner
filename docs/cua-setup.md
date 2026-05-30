# CUA Setup Guide

This guide explains how to configure a Claw-based CUA (Computer Use Agent) to work with SquadRunner.

## Overview

The CUA acts as Chief of Staff, managing the backlog and coordinating work between the Product Owner and the squad. Configuration involves:

1. Loading squad skills
2. Pointing to project repositories
3. Connecting to the SquadRunner VM

## Prerequisites

- Claw-based CUA environment running
- SquadRunner VM provisioned and accessible
- GitHub CLI authenticated on your machine
- SSH access to SquadRunner VM configured

## Skills Setup

Skills are instruction sets that define how the CUA operates. SquadRunner includes four core skills:

### 1. Chief of Staff Skill

Defines the PO/CUA relationship and engagement workflow.

**Location:** `.skills/chief-of-staff.md`

**Key concepts:**
- PO decides scope, priority, architecture
- CUA owns backlog operations
- Squad executes labeled issues

**Usage:**
The CUA automatically loads this skill when working with a squad-enabled repo.

### 2. Working Agreements Skill

Defines quality standards and conventions.

**Location:** `.skills/working-agreements.md`

**Key concepts:**
- Definition of Ready (DoR)
- Definition of Done (DoD)
- ADR conventions
- Code review standards

### 3. Ralph Rules Skill

Defines backlog pickup behavior.

**Location:** `.skills/ralph-rules.md`

**Key concepts:**
- Label-based routing
- Priority ordering (P0 > P1 > P2)
- Epic vs executable issues
- Blocked issue handling

### 4. Dev Workflow Skill

Defines the development lifecycle.

**Location:** `.skills/dev-workflow.md`

**Key concepts:**
- Branch naming: `<issue-number>-<description>`
- Commit conventions
- PR requirements
- Merge criteria

## Loading Skills

### Method 1: Project-Local Skills

If skills are in the project repo:

```
project-repo/
├── .skills/
│   ├── chief-of-staff.md
│   ├── working-agreements.md
│   ├── ralph-rules.md
│   └── dev-workflow.md
└── .squad/
    ├── team.md
    └── routing.md
```

The CUA will discover these when you open the repo.

### Method 2: Global Skills

For skills that apply across all projects, place them in your CUA's skills directory:

```
~/.copilot-dev/m-skills/
├── cos/
│   └── SKILL.md
├── squad-working-agreements/
│   └── SKILL.md
└── ...
```

These load automatically in all sessions.

## Connecting to a Project

### Step 1: Show the GitHub Repo

Tell the CUA which repo to work with:

```
"Let's work on github.com/myorg/myproject"
```

The CUA will:
1. Check for `.squad/` folder
2. Load `team.md` and `routing.md`
3. Understand the squad configuration

### Step 2: Show Local Clone (Optional)

If you have a local clone:

```
"The repo is cloned at C:\Users\me\projects\myproject"
```

This enables the CUA to:
- Read local files directly
- Run local scripts
- Commit and push changes

### Step 3: Connect to SquadRunner VM

```
"Connect to the SquadRunner VM"
```

The CUA will SSH to the VM to:
- Check squad watch status
- Tail logs
- Restart services if needed

## Engagement Workflow

### Starting an Engagement

1. **Draft a brief** describing the work
2. **Give brief to CUA**: "Here's the engagement brief"
3. **CUA proposes plan**: Issues, labels, assignments
4. **Review and approve**: "Go" or provide feedback
5. **CUA dispatches**: Creates issues, sets labels

### During an Engagement

- CUA monitors progress via GitHub
- Squad picks up and executes issues
- CUA merges PRs when CI passes
- CUA reports status on request

### Ending an Engagement

- All issues closed
- Final review with PO
- CUA archives engagement state

## SSH Configuration for CUA

The CUA uses SSH to connect to the VM. Ensure your SSH config is set:

```
Host squadrunner
    HostName <VM_IP>
    User azureuser
    IdentityFile ~/.ssh/squadrunner_ed25519
```

Test from CUA:

```
ssh squadrunner "squad status"
```

## GitHub Configuration

### Authentication

The CUA uses `gh` CLI for GitHub operations. Ensure it's authenticated:

```bash
gh auth status
```

If not authenticated:

```bash
gh auth login
```

### Permissions Required

The CUA needs permission to:
- Create/edit/close issues
- Create/merge PRs
- Create labels
- Read repository content

For organization repos, ensure appropriate access.

## Directory Structure

A fully configured project looks like:

```
project-repo/
├── .github/
│   ├── ISSUE_TEMPLATE/
│   │   ├── squad-task.yml
│   │   ├── epic.yml
│   │   └── bug.yml
│   └── pull_request_template.md
├── .skills/
│   ├── chief-of-staff.md
│   ├── working-agreements.md
│   ├── ralph-rules.md
│   └── dev-workflow.md
├── .squad/
│   ├── team.md
│   ├── routing.md
│   ├── agents/
│   │   ├── lead/
│   │   │   └── charter.md
│   │   ├── backend/
│   │   │   └── charter.md
│   │   └── ...
│   └── engagements/
│       └── <epic-code>/
│           ├── log.md
│           └── ...
├── docs/
├── src/
└── README.md
```

## Commands Reference

### Sitrep

Get squad status:

```
"Give me a sitrep"
```

CUA will:
1. SSH to VM
2. Check tmux session
3. Tail recent logs
4. Summarize status

### Dispatch

Send work to squad:

```
"Dispatch this to the squad"
```

CUA will:
1. Create GitHub issue
2. Add appropriate labels
3. Confirm dispatch

### Check Progress

```
"What's the status of issue #42?"
```

CUA will:
1. Read issue from GitHub
2. Check for linked PRs
3. Report status

## Troubleshooting

### CUA Can't Find Squad Config

```
"I don't see a .squad folder in this repo"
```

Solution: Run `add-squad.sh` to set up squad configuration.

### CUA Can't Connect to VM

```
"SSH connection to squadrunner failed"
```

Check:
1. VM is running
2. SSH config is correct
3. Key permissions: `chmod 600 ~/.ssh/squadrunner_ed25519`

### CUA Can't Create Issues

```
"Permission denied creating issue"
```

Check:
1. `gh auth status`
2. Token has `repo` scope
3. You have write access to repo

### Skills Not Loading

Check skill file locations:
- Project: `.skills/*.md`
- Global: `~/.copilot-dev/m-skills/*/SKILL.md`

## Best Practices

1. **Keep skills in version control** - Put `.skills/` in the repo
2. **Use consistent naming** - Match skill names to functions
3. **Document customizations** - Note any project-specific rules
4. **Test before dispatch** - Verify labels and routing work

## Next Steps

- [Add Squad to New Project](./new-squad-guide.md)
- [Day-to-Day Workflow](./workflow.md)
