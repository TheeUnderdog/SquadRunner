# Skills

Skills are instruction sets that define how the CUA and Squad operate. They're markdown files loaded at session start or on invocation.

## For CUA (Claw-based Computer Use Agent)

Skills tell the CUA how to behave. Place them in your CUA's skills directory:

```
~/.copilot/m-skills/
├── cos/
│   └── SKILL.md          # Chief of Staff skill
├── working-agreements/
│   └── SKILL.md          # DoR, DoD, ADRs
└── ...
```

Or place them in the project repo's `.skills/` folder for project-specific rules.

**Invocation:** `/cos`, `/working-agreements`, or automatically loaded on session start.

## For Squad

Squad agents read skills from the project repo. Place them in:

```
<repo>/.skills/
├── chief-of-staff.md     # PO/CUA working agreement
├── working-agreements.md # DoR, DoD, ADRs, code review
├── ralph-rules.md        # Backlog pickup behavior
└── dev-workflow.md       # Branch, commit, PR, merge
```

Squad agents reference these when executing work.

## Skills in this repo

| Skill | Purpose | Used by |
|-------|---------|---------|
| `chief-of-staff.md` | PO/CUA working agreement, engagement intake | CUA |
| `working-agreements.md` | DoR, DoD, ADRs, code review, house style | CUA + Squad |
| `ralph-rules.md` | Backlog polling, label routing, priority handling | Squad (Ralph) |
| `dev-workflow.md` | Branch naming, commits, PRs, merge criteria | Squad |

## Adding a skill to your CUA

1. Create folder: `~/.copilot/m-skills/<skill-name>/`
2. Create `SKILL.md` with the skill content
3. Invoke with `/<skill-name>` or it loads automatically

## Adding skills to a project repo

1. Create `.skills/` folder in repo root
2. Copy skill files from this repo's `.skills/`
3. Customize for your project
4. Commit and push

Squad agents will read these on pickup. CUA will discover them when you open the repo.

## Skill format

Skills are plain markdown. Structure varies by purpose, but typically include:

- **Purpose statement** at the top
- **Rules and conventions** as bullet lists or tables
- **Examples** where helpful
- **No code blocks unless showing commands**

Keep skills focused. One skill = one concern.