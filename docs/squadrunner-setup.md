# SquadRunner Setup

**Prompts for setting up SquadRunner with a Claw-based CUA**

Helper scripts are available in `scripts/` — your CUA can use them directly.

---

## Setup Prompts

### 1. Provision the VM

```
Create an Azure VM for running SquadRunner:
- Name: squadrunner
- Resource group: squadrunner-rg
- Location: eastus
- Size: Standard_B2s (2 vCPU, 4GB RAM)
- Image: Ubuntu 22.04 LTS
- Open port 22 for SSH

Save the connection details and test SSH access.
```

### 2. Configure SSH Access

```
Set up SSH config for the squadrunner VM:
- Generate an ed25519 key if needed
- Add an SSH config entry named "squadrunner"
- Enable agent forwarding and keepalive
- Test the connection
```

### 3. Install Dependencies

```
SSH into squadrunner and install:
- Node.js 20.x
- GitHub CLI (gh)
- tmux

Verify each with version commands.
```

### 4. Authenticate GitHub

```
On squadrunner, run gh auth login.
Complete authentication and verify with gh auth status.
```

### 5. Start Squad Watch

```
On squadrunner, start squad watch in a tmux session named "squad".
Verify it's running.
```

---

## Verification

```
Verify SquadRunner setup:
- VM accessible via SSH
- Node.js 20+ installed
- GitHub CLI authenticated
- tmux installed
- squad watch running

Report status.
```

---

## Management

```
Deallocate squadrunner VM to save costs.
```

```
Start squadrunner VM and restart squad watch if needed.
```

```
Check squadrunner status: VM running? Squad watch active?
```

---

## Cost

~$20-40/month. Deallocate when not in use.