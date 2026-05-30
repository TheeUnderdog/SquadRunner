# SquadRunner Architecture

This document describes the SquadRunner system architecture: how a Claw-based CUA (Computer Use Agent) connects to GitHub through a Linux VM running the Squad CLI.

## System Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           Developer Machine                              │
│  ┌─────────────────────┐                                                │
│  │   Claw-based CUA    │                                                │
│  │                     │                                                │
│  │  ┌───────────────┐  │     SSH         ┌─────────────────────────┐   │
│  │  │ Chief of Staff│  │─────────────────│     SquadRunner VM      │   │
│  │  │    Skill      │  │                 │                         │   │
│  │  └───────────────┘  │                 │  ┌───────────────────┐  │   │
│  │                     │                 │  │    Squad CLI      │  │   │
│  │  ┌───────────────┐  │                 │  │                   │  │   │
│  │  │ Working       │  │                 │  │  ┌─────────────┐  │  │   │
│  │  │ Agreements    │  │                 │  │  │ squad watch │  │  │   │
│  │  └───────────────┘  │                 │  │  └─────────────┘  │  │   │
│  │                     │                 │  │         │         │  │   │
│  │  ┌───────────────┐  │                 │  │         ▼         │  │   │
│  │  │ Ralph Rules   │  │                 │  │  ┌─────────────┐  │  │   │
│  │  └───────────────┘  │                 │  │  │   GitHub    │──┼──┼───┼─┐
│  │                     │                 │  │  │     API     │  │  │   │ │
│  │  ┌───────────────┐  │                 │  │  └─────────────┘  │  │   │ │
│  │  │ Dev Workflow  │  │                 │  └───────────────────┘  │   │ │
│  │  └───────────────┘  │                 │                         │   │ │
│  └─────────────────────┘                 └─────────────────────────┘   │ │
└─────────────────────────────────────────────────────────────────────────┘ │
                                                                             │
    ┌────────────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                              GitHub                                      │
│                                                                          │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │                        Repository                                │    │
│  │                                                                  │    │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │    │
│  │  │   Issues    │  │    PRs      │  │       .squad/           │  │    │
│  │  │             │  │             │  │                         │  │    │
│  │  │ squad:danny │  │ CI Pipeline │  │  team.md                │  │    │
│  │  │ priority:P1 │  │ Auto-merge  │  │  routing.md             │  │    │
│  │  └─────────────┘  └─────────────┘  │  agents/*/charter.md    │  │    │
│  │                                    └─────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

## Components

### 1. Claw-based CUA (Computer Use Agent)

The AI assistant that acts as Chief of Staff. Responsibilities:

- **Backlog Management**: Creates, grooms, and prioritizes issues
- **Engagement Intake**: Processes briefs and dispatches work
- **PR Review**: Reviews and merges completed work
- **Coordination**: Reports status to Product Owner

The CUA operates from the developer's machine and has access to:
- Local squad skills (working agreements, rules)
- SSH connection to SquadRunner VM
- Direct GitHub access via `gh` CLI

### 2. SquadRunner VM

A Linux virtual machine running the Squad CLI. Configuration:

| Spec | Value |
|------|-------|
| OS | Ubuntu 22.04 LTS |
| vCPU | 2+ |
| RAM | 4GB+ |
| Storage | 20GB+ |
| Network | Public IP with SSH access |

The VM runs:
- **Node.js 20+**: Runtime for Squad CLI
- **Squad CLI**: Watches backlog and executes work
- **GitHub CLI**: Interacts with GitHub API
- **tmux**: Manages persistent sessions

### 3. Squad CLI

The execution engine. Core commands:

| Command | Function |
|---------|----------|
| `squad watch` | Poll backlog for ready issues |
| `squad status` | Show current state |

The `watch` command:
1. Polls GitHub for issues with `squad` + `squad:<member>` labels
2. Picks highest priority issue
3. Executes the work (via agent logic)
4. Opens PR and closes issue
5. Repeats

### 4. GitHub Repository

The system of record. Contains:

- **Issues**: Work items with routing labels
- **Pull Requests**: Code changes for review
- **`.squad/` folder**: Squad configuration
  - `team.md`: Roster and operating model
  - `routing.md`: Label routing rules
  - `agents/*/charter.md`: Agent-specific instructions

## Data Flow

### Issue Lifecycle

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Created   │────▶│    Ready    │────▶│  Picked Up  │
│  (by CUA)   │     │  (labeled)  │     │ (by Squad)  │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Closed    │◀────│   Merged    │◀────│  PR Open    │
│             │     │             │     │             │
└─────────────┘     └─────────────┘     └─────────────┘
```

### Label Flow

```
Issue Created (no labels)
         │
         ▼
CUA adds: squad + squad:<member> + priority:P1
         │
         ▼
Squad CLI detects via polling
         │
         ▼
Agent picks up, adds: in-progress
         │
         ▼
Work complete, opens PR
         │
         ▼
CI passes, CUA merges
         │
         ▼
Issue auto-closed (via "Closes #N")
```

## Security Model

### Authentication

| Component | Auth Method |
|-----------|-------------|
| CUA → VM | SSH key (ed25519) |
| VM → GitHub | Personal Access Token or GitHub App |
| CUA → GitHub | `gh auth login` |

### Access Control

- **SSH**: Key-based only, password disabled
- **GitHub**: Fine-grained PAT with repo scope
- **VM Firewall**: Port 22 only

### Secrets Management

| Secret | Location |
|--------|----------|
| SSH private key | `~/.ssh/squadrunner_ed25519` (local) |
| GitHub token | `gh auth` credential store (VM) |

**Never commit secrets to the repository.**

## Deployment Topology

### Single VM (Default)

```
┌──────────────┐     ┌──────────────┐
│   Dev 1      │────▶│              │
└──────────────┘     │              │
                     │  SquadRunner │────▶ GitHub
┌──────────────┐     │     VM       │
│   Dev 2      │────▶│              │
└──────────────┘     └──────────────┘
```

Multiple developers share one VM. Each dev has SSH access.

### Multi-VM (Isolated)

```
┌──────────────┐     ┌──────────────┐
│   Dev 1      │────▶│   VM 1       │────▶ Repo A
└──────────────┘     └──────────────┘

┌──────────────┐     ┌──────────────┐
│   Dev 2      │────▶│   VM 2       │────▶ Repo B
└──────────────┘     └──────────────┘
```

Separate VMs per project for isolation.

## Cost Estimate

| Resource | Size | Monthly Cost |
|----------|------|--------------|
| Azure VM | Standard_B2s (2 vCPU, 4GB) | ~$15-30 |
| Storage | 20GB SSD | ~$2 |
| Network | Outbound data | ~$1-5 |
| **Total** | | **~$18-37/month** |

Costs vary by region and usage. Shut down VM when not in use to save money.

## Failure Modes

| Failure | Detection | Recovery |
|---------|-----------|----------|
| VM down | SSH connection fails | Restart VM via Azure portal |
| Squad CLI crash | tmux session empty | Restart with `start-watch.sh` |
| GitHub rate limit | API errors in logs | Wait for reset (1 hour) |
| Network issues | Polling timeouts | Auto-retry with backoff |

## Monitoring

### Health Checks

```bash
# Check VM is reachable
ssh squadrunner "echo ok"

# Check Squad CLI is running
ssh squadrunner "tmux has-session -t squad && echo running"

# Check recent activity
ssh squadrunner "tail -20 ~/.squad/logs/squad.log"
```

### Sitrep Command

Quick status from the CUA:
1. Send "sitrep" to squad tmux session
2. Wait for response
3. Tail the log
4. Summarize findings

## Related Documentation

- [VM Setup Guide](./vm-setup.md)
- [CUA Setup Guide](./cua-setup.md)
- [New Squad Guide](./new-squad-guide.md)
- [Workflow Guide](./workflow.md)
