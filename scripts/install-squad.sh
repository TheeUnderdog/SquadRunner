#!/usr/bin/env bash
#
# install-squad.sh - Install Squad CLI and dependencies on Ubuntu VM
#
# Usage: ./install-squad.sh
#
# This script installs:
#   - Node.js 20 LTS
#   - npm packages
#   - Squad CLI
#   - GitHub CLI
#   - tmux
#
# Run this on the VM after provisioning.

set -euo pipefail

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

# Check if running on Ubuntu
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    log_warn "This script is designed for Ubuntu. Proceeding anyway..."
fi

# Update system packages
log_info "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install essential tools
log_info "Installing essential tools..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    tmux \
    jq \
    unzip \
    build-essential

# Install Node.js 20 LTS
log_info "Installing Node.js 20 LTS..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    log_info "Node.js already installed: $NODE_VERSION"
else
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
fi

# Verify Node.js installation
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)
log_info "Node.js version: $NODE_VERSION"
log_info "npm version: $NPM_VERSION"

# Install GitHub CLI
log_info "Installing GitHub CLI..."
if command -v gh &> /dev/null; then
    GH_VERSION=$(gh --version | head -1)
    log_info "GitHub CLI already installed: $GH_VERSION"
else
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y gh
fi

# Install Squad CLI
log_info "Installing Squad CLI..."
# Note: Replace with actual squad CLI installation when available
# For now, create a placeholder
mkdir -p ~/.local/bin

# Create squad CLI placeholder
cat > ~/.local/bin/squad << 'SQUAD_CLI'
#!/usr/bin/env bash
#
# Squad CLI - Placeholder
# Replace this with the actual Squad CLI installation

set -euo pipefail

COMMAND="${1:-help}"

case "$COMMAND" in
    watch)
        echo "Starting squad watch..."
        echo "Polling for issues with 'squad' label..."
        # Placeholder: actual watch implementation would go here
        while true; do
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Polling backlog..."
            sleep 60
        done
        ;;
    status)
        echo "Squad CLI Status"
        echo "  Node.js: $(node --version)"
        echo "  npm: $(npm --version)"
        echo "  gh: $(gh --version | head -1)"
        ;;
    help|*)
        echo "Squad CLI"
        echo ""
        echo "Usage: squad <command>"
        echo ""
        echo "Commands:"
        echo "  watch   - Start watching for backlog issues"
        echo "  status  - Show CLI status"
        echo "  help    - Show this help message"
        ;;
esac
SQUAD_CLI

chmod +x ~/.local/bin/squad

# Add to PATH if not already
if ! grep -q '.local/bin' ~/.bashrc; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

# Create squad directories
log_info "Creating squad directories..."
mkdir -p ~/.squad/logs
mkdir -p ~/.squad/config

# Copy tmux config if available
if [[ -f ./templates/tmux.conf ]]; then
    cp ./templates/tmux.conf ~/.tmux.conf
    log_info "Copied tmux configuration"
fi

# Final verification
echo ""
echo "=============================================="
echo -e "${GREEN}Installation complete!${NC}"
echo "=============================================="
echo ""
echo "Installed versions:"
echo "  Node.js:    $(node --version)"
echo "  npm:        $(npm --version)"
echo "  GitHub CLI: $(gh --version | head -1)"
echo "  tmux:       $(tmux -V)"
echo "  Squad CLI:  ~/.local/bin/squad (placeholder)"
echo ""
echo "Next steps:"
echo "  1. Authenticate with GitHub: gh auth login"
echo "  2. Clone your project repo"
echo "  3. Run: squad watch"
echo ""
echo "Or start a tmux session:"
echo "  tmux new-session -s squad"
echo "  squad watch"
echo ""

# Remind to reload shell
log_warn "Run 'source ~/.bashrc' or start a new shell to update PATH"
