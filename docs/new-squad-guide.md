# New Squad Guide

This guide walks through adding a squad to a new project repository.

## Prerequisites

- Git repository (local clone)
- GitHub remote configured
- GitHub CLI installed and authenticated (`gh auth status`)
- SquadRunner VM running (optional, for execution)

## Quick Start

```bash
# Navigate to your project
cd /path/to/your/project

# Run the add-squad script
./path/to/SquadRunner/scripts/add-squad.sh
```

Follow the prompts to configure your squad.

## Step-by-Step Guide

### Step 1: Choose a Squad Theme

SquadRunner supports themed squads. Choose one:

| Theme | Lead | Backend | Frontend | Data | Scribe |
|-------|------|---------|----------|------|--------|
| `generic` | lead | backend | frontend | data | scribe |
| `oceans-eleven` | danny | basher | linus | saul | scribe |
| `a-team` | hannibal | ba | murdock | face | amy |

Themes are cosmetic. Choose based on team preference.

### Step 2: Run add-squad.sh

```bash
./scripts/add-squad.sh \
  --path /path/to/project \
  --theme oceans-eleven \
  --remote owner/repo-name
```

Or interactive mode:

```bash
./scripts/add-squad.sh
```

The script will:
1. Create `.squad/` folder structure
2. Generate `team.md` and `routing.md`
3. Create agent charters
4. Create GitHub labels
5. Create a tracking epic

### Step 3: Review Configuration

Check the generated files:

```
.squad/
├── team.md           # Squad roster
├── routing.md        # Label routing rules
└── agents/
    ├── danny/
    │   └── charter.md
    ├── basher/
    │   └── charter.md
    └── ...
```

Edit as needed:
- Customize agent charters for your project
- Adjust routing rules
- Add project-specific instructions

### Step 4: Add Skills (Optional)

Copy skill files for CUA guidance:

```bash
# From SquadRunner repo
cp -r .skills/ /path/to/your/project/.skills/
```

Or reference global skills in your CUA configuration.

### Step 5: Add GitHub Templates (Recommended)

Copy issue and PR templates:

```bash
cp -r templates/.github/ /path/to/your/project/.github/
```

This gives you:
- Squad-ready issue template
- Epic template
- Bug report template
- PR template with checklist

### Step 6: Commit Configuration

```bash
cd /path/to/your/project

# Add squad configuration
git add .squad/ .skills/ .github/

# Commit
git commit -m "Add squad configuration"

# Push
git push origin main
```

### Step 7: Verify Labels

Check that labels were created:

```bash
gh label list -R owner/repo-name
```

Expected labels:
- `squad` (gate)
- `priority:P0`, `priority:P1`, `priority:P2`, `priority:P3`
- `epic`
- `squad:danny`, `squad:basher`, etc. (per theme)

### Step 8: Connect to SquadRunner VM

On the VM:

```bash
# Clone the repo
git clone https://github.com/owner/repo-name.git

# Or pull if already cloned
cd repo-name && git pull

# Start watching
squad watch
```

## Creating Your First Issue

### Manual Creation

```bash
gh issue create \
  --title "Add health check endpoint" \
  --body "## Goal
Add /health endpoint for monitoring.

## Acceptance
- [ ] GET /health returns 200 OK
- [ ] Response includes version" \
  --label "squad,squad:basher,priority:P1" \
  -R owner/repo-name
```

### Using Issue Template

1. Go to GitHub → Issues → New Issue
2. Select "Squad-Ready Task"
3. Fill in the form
4. Submit

The issue will have correct labels and format.

## Verification Checklist

After setup, verify:

- [ ] `.squad/` folder committed to repo
- [ ] GitHub labels created
- [ ] Tracking epic issue created
- [ ] (Optional) `.skills/` folder added
- [ ] (Optional) `.github/` templates added
- [ ] VM can clone/access the repo
- [ ] `squad watch` sees the repo

## Customizing the Squad

### Adding an Agent

1. Create charter: `.squad/agents/<name>/charter.md`
2. Add to roster in `team.md`
3. Add routing rule in `routing.md`
4. Create GitHub label: `gh label create "squad:<name>"`

### Removing an Agent

1. Delete agent folder
2. Remove from `team.md`
3. Remove from `routing.md`
4. (Optional) Delete GitHub label

### Adjusting Priorities

Edit `routing.md` to change priority behavior:

```markdown
## Priority Order

P0 > P1 > P2

- P0: Critical, drop everything
- P1: High, next in queue
- P2: Normal, standard queue
- P3: Skip, requires human assignment
```

### Project-Specific Rules

Add to agent charters:

```markdown
## Project-Specific Rules

- All API endpoints must include tests
- Documentation required for public functions
- No direct database access from UI layer
```

## Multi-Squad Setup

For large projects with multiple squads:

```
.squad/
├── team.md              # Lists all squads
├── alpha/               # First squad
│   ├── team.md
│   ├── routing.md
│   └── agents/
└── beta/                # Second squad
    ├── team.md
    ├── routing.md
    └── agents/
```

Use different label prefixes:
- `squad:alpha:backend`
- `squad:beta:backend`

## Troubleshooting

### Labels Not Created

```bash
# Check GitHub CLI auth
gh auth status

# Create manually
gh label create "squad" --color "0E8A16" -R owner/repo
```

### Script Permission Denied

```bash
chmod +x scripts/add-squad.sh
```

### Git Remote Not Detected

```bash
# Check remote
git remote -v

# Set if missing
git remote add origin https://github.com/owner/repo.git
```

### Squad Watch Not Finding Issues

Verify labels on issue:
1. Must have `squad` label
2. Must have `squad:<member>` label
3. Must have `priority:P0/P1/P2` (not P3)
4. Must be in `open` state

## Next Steps

- [Day-to-Day Workflow](./workflow.md)
- [Architecture Overview](./architecture.md)
- [CUA Setup](./cua-setup.md)
