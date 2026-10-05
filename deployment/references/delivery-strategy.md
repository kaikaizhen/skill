# Delivery Strategy

How versions, promotion, environments, the production path and rollback are designed.
Provider syntax lives in `ci/*.md`; target mechanics in `targets/*.md`.

## 1. Version identity

| Artifact | Version | Source |
|---|---|---|
| Container image | 8-char commit SHA, e.g. `my-api:a38f71c2` | GitLab `$CI_COMMIT_SHORT_SHA`; GitHub `${GITHUB_SHA::8}`; local `git rev-parse --short=8 HEAD` |
| Runtime bundle (systemd) | `<app>-<sha>.tar.gz` | same SHA |
| Package (NuGet) | SemVer from a release tag `v1.2.3`; non-release builds get a pre-release suffix with the SHA | `stacks/dotnet.md` §Package |

- Image name is environment-neutral (`my-api`, not `my-api-qa`), so one image can be
  promoted. Existing per-environment names are kept and flagged (§2).
- Additional human-friendly tags (`v1.2.3`) may point to the same digest; a deploy job
  always references the SHA tag. `latest` may exist for local convenience only.
- Record the deployed version where the target can show it: the Deployment's image
  field (K8s), `IMAGE_TAG` in the host's compose `.env` (Compose), the `current`
  symlink target (systemd). Rollback reads it from there.

Traceability chain the generated pipeline must preserve:
`commit SHA -> artifact (tag / bundle / package version) -> environment deployment`.

## 2. Build once, promote many

```
commit SHA -> build + test (once) -> artifact:<sha> -> QA -> STG -> PROD
                                                       (same artifact, no rebuild)
```

Mechanics:

- One build job per commit produces the artifact; every deploy job takes the artifact
  by SHA and only deploys it.
- **Default promotion model (new pipelines)**: pipeline on the release branch (usually
  `main`) -> build -> deploy to the first environment automatically -> later
  environments are manual jobs **in the same pipeline**, so they deploy the same SHA.
- Re-deploying an older version = re-running that commit's deploy job (or a
  dispatch / web pipeline with the SHA as input). Never rebuild to roll back.
- Environment differences live in configuration (ConfigMap / env file / overlay /
  secret), never in the artifact.

**Existing environment-specific builds** (per-env image names, branch-per-environment
with merge commits that rebuild, build-time env flags): keep the design, extend it in
its own shape, and add a Finding / Assessment note: *"builds per environment; the
artifact that reaches PROD is not the one QA tested"*. Refactoring it is Gate 3 / 6.

## 3. Environment matrix

Built only from Discovery evidence and the user's request. Never add an environment
the repository does not have and the user did not ask for.

| Column | Meaning |
|---|---|
| Environment | repository spelling |
| Trigger | branch / tag / manual input that deploys it |
| Approval | auto / manual |
| Config source | overlay, env file, appsettings, CI variables |
| Secret source | `secrets.md` §2 |
| Target | cluster+namespace / host / platform |

Adding an environment (Extend): copy the nearest existing environment's shape -
trigger style, config layout, naming - and change only what differs. Values the
repository cannot supply (namespace, host, URL) are listed as `Unknown` and resolved
by asking or left as clearly named CI variables reported in Manual setup.

## 4. Production path

Required shape (Hard Rule 4 is the rule; this is how it looks):

```
release branch / tag (protected)
  -> build + test (automatic)
  -> package / push artifact:<sha> (automatic)
  -> lower environment(s) (automatic or manual per repository)
  -> PROD deploy job: manual approval, same artifact:<sha>
       -> apply / switch
       -> deployment-time verification (validation.md §3)
       -> job fails if verification fails
```

- Serialize production deploys (one at a time) - provider mechanism in `ci/*.md`.
- Approval that the CI file cannot express alone (GitHub required reviewers, GitLab
  protected environments) goes into the Report's Manual setup.
- Changing an existing production job's trigger, approval, target or strategy is
  Gate 3, even when the user asked for something nearby.

## 5. Rollback

Every CD design ships a rollback runbook in the Report:

1. **How to see what is running now** (target-specific command / location).
2. **How to return to the previous version** - always "deploy the previous immutable
   artifact"; target commands in the target reference.
3. **How to verify** the rollback (same checks as the deploy).
4. **What rollback does not undo**: database schema migrations, published messages,
   external side effects. If the app migrates its schema at startup, say so and
   recommend backward-compatible (expand / contract) migrations.

Packages cannot be truly rolled back once published: the runbook is "unlist / deprecate
the bad version, publish a fixed higher version".

No automatic rollback is generated in v1; a failed deploy fails the job and leaves the
previous version serving where the target allows it (K8s `maxUnavailable: 0`).
