#!/usr/bin/env bash
#
# add-squad.sh - Add a squad to a new project repository
#
# Usage: ./add-squad.sh [options]
#
# Options:
#   -p, --path PATH       Project repo path (default: current directory)
#   -t, --theme THEME     Squad theme: generic, oceans-eleven, a-team (default: generic)
#   -r, --remote REMOTE   GitHub remote (default: auto-detect from git)
#   -y, --yes             Skip confirmation prompts
#   -h, --help            Show this help message
#
# This script:
#   - Creates .squad/ folder structure
#   - Creates GitHub labels
#   - Creates a tracking epic issue
#   - Outputs next steps

set -euo pipefail

# Default values
PROJECT_PATH="${PROJECT_PATH:-.}"
THEME="${THEME:-generic}"
GITHUB_REMOTE=""
SKIP_CONFIRM=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

prompt() {
    echo -e "${BLUE}[?]${NC} $1"
}

show_help() {
    head -18 "$0" | tail -15
    exit 0
}

# Theme configurations
declare -A THEME_LEAD=( ["generic"]="lead" ["oceans-eleven"]="danny" ["a-team"]="hannibal" )
declare -A THEME_BACKEND=( ["generic"]="backend" ["oceans-eleven"]="basher" ["a-team"]="ba" )
declare -A THEME_FRONTEND=( ["generic"]="frontend" ["oceans-eleven"]="linus" ["a-team"]="murdock" )
declare -A THEME_DATA=( ["generic"]="data" ["oceans-eleven"]="saul" ["a-team"]="face" )
declare -A THEME_SCRIBE=( ["generic"]="scribe" ["oceans-eleven"]="scribe" ["a-team"]="amy" )

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--path)
            PROJECT_PATH="$2"
            shift 2
            ;;
        -t|--theme)
            THEME="$2"
            shift 2
            ;;
        -r|--remote)
            GITHUB_REMOTE="$2"
            shift 2
            ;;
        -y|--yes)
            SKIP_CONFIRM=true
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

# Validate theme
if [[ ! "${THEME_LEAD[$THEME]+isset}" ]]; then
    log_error "Invalid theme: $THEME"
    echo "Available themes: generic, oceans-eleven, a-team"
    exit 1
fi

# Get role names for theme
ROLE_LEAD="${THEME_LEAD[$THEME]}"
ROLE_BACKEND="${THEME_BACKEND[$THEME]}"
ROLE_FRONTEND="${THEME_FRONTEND[$THEME]}"
ROLE_DATA="${THEME_DATA[$THEME]}"
ROLE_SCRIBE="${THEME_SCRIBE[$THEME]}"

# Interactive mode if not all required info provided
if [[ "$PROJECT_PATH" == "." ]] && [[ "$SKIP_CONFIRM" == "false" ]]; then
    echo ""
    echo "╔══════════════════════════════════════════════╗"
    echo "║         Add Squad to Project                 ║"
    echo "╚══════════════════════════════════════════════╝"
    echo ""
    
    prompt "Project path (Enter for current directory):"
    read -r INPUT_PATH
    if [[ -n "$INPUT_PATH" ]]; then
        PROJECT_PATH="$INPUT_PATH"
    fi
fi

# Validate project path
if [[ ! -d "$PROJECT_PATH" ]]; then
    log_error "Directory does not exist: $PROJECT_PATH"
    exit 1
fi

cd "$PROJECT_PATH"

# Check if it's a git repo
if [[ ! -d ".git" ]]; then
    log_error "Not a git repository: $PROJECT_PATH"
    exit 1
fi

# Auto-detect GitHub remote if not provided
if [[ -z "$GITHUB_REMOTE" ]]; then
    GITHUB_REMOTE=$(git remote get-url origin 2>/dev/null | sed 's/.*github.com[:/]//' | sed 's/\.git$//' || true)
fi

if [[ -z "$GITHUB_REMOTE" ]]; then
    log_error "Could not detect GitHub remote. Use -r to specify."
    exit 1
fi

# Confirm before proceeding
if [[ "$SKIP_CONFIRM" == "false" ]]; then
    echo ""
    echo "Configuration:"
    echo "  Project:  $(pwd)"
    echo "  GitHub:   $GITHUB_REMOTE"
    echo "  Theme:    $THEME"
    echo ""
    echo "Roles:"
    echo "  Lead:     $ROLE_LEAD"
    echo "  Backend:  $ROLE_BACKEND"
    echo "  Frontend: $ROLE_FRONTEND"
    echo "  Data:     $ROLE_DATA"
    echo "  Scribe:   $ROLE_SCRIBE"
    echo ""
    prompt "Proceed? [Y/n]"
    read -r CONFIRM
    if [[ "$CONFIRM" =~ ^[Nn] ]]; then
        log_info "Cancelled"
        exit 0
    fi
fi

# Check if gh CLI is available and authenticated
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is not installed"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    log_error "Not authenticated with GitHub. Run 'gh auth login' first."
    exit 1
fi

# Check if .squad already exists
if [[ -d ".squad" ]]; then
    log_warn ".squad directory already exists"
    prompt "Overwrite? [y/N]"
    read -r OVERWRITE
    if [[ ! "$OVERWRITE" =~ ^[Yy] ]]; then
        log_info "Keeping existing .squad directory"
    else
        rm -rf .squad
    fi
fi

# Create .squad directory structure
log_info "Creating .squad directory..."
mkdir -p .squad/agents/$ROLE_LEAD
mkdir -p .squad/agents/$ROLE_BACKEND
mkdir -p .squad/agents/$ROLE_FRONTEND
mkdir -p .squad/agents/$ROLE_DATA
mkdir -p .squad/agents/$ROLE_SCRIBE
mkdir -p .squad/engagements

# Copy and customize templates
log_info "Creating team.md..."
cat > .squad/team.md << EOF
# Squad Charter

> Squad configuration for $(basename "$(pwd)")
> Theme: $THEME

## Roster

| Agent | Role | Handles |
|-------|------|---------|
| $ROLE_LEAD | Lead/Architect | Triage, breakdown, design decisions |
| $ROLE_BACKEND | Backend Dev | Scripts, CLI, APIs, infrastructure |
| $ROLE_FRONTEND | Frontend Dev | UI, components, user-facing features |
| $ROLE_DATA | Data Engineer | Pipelines, schemas, data processing |
| $ROLE_SCRIBE | Documentation | Docs, README, decision records |

## Operating Model

- **Backlog-driven**: All work comes from GitHub issues
- **Label-routed**: \`squad:<member>\` labels route to specific agents
- **Priority-ordered**: P0 > P1 > P2 (P3 is skip)
- **PR-based**: All changes via pull request
- **CI-gated**: Green CI required for merge

## Labels

Required for pickup:
- \`squad\` - Gate label
- \`squad:<member>\` - Routes to specific agent
- \`priority:P0/P1/P2\` - Priority level

## Standards

See \`.skills/\` folder for operating rules.
EOF

log_info "Creating routing.md..."
cat > .squad/routing.md << EOF
# Routing Rules

## Member Routes

| Label | Routes To | Handles |
|-------|-----------|---------|
| \`squad:$ROLE_LEAD\` | $ROLE_LEAD | Triage, architecture |
| \`squad:$ROLE_BACKEND\` | $ROLE_BACKEND | Scripts, CLI, APIs |
| \`squad:$ROLE_FRONTEND\` | $ROLE_FRONTEND | UI, components |
| \`squad:$ROLE_DATA\` | $ROLE_DATA | Pipelines, schemas |
| \`squad:$ROLE_SCRIBE\` | $ROLE_SCRIBE | Documentation |

## Priority Order

\`priority:P0\` > \`priority:P1\` > \`priority:P2\`

P3 requires human intervention.

## Skip Conditions

- Has \`epic\` label
- Has \`blocked\` label
- Has \`priority:P3\` label
- Lacks \`squad\` gate label
EOF

# Create agent charters
for ROLE in "$ROLE_LEAD" "$ROLE_BACKEND" "$ROLE_FRONTEND" "$ROLE_DATA" "$ROLE_SCRIBE"; do
    cat > ".squad/agents/$ROLE/charter.md" << EOF
# $ROLE Charter

## Role
Agent charter for $ROLE in the $THEME squad.

## Pickup Criteria
- \`squad:$ROLE\` label
- \`priority:P0/P1/P2\` label
- No \`blocked\` label

## Responsibilities
[Customize based on role]
EOF
done

# Create GitHub labels
log_info "Creating GitHub labels..."

create_label() {
    local name="$1"
    local color="$2"
    local desc="$3"
    
    if gh label create "$name" --color "$color" --description "$desc" -R "$GITHUB_REMOTE" 2>/dev/null; then
        echo "  Created: $name"
    else
        echo "  Exists:  $name"
    fi
}

# Gate label
create_label "squad" "0E8A16" "Ready for squad pickup"

# Priority labels
create_label "priority:P0" "B60205" "Critical"
create_label "priority:P1" "D93F0B" "High"
create_label "priority:P2" "FBCA04" "Normal"
create_label "priority:P3" "C5DEF5" "Skip - human review required"

# Epic label
create_label "epic" "7057FF" "Container issue"

# Routing labels
create_label "squad:$ROLE_LEAD" "FBCA04" "Route to $ROLE_LEAD"
create_label "squad:$ROLE_BACKEND" "1D76DB" "Route to $ROLE_BACKEND"
create_label "squad:$ROLE_FRONTEND" "5319E7" "Route to $ROLE_FRONTEND"
create_label "squad:$ROLE_DATA" "006B75" "Route to $ROLE_DATA"
create_label "squad:$ROLE_SCRIBE" "BFD4F2" "Route to $ROLE_SCRIBE"

# Status labels
create_label "blocked" "D93F0B" "Blocked - cannot proceed"
create_label "in-progress" "0E8A16" "Currently being worked"

# Create tracking epic
log_info "Creating tracking epic..."
EPIC_BODY="## Squad Setup Complete

This repo is now configured for squad operation.

### Configuration
- Theme: $THEME
- Roles: $ROLE_LEAD, $ROLE_BACKEND, $ROLE_FRONTEND, $ROLE_DATA, $ROLE_SCRIBE

### Getting Started
1. Groom issues with \`squad\` + \`squad:<member>\` + \`priority:P*\` labels
2. Connect SquadRunner VM to this repo
3. Run \`squad watch\` to start picking up issues

### Documentation
- See \`.squad/team.md\` for roster
- See \`.squad/routing.md\` for label routing
- See \`.skills/\` for operating rules (if present)
"

EPIC_URL=$(gh issue create \
    --title "[Setup] Squad Configuration Complete" \
    --body "$EPIC_BODY" \
    --label "epic" \
    -R "$GITHUB_REMOTE")

log_info "Created epic: $EPIC_URL"

# Final output
echo ""
echo "=============================================="
echo -e "${GREEN}Squad added successfully!${NC}"
echo "=============================================="
echo ""
echo "Created:"
echo "  .squad/team.md"
echo "  .squad/routing.md"
echo "  .squad/agents/*/charter.md"
echo ""
echo "GitHub labels created for $GITHUB_REMOTE"
echo ""
echo "Next steps:"
echo "  1. Commit the .squad/ folder:"
echo "     git add .squad/ && git commit -m 'Add squad configuration'"
echo ""
echo "  2. Push to GitHub:"
echo "     git push origin main"
echo ""
echo "  3. Connect SquadRunner VM:"
echo "     ssh squadrunner"
echo "     cd /path/to/repo && squad watch"
echo ""
echo "  4. Create your first squad-ready issue with labels:"
echo "     squad + squad:$ROLE_BACKEND + priority:P1"
echo ""
