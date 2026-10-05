# Validation

Two layers. The skill **runs** layer 1; it **writes** layer 2 into the pipeline and
the runbook. Hard Rule 8 (evidence only) and Hard Rule 10 (no external contact without
consent) apply.

## 1. Before running anything

- Check the tool exists (`dotnet --version`, `docker version`, `kubectl version
  --client`). Missing -> `NOT RUN (tool not installed)`.
- Docker daemon not running -> `NOT RUN (daemon unavailable)`.
- Never "fix" a failing validation by weakening the generated file (removing a probe,
  dropping a test). Fix the cause or report `FAIL`.

## 2. Generation-time validation (run locally)

Run whatever applies to the files actually generated or changed:

| Generated / changed | Command | Notes |
|---|---|---|
| Any .NET code or build change | `dotnet build -c Release` | solution or project the pipeline builds |
| Tests exist | `dotnet test -c Release` | tests needing live services: run if the pipeline will; otherwise `NOT RUN (needs <service>)` |
| Package job | `dotnet pack -c Release -o <scratch>` | output to scratch, never committed |
| Dockerfile | `docker build -f <Dockerfile> -t <name>:validate-<sha> <context>` | local tag only; never push. Optionally run it and hit the health endpoint |
| Compose file | `docker compose -f <file> config --quiet` | supply dummy values for required variables via a scratch env file, never real ones |
| Kustomize | `kubectl kustomize <dir>` | offline |
| Plain manifests | `kubectl apply --dry-run=client -f <file>` | see below |
| systemd unit | `systemd-analyze verify <unit>` | Linux only; elsewhere `NOT RUN (not Linux)` |
| Any YAML | parse with `yq` or `python -c "import yaml,sys; [list(yaml.safe_load_all(open(f))) for f in sys.argv[1:]]"` | |
| GitHub workflow | `actionlint` | if installed |
| GitLab CI | YAML parse + check every `needs` / `extends` / `stage` reference resolves | `glab ci lint` contacts the server -> consent first |
| Shell scripts | `bash -n <script>`; `shellcheck` if installed | |
| CI runner capability (DinD, privileged, tools) | - | always `NOT RUN (runner capability Unknown)` unless the user confirmed it; a local `docker build` proves the Dockerfile, not the runner |

Fail-closed placeholders (`decision-rules.md` §9) are validated on a **scratch copy**
with obviously dummy values (`REPLICAS=1`, `NAMESPACE=validate`), never with real
ones; the Report says the dummy values were used and that the real values are still
"must decide".

**`kubectl apply --dry-run=client`** still contacts the current context for API
discovery and to read the live object. Check `kubectl config current-context` first:
- no context -> `NOT RUN (no cluster context)`; rely on `kubectl kustomize` /
  `kubeconform` if installed.
- a context exists -> ask before running (Hard Rule 10), naming the context.

## 3. Deployment-time validation (written, not run)

Placed in the generated deploy job and repeated in the rollback runbook. The skill
**never** runs these locally as part of Validate - not `kubectl rollout status`, not a
readiness probe, not a smoke test against any environment. They are evidence of a
deployment, which the skill does not perform.

| Target | Check |
|---|---|
| Kubernetes | `kubectl rollout status deployment/<name> -n <ns> --timeout=<t>`; non-zero fails the job |
| Compose | container `running` (and `healthy` if a healthcheck is defined), then the smoke test |
| systemd | `systemctl is-active <unit>`, then the smoke test with retries |
| All runtime targets | **readiness**: health endpoint returns 200; **smoke test**: one cheap request that proves the app serves (`curl -fsS <url><health path>` minimum; a real read-only endpoint if the repository has an obvious one) |

## 4. Reporting

Report table: `Check | Command | Result (PASS / FAIL / NOT RUN) | Evidence or reason`.
`PASS` needs the real exit code. Deployment-time checks appear in a separate list as
"in pipeline", never as `PASS`.
