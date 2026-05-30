# Squad Starter Kit

This folder contains templates for setting up a squad in a new project repository.

## Contents

```
.squad/
├── team.md           # Squad roster and configuration
├── routing.md        # Label-based routing rules
├── README.md         # This file
└── agents/           # Agent charters
    ├── lead/
    │   └── charter.md
    ├── backend/
    │   └── charter.md
    ├── frontend/
    │   └── charter.md
    ├── data/
    │   └── charter.md
    └── scribe/
        └── charter.md
```

## Usage

### Option 1: Use add-squad.sh (Recommended)

```bash
./scripts/add-squad.sh
```

The script will prompt for your project details and copy these templates.

### Option 2: Manual Setup

1. Copy this entire `.squad/` folder to your project root
2. Edit `team.md` to customize the squad theme and roster
3. Edit `routing.md` to adjust label mappings
4. Edit agent charters as needed
5. Create GitHub labels (see below)

## Required GitHub Labels

Create these labels in your repository:

```bash
# Gate label
gh label create "squad" --color "0E8A16" --description "Ready for squad pickup"

# Priority labels
gh label create "priority:P0" --color "B60205" --description "Critical"
gh label create "priority:P1" --color "D93F0B" --description "High"
gh label create "priority:P2" --color "FBCA04" --description "Normal"
gh label create "priority:P3" --color "C5DEF5" --description "Skip - human review"

# Epic label
gh label create "epic" --color "7057FF" --description "Container issue"

# Routing labels (customize names for your theme)
gh label create "squad:lead" --color "FBCA04" --description "Route to Lead"
gh label create "squad:backend" --color "1D76DB" --description "Route to Backend"
gh label create "squad:frontend" --color "5319E7" --description "Route to Frontend"
gh label create "squad:data" --color "006B75" --description "Route to Data"
gh label create "squad:scribe" --color "BFD4F2" --description "Route to Scribe"
```

## Customization

### Themes

The starter kit uses generic role names. Popular themes include:

| Role | Oceans Eleven | A-Team | Generic |
|------|---------------|--------|---------|
| Lead | Danny | Hannibal | lead |
| Backend | Basher | B.A. | backend |
| Frontend | Linus | Murdock | frontend |
| Data | Saul | Face | data |
| Docs | Scribe | Amy | scribe |

To theme your squad:
1. Rename agent folders
2. Update `team.md` with themed names
3. Update `routing.md` with themed labels
4. Create themed GitHub labels

### Adding Agents

To add a new agent role:
1. Create `agents/<role>/charter.md`
2. Add to roster in `team.md`
3. Add routing rule in `routing.md`
4. Create `squad:<role>` label in GitHub

### Removing Agents

To remove an unused role:
1. Delete the agent folder
2. Remove from `team.md`
3. Remove from `routing.md`
4. Optionally delete the GitHub label
