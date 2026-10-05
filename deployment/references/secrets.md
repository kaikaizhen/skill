# Secret Handling

Hard Rule 7 is the rule. This file is the how.

## 1. What counts as a secret

Passwords, connection strings containing credentials, JWT / signing keys, API keys,
tokens, private keys and certificates with keys, registry credentials, kubeconfigs,
SSH deploy keys, webhook secrets. When unsure, treat it as a secret.

Non-secret configuration (feature flags, URLs without credentials, log levels, ports)
goes to normal configuration (ConfigMap, env file, appsettings).

## 2. Where secrets live, by target

| Target | Secret store | What the repository contains |
|---|---|---|
| CI itself (registry login, deploy keys, kubeconfig, NuGet key) | CI variables / secrets (masked, protected for production) | the variable **name** only |
| Kubernetes | Kubernetes Secret created outside the repository (operator `kubectl create secret`, or External Secrets / Vault if the repository already uses it) | `secretKeyRef` / `envFrom.secretRef` by name |
| Docker Compose on VM | env file on the host, outside the repository, mode `0600` | `env_file: <host path>` + `.env.example` with names only |
| systemd | `EnvironmentFile=/etc/<app>/<app>.env` on the host, `root:root 0600` (readable by systemd, injected into the service) | the unit file referencing it |
| Existing Vault / cloud secret manager | that store | whatever reference style the repository already uses |

Never generate a Kubernetes `Secret` manifest with `data` / `stringData` values, and
never base64 a value into a file - base64 is not encryption.

## 3. Conventions

- ASP.NET Core: inject via environment variables using `__` for nesting
  (`ConnectionStrings__Default`, `Jwt__SigningKey`). Committed `appsettings*.json`
  keep the key with an empty value or omit it - never a real value.
- Name variables `<APP>_<PURPOSE>` or follow the repository's existing pattern.
- CI jobs never `echo` a secret, never pass one on a command line that is logged
  (`docker login --password-stdin`, not `-p`).
- Production secrets are scoped to production (protected variables / environment
  secrets), not visible to MR / PR pipelines.

### 3.1 Env files: content decides, not the extension

A `.env` extension does not make a file secret. Many repositories legitimately track
per-environment, non-secret configuration (`env/dev.env`, `env/qa.env`) and feed it to
ConfigMaps or compose.

| File | Git |
|---|---|
| `.env.example`, `*.env.example` | **track** - names only, empty values, one-line comment each |
| Tracked config env files (`env/qa.env`, ...) whose every value passes the check below | **track** - leave as they are |
| Local / developer env files: `.env`, `.env.local`, `.env.*.local` (e.g. `.env.production.local`) | **ignore** |
| Files named or used as secret carriers: `.env.secret`, `secrets.env`, the files the repository's own docs / scripts load secrets from | **ignore** |

- Add only the specific ignore entries the repository is missing, each listed in the
  Change Plan. Never add a blanket `*.env` pattern, and never untrack or ignore a file
  that is already tracked as configuration.
- **Content check** for every tracked env / config file the work touches or relies on:
  keys or values matching `discovery.md` §7 (`PASSWORD`, `PWD`, `CONNECTION_STRING`
  / `ConnectionStrings__*` with credentials, `*_KEY`, `JWT*`, `API_KEY`, `TOKEN`,
  `SECRET`, `PRIVATE_KEY`, key material) with a non-empty, non-placeholder value -> a
  leak (§4). Report path:line and key, value masked; recommend moving it to the CI
  secret / Kubernetes Secret / Vault (§2). The rest of the file stays tracked.
- Values like `ASPNETCORE_ENVIRONMENT=QA`, `LOG_LEVEL=Information`, `FEATURE_X=true`
  are configuration, not secrets.

## 4. Existing leaks

When Discovery finds one:

1. Report path:line and key name with the value masked (`Password=****`).
2. Recommend: rotate the credential (it is in Git history), move it to the store in §2,
   replace the file value with an empty value or variable reference.
3. Replacing the value in the working tree is allowed in Generate / Extend when the
   file is one the Change Plan already touches - it removes a secret, it adds no
   behaviour. Otherwise it stays a Finding.
4. Never rewrite Git history; never print the value anywhere.

## 5. Report: Manual setup

The Report lists every secret / variable the user must create: name, where (CI variable
/ K8s Secret name+key / host file path), which environments, and purpose. No values.
