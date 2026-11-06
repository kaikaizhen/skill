# Review Mode

Read-only audit of the current delivery setup. Output: the Assessment (what the setup
is) plus Findings (what is wrong or risky). No file changes; fixes happen only if the
user then asks for Generate / Extend.

## 1. Checklist

Check only what applies to the repository's actual setup.

**Versioning & promotion**
- Deploys reference `latest` or another moving tag.
- Image / artifact cannot be traced to a commit.
- Artifact rebuilt per environment (`delivery-strategy.md` §2).

**Production**
- Production deploys automatically with no approval and no explicit decision recorded.
- Production triggered from an unprotected or arbitrary branch.
- Production job builds.
- No rollout verification; deploy job succeeds even when the rollout fails.
- No serialization of concurrent deploys.

**Secrets**
- Any leak from `discovery.md` §7.
- Secrets in ConfigMaps or committed env files.
- Secret visible to MR / PR pipelines.

**Kubernetes** (if used)
- No readinessProbe; liveness identical to readiness; no startupProbe on slow starts.
- `maxUnavailable` allows dropping below capacity on a 1-replica service.
- Service selector does not match Pod labels; `targetPort` differs from the container port.
- No resource requests (and HPA present without them).
- CI deletes Pods / Deployments before applying.

**VM**
- Deploy overwrites the only copy of the previous version (no rollback path).
- Service runs as root; secrets in the unit file or compose file.
- No health check after restart.

**Supply chain & transport** (CI scripts and shared components)
- TLS verification disabled: `GIT_SSL_NO_VERIFY=true`, `curl -k` / `--insecure`,
  `npm config set strict-ssl false`. Medium; High when the fetched content is executed
  (e.g. cloning helper scripts then `source`-ing them).
- Helper-script or template repository fetched by a moving ref (branch, no ref) instead
  of a tag / SHA.
- CI job images on `latest` or unpinned (`curlimages/curl:latest`,
  `release-cli:latest`); package manager pointed at a plain-`http` mirror.
- NuGet / npm credentials stored in clear text on the runner
  (`--store-password-in-clear-text`) - acceptable only on an ephemeral job container;
  Low there, Medium on a shell runner.
- Kubernetes manifests rendered with a bare `envsubst` (no explicit variable list) -
  any `$` in the manifest is silently replaced.

**Traffic layer** (nginx / Gateway / bot detection / honeypot): see
`edge-protection.md` §5 for the findings specific to that layer.

**Runners and build hosts**
- `/var/run/docker.sock` mounted into runner containers: any job controlling it is root
  on the host. Acceptable only for trusted projects on dedicated runners; otherwise
  recommend DinD/rootless builds. Medium.
- Runner, GitLab server or tool images on `latest` (an unattended upgrade of the CI
  server or runner is a delivery outage). Medium.
- Registry mirror / registry reached over plain HTTP with `insecure-registries`. Medium.
- Tool images (`alpine:latest` with `lftp`/`ssh`) with a baked-in `known_hosts`: pin the
  base, and record who refreshes `known_hosts` when the host key changes. Low.
- Host workarounds in cron (memory guards, image prune) lack a documented trigger and
  removal condition. Low. Image prune must exclude images kept for rollback (label such
  as `keep=true`).

**Observability stack**: see `observability.md` §4.

**Configuration repositories**
- Environment folders hold near-identical copies of the same file (drift risk).
- A pipeline `changes:` path does not match the folder its include deploys.
- Generated data (IP / ASN lists, GeoIP databases) committed with no generator script
  or source recorded.

**CI**
- No tests run though tests exist; tests run but failures are ignored (`allow_failure`, `|| true`).
- Two CI systems both deploying.
- Credentials passed on command lines (`docker login -p`).

**Rollback**
- No documented or practical way back to the previous version.
- Startup schema migration with no backward-compatibility note.

## 2. Findings format

Ordered by severity:

```
[High | Medium | Low] <one-line title>
  Evidence: <path:line or CI job name>   (CONFIRMED / INFERRED)
  Risk:     <what goes wrong, concretely>
  Suggest:  <smallest change; which mode would do it, e.g. "Extend: add manual approval">
```

High = can take production down, leak a secret, or deploy an untested artifact. Medium
= weakens rollback, traceability or safety. Low = hygiene.

Also list what is **good** in one or two lines, so the user knows what to keep.
