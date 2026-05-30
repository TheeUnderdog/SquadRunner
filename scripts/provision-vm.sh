#!/usr/bin/env bash
#
# provision-vm.sh - Provision an Azure VM for SquadRunner
#
# Usage: ./provision-vm.sh [options]
#
# Options:
#   -n, --name NAME       VM name (default: squadrunner)
#   -g, --group GROUP     Resource group (default: squadrunner-rg)
#   -l, --location LOC    Azure region (default: eastus)
#   -s, --size SIZE       VM size (default: Standard_B2s)
#   -h, --help            Show this help message
#
# Prerequisites:
#   - Azure CLI installed and logged in (az login)
#   - Subscription selected (az account set -s <subscription>)

set -euo pipefail

# Default values
VM_NAME="${VM_NAME:-squadrunner}"
RESOURCE_GROUP="${RESOURCE_GROUP:-squadrunner-rg}"
LOCATION="${LOCATION:-eastus}"
VM_SIZE="${VM_SIZE:-Standard_B2s}"
IMAGE="Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest"
ADMIN_USER="azureuser"

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
    head -20 "$0" | tail -15
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            VM_NAME="$2"
            shift 2
            ;;
        -g|--group)
            RESOURCE_GROUP="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -s|--size)
            VM_SIZE="$2"
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

# Check prerequisites
log_info "Checking prerequisites..."

if ! command -v az &> /dev/null; then
    log_error "Azure CLI is not installed. Install it from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi

if ! az account show &> /dev/null; then
    log_error "Not logged in to Azure. Run 'az login' first."
    exit 1
fi

SUBSCRIPTION=$(az account show --query name -o tsv)
log_info "Using subscription: $SUBSCRIPTION"

# Create resource group
log_info "Creating resource group '$RESOURCE_GROUP' in '$LOCATION'..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

# Create VM
log_info "Creating VM '$VM_NAME' (this may take a few minutes)..."
VM_OUTPUT=$(az vm create \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --image "$IMAGE" \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USER" \
    --generate-ssh-keys \
    --public-ip-sku Standard \
    --output json)

PUBLIC_IP=$(echo "$VM_OUTPUT" | jq -r '.publicIpAddress')

# Open SSH port (should be open by default, but ensure it)
log_info "Configuring network security group..."
az vm open-port \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --port 22 \
    --priority 1000 \
    --output none 2>/dev/null || true

# Output connection info
echo ""
echo "=============================================="
echo -e "${GREEN}VM provisioned successfully!${NC}"
echo "=============================================="
echo ""
echo "VM Details:"
echo "  Name:         $VM_NAME"
echo "  Public IP:    $PUBLIC_IP"
echo "  Username:     $ADMIN_USER"
echo "  OS:           Ubuntu 22.04 LTS"
echo "  Size:         $VM_SIZE"
echo ""
echo "Connect with:"
echo "  ssh $ADMIN_USER@$PUBLIC_IP"
echo ""
echo "Next steps:"
echo "  1. Run ./scripts/install-squad.sh on the VM"
echo "  2. Run ./scripts/configure-ssh.sh locally"
echo "  3. Run ./scripts/start-watch.sh to start squad watch"
echo ""
echo "SSH Config snippet (add to ~/.ssh/config):"
echo ""
echo "Host squadrunner"
echo "    HostName $PUBLIC_IP"
echo "    User $ADMIN_USER"
echo "    IdentityFile ~/.ssh/id_rsa"
echo ""

# Save connection info to file
CONNECTION_FILE="vm-connection.txt"
cat > "$CONNECTION_FILE" << EOF
# SquadRunner VM Connection Info
# Generated: $(date)

VM_NAME=$VM_NAME
PUBLIC_IP=$PUBLIC_IP
ADMIN_USER=$ADMIN_USER
RESOURCE_GROUP=$RESOURCE_GROUP

# Connect command:
# ssh $ADMIN_USER@$PUBLIC_IP
EOF

log_info "Connection info saved to $CONNECTION_FILE"
