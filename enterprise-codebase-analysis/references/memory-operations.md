# Memory Operations

How memory is **changed**. The trust model, layout, entry format and scope rule
are `memory-system.md`; section numbers continue from it.

---

## 8. Promotion (repository -> shared -> global)

Promote only when at least one holds:

- the repositories use the same shared library;
- the repositories use the same connection factory;
- the same evidence has been found in several repositories;
- official company documentation defines it as a shared rule;
- a DBA or developer has confirmed it.

Only genuinely company-level concepts belong in `global/`. Promotion keeps the
evidence that justified it:

```
## ShardedDb Routing
Status: CONFIRMED
Scope:  SHARED
Promoted From: repositories/ServiceA/routing.md, repositories/ServiceB/routing.md
Evidence:
- ServiceA/src/.../DbConnectionFactory.cs
- ServiceB/src/.../DbConnectionFactory.cs   (same Shared.Data package)
```

## 9. Demotion

If new code no longer matches a `CONFIRMED` entry, demote it - do not delete it:

```
CONFIRMED -> INFERRED | OUTDATED | CONFLICTING
```

Use only the five trust levels, and record why and when. **"Not verified for a
long time" is not a demotion and not a new status.** Keep it `CONFIRMED` with its
old `Last Verified`; spot-check only when a ticket depends on it, then update the
date or demote.

## 10. Incremental Update Only

Updates are an incremental merge, never a full rewrite. Forbidden: regenerating
`database.md` because one fact appeared, overwriting an `overview.md` wholesale,
deleting unrelated knowledge while correcting one item.

```
read the existing memory -> locate the relevant knowledge block -> edit that block
  -> keep everything else untouched -> add Exception / Evidence / Last Verified
```

> Optimise memory, do not replace memory.

A whole-file rewrite is allowed only if the file itself is corrupted.

Targeted edit - before:

```
## ShardedDb Routing
Status: INFERRED
userId last digit may determine ShardedDb.
```

After (every other section unchanged):

```
## ShardedDb Routing
Status: CONFIRMED
userId % 10 determines the ShardedDb shard.
Evidence: ServiceA/src/.../DbConnectionFactory.cs
Last Verified: 2026-09-15
```

## 11. Memory Delta

### Admission - does it belong in long-term memory, and where?

**`memory-admission.md` (§17-22) is the authority**: reusability -> evidence ->
scope -> owner -> duplication -> cohesion, then update / create / split / reject.
Run it before any delta below; `NO CHANGE` is a normal outcome.

Destination within a repository: keep `overview.md` a map, not an architecture
document - add to it only when the repository's purpose, stack, layout, entry
points or legacy hazards change. Prefer the narrower file (`patterns.md`,
`routing.md`, `database.md`, `business-rules.md`) for everything else.

### Delta types

| Delta | When |
|---|---|
| `ADD` | A new reusable fact |
| `UPDATE` | An existing fact gains detail |
| `CORRECT` | An existing fact was wrong or incomplete |
| `PROMOTE` | `INFERRED -> CONFIRMED`, or repository -> shared, with evidence |
| `DEMOTE` | `CONFIRMED -> INFERRED / OUTDATED` because the code changed |
| `NO CHANGE` | Nothing reusable was learned - **do not touch memory** |

Report the delta at Approval Gate #2 as a list of file + section, never as a
regenerated file.

### Companion-source evidence delta

When a ticket used a companion knowledge source declared in `workspace/PROFILE.md`,
perform this small check before writing any memory delta:

1. State the exact page/artifact and the claim it supplied.
2. Confirm whether current repository code, current config/schema, runtime output,
   or an authoritative source supports the same claim for the **active carrier**.
3. Assign one of the five trust levels; a synthesis page or operation log alone
   does not qualify as `CONFIRMED`.
4. Write only the reusable, bounded conclusion to the narrowest destination:
   repository memory by default; `shared/` only after the normal promotion test;
   `global/` only for a genuine company-wide rule.
5. If it is unresolved, contradictory, historical, or ticket-only, do not promote
   it. Record it as `UNKNOWN`, `CONFLICTING`, `OUTDATED`, or leave it in the issue
   analysis as appropriate.

The delta's `Evidence:` must cite both the companion source and the current evidence
that validated or contradicted it. Do not copy raw dumps, credentials, hosts,
connection strings, full query payloads, or historical logs into memory.

## 12. Corrections

When an entry turns out to be inaccurate, correct the block in place and append
to `<skill>/workspace/memory/corrections.md`:

```
## 2026-09-15 - Talent write path
Status: CURRENT
Superseded by: -
Current Rule Location: workspace/memory/repositories/ServiceA/database.md (Write Path)
Repository: ServiceA          Issue: T12345

Previous Understanding (OUTDATED - do not apply):
All talent writes go to PrimaryDb.

New Understanding:
FooLogRepository is an exception and writes ShardedDb directly.

Evidence: ServiceA/src/.../FooLogRepository.cs
Impact:   Read-after-write for FooLog data does not depend on sync latency.
```

And in the memory file itself, keep the general rule with the exception attached
rather than replacing it:

```
Fact:       Most standard talent writes use PrimaryDb as the source before ShardedDb sync.
Exceptions: - FooLogRepository writes ShardedDb directly.
Status:     CONFIRMED
```

Never delete a whole memory file to "clean it up".

### Superseded corrections and resolved unknowns

Old rules must never sit next to new rules unlabelled - a reader can apply the
wrong one. Do not delete history; mark it:

- A correction replaced by a later one -> set the old entry to `Status: OUTDATED`
  and `Superseded by: <new entry heading>`. Only one entry per topic is `CURRENT`.
- Old rule text goes under `Previous Understanding (OUTDATED - do not apply)`
  (or `... (OUTDATED context - do not apply)` in `unknowns.md`).
- When reading `corrections.md` / `unknowns.md`, apply only `CURRENT` entries and
  the memory file named in `Current Rule Location`.

## 13-14. Conflicts, and their limits

If two repositories genuinely behave differently, **keep both**. Do not overwrite
one with the other and do not force a single rule:

```
shared/shard-routing.md            PrimaryDb commonly acts as the source. CONFIRMED
                                   (general), see repository exceptions.
repositories/ServiceA/database.md PrimaryDb -> Sync -> ShardedDb.          CONFIRMED
repositories/ServiceC/database.md direct ShardedDb write for Foo.      CONFIRMED
```

If the conflict cannot be resolved with available evidence, mark the shared entry
`CONFLICTING` and record both observations.

**A contradiction does not justify unbounded analysis.** Investigate one only if
it affects this issue. Memory says `ServiceB Redis topology: UNKNOWN` and this ticket
never touches Redis? Then do not investigate Redis. Issue scope wins over memory
tidiness.

## 15. Optimisation

Over time memory becomes more precise, better evidenced, richer in exceptions,
better scoped and more recently verified - not merely longer. Repeated knowledge
inside a file may be tidied **in that section**; the memory tree and other files
may not be rewritten in the name of tidying.

## 16. Splitting a large `patterns.md`

The general split / over-split policy for **any** memory file is
`memory-admission.md` §21. This section is the repository-`patterns.md` case.

`patterns.md` is a repository-level quick-navigation file, not a dump for every
domain. **File size alone is never a sufficient reason to split.** Consider
splitting into `repositories/<repo>/<domain>.md` only when most of these hold:

1. Multiple genuinely unrelated domains have accumulated in the same file (not
   several sections about one domain).
2. At least one of those domains has enough stable, evidenced knowledge to stand
   on its own.
3. Splitting measurably lowers the cost of reading memory for a typical ticket.
4. The domain's content would otherwise keep being duplicated inline.

A file that is long because one domain has a lot of detail is a candidate for
tidying (§15), not for a split.

After a split, `patterns.md` keeps **only** each split domain's name, a 1-3 line
summary, a link to `repositories/<repo>/<domain>.md`, and the single most
important cross-domain warning if one exists. Everything else -
`Fact`/`Status`/`Evidence`/`Notes` - moves to the dedicated file. Never leave a
copy in both: `patterns.md` indexes, the dedicated file holds the content.

Unchanged by a split: the trust model (current code still outranks every memory
file), the entry format and the five statuses, explicit demotion when a dedicated
file goes stale (a stale dedicated file is *more* dangerous, because the index
keeps pointing at it), and the requirement that the split itself be a targeted
incremental edit rather than a wholesale regeneration.
