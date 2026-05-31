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

## Helper Scripts

The `scripts/` folder contains bash scripts to assist setup:

| Script | Purpose |
|--------|---------|
| `provision-vm.sh` | Create Azure VM with correct specs |
| `configure-ssh.sh` | Generate keys, copy to VM, add SSH config |
| `install-squad.sh` | Install Node.js, GitHub CLI, tmux on VM |
| `start-watch.sh` | Start squad watch in tmux session |
| `setup-squadrunner.sh` | All-in-one setup (provisions + configures everything) |

Your CUA can run these directly or use them as reference.

---

## Setup Prompts

### Option A: All-in-One Setup

```
Clone https://github.com/TheeUnderdog/SquadRunner.git and run scripts/setup-squadrunner.sh to provision and configure everything.
Use these settings:
- VM name: squadrunner
- Resource group: squadrunner-rg
- Location: eastus
- Size: Standard_B2s

Report progress and any errors.
```

### Option B: Step-by-Step Setup

#### 1. Provision the VM

```
Clone https://github.com/TheeUnderdog/SquadRunner.git and run:
./scripts/provision-vm.sh --name squadrunner --group squadrunner-rg --location eastus

Save the VM IP address from the output.
```

#### 2. Configure SSH Access

```
Run the SSH configuration script with the VM IP:
./scripts/configure-ssh.sh --ip <VM_IP>

This generates keys, copies them to the VM, and adds SSH config.
Test the connection works.
```

#### 3. Install Dependencies

```
Run the install script on the VM:
ssh squadrunner "bash -s" < ./scripts/install-squad.sh

Or SSH in and run:
./scripts/install-squad.sh

Verify Node.js 20+, GitHub CLI, and tmux are installed.
```

#### 4. Authenticate GitHub

```
On the squadrunner VM, authenticate GitHub CLI:
ssh squadrunner "gh auth login"

Complete the device flow authentication.
Verify with: ssh squadrunner "gh auth status"
```

#### 5. Start Squad Watch

```
Start squad watch using the script:
./scripts/start-watch.sh --remote --attach

Or manually:
ssh squadrunner "tmux new-session -d -s squad && tmux send-keys -t squad 'squad watch' Enter"

Verify it's running.
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
If the tmux session is gone, run: ./scripts/start-watch.sh --remote
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