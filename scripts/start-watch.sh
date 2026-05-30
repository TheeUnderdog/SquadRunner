#!/usr/bin/env bash
#
# start-watch.sh - Start squad watch in a tmux session
#
# Usage: ./start-watch.sh [options]
#
# Options:
#   -s, --session NAME    tmux session name (default: squad)
#   -r, --remote          Run on remote VM via SSH
#   -a, --attach          Attach to session after starting
#   -h, --help            Show this help message
#
# This script:
#   - Creates or attaches to a tmux session
#   - Starts squad watch in the session
#   - Optionally attaches to the session

set -euo pipefail

# Default values
SESSION_NAME="${SESSION_NAME:-squad}"
REMOTE=false
ATTACH=false

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
    head -16 "$0" | tail -13
    exit 0
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--session)
            SESSION_NAME="$2"
            shift 2
            ;;
        -r|--remote)
            REMOTE=true
            shift
            ;;
        -a|--attach)
            ATTACH=true
            shift
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

start_local() {
    # Check if tmux is installed
    if ! command -v tmux &> /dev/null; then
        log_error "tmux is not installed"
        exit 1
    fi

    # Check if squad CLI is available
    if ! command -v squad &> /dev/null; then
        log_error "squad CLI is not installed or not in PATH"
        exit 1
    fi

    # Check if session already exists
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        log_info "Session '$SESSION_NAME' already exists"
        
        if [[ "$ATTACH" == "true" ]]; then
            log_info "Attaching to existing session..."
            tmux attach -t "$SESSION_NAME"
        else
            echo ""
            echo "To attach: tmux attach -t $SESSION_NAME"
            echo "To kill:   tmux kill-session -t $SESSION_NAME"
        fi
        return
    fi

    # Create new session
    log_info "Creating tmux session '$SESSION_NAME'..."
    tmux new-session -d -s "$SESSION_NAME" -n watch

    # Start squad watch
    log_info "Starting squad watch..."
    tmux send-keys -t "$SESSION_NAME:watch" "squad watch" Enter

    # Create a logs window
    tmux new-window -t "$SESSION_NAME" -n logs
    tmux send-keys -t "$SESSION_NAME:logs" "tail -f ~/.squad/logs/squad.log 2>/dev/null || echo 'No log file yet'" Enter

    # Go back to watch window
    tmux select-window -t "$SESSION_NAME:watch"

    echo ""
    echo "=============================================="
    echo -e "${GREEN}Squad watch started!${NC}"
    echo "=============================================="
    echo ""
    echo "Session: $SESSION_NAME"
    echo "Windows:"
    echo "  1. watch - squad watch running"
    echo "  2. logs  - log tail"
    echo ""
    echo "Commands:"
    echo "  Attach:  tmux attach -t $SESSION_NAME"
    echo "  Detach:  Ctrl-a d (when attached)"
    echo "  Kill:    tmux kill-session -t $SESSION_NAME"
    echo ""

    if [[ "$ATTACH" == "true" ]]; then
        log_info "Attaching to session..."
        tmux attach -t "$SESSION_NAME"
    fi
}

start_remote() {
    # Check if squadrunner SSH config exists
    if ! grep -q "Host squadrunner" ~/.ssh/config 2>/dev/null; then
        log_error "SSH config for 'squadrunner' not found"
        echo ""
        echo "Run ./scripts/configure-ssh.sh first to set up SSH access"
        exit 1
    fi

    # Test connection
    log_info "Connecting to squadrunner VM..."
    if ! ssh -o ConnectTimeout=10 -o BatchMode=yes squadrunner "echo 'Connected'" 2>/dev/null; then
        log_error "Failed to connect to squadrunner VM"
        exit 1
    fi

    # Check if session already exists on remote
    if ssh squadrunner "tmux has-session -t $SESSION_NAME 2>/dev/null"; then
        log_info "Session '$SESSION_NAME' already exists on VM"
        
        if [[ "$ATTACH" == "true" ]]; then
            log_info "Attaching to remote session..."
            ssh -t squadrunner "tmux attach -t $SESSION_NAME"
        else
            echo ""
            echo "To attach: ssh -t squadrunner 'tmux attach -t $SESSION_NAME'"
        fi
        return
    fi

    # Create session on remote
    log_info "Creating tmux session on VM..."
    ssh squadrunner "tmux new-session -d -s $SESSION_NAME -n watch && tmux send-keys -t $SESSION_NAME:watch 'squad watch' Enter"

    echo ""
    echo "=============================================="
    echo -e "${GREEN}Squad watch started on VM!${NC}"
    echo "=============================================="
    echo ""
    echo "Session: $SESSION_NAME (on squadrunner VM)"
    echo ""
    echo "Commands:"
    echo "  Attach:  ssh -t squadrunner 'tmux attach -t $SESSION_NAME'"
    echo "  Status:  ssh squadrunner 'tmux list-sessions'"
    echo "  Kill:    ssh squadrunner 'tmux kill-session -t $SESSION_NAME'"
    echo ""

    if [[ "$ATTACH" == "true" ]]; then
        log_info "Attaching to remote session..."
        ssh -t squadrunner "tmux attach -t $SESSION_NAME"
    fi
}

# Main
if [[ "$REMOTE" == "true" ]]; then
    start_remote
else
    start_local
fi
