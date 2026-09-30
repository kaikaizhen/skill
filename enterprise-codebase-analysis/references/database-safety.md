# Database Safety

**Highest priority hard rule.**

```
READ ONLY BY DEFAULT
ANY MUTATION REQUIRES EXPLICIT USER APPROVAL
```

---

## Allowed Without Asking (read-only)

Only if you are certain the operation has no side effect:

```
SELECT
read schema
read table definition
read index definition
read view definition
read stored procedure definition
read execution plan
read DB metadata
read config
read connection mapping
read log
compare data across shards
read repository code
```

---

## Requires Explicit Approval

```
INSERT   UPDATE   DELETE   MERGE   TRUNCATE
CREATE   ALTER    DROP
migration            schema change          index change
executing a mutating stored procedure
SQL Agent job        batch                  sync
backfill             data repair            test-data write
persistent cache rebuild                    trigger-related mutation
```

Plus: **any operation whose side effects you are not sure about.**

Including this - the rollback does not exempt it:

```sql
BEGIN TRANSACTION
UPDATE ...
ROLLBACK
```

Writing test data into any shared or non-local database is a mutation and needs
approval like any other.

---

## Approval Format

When a DB write is genuinely needed, stop and output:

```
DATABASE MUTATION APPROVAL REQUIRED

Operation:
...

Target Repository:
...

Server:
...

Database:
...

Table / Object:
...

Purpose:
...

Expected Changes:
...

Possible Impact:
...

Rollback / Recovery:
...

Alternative Read-only Investigation:
...

Awaiting explicit approval.
```

Then **STOP**. No approval, no execution.

If the user declines, continue the ticket using the read-only alternative you
listed - do not treat the refusal as a blocker unless it genuinely is one.

## This Gate Is Not The Blocking Gate

Needing a DB mutation does **not** make the requirement blocked. The analysis
reports:

```
STATUS: READY FOR ANALYSIS
Database Mutation Required: YES
```

and the approval above is requested at the point the write is needed.

It escalates to `STATUS: BLOCKED` only when **all** hold: the user declines,
no read-only alternative exists, and the root cause / implementation therefore
cannot be established.

---

## Notes

- Approval is per operation, per session. Approval for one `UPDATE` does not
  authorise the next one.
- Never widen an approved statement (extra rows, extra columns, a looser
  `WHERE`). If the statement changes, ask again.
- If a test plan requires DB writes, surface that at Approval Gate #1 so the user
  sees it before implementation starts - do not discover it mid-implementation.
- Prefer investigation that does not mutate: read the repository code, read the
  schema, compare shards with `SELECT`, read logs.
