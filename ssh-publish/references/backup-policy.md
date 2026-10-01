# Backup Policy

UPDATE only. HARD RULE 3: no verified backup, no change.

## 1. Layout

```
<deploy_root>/<project-folder>/backup/<backup-id>/
├─ .skill-backup          marker: created by this skill (retention relies on it)
├─ compose/               docker-compose.yml / compose.yaml as deployed
├─ config/                .env or deployment config (stays on the NAS)
├─ nginx/                 <project-folder>.conf as it was
├─ metadata/              .deploy/current.yaml, plus image/container state
└─ data/                  only what §3 says to include
```

`backup-id` = `YYYY-MM-DD_HHmmss` (`deployment-workflow.md` §0). The backup lives
under the project, inside the fixed root - never elsewhere.

## 2. Scope - what every UPDATE backs up

```
compose file                          current deployed image name:tag
.env / deployment config              container state  (docker compose ps, inspect)
Nginx project conf                    .deploy/current.yaml
```

`metadata/` records: the image tag and image ID currently running, container
names/status, and the compose project name - everything §5 of the workflow needs to
switch back.

## 3. Persistent data - classify first, never a blanket `cp -r`

Before the first backup of a project, list what the compose mounts and classify each:

| Kind | Backup | Rollback |
|---|---|---|
| Application config / compose / Nginx | always (§2) | automatic |
| Bind-mounted files (uploads, assets) | per project policy: include, exclude, or ask | **not** automatic |
| Named volume | per project policy; never read a live volume by guessing its path | **not** automatic |
| **Database** | **DB-native dump only** (`pg_dump`, `mysqldump`, `sqlite3 .backup`, ...) | restore is a user decision |

- A **live database's files are never copied** - the copy can be torn and still look
  fine. No DB-native method available or authorised -> record
  `data: NOT BACKED UP - <reason>` and ask whether to continue.
- The classification is saved in the project's metadata so the next update does not
  re-ask. Unclassified data is treated as **ask**, not **skip**.
- **Application rollback and data rollback are different operations.** Rolling back
  the app never restores data, and says so; restoring data is destructive and needs
  approval (`safety-policy.md` §3).

## 4. Verify - a backup is not a backup until checked

```
every expected file exists in backup/<id>/ and is non-empty
compose + nginx copies are byte-identical to the live files   (sha256 compare)
metadata/ records the running image tag and container state
data/ dumps (if any) exit 0 and are non-empty
```

Result `VERIFIED` or `NOT VERIFIED - <what failed>`. `NOT VERIFIED` -> `STOP`; the
live deployment is untouched, so nothing is lost by stopping.

## 5. Retention

```yaml
backup: { keep: 5 }          # workspace/deploy.yaml
```

After a **successful** deployment, a backup directory may be removed only if **all**
hold:

1. it is directly under `<project>/backup/` of the project being deployed;
2. its name matches `^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{6}$`;
3. it contains the `.skill-backup` marker;
4. it is older than the `keep` most recent such directories;
5. it is not the backup that belongs to the deployment just made.

Pruning removes exactly the validated directory by its full path - the one narrow
form of recursive delete this skill performs - and lists what it removed. Anything
that fails a check is left alone. Never a glob, never a variable that was not
validated, never an unmarked directory.
