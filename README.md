# SquadRunner

**Cloud-based agentic development with Squad CLI and GitHub**

SquadRunner is an architecture pattern for orchestrating multi-agent AI workflows. It combines a local CUA (Computer Use Agent), the Squad CLI framework, a persistent cloud VM, and GitHub to create an autonomous development pipeline.

## The Stack

| Component | Role |
|-----------|------|
| **Claw-based CUA** | Chief of Staff — bridges human PO and AI agents, skills, M365 integration |
| **Squad CLI** | Multi-agent framework — Danny, Basher, Linus, Saul, Scribe, Ralph |
| **SquadRunner VM** | Cloud execution — Azure VM running `squad watch` via SSH/tmux |
| **GitHub** | Backlog + PRs — issues drive work, labels route to agents |
| **GH Copilot CLI** | Session-based development — issues, PRs, code in one terminal |

## How It Works

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Human (PO)    │────▶│  Claw-based CUA │────▶│  GitHub Issues  │
│                 │     │  Chief of Staff │     │  (Backlog)      │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                        ┌────────────────────────────────┘
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                     SquadRunner VM (Azure)                      │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  squad watch --execute --interval 5 --verbose           │   │
│  │                                                         │   │
│  │  Ralph (Monitor) ──▶ Danny (Triage) ──┬──▶ Basher      │   │
│  │                                       ├──▶ Linus       │   │
│  │                                       ├──▶ Saul        │   │
│  │                                       └──▶ Scribe      │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                        │
                        ▼
              ┌─────────────────┐
              │   GitHub PRs    │
              │   (Output)      │
              └─────────────────┘
```

## Squad Agents

| Agent | Role | Specialty |
|-------|------|-----------|
| **Danny** | Lead/Architect | Triages issues, breaks down epics, dispatches work |
| **Basher** | Backend Dev | Python, APIs, auth, infrastructure |
| **Linus** | Frontend Dev | React, TypeScript, UI components |
| **Saul** | Data Engineer | Fabric, SQL, data pipelines |
| **Scribe** | Session Logger | Commits history, merges decisions to repo |
| **Ralph** | Work Monitor | Polls GitHub, routes issues, tracks PRs |

## Definition of Ready (DOR)

For Squad to pick up an issue, it needs:

- `squad` label (base requirement)
- `priority:P{N}` label (P0 = critical, P1 = high, P2 = normal, P3 = skip)

Optional routing:
- `squad:basher` — direct to backend
- `squad:linus` — direct to frontend
- `squad:saul` — direct to data
- No routing label → Danny triages

## SquadRunner VM Setup

### Prerequisites

- Azure subscription
- SSH key pair
- GitHub CLI (`gh`) authenticated

### Provisioning

```bash
# Create resource group
az group create --name rg-squadrunner --location westus3

# Create VM
az vm create \
  --resource-group rg-squadrunner \
  --name squadrunner \
  --image Ubuntu2204 \
  --size Standard_B2s \
  --admin-username squad \
  --ssh-key-values ~/.ssh/id_rsa.pub

# Open SSH
az vm open-port --resource-group rg-squadrunner --name squadrunner --port 22
```

### SSH Config

Add to `~/.ssh/config`:

```
Host squadrunner
  HostName <vm-public-ip>
  User squad
  IdentityFile ~/.ssh/id_rsa
```

### Squad CLI Installation

```bash
ssh squadrunner

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Squad CLI
sudo npm install -g @bradygaster/squad-cli

# Authenticate GitHub
gh auth login
```

### Running Squad Watch

```bash
# Create tmux session
tmux new-session -d -s squad

# Start watching
tmux send-keys -t squad 'cd ~/repos/your-project && squad watch --execute --interval 5 --verbose' Enter

# Attach to monitor
tmux attach -t squad
```

### Windows Terminal Integration

Create a shortcut profile in Windows Terminal:

```json
{
  "name": "SquadRunner",
  "commandline": "ssh squadrunner -t 'tmux attach -t squad || tmux new -s squad'",
  "icon": "🤖",
  "startingDirectory": "~"
}
```

## The Workflow

1. **Groom** — Human + CUA audit GitHub backlog, set priorities and labels
2. **Watch** — Ralph scans issues every 5 min, routes to Danny or direct to agents
3. **Execute** — Danny dispatches Basher/Linus/Saul in parallel, Scribe logs
4. **Review** — PRs opened as drafts, human reviews via sitrep command
5. **Merge** — Approved PRs merge, issues close, cycle repeats

## Monitoring

### Sitrep Command

Send a status request to the running Squad:

```bash
ssh squadrunner "tmux send-keys -t squad 'sitrep' Enter"
sleep 2
ssh squadrunner "tmux capture-pane -t squad -p | tail -50"
```

### Log File

Enable persistent logging:

```bash
ssh squadrunner "tmux pipe-pane -t squad 'cat >> ~/squad-watch.log'"
```

## Results

In our first production run:

- **3 PRs in 15 minutes** while the human watched
- **Parallel execution** — Basher + Linus + Scribe running simultaneously
- **Autonomous overnight** — Squad works while you sleep
- **Full traceability** — every decision logged, every commit attributed

## Cost

| Resource | Monthly Cost |
|----------|-------------|
| Azure VM (Standard_B2s) | ~$15 |
| GitHub (existing) | $0 |
| Total | ~$15/month |

## License

MIT

---

*This architecture pattern is not documented anywhere else. Novel as of May 2026.*
