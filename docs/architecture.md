# SquadRunner Architecture

This document describes the SquadRunner system architecture: how a Claw-based CUA (Computer Use Agent) connects to GitHub through a Linux VM running the GitHub Copilot CLI.

## System Overview

```mermaid
flowchart TB
    subgraph Skills["Skills & Rules"]
        COS["Chief of Staff<br/>Skill"]
        WA["Working<br/>Agreements"]
        RR["Ralph Rules"]
        DW["Dev Workflow"]
    end

    subgraph Local["Developer Machine"]
        CUA["Claw-based CUA"]
    end

    subgraph VM["SquadRunner VM"]
        CLI["GitHub Copilot CLI"]
        RALPH["Ralph Loop"]
        AGENTS["Squad Agents"]
    end

    subgraph GH["GitHub"]
        REPO["Repository"]
        ISSUES["Issues<br/>Backlog"]
        PRS["Pull Requests"]
        SQUAD[".squad/<br/>Configuration"]
    end

    %% Skill inputs
    COS -.->|"configures"| CUA
    WA -.->|"standards"| AGENTS
    RR -.->|"pickup rules"| RALPH
    DW -.->|"workflow"| AGENTS

    %% Main flow
    CUA -->|"SSH"| CLI
    CUA -->|"gh CLI"| ISSUES
    CLI --> RALPH
    RALPH -->|"polls"| ISSUES
    RALPH --> AGENTS
    AGENTS -->|"commits"| PRS
    PRS -->|"merges to"| REPO
    SQUAD -.->|"defines"| AGENTS

    %% Styling
    classDef skill fill:#e1f5fe,stroke:#0288d1,stroke-width:2px
    classDef machine fill:#fff3e0,stroke:#ff9800,stroke-width:2px
    classDef vm fill:#e8f5e9,stroke:#4caf50,stroke-width:2px
    classDef github fill:#fce4ec,stroke:#e91e63,stroke-width:2px

    class COS,WA,RR,DW skill
    class CUA machine
    class CLI,RALPH,AGENTS vm
    class REPO,ISSUES,PRS,SQUAD github
```

## Data Flow

```mermaid
flowchart LR
    subgraph Intake["Engagement Intake"]
        BRIEF["Brief"] --> CUA["CUA"]
        CUA -->|"creates"| ISSUES["Issues"]
    end

    subgraph Execution["Squad Execution"]
        ISSUES -->|"labeled"| RALPH["Ralph"]
        RALPH -->|"assigns"| AGENT["Agent"]
        AGENT -->|"works"| PR["PR"]
    end

    subgraph Delivery["Delivery"]
        PR -->|"reviewed"| CUA2["CUA"]
        CUA2 -->|"merges"| DONE["Done"]
    end

    classDef intake fill:#e3f2fd,stroke:#1976d2
    classDef exec fill:#e8f5e9,stroke:#388e3c
    classDef deliver fill:#fff8e1,stroke:#fbc02d

    class BRIEF,CUA,ISSUES intake
    class RALPH,AGENT,PR exec
    class CUA2,DONE deliver
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

**Input**: Chief of Staff Skill defines the PO/CUA relationship and backlog ownership.

### 2. SquadRunner VM

A Linux virtual machine running the GitHub Copilot CLI. Configuration:

| Spec | Value |
|------|-------|
| OS | Ubuntu 22.04 LTS |
| vCPU | 2+ |
| RAM | 4GB+ |
| Storage | 20GB+ |
| Network | Public IP with SSH access |

The VM runs:
- **Node.js 20+**: Runtime for GitHub Copilot CLI
- **GitHub Copilot CLI (`squad`)**: Watches backlog and dispatches work to agents
- **GitHub CLI (`gh`)**: Interacts with GitHub API
- **tmux**: Manages persistent sessions

### 3. Ralph Loop

The dispatcher that picks up work from the backlog.

**Input**: Ralph Rules skill defines:
- Label-based routing (`squad:<member>`)
- Priority ordering (P0 > P1 > P2)
- Skip conditions (P3, blocked, epic)
- Pickup algorithm

```mermaid
flowchart TD
    POLL["Poll Backlog"] --> FILTER["Filter Ready Issues"]
    FILTER --> SORT["Sort by Priority"]
    SORT --> PICK["Pick Highest"]
    PICK --> EXEC["Execute Work"]
    EXEC --> PR["Open PR"]
    PR --> POLL

    classDef loop fill:#e8f5e9,stroke:#4caf50
    class POLL,FILTER,SORT,PICK,EXEC,PR loop
```

### 4. Squad Agents

The workers that execute issues.

**Inputs**:
- Working Agreements skill defines DoR, DoD, ADR conventions
- Dev Workflow skill defines branch/commit/PR flow
- Agent charters in `.squad/agents/*/charter.md`

### 5. GitHub Repository

The system of record. Contains:

- **Issues**: Work items with routing labels
- **Pull Requests**: Code changes for review
- **`.squad/` folder**: Squad configuration
  - `team.md`: Roster and operating model
  - `routing.md`: Label routing rules
  - `agents/*/charter.md`: Agent-specific instructions

## Security Model

### Authentication

| Component | Auth Method |
|-----------|-------------|
| CUA to VM | SSH key (ed25519) |
| VM to GitHub | Personal Access Token or GitHub App |
| CUA to GitHub | `gh auth login` |

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

```mermaid
flowchart LR
    subgraph Devs["Developers"]
        D1["Dev 1"]
        D2["Dev 2"]
    end

    subgraph Infra["Infrastructure"]
        VM["SquadRunner VM"]
    end

    subgraph GitHub["GitHub"]
        R1["Repo A"]
        R2["Repo B"]
    end

    D1 & D2 -->|SSH| VM
    VM -->|watches| R1 & R2

    classDef dev fill:#e3f2fd,stroke:#1976d2
    classDef infra fill:#e8f5e9,stroke:#388e3c
    classDef gh fill:#fce4ec,stroke:#e91e63

    class D1,D2 dev
    class VM infra
    class R1,R2 gh
```

Multiple developers share one VM. Each dev has SSH access.

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
| GitHub Copilot CLI crash | tmux session empty | Restart with `start-watch.sh` |
| GitHub rate limit | API errors in logs | Wait for reset (1 hour) |
| Network issues | Polling timeouts | Auto-retry with backoff |

## Monitoring

### Health Checks

```bash
# Check VM is reachable
ssh squadrunner "echo ok"

# Check GitHub Copilot CLI is running
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

