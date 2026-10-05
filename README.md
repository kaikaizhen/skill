# Skills

Reusable agent skills for software engineering workflows.

This repository is a small monorepo of agent skills. Each skill owns one clearly
bounded kind of work - understanding an organization's codebase, deciding and
generating a delivery pipeline, building trustworthy project knowledge before coding,
delivering a small task under a time budget, or publishing a project to a NAS - and
carries its own rules, references and templates.

This README is a map for people. The behaviour an agent follows lives in each skill's
`SKILL.md` (see [README vs SKILL.md](#readme-vs-skillmd)).

## Available skills

| Skill | Purpose | Best for | Changes files? |
|---|---|---|---|
| [deployment](./deployment/SKILL.md) | **Deployment Decision + CI/CD Generator.** Analyses a repository, then decides whether CI, CD, a container and Kubernetes are actually needed, which deployment target fits (CI only, VM with systemd or Docker Compose, Kubernetes, or the platform already in use), and only then generates the minimum pipeline and deployment files and validates them locally | Creating or extending CI/CD, adding a QA / production environment, reviewing whether the current deployment setup is sound | Yes - working tree only. Never deploys, never commits or pushes |
| [enterprise-codebase-analysis](./enterprise-codebase-analysis/SKILL.md) | Analysis and safe-implementation engine for **an organization's own repositories**, backed by a persistent, git-ignored organization knowledge workspace. Three modes: ticket work (analysis -> approval -> implementation -> approval -> local commit), repository onboarding, scoped code explanation | Tickets, bugs, features and impact analysis in organization repositories; onboarding to one; explaining an API or flow in one | Ticket mode only, after explicit approval; local commit after a second approval. Never pushes or opens MR / PR |
| [harness-engineering](./harness-engineering/SKILL.md) | Builds **trustworthy upstream knowledge before coding starts**: source extraction -> requirements and open questions -> project context -> human-owned architecture decisions (ADRs). Every artifact must pass an independent evaluation gate | Starting a new project on a reliable footing, turning a spec / brief into validated requirements and context for a coding agent, running an architecture decision workflow | Writes knowledge artifacts (requirements, context, ADRs, evaluations); does not write application code |
| [harness-engineering-fast](./harness-engineering-fast/SKILL.md) | Delivers a **small, verified task inside a hard time budget** (60-180 min, default 90) with one execution contract, minimum architecture, early implementation and reserved verification time | Timed coding challenges, take-home exercises, MVP spikes, prototypes, small bounded features - when no human may be available mid-task | Yes - code plus one execution contract |
| [harness-engineering-rapid-hitl](./harness-engineering-rapid-hitl/SKILL.md) | Delivers a small task fast **with a live human in the loop**: understands just enough, asks only genuinely blocking questions, builds vertical slices, verifies with real evidence, re-understands as it learns | The same kind of 60-180 min work - including features inside an existing project - when someone can answer short questions during implementation | Yes - code plus one thin, mutable contract |
| [ssh-publish](./ssh-publish/SKILL.md) | **Executes** a deployment of a local project to the user's SSH-reachable Docker host (e.g. a NAS): local build, image transfer over SSH, compose up, Nginx config, backup-first update, health check, verified rollback | Explicit requests to publish or update a project **on the NAS** | Changes the remote host; Git is read-only |

## How to choose a skill

```text
Change, ticket, bug or explanation inside an ORGANIZATION repository
  -> enterprise-codebase-analysis

Decide or build HOW an application is delivered
(CI, CD, Docker / VM / Kubernetes deployment, environments, production path)
  -> deployment            (designs and generates; never runs a deploy)

Actually PUBLISH a project to the NAS now
  -> ssh-publish           (runs the deploy; only on an explicit NAS request)

New project: establish validated requirements, context and architecture decisions
before anyone codes
  -> harness-engineering

Small task, 60-180 minutes:
  a human can answer quick questions while you work -> harness-engineering-rapid-hitl
  no human reachable, or a timed solo exercise      -> harness-engineering-fast
```

Notes:

- `deployment` and `ssh-publish` do not overlap: `deployment` decides and writes the
  delivery pipeline into the repository; `ssh-publish` performs one concrete kind of
  deployment (to a NAS) on request. Neither calls the other.
- `enterprise-codebase-analysis` applies only to repositories identified as the
  organization's (by its workspace memory, a configured marker, the repository's own
  instructions, or the user). Delivery work in an organization repository still goes
  to `deployment`, with the organization skill's Git / DB safety rules in force.
- Generic technology questions ("what is Kubernetes?", "Redis vs OpenSearch?") need
  none of these skills.

## Harness engineering variants

Three skills share the "harness engineering" name because they share the same core
ideas - an artifact is not trusted just because it exists, an unknown is not an
assumption, an AI recommendation is not a human decision, and nothing is `PASS`
without real evidence. They differ in what they optimize for.

| | [harness-engineering](./harness-engineering/SKILL.md) | [harness-engineering-fast](./harness-engineering-fast/SKILL.md) | [harness-engineering-rapid-hitl](./harness-engineering-rapid-hitl/SKILL.md) |
|---|---|---|---|
| Optimized for | Trustworthy authority chain before coding | Correct delivery inside a fixed time budget, no human needed | Delivery progress with a human available |
| Phase covered | Before coding: source -> requirements -> context -> architecture decisions | Requirement scan through implementation, verification and final acceptance | Same end-to-end range, as a repeating understand -> question -> build -> verify loop |
| Writes code? | No | Yes | Yes |
| Upstream artifacts | Many, each independently evaluated and gated | One execution contract | One thin contract, kept mutable |
| Blocking unknown | Preserved as an open question; architecture decisions go through a formal human decision -> ADR cycle | Stop, report, wait (or deliver as `NEEDS_ATTENTION`) | Ask one short question and continue (max 3 up front, 1 per interruption) |
| Requirement freeze | Gated promotion | Yes, per run | Provisional - reopened by new evidence |
| Time budget | None | Hard: 60-180 min, default 90, verification time reserved | Default 90 min, last 15-20% reserved for verification |
| Status | v0.1 experimental | v0.1 experimental | v0.1 experimental |

When to pick which:

- **Long-lived project, decisions that must stay authoritative** -> `harness-engineering`.
  Both fast variants recommend escalating to it for production-critical, high-risk or
  architecturally long-lived work.
- **Short task, you will not be around to answer questions** -> `harness-engineering-fast`.
- **Short task, you can answer questions as they come up** -> `harness-engineering-rapid-hitl`
  (its own guidance points to the fast variant when no human is reachable).

## Example requests

| Request | Skill |
|---|---|
| 「幫我分析這張 bug 單 T12345」/「這支 API 在做什麼」(organization repository) | enterprise-codebase-analysis |
| 「先掃描這個 repo，幫我理解整體架構」(organization repository) | enterprise-codebase-analysis |
| 「幫我判斷這個 WebAPI 需不需要 Kubernetes」 | deployment |
| 「幫我建立 CI/CD」/「我只有一台 VM，不要 Kubernetes」 | deployment |
| 「幫我加入 QA environment」/「檢查目前部署方式是否合理」 | deployment |
| 「從這份規格開始建立需求與架構決策，再開始寫 code」 | harness-engineering |
| 「90 分鐘內完成這個 take-home 題目」 | harness-engineering-fast |
| 「我在旁邊可以隨時回答問題，幫我快速做這個小 feature」 | harness-engineering-rapid-hitl |
| 「把這個專案發佈到 NAS」/「更新 NAS 上的專案」 | ssh-publish |

## Skill anatomy

A skill is a directory. Most contain some of:

```text
<skill-name>/
├── SKILL.md       main execution rules and workflow - what the agent follows
├── references/    detailed knowledge, loaded only when a step needs it
├── templates/     reusable output formats and skeletons
└── examples.md    behaviour examples (illustrative, not extra rules)
```

Not every skill has every part, and some have more: `tests/` (behaviour test
matrices in the fast and rapid-hitl variants), `workspace/` (installation- or
organization-specific settings and knowledge, git-ignored, in
`enterprise-codebase-analysis` and `ssh-publish`), `scripts/`, `runtime/`, and design
or extraction reports.

## README vs SKILL.md

- **README.md** - human-facing navigation: what exists and which one to use.
- **SKILL.md** - agent-facing execution contract: triggers, workflow, hard rules.

If this README and a `SKILL.md` disagree, the `SKILL.md` wins.

## Repository structure

```text
skill/
├── deployment/
├── enterprise-codebase-analysis/
├── harness-engineering/
├── harness-engineering-fast/
├── harness-engineering-rapid-hitl/
├── ssh-publish/
├── .gitignore
└── README.md
```

## Installing a skill

Make a skill visible to Claude Code by linking its directory into the user skills
folder:

```powershell
# Windows
New-Item -ItemType Junction -Path "$env:USERPROFILE\.claude\skills\<skill-name>" `
         -Target "<clone>\<skill-name>"
```

```bash
# macOS / Linux
ln -s "<clone>/<skill-name>" ~/.claude/skills/<skill-name>
```

Skills with a `workspace/` need it filled in from the committed example files
(`enterprise-codebase-analysis/workspace/PROFILE.example.md`,
`ssh-publish/workspace/deploy.example.yaml`) before first use.

## Shared design principles

Recurring across these skills (each `SKILL.md` states its own exact form):

- **Inspect before acting.** Every skill starts by reading the current state -
  repository, existing artifacts, remote host - rather than assuming a blank slate.
- **Unknown stays unknown.** Missing facts are recorded and asked about, not filled
  with convention or "common sense".
- **Evidence over claims.** `PASS` / `DONE` requires a real build, test, command or
  check result; otherwise the outcome is reported as not verified or incomplete.
- **Humans own the important decisions.** Each skill names the points where it stops
  for a person - approvals, blocking questions, architecture decisions, risky changes.
- **Follow what already exists.** Existing architecture, conventions and repository
  rules are extended rather than replaced.
- **Load only what is needed.** `SKILL.md` routes to references on demand instead of
  reading everything up front.
- **Git stays with the user.** `enterprise-codebase-analysis`, `deployment` and
  `ssh-publish` never push, open MR / PR or merge.

## License

MIT
