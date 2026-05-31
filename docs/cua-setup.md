# CUA Setup

Configure a Claw-based CUA to work with SquadRunner.

## Overview

The CUA acts as Chief of Staff — managing the backlog and coordinating between the PO and squad.

## Skills

Skills are instruction sets loaded by the CUA. Place in `.skills/` in the project repo:

| Skill | Purpose |
|-------|---------|
| `chief-of-staff.md` | PO/CUA relationship, engagement workflow |
| `working-agreements.md` | DoR, DoD, ADR conventions |
| `ralph-rules.md` | Backlog pickup behavior, label routing |
| `dev-workflow.md` | Branch, commit, PR, merge lifecycle |

## Connecting to a Project

```
Let's work on github.com/owner/repo
The repo is cloned at C:\path\to\repo
```

The CUA will load `.squad/team.md` and `.squad/routing.md`.

## Connecting to SquadRunner VM

```
Connect to the SquadRunner VM
```

The CUA will SSH to check status, tail logs, restart services.

## Commands

| Command | What CUA Does |
|---------|---------------|
| "sitrep" | SSH to VM, check tmux, summarize status |
| "dispatch this" | Create issue with labels |
| "status of #42" | Read issue, check PRs, report |

## Troubleshooting

| Problem | Fix |
|---------|-----|
| No .squad folder | Run `squad init` |
| SSH fails | Check VM running, SSH config, key permissions |
| Can't create issues | Check `gh auth status`, token scope |