# VM Setup Guide

This guide walks through provisioning and configuring a Linux VM for SquadRunner.

## Prerequisites

- Azure subscription (or other cloud provider)
- Azure CLI installed (`az`)
- SSH client (built into macOS/Linux, Windows Terminal on Windows)

## Quick Start

```bash
# Clone the repo
git clone https://github.com/TheeUnderdog/SquadRunner.git
cd SquadRunner

# Provision VM (Azure)
./scripts/provision-vm.sh

# Configure SSH access
./scripts/configure-ssh.sh --ip <VM_IP>

# Install GitHub Copilot CLI on VM
ssh squadrunner "bash -s" < ./scripts/install-squad.sh

# Start squad watch
./scripts/start-watch.sh --remote --attach
```

## Step-by-Step Setup

### 1. Provision the VM

#### Option A: Using the Script (Recommended)

```bash
./scripts/provision-vm.sh \
  --name squadrunner \
  --group squadrunner-rg \
  --location eastus \
  --size Standard_B2s
```

The script will:
- Create a resource group
- Provision Ubuntu 22.04 VM
- Configure networking
- Output connection details

#### Option B: Manual Azure CLI

```bash
# Create resource group
az group create --name squadrunner-rg --location eastus

# Create VM
az vm create \
  --resource-group squadrunner-rg \
  --name squadrunner \
  --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest \
  --size Standard_B2s \
  --admin-username azureuser \
  --generate-ssh-keys

# Open SSH port
az vm open-port \
  --resource-group squadrunner-rg \
  --name squadrunner \
  --port 22
```

#### Option C: Azure Portal

1. Go to portal.azure.com
2. Create a resource → Virtual Machine
3. Settings:
   - Image: Ubuntu 22.04 LTS
   - Size: Standard_B2s (2 vCPU, 4GB RAM)
   - Authentication: SSH public key
   - Inbound ports: SSH (22)
4. Review and create

### 2. VM Specifications

| Spec | Minimum | Recommended |
|------|---------|-------------|
| vCPU | 1 | 2 |
| RAM | 2GB | 4GB |
| Storage | 10GB | 20GB SSD |
| OS | Ubuntu 20.04 | Ubuntu 22.04 LTS |

### 3. Configure SSH Access

#### Generate SSH Key (if needed)

```bash
ssh-keygen -t ed25519 -f ~/.ssh/squadrunner_ed25519 -N ""
```

#### Copy Key to VM

```bash
ssh-copy-id -i ~/.ssh/squadrunner_ed25519.pub azureuser@<VM_IP>
```

#### Add SSH Config

Add to `~/.ssh/config`:

```
Host squadrunner
    HostName <VM_IP>
    User azureuser
    IdentityFile ~/.ssh/squadrunner_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ForwardAgent yes
```

#### Test Connection

```bash
ssh squadrunner "echo 'Connection successful!'"
```

### 4. Install Dependencies on VM

SSH into the VM and run the install script:

```bash
ssh squadrunner
```

Then on the VM:

```bash
# Download and run install script
curl -fsSL https://raw.githubusercontent.com/TheeUnderdog/SquadRunner/main/scripts/install-squad.sh | bash
```

Or manually:

```bash
# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt-get update && sudo apt-get install -y gh

# Install tmux
sudo apt-get install -y tmux

# Verify installations
node --version    # Should show v20.x
npm --version     # Should show 10.x
gh --version      # Should show gh version
tmux -V           # Should show tmux 3.x
```

### 5. Authenticate with GitHub

On the VM:

```bash
gh auth login
```

Follow the prompts:
1. Select GitHub.com
2. Select HTTPS
3. Authenticate with browser or token

Verify:

```bash
gh auth status
```

### 6. Configure tmux

Copy the tmux configuration:

```bash
# From your local machine
scp templates/tmux.conf squadrunner:~/.tmux.conf
```

Or create manually on VM:

```bash
cat > ~/.tmux.conf << 'EOF'
# Use Ctrl-a as prefix
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Enable mouse
set -g mouse on

# Increase scrollback
set -g history-limit 50000
EOF
```

### 7. Start Squad Watch

```bash
# Create tmux session
tmux new-session -d -s squad -n watch

# Start squad watch
tmux send-keys -t squad:watch "squad watch" Enter

# Attach to session
tmux attach -t squad
```

Or use the start script:

```bash
./scripts/start-watch.sh --remote --attach
```

## Verification Checklist

- [ ] VM is running and accessible via SSH
- [ ] Node.js 20+ installed
- [ ] GitHub CLI installed and authenticated
- [ ] tmux installed
- [ ] GitHub Copilot CLI installed
- [ ] squad watch running in tmux session

## Firewall Configuration

### Azure Network Security Group

Default rules for SquadRunner:

| Priority | Direction | Port | Protocol | Action |
|----------|-----------|------|----------|--------|
| 1000 | Inbound | 22 | TCP | Allow |
| 65000 | Inbound | Any | Any | Deny |
| 65000 | Outbound | Any | Any | Allow |

### VM Firewall (ufw)

```bash
# Check status
sudo ufw status

# Allow SSH only
sudo ufw allow ssh
sudo ufw enable
```

## Cost Management

### Stop VM When Not in Use

```bash
# Stop VM (still incurs storage costs)
az vm stop --resource-group squadrunner-rg --name squadrunner

# Deallocate VM (no compute costs)
az vm deallocate --resource-group squadrunner-rg --name squadrunner

# Start VM
az vm start --resource-group squadrunner-rg --name squadrunner
```

### Auto-Shutdown

Configure in Azure portal:
1. VM → Auto-shutdown
2. Set time (e.g., 7:00 PM)
3. Enable

### Cost Estimate

| Resource | Monthly Cost (East US) |
|----------|------------------------|
| Standard_B2s VM | ~$15-30 |
| 20GB Premium SSD | ~$3 |
| Network (outbound) | ~$1-5 |
| **Total** | **~$20-40/month** |

## Troubleshooting

### Cannot SSH to VM

```bash
# Check if VM is running
az vm show --resource-group squadrunner-rg --name squadrunner --query powerState

# Check public IP
az vm show --resource-group squadrunner-rg --name squadrunner --show-details --query publicIps

# Test port connectivity
nc -zv <VM_IP> 22
```

### GitHub Copilot CLI Not Found

```bash
# Check PATH
echo $PATH

# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### tmux Session Lost

```bash
# List sessions
tmux list-sessions

# If empty, recreate
tmux new-session -d -s squad
tmux send-keys -t squad "squad watch" Enter
```

### GitHub Authentication Expired

```bash
gh auth status
gh auth refresh
```

## Next Steps

- [Configure CUA](./cua-setup.md)
- [Add Squad to Project](./new-squad-guide.md)
- [Day-to-Day Workflow](./workflow.md)

