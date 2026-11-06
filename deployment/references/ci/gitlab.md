# GitLab CI

Generate or extend `.gitlab-ci.yml`. Promotion, production shape and rollback
principles: `delivery-strategy.md`. Build commands: the stack reference.

## 1. Extending an existing file

- Shared templates (`include:` of a project / remote file, or `component:`): change
  only the **inputs / variables** the template exposes. Never inline the template's
  logic. If the template cannot express the change -> say so; changing the template
  repository is out of scope (Gate 6).
- Mirror the existing jobs: names, stage names, `rules` style, variable names, image
  placeholder style, scripts in `build-script/`. A new environment's job is a copy of
  the nearest environment's job with the differences only (`extends:` / YAML anchors if
  the file already uses them).
- Keep job order and comments; do not reformat untouched parts.

### 1.1 Reading a shared component (`spec: inputs:`)

Typical shape of a GitLab CI/CD component or template that owns build, package and
deploy for many repositories. Recognise it so inputs are passed correctly:

| Convention | Meaning for the consumer |
|---|---|
| `inputs:` `env`, `job_suffix`, `stage_suffix` | Job names are built from them (`deploy-<kind><suffix>-<env>`). Including the same component twice (two projects, two envs) needs distinct `env` / suffix values, or the job names collide |
| `manual_deploy` (boolean) | Switches the deploy job to `when: manual`. Use it for every protected environment instead of editing rules |
| `wait_for_rollout` (+ timeout) | Keep **on** for Kubernetes (§ `targets/kubernetes.md` 5.1) |
| `before_*_script` / `after_*_script` | The sanctioned extension points. Use them instead of copying the component's script |
| rules keyed on a variable (e.g. `$action =~ /build|package|deploy/`) | Pipeline behaviour is chosen by a variable on the pipeline (branch rules, schedule, web trigger). Set it in the consumer's `workflow:` / trigger, do not fork the component |
| `dependencies: []` on deploy jobs | Deploy does not download build artifacts; it uses the image already in the registry (build once, promote many) |
| Shared scripts fetched at job start (`git clone --branch <tag>`) | Version is a tag. Upgrading is a one-line input/tag change in the consumer, not a copy of the scripts |

Review points for such a component (Findings, not fixes - the component belongs to
another repository): the script repository is pinned to an immutable tag; the clone does
not disable TLS verification; job images are pinned (not `latest`); registry mirrors are
reached over TLS or an explicitly trusted internal path.

### 1.2 Configuration repositories (manifests / proxy config, one folder per environment)

A repository that only holds deployable configuration (nginx image, gateway routes,
manifests) is delivered with the same component, one `include:` per environment/unit:

- Each include has `rules:` with two entries: automatic on push/MR **with
  `changes:` limited to that unit's folder** (so only the touched unit deploys), and a
  manual `web` pipeline selected by `env` / `service` variables.
- Declare those variables with `options:` and a description so the "Run pipeline" form
  is a dropdown; the default for destructive scopes is not "all".
- When every include is rule-gated, a pipeline can end up with no jobs and fail. Keep
  a never-running placeholder job (`stage: .pre`, `rules: - when: never`) - a known
  GitLab workaround, with the issue link in a comment.
- Production includes pass `manual_deploy: true`; lower environments deploy
  automatically. A `changes:` path must match the folder the include actually deploys
  (copy-paste mismatches between unit and path are the common defect - check each).
- Image tag for these pipelines: `<branch>-<short sha>`, never starting with `-`.

### 1.3 Runner facts to record (do not provision)

Record as `INFERRED` / Manual setup when found: Docker executor with `privileged`
(DinD), `concurrent` limit, a self-signed registry CA mounted into the runner
(`/etc/docker/certs.d`, CA bundle), a pull-through registry mirror, `extra_hosts`
for the host gateway, and a scheduled `docker image prune`. These explain why the
component's build jobs work; they are runner configuration, owned outside the
repository being delivered.

## 2. New file layout

```yaml
stages: [build, test, package, deploy]

variables:
  IMAGE_NAME: $CI_REGISTRY_IMAGE            # or the repository's registry path
  IMAGE_TAG: $CI_COMMIT_SHORT_SHA

workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
    - if: $CI_COMMIT_TAG
```

Use `$CI_DEFAULT_BRANCH` rather than a literal `main` unless the repository's rules
already name branches. Keep `test` as its own stage only if tests are slow enough to
matter; otherwise build + test in one job.

## 3. Jobs

| Job | Key points |
|---|---|
| build / test | SDK image pinned to the major (`mcr.microsoft.com/dotnet/sdk:<major>`); NuGet cache `cache: key: files: [**/packages.lock.json]` only if lock files exist, else key on `$CI_COMMIT_REF_SLUG`; runs on MRs too |
| package (image) | not on MRs; built with the mechanism chosen in §3.1; registry login from the registry variables the repository uses (`$CI_REGISTRY_USER` / `$CI_REGISTRY_PASSWORD` via `--password-stdin` for Docker); tagged and pushed as `$IMAGE_NAME:$IMAGE_TAG` |
| package (bundle, systemd) | `dotnet publish` -> `tar czf <app>-$CI_COMMIT_SHORT_SHA.tar.gz`; keep as `artifacts:` with `expire_in` long enough for promotion, or upload to the generic package registry if releases must outlive artifact expiry |
| package (NuGet) | `rules: - if: $CI_COMMIT_TAG =~ /^v\d+\.\d+\.\d+/`; `stacks/dotnet.md` §4 |
| deploy-<env> | `stage: deploy`, `needs:` the package job, `environment: { name: <env>, url: <url if known> }`, `resource_group: deploy-<env>` (serializes deploys), deployment-time verification from `validation.md` §3 |

### 3.1 Image build mechanism

Decide in this order; the first that applies wins:

| Evidence | Action |
|---|---|
| A shared component / template / reusable job already builds images (`include:` / `component:` with image inputs) | Pass inputs only. Do **not** add a separate build job beside it |
| An existing job builds images - DinD, Docker on a shell runner, Kaniko, Buildah, BuildKit (`buildctl`), `docker buildx` | Continue that mechanism, same image and runner tags |
| Runner documentation / tags in the repository or the user's statement say what runners support | Use the supported mechanism |
| No evidence at all | **Fallback baseline: Docker-in-Docker** (`services: [docker:<ver>-dind]`, `DOCKER_TLS_CERTDIR: "/certs"`) |

The DinD fallback is an **assumption, not a standard**:

- Assessment: `Image build: DinD - INFERRED (fallback, no build mechanism evidence)`;
  `Runner capability: Unknown`.
- Report, Manual setup: "Prerequisite: a runner that allows **privileged** Docker-in-
  Docker. If your runners are not privileged, switch the job to Kaniko or Buildah."
- Validation cannot prove runner capability - local `docker build` proves the
  Dockerfile, not the runner. Report the runner as `NOT RUN (runner capability
  Unknown)` in the validation table.
- Never describe the generated job as "will run on your runners".

## 4. Production job

```yaml
deploy-prod:
  stage: deploy
  needs: [package]
  environment: { name: production }
  resource_group: deploy-production
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH   # or the repository's release branch / tag rule
      when: manual
  allow_failure: false
  script:
    - <target deploy commands for $IMAGE_NAME:$IMAGE_TAG>
    - <deployment-time verification>
```

- `when: manual` inside the `rules:` entry; `allow_failure: false` keeps the pipeline
  "blocked" until played, so later stages cannot proceed by accident.
- Report under Manual setup: protect the release branch, mark production variables
  **Protected** + **Masked**, and (if available on the plan) configure the environment
  as a protected environment with approvers.
- The job never contains `docker build`.

## 5. Credentials for deploy jobs

| Target | Mechanism | Variable names (Manual setup) |
|---|---|---|
| Kubernetes | existing GitLab agent (`KUBE_CONTEXT`) if used; else a **File**-type variable holding a kubeconfig, per environment | `KUBECONFIG` (file, scoped to environment) |
| VM (Compose / systemd) | SSH key as a **File**-type variable + known host entry | `DEPLOY_SSH_KEY`, `DEPLOY_KNOWN_HOSTS`, `DEPLOY_HOST`, `DEPLOY_USER` (environment-scoped) |

Environment-scoped variables (`environment_scope`) let the same job template read
different values per environment without new variable names.

## 6. Promotion

Default: all environment deploy jobs in the default-branch pipeline - lower
environments automatic, later ones `when: manual` - all using `$CI_COMMIT_SHORT_SHA`.
Re-deploy / rollback = re-run that older pipeline's deploy job. Repository uses
branch-per-environment rules -> keep them (`delivery-strategy.md` §2).
