---
name: deployment
description: Deployment Decision + CI/CD Generator for application repositories. Use when the user wants to work out how a repository should be built and delivered, create or extend CI, CD or a full CI/CD pipeline, containerize an application for deployment, generate Docker Compose / systemd / Kubernetes deployment artifacts, add an environment (QA / STG / PROD) or a production deployment to a pipeline, or review whether the current deployment setup is sound (分析部署方式、建立 CI、建立 CD、建立 CI/CD、加入 QA environment、加入 production deployment、檢查目前部署方式是否合理、只有一台 VM 不要 Kubernetes、使用 Kubernetes). Decides first - CI? CD? container? Kubernetes? which target, environments, rollback - then generates the minimum artifact set and validates it locally. Never deploys, never pushes images or git, never commits. Do NOT use for generic questions (what is Kubernetes / Docker / CI/CD), for provisioning infrastructure (Terraform, clusters, VMs, cloud services), or for publishing to the user's NAS (that is ssh-publish).
version: 1.0
status: draft
---

# Deployment Decision + CI/CD Generator

**Router only**: scope, modes, workflow, gates, decision vocabulary, hard rules and
output contract. Each procedure lives in exactly one reference; on any detail that
reference wins. **Load a reference when its step is reached** - never all of
`references/` up front.

Responsibility: analyse a repository and build its **application delivery
pipeline**. Not a cloud-infrastructure framework, not a deploy executor.

## Core principles

1. **Decide first, generate second.** No file changes before the Assessment exists.
2. **Existing technology wins over preference and inference.** Extend what the
   repository already uses. Only a user's hard constraint outranks it - and then as a
   gated migration, never a silent replacement (`decision-rules.md` §1).
3. **No Kubernetes for its own sake, no CI/CD for its own sake.** Every generated
   artifact has a stated reason; every deliberate omission is recorded.
4. **Production deploys need human approval** unless the user explicitly asks otherwise.
5. **Secrets never enter version control.**
6. **Every artifact carries an immutable, traceable version** (commit SHA).
7. **Build once, promote many.**
8. **Every CD design comes with a rollback.**

## Scope (v1)

| Area | Generate | Discover / assess / extend-existing only |
|---|---|---|
| CI provider | GitLab CI, GitHub Actions | Azure Pipelines, Jenkins |
| Stack | .NET (discovery → assessment → generate → validate) | Node.js (discovery + assessment) |
| Target | CI Only · VM-systemd · VM-Docker Compose · Kubernetes (plain / Kustomize) | Existing Platform (anything the repository already uses) |

Never introduced in v1 unless the repository already uses it: Terraform, Pulumi,
Helm, ArgoCD, Flux, AWS ECS, Lambda, Azure App Service, Google Cloud Run.

**Does not own**: provisioning clusters / VMs / registries / DNS / TLS; setting secret
values; running any deployment; `git commit` / `push` / MR / PR / merge. Publishing to
the user's NAS belongs to `ssh-publish`; this skill never calls it.

## Modes

Read intent from natural language; no fixed syntax. Constraints ("只有一台 VM",
"不要 K8s", "使用 K8s", "prod 要自動部署") are **modifiers**, not modes.

```
Assess    分析這個專案 / 我該怎麼部署            read-only  -> Assessment, STOP
Review    檢查目前部署方式是否合理                read-only  -> Assessment + Findings, STOP
Generate  建立 CI | 建立 CD | 建立完整 CI/CD      scope ci | cd | full -> full workflow
Extend    加入 QA environment | 加入 production   scope = the named addition -> full workflow
```

Unsure between Assess and Generate -> **Assess**. "建立 CD" with no CI that produces a
deployable artifact -> the Change Plan includes the CI part it depends on (stated, not
silent). Constraint handling: `decision-rules.md` §1, §6.

## Workflow

```
Discovery -> Assessment -> Change Plan -> [Gate?] -> Generate -> Validate -> Report
```

- **Assess / Review** stop after the Assessment (+ Findings). They never change a file.
- **Generate / Extend**: the user's request is the permission to change the
  repository. Proceed through Generate without asking, **unless a gate fires**.
- The Assessment and Change Plan are always shown **before** the first file change,
  gate or not.

## Gates

Stop and ask only when one of these holds:

1. A target the request needs is `Unknown` - where the artifact goes (host, cluster,
   registry, package feed) or, with no CI yet, which CI provider runs the pipeline.
   Other unknowns are resolved by mirroring the nearest existing pattern (`INFERRED`,
   stated) or reported as open items.
2. Application business or runtime behaviour must change (the minimal health endpoint
   under Hard Rule 9 is the only exception).
3. Production deployment semantics change - trigger, approval, target, strategy.
4. An existing pipeline, job, manifest or deploy script would be removed or replaced -
   including **Migration Required**: a hard constraint asks for a target / provider /
   mechanism other than the existing one (`decision-rules.md` §1.1).
5. A destructive or irreversible change is needed.
6. The work clearly exceeds the original request.
7. A required operational value (port, replicas under HA, ...) is `Unknown` and cannot
   be left as a fail-closed placeholder (`decision-rules.md` §9).

When a gate fires: show the Assessment, the Change Plan and the one question that
resolves it. Parts of the plan that **do not depend** on the gated item may still be
generated (e.g. CI while the CD target is `Unknown`); say which parts were held back.

## Decision status

CI, CD, Container and Kubernetes each get exactly one of:

```
Required         the repository or the user's request makes it necessary
Recommended      not necessary, but evidence says it is the better choice
Not Recommended  evidence says it should not be used here
Unknown          evidence is insufficient to decide
```

Each status cites evidence labelled `CONFIRMED` (a file / config / user statement) or
`INFERRED`. **`Unknown` is never rewritten as `Not Recommended`.** Assignment rules:
`decision-rules.md`.

## Hard rules

1. **Never deploy.** No `kubectl apply` (except `--dry-run=client`), `rollout undo /
   restart`, `delete`, `docker push`, remote `docker compose up`, SSH to a target,
   deploy-script execution or pipeline trigger. Rollout checks go **into** the
   generated pipeline / runbook.
2. **Git is read-only.** Leave changes in the working tree. No commit, push, branch
   change, MR / PR or merge unless the user separately and explicitly asks.
3. **One delivery system.** Never add a second CI provider or deployment mechanism
   beside an existing one - except a migration confirmed at Gate 4, where the new one
   is generated alongside and the old one stays until the user explicitly asks to
   remove it (Gate 5).
4. **Production**: manual approval by default; triggered only from a protected branch
   or tag; the production job never builds; it verifies the rollout and fails on a
   failed rollout. Automatic production deploys only on the user's explicit request,
   recorded in the Report.
5. **Build once, promote many.** One commit -> one immutable artifact -> promoted
   unchanged through every environment. A repository that builds per environment keeps
   its design; the difference is flagged in the Assessment / Review, not refactored.
6. **Immutable versions.** Deploy jobs reference the commit-SHA tag (or a release
   version for packages), never `latest` or another moving tag.
7. **Secrets** are referenced by name only - never written to any tracked file.
   Existing leaks are reported with the value masked.
8. **Validation is evidence.** `PASS` only on a real exit code 0; a tool that is
   missing or not permitted is `NOT RUN` with its reason. A written file is not a done
   task.
9. **Application code** changes only to add a minimal health endpoint, and only when
   all hold: mode is Generate / Extend, a probe / health check is actually needed, no
   usable endpoint exists, and the Change Plan lists the code change. Never in Assess
   / Review. Anything else -> Gate 2.
10. **No external contact without consent.** Commands that reach a cluster, registry or
    CI server (server-side dry-run, `glab ci lint`, a `kubectl` call against a live
    context) need the user's go-ahead.
11. **Minimum artifact set.** Generate only what the Change Plan lists with a reason.
12. **Precedence.** Repository-local instructions (`CLAUDE.md`, `AGENTS.md`) and the
    `enterprise-codebase-analysis` Git / DB / repository safety floor apply here; the
    stricter rule wins.
13. **No guessed operational values.** Ports, replicas, resources, namespaces, hosts
    come from evidence or the user; otherwise `Unknown` (`decision-rules.md` §9).
    Framework conventions ("ASP.NET listens on 8080", "HA = 2 replicas", "Service on
    80") are not evidence.

## Output contract

1. **Assessment + Change Plan** - `templates/assessment.md`. Always first.
2. **Findings** (Review only) - format in `review.md`.
3. **Report** - `templates/report.md`: changed files, validation table, manual setup
   (secret / variable names, runner, approvals), rollback runbook, open unknowns.
   `Status: DONE` only when every applicable validation is `PASS`.

## Reference routing

| Load when | File |
|---|---|
| Discovery (every mode) | `references/discovery.md` |
| Assigning any decision status, classification, target choice | `references/decision-rules.md` |
| Versioning, promotion, environments, production pipeline shape, rollback | `references/delivery-strategy.md` |
| Any secret, credential, `.env`, connection string or leak | `references/secrets.md` |
| Validate step | `references/validation.md` |
| Review mode | `references/review.md` |
| .NET repository | `references/stacks/dotnet.md` |
| Node.js repository | `references/stacks/node.md` |
| Generating / extending GitLab CI | `references/ci/gitlab.md` |
| Generating / extending GitHub Actions | `references/ci/github-actions.md` |
| Target Kubernetes | `references/targets/kubernetes.md` |
| Target VM-Docker Compose | `references/targets/docker-compose.md` |
| Target VM-systemd | `references/targets/systemd.md` |
| Azure Pipelines, Jenkins, Helm, GitOps, cloud PaaS, shared CI components already in use | `references/existing-platform.md` |

`examples.md` shows the behaviour on typical repositories. It illustrates the rules;
it does not add any.
