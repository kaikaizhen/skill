# GitHub Actions

Generate or extend `.github/workflows/*.yml`. Promotion, production shape and rollback
principles: `delivery-strategy.md`. Build commands: the stack reference.

## 1. Extending existing workflows

- Reusable workflows (`workflow_call`, `uses: org/repo/.github/workflows/x.yml@ref`)
  or composite actions: change only their `with:` inputs and `secrets:`. Never inline
  them. Cannot be expressed -> say so (Gate 6).
- Mirror existing job names, triggers, environment names and step style.

## 2. New workflow layout

One workflow file is enough for most units (`ci-cd.yml`); split into `ci.yml` and
`deploy.yml` only when the repository already splits or deploys must be dispatchable
independently.

```yaml
on:
  pull_request:
  push:
    branches: [main]          # the repository's default branch
    tags: ['v*']
  workflow_dispatch:

permissions:
  contents: read              # widen per job only (packages: write for GHCR push)

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

## 3. Jobs

| Job | Key points |
|---|---|
| build-test | `actions/setup-dotnet` with `global-json-file: global.json` (or `dotnet-version` from the TFM major); `cache: true` + `cache-dependency-path` only if `packages.lock.json` exists; runs on PRs |
| package (image) | `if: github.event_name != 'pull_request'`; tag `SHORT_SHA=${GITHUB_SHA::8}` exported to `$GITHUB_OUTPUT`; registry: GHCR (`ghcr.io/${{ github.repository }}`, `GITHUB_TOKEN`, `packages: write`) unless another registry is referenced; `docker/login-action`, `docker/build-push-action` with `push: true` and the SHA tag |
| package (bundle) | `actions/upload-artifact` with the SHA in the name; retention long enough for promotion |
| package (NuGet) | `if: startsWith(github.ref, 'refs/tags/v')`; `stacks/dotnet.md` §4 |
| deploy-<env> | `needs: package`; `environment: { name: <env>, url: <if known> }`; `concurrency: { group: deploy-<env>, cancel-in-progress: false }`; consumes the SHA output from `package`; deployment-time verification from `validation.md` §3 |

Pin third-party actions at least to a major version tag; pin to a full commit SHA if the
repository already does.

## 4. Production job

```yaml
deploy-prod:
  needs: [package, deploy-<previous env>]
  if: github.ref == 'refs/heads/main'          # or tag rule
  environment: { name: production }
  concurrency: { group: deploy-production, cancel-in-progress: false }
  runs-on: ubuntu-latest
  steps:
    - <target deploy commands for the SHA tag from needs.package.outputs>
    - <deployment-time verification>
```

The manual approval is **not** in YAML: it is the environment's *Required reviewers*
protection rule. Report under Manual setup: create the `production` environment, add
required reviewers, restrict deployment branches / tags to the release branch, put
production secrets in **environment** secrets (not repository secrets). Until that is
done the job deploys without approval - say this explicitly in the Report.

## 5. Credentials for deploy jobs

| Target | Secrets (environment-scoped) |
|---|---|
| Kubernetes | `KUBECONFIG_B64` (or OIDC to the cluster if the repository already uses it); write to a temp file, `chmod 600`, never `cat` |
| VM | `DEPLOY_SSH_KEY`, `DEPLOY_KNOWN_HOSTS`, `DEPLOY_HOST`, `DEPLOY_USER` |

## 6. Promotion

Default: one run on the default branch -> build once -> environments as chained jobs
gated by their environment protection rules, all using the same SHA output.
Re-deploy / rollback = a `workflow_dispatch` with an input `sha` that skips build and
runs only the deploy job for the chosen environment against `<image>:<sha>` - generate
this input when CD is generated.
