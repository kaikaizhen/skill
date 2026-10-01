# Deployment Workflow

Order of work for both modes. Rules of backup, Nginx, credentials and safety live in
their own references - cited, not repeated.

```
NEW
 Request -> Detect NEW -> Ask subdomain -> Ask folder name -> Credential check
 -> SSH preflight -> Local build -> docker save -> Create remote dir -> Stage
 -> docker load -> Install compose -> Create Nginx conf -> Validate Nginx
 -> Compose up -> Health check -> Write metadata -> DONE

UPDATE
 Request -> Detect existing -> Read metadata -> Credential check -> SSH preflight
 -> Local build -> docker save -> Backup -> VERIFY backup -> Stage -> docker load
 -> Update compose / image tag -> Validate Nginx -> Compose up -> Health check
 -> PASS: update metadata -> DONE
 -> FAIL: Rollback -> verify previous version -> report ROLLED BACK
```

Any step failing stops the pipeline and is reported with the real error lines. One
retry for an obvious, named cause (wrong sudo prefix, wrong `--platform`); a second
failure on the same step means stop. **Nothing in this file runs until the user has
asked to publish** - and each remote-changing step is preceded by its preflight.

---

## 0. Identity of this run

One instant, formatted twice, used everywhere:

```
deployment-id   YYYYMMDD-HHmmss        image tag, .staging/ folder
backup-id       YYYY-MM-DD_HHmmss      backup/ folder
```

Project name = the local project's name (its folder or compose project name),
lower-cased for the image repository (Docker requires it). Image tag:

```
<image-repo>:<deployment-id>-<short-sha>      my-api:20261001-221500-a18c992
<image-repo>:<deployment-id>                  no git repository, or no commit yet
```

`<short-sha>` comes only from `git rev-parse --short HEAD`. If `git status` shows
uncommitted changes, append `-dirty` and say so in the report - the image contains
code that no commit identifies. Never commit, stash, or push to make it clean.

## 1. Detect NEW / UPDATE (remote read, no changes)

Validate the folder name first (`safety-policy.md` §2), then read:

```
test -d '<root>/<folder>'           and        <root>/<folder>/.deploy/current.yaml
```

| Directory | `.deploy/current.yaml` | Mode |
|---|---|---|
| missing | - | NEW |
| present | present, parses | UPDATE |
| present | missing / unparsable | **STOP** - unknown existing directory, ask the user |

In UPDATE mode, folder, subdomain, service port, nginx path, health spec and the
currently deployed image tag come from the metadata, the existing compose and the
existing Nginx conf - not from the user.

## 2. NEW project - questions come before any action

Ask in one message and wait for both answers:

1. **Subdomain** (label only, e.g. `api`). Validate (`safety-policy.md` §2). The FQDN
   is `<subdomain>.<nginx.base_domain>`; `base_domain` comes from `workspace/deploy.yaml`.
   Missing -> ask for it, do not default.
2. **Is `<project-name>` also the NAS folder name?** Show the resulting path
   `<deploy_root>/<project-name>`. Yes -> use it. No -> ask for the
   folder name and validate it.

Also needed for the Nginx upstream and health check, from the project when it states
them (compose `ports` / Dockerfile `EXPOSE` / an existing healthcheck), otherwise
asked once: **service port**, **health spec** (§8). Nothing is created before all are
answered. If the target path turns out to exist at creation time, that is a mode
change to STOP, not an overwrite.

## 3. Preflight (read-only)

```
credentials   resolve via CredentialProvider            credential-policy.md
ssh           connect with host-key pinning; run `true`
nas arch      uname -m   x86_64 -> linux/amd64 | aarch64 -> linux/arm64
nas docker    which prefix works: docker | sudo docker | /usr/local/bin/docker
nas compose   `docker compose version`, else `docker-compose version`
nas disk      df on the Docker volume - must hold the image tar + backup
nginx         container is running (nginx-policy.md §1) - when Nginx work is needed
```

Build for the **NAS** architecture, not the local one. Anything unreadable becomes a
named blocker, never an assumption. A preflight failure stops before anything is built.

## 4. Local build and export (this machine only)

```
validate Dockerfile exists -> docker build --platform <nas-arch> -t <tag> <context>
-> docker image inspect <tag>            (image exists - exit code, not belief)
-> docker save -o <scratch>/<repo>-<deployment-id>.tar <tag>
-> sha256 of the tar                      (kept for step 6)
```

If the compose has `build:`, see §7 - the NAS-side compose never builds. Build
failure stops here; nothing has touched the NAS. The `.tar` lives in the scratch
directory (outside the project and outside any repository).

## 5. UPDATE: backup, then verify

`backup-policy.md`. Runs **before** anything on the NAS changes - including staging
into the project directory's live files and `docker load`. No `VERIFIED` backup ->
`STOP`, report, no change.

## 6. Stage, transfer, load

```
mkdir  <project>/.staging/<deployment-id>/       (NEW: also the project dir)
transfer  image tar + staged compose + needed config   -> .staging/<deployment-id>/
remote sha256sum == local sha256                  (transfer verified, or STOP)
docker load -i .staging/<deployment-id>/<tar>
docker image inspect <tag>                        (the expected tag is now present)
```

Transfer tool: `runtime/transfer-provider.md`. Nothing in `.staging/` is live: the
compose and config are promoted into the project directory only after the load check
passes. `.env` is never staged unless the user confirms it is intended.

## 7. Compose

The compose that runs on the NAS is image-based:

```yaml
services:
  app:
    image: my-api:20261001-221500-a18c992      # explicit tag - never `latest`
```

- If the local compose contains `build:`, say: **"NAS deployment policy prohibits
  build on NAS"**. The staged copy is derived by setting `image:` to the tag and
  removing `build:`; the user's local file is never edited. If the transformation is
  not mechanical, stop and ask.
- Promote: write the staged compose over the live one only after backup (UPDATE) and
  load verification.
- Validate: `docker compose config` must exit 0 **before** `up`.
- Apply: `docker compose up -d` - never `build`, never `--build`, never `down -v`.
- Image changed -> UPDATE records the previous tag first (it is the rollback target).

## 8. Health verification

Compose returning 0 is not a deployment. Check, per `health` in the metadata /
project settings, and report each with its real output:

```
container running     docker compose ps -> state running, no restart loop
container health       docker inspect -> Health.Status, when a healthcheck exists
tcp                    port accepts a connection
http                   status == expected_status, path and port from the spec
app endpoint           e.g. /health through Nginx at the FQDN, when Nginx is in play
```

```yaml
health: { type: http, path: /health, expected_status: 200, timeout_s: 60, interval_s: 3 }
```

Poll until `timeout_s`; success needs the check to pass, not merely not-yet-fail.
No health spec and none inferable -> container-running only, and the report says
`Health: container-only (no application check defined)` - never `PASS` for an
application check that was not run.

## 9. Nginx

`nginx-policy.md`. NEW: create the conf, validate, reload. UPDATE: back up, change
only if the change is needed, validate, reload. Test before every reload; a failed
test never reloads.

## 10. Metadata

On success write `<project>/.deploy/current.yaml` (`templates/deployment-metadata.example.yaml`):
project, folder, subdomain, deployment id and time, image name + tag, local commit
(short sha, `dirty` flag), Nginx config path, **previous image tag**, health status.
No key, password, token or `.env` content. Written last, so a half-finished deploy
never claims to be current.

## 11. Rollback (UPDATE only; a NEW project that fails is reported, not deleted)

Triggers: `docker load` ok but compose will not start · container crash / restart
loop · health failure · Nginx validation failure · application validation failure.

```
1 stop the failed deployment                 docker compose stop   (not `down -v`)
2 restore previous compose + config          from backup/<id>/compose, /config
3 restore previous Nginx conf                from backup/<id>/nginx   -> nginx -t
4 switch back to the previous image tag      still loaded - never removed early
5 docker compose up -d
6 VERIFY the previous version                the same §8 checks - rollback is not
                                             trusted until they pass
7 reload Nginx if its conf changed (after nginx -t)
```

Persistent data is **not** restored by rollback (`backup-policy.md` §3). If step 6
fails: `ROLLBACK FAILED - MANUAL INTERVENTION`, with the backup id and what was
tried; stop, do not improvise further. A NEW project's failure leaves what exists
and reports it - removing it is a deletion needing approval.

## 12. Cleanup

- Local `.tar`: removed after a successful deploy; kept on failure for one retry; at
  most the most recent failed one is kept.
- NAS `.staging/<deployment-id>/`: removed after success - only that exact validated
  path, which this run created.
- Previous image: kept until the new version's health check is `PASS`; pruning
  afterwards is a destructive operation (`safety-policy.md` §3), listed and asked.
- Temporary key file: removed in every outcome (`credential-policy.md` §3).
