# Deployment Assessment

<!-- One block per deployable unit in scope. Every value cites evidence:
     CONFIRMED (path[:line] or "user") / INFERRED (from what) / UNKNOWN (missing fact).
     Status vocabulary: Required | Recommended | Not Recommended | Unknown. -->

**Mode:** Assess | Review | Generate (ci / cd / full) | Extend (<addition>)
**Constraints from request:** <e.g. "single Ubuntu VM, no Kubernetes" | none>

## Unit: <name> (`<path>`)

| Item | Decision | Evidence / reason |
|---|---|---|
| Stack | <.NET 8 / Node 20 / ...> | |
| Application Type | <Library / Web API / Frontend / Worker / Background Service / CLI / Scheduled Job / Other> | |
| CI | <status> | |
| CD | <status> | |
| Container | <status> | |
| Kubernetes | <status> | <signals for / against> |
| CI Provider | <GitLab CI / GitHub Actions / existing: ...> | |
| Existing Target | <what the repository deploys with today / none> | |
| Desired Target | <CI Only / VM-systemd / VM-Docker Compose / Kubernetes / Existing Platform: ... / Unknown> | <hard constraint / existing / preference / evidence> |
| Migration Required | <No / Yes - Risk: deployment mechanism replacement, ...> | <Yes -> Gate 4> |
| Image / Artifact Strategy | <registry/name:<sha8> / <app>-<sha8>.tar.gz / NuGet SemVer from tag> | |
| Promotion | <build once -> env -> env> or <existing per-env build (flagged)> | |
| Environments | see matrix | |
| Production Strategy | <manual approval on <branch/tag> / not in scope> | |
| Rollback Strategy | <one line; full runbook in Report> | |

### CI steps

| Step | Need | Exists | Action |
|---|---|---|---|
| Build | | | keep / extend / create / skip |
| Test | | | |
| Lint | | | |
| Security scan | | | |
| Package | | | |
| Docker build | | | |
| Docker push | | | |

### Environment matrix

<!-- Only environments with evidence or explicitly requested. -->

| Environment | Trigger | Approval | Config source | Secret source | Target |
|---|---|---|---|---|---|

### Operational values

<!-- Only values this target needs. Evidence or Unknown - never a convention
     (decision-rules.md §9). Unknown -> fail-closed placeholder or Gate 7. -->

| Value | Value | Evidence / reason |
|---|---|---|
| Container / listening port | | |
| Service / host port | | |
| Replicas | | |
| Resources | | |
| Namespace / host | | |
| Health path | | |
| Image build mechanism / runner capability | | |

### Prerequisites

<!-- e.g. health endpoint missing, registry not configured, runtime on host. -->

### Unknowns

<!-- fact missing -> question that resolves it -> which decision / gate it blocks -->

### Findings (Review mode, or noteworthy in any mode)

<!-- format: references/review.md §2 -->

## Change Plan

<!-- Generate / Extend only. Every file with a reason. -->

| File | Action | Reason |
|---|---|---|
| | create / modify | |

**Application code changes:** <none | the minimal health endpoint in `<file>` (Hard Rule 9)>

**Deliberately not generated:**

| Item | Reason |
|---|---|

**Gate:** <none - proceeding | Gate <n>: <question>; held back: <parts>>
