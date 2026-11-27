# Backup & Restore (assess / review / extend-existing only)

For repositories whose delivery includes **state that a redeploy does not bring back**:
cluster objects (Secrets, ConfigMaps), persistent volumes, databases, object storage.
v1 does not design a backup system (`existing-platform.md` §1). It recognises one,
checks that it covers what the pipeline changes, and extends it by copying an existing
schedule. Never introduce a backup product the repository does not already use.

## 1. What a pipeline redeploy does not restore

| State | Why git + CI cannot rebuild it | Usual owner of the copy |
|---|---|---|
| Secrets created outside the repository (`secrets.md` §2) | the value was never committed | cluster backup of `secret` objects, or the secret store itself |
| Database contents | data, not manifests | database-native backup + log archive to object storage |
| Persistent volumes | data on a disk | volume snapshot via the CSI snapshot controller, or a storage-layer backup target |
| Helm release state | the rendered manifests of a past revision live in release Secrets | cluster backup of the release Secrets |
| Object-store buckets | data | bucket replication / versioning |

Manifests, images and ConfigMaps from git are **not** the backup: re-running the
pipeline recreates them. Record per environment which of the rows above exist.

## 2. Cluster-object backup (Velero style)

- Backup storage is an **S3-compatible bucket** (object store in the same site or
  another); credentials come from a file or Secret outside the repository, the
  bucket name and endpoint are values, a private CA is given with `--cacert`.
  Backing up to storage on the same host as the cluster is not a disaster copy
  (Finding, Medium).
- Schedules are explicit: include-namespaces, **include-resources** (an allow-list such
  as `deployments,services,configmap,secret,cronjob,ingress`), a cron expression and a
  `ttl`. Frequent (hourly) for the application namespace, daily for Secrets that
  rarely change. A schedule with no `ttl` grows without bound.
- **Exclusion by label**: `velero.io/exclude-from-backup=true` on objects that are
  regenerated (the per-namespace root-CA ConfigMap, Secrets copied by a replicator) so a
  restore does not fight the controller that owns them. Objects that must be kept but
  have no natural selector get an explicit label (e.g. `is-<tool>-agent=true`) so a
  schedule can select them with `--selector`.
- Volume snapshots need the snapshot CRDs and controller **pinned to a version** and
  the CSI feature enabled; without them a "backup" holds manifests only. Say which.
- Helm releases restored from release Secrets: after the restore, re-apply the manifest
  of the **highest revision** per release
  (`helm get manifest <rel> --revision <n> -n <ns> | kubectl apply -f -`).
  A restore that stops at the Secrets leaves the workloads absent.
- A restore name is `<backup>-<UTC timestamp>` so repeated restores do not collide.

## 3. Database backup (operator-managed PostgreSQL style)

- Two parts: **base backup on a schedule** (`ScheduledBackup`) **plus continuous log
  archiving** (WAL) to an object store, with a **retention policy** (e.g. 30 days).
  Both present = point-in-time recovery; only a schedule = restore to the last backup.
- One object-store definition per environment, referenced by name from the cluster
  (`barmanObjectName`); the server name inside the bucket is part of the key - a
  rebuilt cluster that reuses the old name overwrites or mixes archives. Use a new
  server name for a new cluster and keep the old one as the restore source.
- Restore is a **bootstrap from a recovery source** on a *new* cluster
  (`bootstrap.recovery.source` + `externalClusters`), kept as a commented block next to
  the live bootstrap so the procedure is reviewed, not improvised. Restore is never
  run by the pipeline, and never over a live cluster.
- Single-instance clusters (`instances: 1`) have no replica to fail over to: backups
  are the only recovery. State that in the Assessment.
- Credentials and the CA for the object store are Secret references, never inline.

## 4. Review questions (each answered with `path:line` or `UNKNOWN`)

```
1 Which state does this delivery change that git cannot restore, and is each covered?
2 Where is the copy: same host / same site / another site?
3 How often, how long kept (ttl / retention)?
4 When was a restore last exercised, and by whom?        (never exercised = Finding)
5 Does the backup include the objects a new service adds (new namespace, new Secret)?
6 Are the credentials for the backup store outside the repository?
7 What does restore need that is not in the backup (CA, encryption key, DNS entry)?
```

## 5. Findings

| Severity | Finding |
|---|---|
| High | Production data store with **no** backup, or backups only on the same disk/host |
| High | Backup credentials or object-store keys in a tracked file (`secrets.md` §4) |
| Medium | Base backups without log archiving where point-in-time recovery is assumed |
| Medium | Schedule without `ttl` / retention; resource allow-list missing a new Secret kind |
| Medium | Volume snapshot expected but the CSI snapshot controller / CRDs are not installed |
| Medium | Restore path never rehearsed, or documented only as an inline shell history |
| Low | Per-environment copies of the same schedule with drifting retention |

## 6. What this reference does not do

No new schedules, buckets, retention values or restore runs are generated. Extend is
limited to copying an existing schedule or backup object for a new namespace or
service and changing values; a restore is always the operator's action, after approval.
