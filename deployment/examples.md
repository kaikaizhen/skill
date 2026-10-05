# Examples

Behaviour illustrations. They apply the rules in `SKILL.md` and `references/`; they do
not add rules. Real repositories will differ - follow the evidence, not these stories.

---

## 1. NuGet library, "幫我建立 CI"

**Repository:** `src/Acme.Text/Acme.Text.csproj` (class library, `PackageId`,
`IsPackable` unset), `tests/Acme.Text.Tests` (xUnit), `global.json` (SDK 8), no CI
file, repository hosted on GitHub (user).

**Assessment (abridged):** Library / Package. CI **Required** (user). CD **Not
Recommended** - nothing runs. Container **Not Recommended**. Kubernetes **Not
Recommended**. Provider GitHub Actions (user; no existing CI). Artifact: NuGet, version
from tag `v*`. Feed **Unknown** - `nuget.config` names none.

**Behaviour:** Gate 1 fires only for the **publish** part (target feed unknown). Build
+ test + pack are generated anyway: `.github/workflows/ci.yml` with PR/push triggers,
`setup-dotnet` from `global.json`, `dotnet test`, `dotnet pack` as validation. The
Report lists the held-back publish job and the question "nuget.org, GitHub Packages or
another feed?". Validation: `dotnet build`, `dotnet test`, `dotnet pack` to scratch,
YAML parse, `actionlint` if installed. Rollback runbook: unlist + publish higher
version (stated for when publishing is added).

---

## 2. Single ASP.NET Core API, "我只有一台 Ubuntu VM，不要 Kubernetes，幫我建立 CI/CD"

**Repository:** `src/Shop.Api` (`Sdk.Web`, .NET 8), tests present, `.gitlab-ci.yml`
absent, GitLab hosting (user), no Dockerfile, no health endpoint,
`appsettings.Production.json` contains `Password=` in a connection string.

**Assessment:** Web API. CI **Required**. CD **Required**. Kubernetes **Not
Recommended** (user constraint + single VM). Target **VM-systemd**: no Dockerfile, no
registry, single process (`decision-rules.md` §6) - the user may switch to Compose.
Container **Not Recommended**. Artifact `shop-api-<sha8>.tar.gz`. Environments: only
`Production` has evidence -> matrix has one row: `main` -> PROD, manual. Leak reported
masked. Operational values: listening port **Unknown** - no unit file, no Kestrel
endpoint or `urls` in `appsettings*`, no `UseUrls`; only `launchSettings.json`
(development, not evidence). Host path, service user: new-setup layout from
`targets/systemd.md`, stated.

**Change Plan:** `.gitlab-ci.yml` (build-test, package bundle, deploy-prod manual with
`resource_group`), `deploy/shop-api.service`, `deploy/shop-api.env.example`, minimal
`MapHealthChecks("/health")` in `Program.cs` (Hard Rule 9 - smoke test needs it).
The leaked password stays a Finding: the plan does not touch that file
(`secrets.md` §4).

**Gate 7** (port): build-test and package jobs are generated; the unit file and
`deploy-prod` (both need the port for `ASPNETCORE_URLS` and the smoke test) are held
back with "Which port should Shop.Api listen on behind the VM's reverse proxy?". No
other gate: target known, production is new (no existing semantics change), nothing
removed.

**Validation:** `dotnet build`, `dotnet test`, YAML parse + reference check,
`bash -n` on embedded scripts, `systemd-analyze verify` -> `NOT RUN (not Linux)` on a
Windows workstation.

---

## 3. Existing GitLab CI + Kubernetes, "幫我加入 QA environment"

**Repository:** `.gitlab-ci.yml` with `build`, `package`, `deploy-dev` (auto on
`develop`), `deploy-prod` (manual on `main`); `kubernetes/dev/` and `kubernetes/prod/`
Kustomize overlays over `kubernetes/base/`; image `registry.example.com/my-api:$CI_COMMIT_SHORT_SHA`.

**Assessment:** CI **Required** (keep). CD **Required** (extend). Kubernetes
**Required** (existing). Promotion: branch-per-environment - DEV image built on
`develop`, PROD image built on `main` -> flagged "PROD artifact is not the one tested",
not refactored. Environment matrix gains `qa`, shaped like its nearest sibling DEV:
branch rule on `qa`, automatic (`INFERRED` from DEV; stated so the user can change it).

**Behaviour:** no gate - the target (same cluster style) is known, production is not
touched, nothing is removed. Mirror `deploy-dev` into `deploy-qa`, copy
`kubernetes/dev/` to `kubernetes/qa/` changing namespace and config only; `deploy-prod`
untouched. Namespace follows DEV's naming (`INFERRED`); kubeconfig and config values
the repository cannot supply go to Manual setup as `qa`-scoped variables.

---

## 4. Node.js frontend, "/deployment 建立 CI/CD"

**Repository:** Vite SPA, `package-lock.json`, no CI.

**Behaviour:** full Assessment (Frontend static; CI Required; CD Unknown - no hosting
evidence). Generation stops for the unit: "Node.js generation is not supported in v1"
with the recommended design (npm ci -> build -> artifact; hosting to be decided) in the
Report. No files changed.
