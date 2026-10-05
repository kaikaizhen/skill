# Target: VM + Docker Compose

Single host running the app as containers. When to pick it over systemd:
`decision-rules.md` §6.

## 1. Files

| File | In repository | Purpose |
|---|---|---|
| `deploy/compose.yaml` (or the existing compose path) | yes | the **host** compose: `image:` only, no `build:` |
| `deploy/.env.example` | yes | names of every variable the host must provide |
| Local-dev compose with `build:` | keep if it exists | not used for deployment |
| `/opt/<app>/.env` on host | **no** | `IMAGE_TAG` + non-secret config |
| `/opt/<app>/secrets.env` on host | **no** | secrets, `0600` (`secrets.md` §2) |

If the repository's only compose file mixes `build:` with deployment use, keep it for
local development and add a separate host compose; do not rewrite the existing one
(Gate 4 otherwise).

## 2. Host compose shape

```yaml
services:
  <app>:
    image: ${REGISTRY_IMAGE}:${IMAGE_TAG:?IMAGE_TAG is required}
    restart: unless-stopped
    env_file: [.env, secrets.env]
    ports: ["127.0.0.1:<host port>:<container port>"]   # loopback behind an existing reverse proxy; 0.0.0.0 only if the user says it is exposed directly
    # healthcheck: only when the image has a tool to run it - see below
```

- `<container port>`: `stacks/dotnet.md` §1.1. `<host port>`: existing compose /
  reverse-proxy config -> user. Either `Unknown` -> Gate 7 (`decision-rules.md` §9);
  never a conventional number.
- The healthcheck command must exist in the image: Debian `aspnet` images have
  neither `curl` nor `wget`, and `-chiseled` images have no shell at all. Default:
  **omit the container healthcheck** and let the deploy job's smoke test call
  `http://127.0.0.1:<host port><health path>` from the host. Keep a container healthcheck only if
  the image already ships a usable tool, or add one to the Dockerfile as an item listed
  in the Change Plan. State which in the Assessment.
- Supporting services (Redis, DB) only if the repository already runs them in compose
  or the user asks; volumes for them are named volumes, never bind-mounted into the
  repository checkout.

## 3. Deploy job (from CI over SSH)

```bash
scp deploy/compose.yaml "$DEPLOY_USER@$DEPLOY_HOST:/opt/<app>/compose.yaml"
ssh "$DEPLOY_USER@$DEPLOY_HOST" '
  set -euo pipefail
  cd /opt/<app>
  grep -E "^IMAGE_TAG=" .env > .previous_tag || true
  if grep -q "^IMAGE_TAG=" .env; then sed -i "s/^IMAGE_TAG=.*/IMAGE_TAG=<sha>/" .env; else echo "IMAGE_TAG=<sha>" >> .env; fi
  docker compose pull
  docker compose up -d --remove-orphans
'
<smoke test against 127.0.0.1:<host port><health path> on the host, with retries; fail the job otherwise>
```

- Host must be logged in to the registry with a **read-only** pull token (Manual setup).
- `up -d` recreates the container: brief downtime on a single host. Say so in the
  Assessment; zero-downtime on one VM is out of scope for v1.
- `--remove-orphans` is included only when this compose file is the only one in that
  project directory.

## 4. Manual setup (Report)

Docker + compose plugin on the host; `/opt/<app>/` owned by the deploy user; deploy
user in the `docker` group (note: equivalent to root on that host); registry pull
login; `.env` and `secrets.env` created; CI variables from `ci/<provider>.md` §5.

## 5. Rollback

```bash
ssh <host> 'cd /opt/<app> && grep IMAGE_TAG .env && cat .previous_tag'
ssh <host> 'cd /opt/<app> && sed -i "s/^IMAGE_TAG=.*/IMAGE_TAG=<previous sha>/" .env && docker compose up -d'
```

Then the same health / smoke checks. Or re-run the previous good commit's deploy job.
Images for older tags must still exist in the registry - keep a retention policy that
retains at least the last few production tags (Manual setup note).
