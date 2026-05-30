#!/usr/bin/env bash
#
# configure-ssh.sh - Configure SSH for SquadRunner VM access
#
# Usage: ./configure-ssh.sh [options]
#
# Options:
#   -i, --ip IP           VM IP address (required)
#   -u, --user USER       SSH username (default: azureuser)
#   -k, --key-name NAME   SSH key name (default: squadrunner_ed25519)
#   -h, --help            Show this help message
#
# This script:
#   - Generates an ed25519 SSH key pair (if needed)
#   - Copies public key to the VM
#   - Adds SSH config entry
#   - Tests the connection

set -euo pipefail

# Default values
VM_IP=""
SSH_USER="${SSH_USER:-azureuser}"
KEY_NAME="${KEY_NAME:-squadrunner_ed25519}"
SSH_DIR="$HOME/.ssh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_help() {
    head -15 "$0" | tail -12
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--ip)
            VM_IP="$2"
            shift 2
            ;;
        -u|--user)
            SSH_USER="$2"
            shift 2
            ;;
        -k|--key-name)
            KEY_NAME="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            ;;
        *)
            log_error "Unknown option: $1"
            show_help
            ;;
    esac
done

# Validate required arguments
if [[ -z "$VM_IP" ]]; then
    log_error "VM IP address is required. Use -i or --ip option."
    echo ""
    show_help
fi

# Ensure .ssh directory exists
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# Generate SSH key if it doesn't exist
KEY_PATH="$SSH_DIR/$KEY_NAME"
if [[ -f "$KEY_PATH" ]]; then
    log_info "Using existing SSH key: $KEY_PATH"
else
    log_info "Generating new ed25519 SSH key..."
    ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "squadrunner-$(date +%Y%m%d)"
    log_info "SSH key generated: $KEY_PATH"
fi

# Copy public key to VM
log_info "Copying public key to VM (you may be prompted for password)..."
if ssh-copy-id -i "${KEY_PATH}.pub" "${SSH_USER}@${VM_IP}"; then
    log_info "Public key copied successfully"
else
    log_warn "ssh-copy-id failed. You may need to manually add the key."
    echo ""
    echo "Public key content:"
    cat "${KEY_PATH}.pub"
    echo ""
    echo "Add this to ~/.ssh/authorized_keys on the VM"
fi

# Add SSH config entry
SSH_CONFIG="$SSH_DIR/config"
CONFIG_ENTRY="Host squadrunner
    HostName $VM_IP
    User $SSH_USER
    IdentityFile $KEY_PATH
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ForwardAgent yes
    Compression yes"

# Check if entry already exists
if grep -q "Host squadrunner" "$SSH_CONFIG" 2>/dev/null; then
    log_warn "SSH config entry 'squadrunner' already exists"
    echo ""
    echo "Existing entry will not be modified. To update, edit ~/.ssh/config manually."
    echo ""
    echo "New config would be:"
    echo "$CONFIG_ENTRY"
else
    # Create config file if it doesn't exist
    touch "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
    
    # Add entry
    echo "" >> "$SSH_CONFIG"
    echo "$CONFIG_ENTRY" >> "$SSH_CONFIG"
    log_info "SSH config entry added"
fi

# Test connection
log_info "Testing SSH connection..."
echo ""

if ssh -o ConnectTimeout=10 -o BatchMode=yes squadrunner "echo 'Connection successful!'" 2>/dev/null; then
    echo ""
    echo "=============================================="
    echo -e "${GREEN}SSH configured successfully!${NC}"
    echo "=============================================="
    echo ""
    echo "You can now connect with:"
    echo "  ssh squadrunner"
    echo ""
    echo "Start squad watch:"
    echo "  ssh squadrunner 'tmux new-session -d -s squad \"squad watch\"'"
    echo ""
    echo "Attach to session:"
    echo "  ssh -t squadrunner 'tmux attach -t squad'"
else
    echo ""
    log_warn "Connection test failed. This might be normal if:"
    echo "  - The VM is still starting up"
    echo "  - Password authentication is required first"
    echo ""
    echo "Try manually:"
    echo "  ssh ${SSH_USER}@${VM_IP}"
fi

echo ""
echo "SSH Config entry added to ~/.ssh/config:"
echo ""
echo "$CONFIG_ENTRY"
echo ""
