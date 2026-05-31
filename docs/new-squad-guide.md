# New Squad Guide

This guide walks through adding a squad to a new project repository.

## Prerequisites

- Git repository (local clone)
- GitHub remote configured
- Squad CLI installed (`squad --version`)
- SquadRunner VM running (optional, for execution)

## Quick Start

```bash
# Navigate to your project
cd /path/to/your/project

# Initialize squad
squad init
```

That's it. The squad is ready.

## Step-by-Step Guide

### Step 1: Initialize the Squad

```bash
cd /path/to/your/project
squad init
```

This creates the `.squad/` folder with:
- `team.md` - Squad roster and configuration
- `routing.md` - Label routing rules
- `agents/` - Agent charters

### Step 2: Review Configuration

Check the generated files:

```
.squad/
├── team.md           # Squad roster
├── routing.md        # Label routing rules
└── agents/
    └── <agent>/
        └── charter.md
```

Edit as needed:
- Customize agent charters for your project
- Adjust routing rules
- Add project-specific instructions

### Step 3: Add Skills (Optional)

Copy skill files for CUA guidance:

```bash
# From SquadRunner repo
cp -r .skills/ /path/to/your/project/.skills/
```

Or reference global skills in your CUA configuration.

### Step 4: Add GitHub Templates (Recommended)

Copy issue and PR templates:

```bash
cp -r templates/.github/ /path/to/your/project/.github/
```

This gives you:
- Squad-ready issue template
- Epic template
- Bug report template
- PR template with checklist

### Step 5: Commit Configuration

```bash
cd /path/to/your/project

# Add squad configuration
git add .squad/ .skills/ .github/

# Commit
git commit -m "Add squad configuration"

# Push
git push origin main
```

### Step 6: Connect to SquadRunner VM

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

### Via CUA

Tell the CUA what you need:

```
"Create an issue for adding a health check endpoint and route it to backend"
```

The CUA will create the issue with proper labels.

### Manual Creation

```bash
gh issue create \
  --title "Add health check endpoint" \
  --body "## Goal
Add /health endpoint for monitoring.

## Acceptance
- [ ] GET /health returns 200 OK
- [ ] Response includes version" \
  --label "squad,squad:backend,priority:P1" \
  -R owner/repo-name
```

Labels are created automatically on first use.

### Using Issue Template

1. Go to GitHub -> Issues -> New Issue
2. Select "Squad-Ready Task"
3. Fill in the form
4. Submit

## Verification Checklist

After setup, verify:

- [ ] `.squad/` folder committed to repo
- [ ] (Optional) `.skills/` folder added
- [ ] (Optional) `.github/` templates added
- [ ] VM can clone/access the repo
- [ ] `squad watch` sees the repo

## Customizing the Squad

### Adding an Agent

1. Create charter: `.squad/agents/<name>/charter.md`
2. Add to roster in `team.md`
3. Add routing rule in `routing.md`

Labels are created when first used on an issue.

### Removing an Agent

1. Delete agent folder
2. Remove from `team.md`
3. Remove from `routing.md`

### Project-Specific Rules

Add to agent charters:

```markdown
## Project-Specific Rules

- All API endpoints must include tests
- Documentation required for public functions
- No direct database access from UI layer
```

## Troubleshooting

### Squad Init Fails

Ensure you are in a git repository:

```bash
git status
```

### Squad Watch Not Finding Issues

Verify labels on issue:
1. Must have `squad` label
2. Must have `squad:<member>` label
3. Must have `priority:P0/P1/P2` (not P3)
4. Must be in `open` state

### Git Remote Not Detected

```bash
# Check remote
git remote -v

# Set if missing
git remote add origin https://github.com/owner/repo.git
```

## Next Steps

- [Day-to-Day Workflow](./workflow.md)
- [Architecture Overview](./architecture.md)
- [CUA Setup](./cua-setup.md)
