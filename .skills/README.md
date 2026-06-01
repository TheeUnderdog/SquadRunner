# Skills

Skills are instruction sets that define how agents operate. They're markdown files loaded at session start or on invocation.

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

**Invocation:** `/cos`, `/working-agreements`, or automatically loaded on session start.

## For Squad

Squad reads skills from `.squad/skills/` in the project repo. Each skill is a folder containing a `SKILL.md` file:

```
<repo>/.squad/skills/
├── working-agreements/
│   └── SKILL.md          # DoR, DoD, ADRs, code review
├── ralph-rules/
│   └── SKILL.md          # Backlog pickup behavior
└── dev-workflow/
    └── SKILL.md          # Branch, commit, PR, merge
```

Skill files use YAML frontmatter to declare metadata:

```yaml
---
name: "working-agreements"
description: "Definition of Ready, Definition of Done, ADR format"
domain: "process"
confidence: "high"
source: "manual"
---
```

See [Squad documentation](https://github.com/bradygaster/squad) for the full skill schema.

## Skills in this repo

This repo uses `.skills/` for CUA skills (the PO/CUA working agreement). For Squad skills, copy to `.squad/skills/` in your project.

| Skill | Purpose | Format | Used by |
|-------|---------|--------|---------|
| `chief-of-staff.md` | PO/CUA working agreement, engagement intake | CUA format | CUA only |
| `working-agreements.md` | DoR, DoD, ADRs, code review, house style | Either | CUA + Squad |
| `ralph-rules.md` | Backlog polling, label routing, priority handling | Squad SKILL.md | Squad (Ralph) |
| `dev-workflow.md` | Branch naming, commits, PRs, merge criteria | Either | CUA + Squad |

## Adding a skill to your CUA

1. Create folder: `~/.copilot/m-skills/<skill-name>/`
2. Create `SKILL.md` with the skill content
3. Invoke with `/<skill-name>` or it loads automatically

## Adding skills to Squad

1. Create `.squad/skills/<skill-name>/` folder in repo
2. Create `SKILL.md` with YAML frontmatter + content
3. Commit and push
4. Squad agents discover them automatically

## Skill format

Skills are plain markdown. Structure varies by purpose, but typically include:

- **Purpose statement** at the top
- **Rules and conventions** as bullet lists or tables
- **Examples** where helpful
- **No code blocks unless showing commands**

Keep skills focused. One skill = one concern.