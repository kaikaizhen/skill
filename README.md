# enterprise-codebase-analysis

A reusable Claude Code skill for working inside an organization's codebases:
ticket analysis and safe implementation, repository onboarding, and scoped code
explanation — backed by a persistent, organization-specific knowledge workspace.

The skill separates **how the agent works** from **what it knows about one
organization**, so the engine can be reused anywhere:

```
enterprise-codebase-analysis/
├── SKILL.md        router: applicability, mode selection, hard rules, routing
├── references/     HOW the agent works  (reusable — published)
├── templates/      reusable document + memory structures (published)
└── workspace/      WHAT it knows about one organization  (NOT published)
    ├── PROFILE.md      organization manifest
    ├── references/     organization-only tooling procedures
    └── memory/
        ├── global/        organization-wide concepts
        ├── shared/        proven across several repositories
        └── repositories/  per-repository implementation knowledge
```

## What is and is not in this repository

`workspace/` is **git-ignored**. Only an empty skeleton is committed, so a clone
has the directories it needs. No organization architecture, repository names,
business rules, schemas, endpoints, credentials or hosts are published here.

## Getting started

```bash
git clone https://github.com/kaikaizhen/skill.git
# make the skill visible to Claude Code (Windows)
#   New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\enterprise-codebase-analysis" `
#            -Target "<clone>\enterprise-codebase-analysis"
# macOS / Linux
#   ln -s "<clone>/enterprise-codebase-analysis" ~/.claude/skills/enterprise-codebase-analysis

cd enterprise-codebase-analysis/workspace
cp PROFILE.example.md PROFILE.md      # then fill it in for your organization
```

Then point the skill at your first repository and run **Mode B** (repository
onboarding). It reads the repository, produces an inline summary, and seeds
`workspace/memory/repositories/<repo>/` from the templates. Knowledge accumulates
from there, governed by the admission policy in
`references/memory-admission.md` — memory growth is intentional, never automatic.

## The three modes

| Mode | For | Ends with |
|---|---|---|
| **A — Ticket** | a ticket / bug / feature / refactor / migration, or the impact of a requirement | analysis → approval → local implementation → approval → local commit |
| **B — Onboarding** | understanding a repository as a whole | inline summary + seeded memory (read-only) |
| **C — Scoped Explanation** | one API / service / flow, with no ticket behind it | business meaning → technical flow → where to look (read-only) |

## Safety model

The engine never pushes, never opens a PR/MR, never merges, and never mutates a
database without explicit approval. Implementation and the local commit are each
gated on human approval, existing test coverage is preserved, and any change to an
existing flow is checked against the authoritative baseline for silent contract
regressions. Current repository evidence always outranks stored memory.

## License

MIT
