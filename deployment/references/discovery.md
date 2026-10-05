# Repository Discovery

Read-only. Goal: an evidence-backed inventory of what the repository **is** and how it
is **already** delivered, cheap enough to run on every request.

## 1. Scan order

Cheapest first; stop reading a category once it is answered.

1. Root listing (one level) and repository-local instructions (`CLAUDE.md`, `AGENTS.md`,
   `README*`, `docs/` deployment notes).
2. CI files (§3).
3. Container and orchestration files (§4).
4. Project / build files -> stack, then the stack reference's Discovery section
   (`stacks/dotnet.md`, `stacks/node.md`).
5. Environment configuration (§5).
6. Health endpoints, tests, scripts (§6).
7. Secret-leak sweep (§7) over the files already found - not the whole repository.

Use glob / grep; do not open every file. Do not read `bin/`, `obj/`, `node_modules/`,
`dist/`, `.git/`.

## 2. Evidence labels

Every inventory item is `CONFIRMED` (cite path, and line where useful), `INFERRED`
(state from what) or `UNKNOWN`. A user statement in this conversation counts as
`CONFIRMED` and is cited as "user". Never fill an `UNKNOWN` with a default.

## 3. CI provider

| Provider | Files | Also record |
|---|---|---|
| GitLab CI | `.gitlab-ci.yml`, files it `include:`s | `include:` / `component:` (shared templates), stages, `rules:` per branch, `environment:` names, `when: manual`, variables naming image / registry / k8s path |
| GitHub Actions | `.github/workflows/*.yml` | triggers, `environment:` names, reusable workflows (`uses: ./.github/workflows/...` or `org/repo/...`) |
| Azure Pipelines | `azure-pipelines.yml`, `**/azure-pipelines*.yml`, `.azure-pipelines/` | stages, environments, templates |
| Jenkins | `Jenkinsfile`, `jenkins/` | stages, shared library (`@Library`) |

More than one provider present -> record all and which one deploys; never pick for the
user which to keep.

No CI file and the user named no provider -> `git remote get-url origin` (read-only):
a `gitlab` host -> GitLab CI, `github.com` -> GitHub Actions, both `INFERRED`. Any other
host or no remote -> `Unknown` (Gate 1 when CI must be generated).

## 4. Container and orchestration

| Item | Detection |
|---|---|
| Dockerfile | `**/Dockerfile*`, `**/*.Dockerfile`; record base images, exposed port, build context implied by `COPY` paths |
| `.dockerignore` | presence next to each build context |
| Compose | `docker-compose*.yml`, `compose*.yaml`; record `build:` vs `image:`, services, `env_file`, healthchecks |
| Kubernetes | YAML with both `apiVersion:` and `kind:`; common dirs `k8s/`, `kubernetes/`, `deploy/`, `manifests/`; record kinds, namespaces, image placeholder style (`${image}`, Kustomize `images:`, hard-coded tag) |
| Kustomize | `kustomization.yaml`; base / overlay layout, `configMapGenerator`, `images:` |
| Helm | `Chart.yaml`, `values*.yaml` -> Existing Platform |
| systemd / VM | `*.service`, `*.timer`, deploy scripts using `ssh` / `scp` / `rsync` / `systemctl` |
| Registry | `docker login`, `CI_REGISTRY*`, `ghcr.io`, `*.azurecr.io`, image name prefixes |

## 5. Environments

Collect environment names only from evidence: `appsettings.<Env>.json`, `.env.<env>`,
`env/*.env`, K8s overlay / directory names, CI `environment:` names, branch rules,
deploy job names. Normalise spelling (`stage` / `stg` / `staging`) **only for display**;
generated files keep the repository's spelling. Building the environment matrix:
`delivery-strategy.md` §3.

## 6. Health, tests, scripts

- **Health**: stack-specific patterns in the stack reference; also any route literal
  containing `health`, `ready`, `live`, `ping`. Record path and whether it checks
  dependencies.
- **Tests**: test projects / test scripts and whether they need external services
  (DB, Redis) - a test needing a live DB is recorded, not silently added to CI.
- **Scripts**: `Taskfile.yml`, `Makefile`, `build-script/`, `scripts/`, `deploy*.sh`,
  `*.ps1`. Record what each does in one line; generated pipelines reuse them where
  they fit instead of re-implementing.

## 7. Secret-leak sweep

Over CI files, compose files, manifests, every env file (`.env*`, `*.env`, `env/`),
`appsettings*.json`, scripts. The file name never decides; the content does
(`secrets.md` §3.1):

- `Password=`, `Pwd=`, `User ID=...;Password` in connection strings
- keys named `*password*`, `*secret*`, `*apikey*`, `*api_key*`, `*token*`,
  `*signingkey*`, `*privatekey*` with a non-empty, non-placeholder value
- `-----BEGIN ... PRIVATE KEY-----`, `AKIA[0-9A-Z]{16}`, `ghp_`, `glpat-`
- `kind: Secret` with populated `data:` / `stringData:`
- `docker login -p <literal>`

Report path:line and the key name; mask the value. Handling: `secrets.md` §4.

## 8. Deployable units

A unit is something released on its own: a deployable app or a published package.
In a monorepo, list each unit with its path, stack and existing delivery; the
Assessment has one block per unit in scope. Shared libraries consumed only inside the
repository are not units.

## 9. Output of Discovery

An inventory feeding the Assessment: stack, units, CI provider(s) and their
conventions, container / orchestration assets, environments, health, tests, scripts,
registry, leaks, and **existing conventions to preserve** (image naming, tag format,
placeholder style, env naming, branch model, shared components). Everything else is
decided in `decision-rules.md`.
