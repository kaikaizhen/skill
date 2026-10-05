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
