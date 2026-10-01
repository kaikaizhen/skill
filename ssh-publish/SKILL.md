---
name: ssh-publish
description: Publish a local project to the user's SSH-reachable Docker host (e.g. a NAS) as a Docker image - build locally, docker save, transfer over SSH, docker load on the NAS, docker compose up, Nginx config, health check, backup-first update and verified rollback. Use ONLY when the user explicitly asks to publish / deploy to the NAS or update a project on the NAS (發佈到 NAS、部署到 NAS、更新 NAS 上的專案, "deploy to NAS", "publish to NAS"). Merely mentioning Docker, NAS or Compose does NOT trigger it. Never builds on the NAS, never pushes git. Credentials come from a replaceable provider (gopass or pass). Independent of enterprise-codebase-analysis - no code analysis, ticket work or development here. Do NOT use for local docker runs, generic Docker questions, or any other deploy target.
version: 1.0
status: draft
---

# SSH Publish

**Router only**: trigger, boundary, hard rules, which reference to load when. Each
procedure lives in exactly one reference; on any detail that reference wins. Load a
reference when its step is reached - not all of them up front.

```
Local machine                                    NAS
 docker build  ->  docker save  ->  transfer ->  docker load  ->  compose up -d
   (the ONLY place images are built)                (never builds)
```

## Boundary

Owns: local build · image export · NAS SSH · transfer · backup · docker load ·
compose deployment · Nginx config · health verification · rollback.

Does **not** own: code analysis, tickets, root cause, development, `git push`.
Those belong to `enterprise-codebase-analysis` (or plain development); this skill
never loads it and it never loads this one. If the user needs the code understood or
changed first, that is a different task - finish it, then publish.

**Git is read-only here**: `git status`, `git rev-parse --short HEAD`, `git diff`.
Uncommitted changes are reported in the result, never committed, stashed or pushed.

## HARD RULES

1. **NAS NEVER BUILDS.** No `docker build`, no `docker compose build`, no `build:` in
   the compose that runs on the NAS. Images are built locally.
2. **Images travel as archives**: build -> `docker save` -> transfer -> `docker load`.
3. **EXISTING PROJECT UPDATE REQUIRES A VERIFIED BACKUP FIRST** - no verified backup,
   no change, `STOP`.
4. Paths below use `<deploy_root>` and `<nginx_conf_dir>`, read from
   `workspace/deploy.yaml` (`paths.deploy_root`, `paths.nginx_conf_dir`); missing -> ask,
   never invent. Backup path: `<deploy_root>/<project-folder>/backup/`
5. Project path: `<deploy_root>/<project-folder>`
6. Nginx config: `<nginx_conf_dir>/<project-folder>.conf`
7. **NEW project asks for the subdomain** - never guessed.
8. **NEW project asks whether the folder name equals the project name.**
9. An existing project takes the UPDATE flow and is not re-asked for folder/subdomain
   unless its deployment metadata is missing or unreadable.
10. **NO GIT PUSH**, no force push, no remote branch change, no auto-commit.
11. **The credential backend is replaceable** (`CredentialProvider`).
12. **Both `gopass` and `pass` are supported**; logical paths are the same.
13. **THE SSH PRIVATE KEY NEVER ENTERS THE LLM CONTEXT, A LOG, A REPORT, THE
    REPOSITORY, METADATA OR A COMMAND LINE.**
14. **SUCCESS IS OBJECTIVE EVIDENCE** - exit codes, checksums, `docker` / `nginx -t` /
    health output. The model never declares a step passed on its own say-so.
15. **A FAILED UPDATE ROLLS BACK, AND THE ROLLBACK IS VERIFIED.**
16. **INDEPENDENT FROM `enterprise-codebase-analysis`.**

Also fixed: every remote path is built from a **validated** project folder under
`<deploy_root>/` and quoted (`safety-policy.md` §2); nothing is written
outside that root except the one Nginx file above.

## Modes

```
NEW      <deploy_root>/<folder> does not exist
UPDATE   it exists AND <folder>/.deploy/current.yaml exists and parses
STOP     it exists but has no readable metadata -> report "unknown existing
         directory", ask the user. Never assume it is safe to deploy over.
```

Decided by a remote read at the start (`deployment-workflow.md` §1).

## Reference routing

| Load when | File |
|---|---|
| Any deployment - step order, NEW and UPDATE flows, tags, staging, load, compose, health, metadata, rollback | `references/deployment-workflow.md` |
| UPDATE (always, before any change), retention, persistent data / database | `references/backup-policy.md` |
| Creating / changing the Nginx conf | `references/nginx-policy.md` |
| Step 0 credential check, any SSH, the pass -> gopass migration | `references/credential-policy.md` |
| Path validation, approval matrix, destructive-operation rules | `references/safety-policy.md` |
| Turning a step into commands on this machine (Windows / NAS shell quirks) | `runtime/runtime-adapter.md` |
| Which backend reads secrets | `runtime/credential-provider.md` |
| Which tool moves files | `runtime/transfer-provider.md` |

Templates in `templates/`: `deployment-metadata.example.yaml` (`.deploy/current.yaml`),
`nginx.conf.template`, `deployment-result.md` (the final report).
`scripts/migrate-pass-to-gopass.sh` - the one-off credential migration helper.

## Settings live outside the skill

Remote paths, provider choice, base domain, Nginx container, retention, docker command prefix and
health defaults come from `workspace/deploy.yaml` (git-ignored, copied from
`workspace/deploy.example.yaml`). Nothing environment-specific - host,
domain, subdomain, key material - is written into `SKILL.md`, `references/`,
`templates/` or `runtime/`. A setting that is missing and needed -> ask, never invent.

## Finishing

Report with `templates/deployment-result.md`. `Final Status: DONE` only when every
evidence line in it is a real `PASS`; otherwise `FAILED` / `ROLLED BACK` /
`INCOMPLETE` with the reason. Never include a credential, a key path's contents, or
the NAS address beyond what the user already sees.
