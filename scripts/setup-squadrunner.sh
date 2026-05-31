#!/bin/bash
# SquadRunner Setup Script
# Deploys VM, installs dependencies, configures SSH/tmux, sets up logging

set -e

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
VM_NAME="${VM_NAME:-squadrunner}"
RESOURCE_GROUP="${RESOURCE_GROUP:-squadrunner-rg}"
LOCATION="${LOCATION:-eastus}"
VM_SIZE="${VM_SIZE:-Standard_B2s}"
ADMIN_USER="${ADMIN_USER:-azureuser}"
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/squadrunner_ed25519}"

#------------------------------------------------------------------------------
# Colors
#------------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[+]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

#------------------------------------------------------------------------------
# Phase 1: Generate SSH Key
#------------------------------------------------------------------------------
log "Phase 1: SSH Key"

if [ ! -f "$SSH_KEY_PATH" ]; then
    log "Generating SSH key: $SSH_KEY_PATH"
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "squadrunner"
else
    log "SSH key exists: $SSH_KEY_PATH"
fi

#------------------------------------------------------------------------------
# Phase 2: Deploy VM
#------------------------------------------------------------------------------
log "Phase 2: Deploy VM"

# Check if Azure CLI is installed
command -v az >/dev/null 2>&1 || error "Azure CLI not installed. Run: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"

# Check if logged in
az account show >/dev/null 2>&1 || error "Not logged in to Azure. Run: az login"

# Create resource group
log "Creating resource group: $RESOURCE_GROUP"
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

# Create VM
log "Creating VM: $VM_NAME (this may take a few minutes)"
VM_OUTPUT=$(az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USER" \
    --ssh-key-value "$SSH_KEY_PATH.pub" \
    --public-ip-sku Standard \
    --output json)

VM_IP=$(echo "$VM_OUTPUT" | grep -o '"publicIpAddress": "[^"]*"' | cut -d'"' -f4)
log "VM deployed at: $VM_IP"

# Open SSH port
log "Configuring network security"
az vm open-port --resource-group "$RESOURCE_GROUP" --name "$VM_NAME" --port 22 --output none

#------------------------------------------------------------------------------
# Phase 3: Configure SSH Config
#------------------------------------------------------------------------------
log "Phase 3: SSH Config"

SSH_CONFIG="$HOME/.ssh/config"
if ! grep -q "Host $VM_NAME" "$SSH_CONFIG" 2>/dev/null; then
    log "Adding SSH config entry"
    cat >> "$SSH_CONFIG" << EOF

Host $VM_NAME
    HostName $VM_IP
    User $ADMIN_USER
    IdentityFile $SSH_KEY_PATH
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ForwardAgent yes
EOF
    chmod 600 "$SSH_CONFIG"
else
    warn "SSH config entry exists, updating IP"
    sed -i "s/HostName .*/HostName $VM_IP/" "$SSH_CONFIG"
fi

# Wait for VM to be ready
log "Waiting for VM to accept SSH connections..."
for i in {1..30}; do
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$VM_NAME" "echo ok" 2>/dev/null; then
        break
    fi
    sleep 5
done

#------------------------------------------------------------------------------
# Phase 4: Install Dependencies on VM
#------------------------------------------------------------------------------
log "Phase 4: Install Dependencies"

ssh "$VM_NAME" << 'REMOTE_SCRIPT'
set -e

echo "[+] Updating system"
sudo apt-get update && sudo apt-get upgrade -y

echo "[+] Installing Node.js 20"
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "[+] Installing tmux"
sudo apt-get install -y tmux

echo "[+] Installing GitHub Copilot CLI"
sudo npm install -g @githubnext/github-copilot-cli

echo "[+] Installing Squad"
sudo npm install -g @anthropic/squad

echo "[+] Creating directories"
mkdir -p ~/.squad/logs
mkdir -p ~/.squad/skills

echo "[+] Verifying installations"
node --version
npm --version
gh --version || echo "gh will be authenticated next"
squad --version || echo "squad installed"

REMOTE_SCRIPT

#------------------------------------------------------------------------------
# Phase 5: Copy Skills to VM
#------------------------------------------------------------------------------
log "Phase 5: Copy Skills"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$SCRIPT_DIR/../.skills"

if [ -d "$SKILLS_DIR" ]; then
    log "Copying skills to VM (excluding chief-of-staff.md)"
    for skill in "$SKILLS_DIR"/*.md; do
        skill_name=$(basename "$skill")
        if [ "$skill_name" != "chief-of-staff.md" ]; then
            log "  - $skill_name"
            scp "$skill" "$VM_NAME:~/.squad/skills/"
        fi
    done
else
    warn "Skills directory not found: $SKILLS_DIR"
fi

#------------------------------------------------------------------------------
# Phase 6: Configure tmux
#------------------------------------------------------------------------------
log "Phase 6: Configure tmux"

ssh "$VM_NAME" << 'REMOTE_SCRIPT'
cat > ~/.tmux.conf << 'EOF'
# Use Ctrl-a as prefix
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Enable mouse
set -g mouse on

# Increase scrollback
set -g history-limit 50000

# Status bar
set -g status-right '%Y-%m-%d %H:%M'
EOF
REMOTE_SCRIPT

#------------------------------------------------------------------------------
# Phase 7: Setup Logging
#------------------------------------------------------------------------------
log "Phase 7: Setup Logging"

ssh "$VM_NAME" << 'REMOTE_SCRIPT'
# Create log rotation config
mkdir -p ~/.squad/logs

# Create a script to start squad watch with logging
cat > ~/start-squad.sh << 'EOF'
#!/bin/bash
REPO_PATH="${1:-$(pwd)}"
LOG_FILE="$HOME/.squad/logs/squad-$(date +%Y%m%d).log"

# Create or attach to tmux session
tmux has-session -t squad 2>/dev/null && tmux kill-session -t squad
tmux new-session -d -s squad -n watch

# Start squad watch with logging
tmux send-keys -t squad:watch "cd $REPO_PATH && squad watch --execute --interval 5 --verbose 2>&1 | tee -a $LOG_FILE" Enter

echo "Squad watch started. Logs: $LOG_FILE"
echo "Attach with: tmux attach -t squad"
EOF
chmod +x ~/start-squad.sh

# Create sitrep helper
cat > ~/sitrep.sh << 'EOF'
#!/bin/bash
# Send sitrep to squad session and capture output
tmux send-keys -t squad "sitrep" Enter
sleep 3
tmux capture-pane -t squad -p | tail -50
EOF
chmod +x ~/sitrep.sh
REMOTE_SCRIPT

#------------------------------------------------------------------------------
# Phase 8: GitHub Authentication Reminder
#------------------------------------------------------------------------------
log "Phase 8: GitHub Auth"

echo ""
echo "=========================================="
echo "  SquadRunner VM Setup Complete!"
echo "=========================================="
echo ""
echo "VM IP: $VM_IP"
echo "SSH:   ssh $VM_NAME"
echo ""
echo "Next steps:"
echo "  1. SSH into VM:  ssh $VM_NAME"
echo "  2. Auth GitHub:  gh auth login"
echo "  3. Clone repo:   git clone <your-repo>"
echo "  4. Start squad:  ~/start-squad.sh ~/repos/your-project"
echo ""
echo "Skills installed on VM:"
ssh "$VM_NAME" "ls ~/.squad/skills/"
echo ""
echo "Chief of Staff skill stays on your LOCAL machine"
echo "for the CUA to use when managing the backlog."
echo ""
