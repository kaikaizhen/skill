# Existing Platform (extend only)

For delivery technology the repository already uses but v1 does not generate from
scratch: Azure Pipelines, Jenkins, Helm, ArgoCD / Flux, Terraform-managed services,
cloud PaaS (ECS, App Service, Cloud Run, Lambda), and shared CI components owned by
another repository.

## 1. Rules

1. **Never translate on your own** to a v1-generated technology (Jenkins -> GitLab CI,
   Helm -> plain manifests). The existing platform outranks preferences and
   inference, but **not** a user's hard constraint ("不要 Helm", "改用 GitHub
   Actions"): that becomes Migration Required -> Gate 4, decided by
   `decision-rules.md` §1.1. The existing setup is never deleted as part of it.
2. **Mirror, don't design.** A change is acceptable in v1 only if it can be made by
   copying an existing pattern in the same file set and changing values: a new stage /
   environment block cloned from a sibling, a new values file next to existing ones, a
   new variable passed to an existing template.
3. **Cannot be mirrored** (needs new tasks, plugins, chart templates, IaC resources,
   agent / runner configuration) -> stop that part with the reason and a written
   recommendation; generate the rest.
4. The principles still apply - immutable versions, build once promote many,
   production approval, secrets by reference, rollback. Deviations in the existing
   platform become Findings, not silent rewrites.
5. Validation: YAML parse and any offline linter already used by the repository
   (`helm lint` / `helm template` only if Helm is installed - offline). Anything that
   contacts a server needs consent (Hard Rule 10).

## 2. Where to look

| Platform | Extend by mirroring |
|---|---|
| Azure Pipelines | `stages:` / `deployment` jobs with `environment:` (approvals live on the Azure DevOps environment -> Manual setup); `template:` references with parameters |
| Jenkins | `stage('...')` blocks; `input` step for manual approval; `@Library` shared steps - pass parameters only |
| Helm | `values-<env>.yaml` alongside existing ones; `image.tag` set from CI with `--set image.tag=<sha>`; chart templates untouched |
| ArgoCD / Flux | the environment's manifest / values path that CI updates with the new tag; the GitOps controller does the deploy, so CI's "deploy" is a commit by CI - not by this skill |
| Shared CI component / template | inputs only (`ci/gitlab.md` §1, `ci/github-actions.md` §1) |
| Cloud PaaS | the existing deploy step with the new artifact version; no new cloud resources |

## 3. Rollback

Use the platform's own mechanism and document it: Azure / Jenkins - re-run the previous
good run's deploy stage; Helm - `helm rollback <release> <revision>`; GitOps - revert
the tag change in the environment path; PaaS - the platform's previous revision /
deployment slot.
