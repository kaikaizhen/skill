# Safety Policy

## 1. Fixed boundaries

```
Project      <deploy_root>/<project-folder>
Backup       <deploy_root>/<project-folder>/backup/
Staging      <deploy_root>/<project-folder>/.staging/<deployment-id>/
Metadata     <deploy_root>/<project-folder>/.deploy/
Nginx conf   <nginx_conf_dir>/<project-folder>.conf
```

Nothing is created, changed or deleted outside these. The root is a constant of the
skill, not an input. Git is read-only (`status`, `rev-parse --short HEAD`, `diff`);
no commit, stash, push, force push or remote branch change, ever.

## 2. Input validation - before any value touches a command

A project folder or subdomain is untrusted input. Validate, then quote, then use.

```
project-folder   ^[A-Za-z0-9][A-Za-z0-9_-]{0,62}$
subdomain        ^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$
image repo       lower-case form of the project name, same charset
```

Rejected: anything containing `/` `\` `..` `~` `$` a space, quote, backtick, `;`
`&` `|` `<` `>` or a leading `.` or `-`; empty; and the reserved folder names `Nginx`
(case-insensitive), `backup`, `.staging`, `.deploy`. So `../`, `/etc`, `~/x` and
`../../etc` all fail. Rejection ends the request with the rule that failed - no
"fixing up" the value silently.

After validation, a remote path is composed only from the constant root plus the
validated name, and each argument is single-quoted in the remote command. A value
never reaches `eval`, `sh -c "...$var..."` unquoted, or a glob.

## 3. Approval matrix

**Automatic** (no prompt):

```
docker build · docker save · SSH connectivity check · read-only remote commands
create backup · verify backup · upload to .staging/ · docker load
docker compose config · health checks · nginx syntax test
```

**Automatic by policy** (`workspace/deploy.yaml` -> `auto_apply`, default `true`),
and only after their gates passed (verified backup, load check, `compose config`,
`nginx -t`):

```
docker compose up -d · nginx reload
```

**Always ask first** - every time, even if a previous approval existed:

```
delete persistent data                  database restore
docker volume rm                        docker compose down -v
docker system prune / image prune / container prune
rm -rf of an arbitrary path             destructive migration
overwrite an unknown project / directory / conf
modify SSH authorized_keys              any credential modification
rollback of persistent data             removing a NEW project that failed
```

The skill-owned exceptions to "no deletion" are exactly: the local `.tar` it made,
its own `.staging/<deployment-id>/`, its own temp key file, a conf file it created in
this run that failed validation, and backups that pass every retention check
(`backup-policy.md` §5). Each is deleted by exact validated path.

## 4. Local-build invariant

On the NAS the only docker operations are: `load`, `image inspect`, `compose config`,
`compose up -d`, `compose ps/stop/logs`, `ps`, `inspect`, `exec <nginx> nginx -t`.
`docker build`, `docker compose build` and `up --build` are never run there, and a
`build:` key is never present in the compose the NAS runs.

## 5. Evidence discipline

Every `PASS` in the report maps to a command that ran and its result. Not run ->
`NOT RUN` with the reason. A model's belief that a step worked is not evidence.
Retry limits: one retry for an obvious named cause; the same step failing twice stops
the run (`deployment-workflow.md`).

## 6. Information handling

Reports and logs contain no key material, no password, no `.env` values, no token.
Quoted tool output is redacted first. The NAS address is not repeated in the final
report beyond a label.
