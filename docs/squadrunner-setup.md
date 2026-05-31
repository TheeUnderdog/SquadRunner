# SquadRunner Setup

**A prompt guide for setting up SquadRunner with a Claw-based CUA**

This document contains the prompts you give to your CUA to provision and configure SquadRunner. Copy-paste the prompts below — the CUA handles execution.

---

## Prerequisites

Before starting, ensure:
- You have an Azure subscription (or other cloud provider)
- Your CUA has shell access and Azure CLI configured
- You have a GitHub account with access to the target repositories

---

## Setup Prompts

### 1. Provision the VM

```
Create an Azure VM for running SquadRunner:
- Name: squadrunner
- Resource group: squadrunner-rg (create if needed)
- Location: eastus
- Size: Standard_B2s (2 vCPU, 4GB RAM)
- Image: Ubuntu 22.04 LTS
- Auth: SSH key (generate if needed)
- Open port 22 for SSH

Save the connection details and test SSH access.
```

### 2. Configure SSH Access

```
Set up SSH config for the squadrunner VM:
- Generate an ed25519 key if I don't have one (~/.ssh/squadrunner_ed25519)
- Add an SSH config entry named "squadrunner" pointing to the VM
- Enable agent forwarding and keepalive
- Test the connection works
```

### 3. Install Dependencies

```
SSH into squadrunner and install:
- Node.js 20.x (via NodeSource)
- GitHub CLI (gh)
- tmux
- Git (if not present)

Verify each installation with version commands.
```

### 4. Authenticate GitHub

```
On the squadrunner VM, authenticate GitHub CLI:
- Run gh auth login
- Use HTTPS protocol
- Complete the device flow authentication
- Verify with gh auth status
```

### 5. Clone SquadRunner

```
On squadrunner VM:
- Clone https://github.com/TheeUnderdog/SquadRunner.git to ~/SquadRunner
- Run npm install in the repo
- Verify squad CLI is available
```

### 6. Configure tmux

```
Set up tmux on squadrunner:
- Use Ctrl-a as prefix (not Ctrl-b)
- Enable mouse support
- Set scrollback to 50000 lines
- Create the ~/.tmux.conf file
```

### 7. Start Squad Watch

```
On squadrunner, start the squad watcher:
- Create a tmux session named "squad"
- Start "squad watch" in that session
- Verify it's running and watching for issues
```

---

## Verification Prompt

After setup, run this verification:

```
Verify SquadRunner setup on the squadrunner VM:
- [ ] VM is running and accessible via SSH
- [ ] Node.js 20+ installed
- [ ] GitHub CLI installed and authenticated
- [ ] tmux installed and configured
- [ ] SquadRunner repo cloned with dependencies
- [ ] squad watch running in tmux session

Report status of each item.
```

---

## Management Prompts

### Stop/Start VM (Cost Savings)

```
Deallocate the squadrunner VM to stop compute charges.
```

```
Start the squadrunner VM and verify squad watch is still running.
If the tmux session is gone, restart squad watch.
```

### Check Status

```
Check the status of squadrunner:
- Is the VM running?
- Is squad watch active in tmux?
- Any recent issues processed?
```

---

## Troubleshooting Prompts

### SSH Issues

```
I can't SSH to squadrunner. Diagnose:
- Is the VM running?
- What's the current public IP?
- Is port 22 open in the NSG?
- Can you reach the port from here?
```

### GitHub Auth Expired

```
GitHub auth on squadrunner has expired. Refresh it and verify squad watch is working.
```

### Squad Watch Stopped

```
Squad watch on squadrunner stopped. Check the tmux session, restart if needed, and show me the recent logs.
```

---

## Cost Estimate

| Resource | Monthly Cost |
|----------|--------------|
| Standard_B2s VM | ~$15-30 |
| 20GB SSD | ~$3 |
| Network | ~$1-5 |
| **Total** | **~$20-40** |

**Tip:** Deallocate the VM when not in use to minimize costs.