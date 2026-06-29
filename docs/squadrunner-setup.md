# SquadRunner Setup

Prompts for setting up SquadRunner with a Claw-based CUA.

Helper scripts not available.  Just have the conversation.  

---

## 1. Provision an Azure VM

```
Create an Azure VM for SquadRunner:
- Name: squadrunner
- Resource group: squadrunner-rg
- Location: eastus
- Size: Standard_B2s (2 vCPU, 4GB RAM)
- Image: Ubuntu 22.04 LTS
- Open port 22

Save connection details.
```

## 2. Configure SSH access

```
Set up SSH for squadrunner VM:
- Generate ed25519 key if needed
- Add SSH config entry "squadrunner"
- Test connection
```

## 3. Install dependencies (Node.js, GitHub CLI, tmux)

```
On squadrunner, install:
- Node.js 20.x
- GitHub CLI
- tmux

Verify with version commands.
```

## 4. Install GitHub Copilot and Squad
```
On squadrunner, install GitHub Copilot and all dependencies
On Squadrunner, install Squad and all dependencies
```

## 4. Authenticate with GitHub

```
On squadrunner, run gh auth login.
Verify with gh auth status.
```

## 5. Install and configure Bastion

```
Deploy Azure Bastion for SquadRunner so I can SSH over 443 instead of 22:

- VM:           squadrunner (resource group squadrunner-rg, region <region>)
- VNet:         the VNet that already hosts squadrunner
- Bastion subnet: create AzureBastionSubnet (/26) in that VNet if missing
- Bastion host: squadrunner-bastion, SKU Standard, native client tunneling enabled
- Public IP:    squadrunner-bastion-pip, Standard SKU, Static, same region
```

## 6. Start squad watch

```
On squadrunner, start squad watch in tmux session "squad".
Verify it's running.
```

---

## Verify

```
Verify SquadRunner: VM accessible, Node 20+, gh authenticated, tmux installed, squad watch running.
```

## Manage

```
Deallocate squadrunner VM.
```

```
Start squadrunner VM and restart squad watch if needed.
```

## Cost

~$20-40/month. Deallocate when not in use.
