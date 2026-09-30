# Memory Admission & Maintenance

**Whether** a fact enters memory, **where** it goes, and **when** a unit is split.
This is the **primary and sufficient** reference for deciding to persist new
knowledge - load it on its own. The files named below are navigation, not a
required reading chain: load one only if you actually reach that situation
(promoting a layer, demoting, recording a correction, reporting the delta).
Section numbers continue from `memory-system.md` (§1-7) and
`memory-operations.md` (§8-16).

```
Memory stores reusable system knowledge, not every fact discovered during a task.
Useful for this task  !=  worth storing in long-term memory.
```

**A completed task does not require a memory update.** `Memory Delta: NONE` is a
normal, correct outcome - including for a large ticket. Growth is intentional,
never automatic.

---

## 17. The Admission Gate

Run in order. The first `No` ends it.

```
New knowledge
  ├─ 1 Reusable?          No  -> REJECT (stays in the issue analysis)
  ├─ 2 Evidence enough?   No  -> record UNKNOWN / INFERRED, do not promote to fact
  ├─ 3 Scope?                 -> global | shared | repository
  ├─ 4 Who owns the topic?    -> find the existing knowledge unit first
  ├─ 5 Already recorded?  Yes -> reference the canonical owner, do not copy
  └─ 6 Cohesion preserved?
         Yes -> UPDATE the owning unit
         No  -> has its own clear retrieval trigger?
                  Yes -> CREATE a new unit   (or SPLIT the owner, §21)
                  No  -> REJECT
```

### 1 - Reusability

> Could this help a **future** ticket, debug, onboarding or explanation?

It qualifies only if it will narrow a future search, avoid a trap, or locate code
/ DB objects / dependencies faster.

| Store | Do not store |
|---|---|
| a repository's fixed responsibility | "Ticket #1234 threw NRE on null input" |
| a stable execution flow for an API | "an API returned 500 in today's test" |
| data ownership for a domain | "the bug was at line 283" |
| what a search index is for | "this change touched three files" |
| a shared auth / authorization pattern | "the build passed today" |
| a fixed routing convention | a temporary branch name |
| an architecture boundary that is easy to misjudge and now evidenced | one-off debug output, IDs, timestamps, request bodies |

Also excluded (carried over from the original admission test, and not covered by
the rows above): code-shape observations such as "method X has 7 `if` branches",
and step-by-step debugging notes.

The right column is task result, investigation evidence, temporary observation or
execution history. It belongs in `<workspace>/issue/<Repo>/`, not in memory - and
being useful *this* time does not change that.

### 2 - Evidence

Current code, config, deployment, schema, logs, tests or verified documentation.
Short of that, do not promote a guess to a fact. Use only the five statuses -
`CONFIRMED` `INFERRED` `UNKNOWN` `OUTDATED` `CONFLICTING` (definitions:
`memory-system.md` §5, needed only if the choice is unclear). Genuinely open
questions go to `unknowns.md` with `Blocking Now:`, never into an architecture or
pattern file as if settled.

### 3 - Scope

| Layer | Admit only if | Counter-example |
|---|---|---|
| `global/` | genuinely cross-repository **and** stable **and** company-level **and** used by several domains | "this is important" - importance is not the test |
| `shared/` | proven across more than one repository, but belonging to one domain / infrastructure (search, auth, authorization, redis, logging, jobs routing) | one repository's implementation detail |
| `repositories/<repo>/` | true only for that repository, or describing its actual implementation | a rule you *assume* other repos share |

Default is `repositories/`. Staying repository-scoped needs nothing further. Only
if you are actually moving a fact **up** a layer, load `memory-operations.md` §8
for the promotion criteria - a hunch that it is "probably shared" is not one.

### 4 - Knowledge Ownership

Never "saw a related filename, appended to it". Find the owner first:

```
new knowledge -> which domain? -> which topic? -> search global/, shared/,
repositories/, corrections.md, unknowns.md -> then decide update / create / reject
```

Search before writing; an owner you did not look for is not an owner that does not
exist (SKILL.md -> negative evidence).

### 5 - Duplication

**One canonical owner per piece of knowledge**, plus lightweight pointers.

```
right:  shared/search/overview.md   holds the Search API architecture
        repositories/<repo>/...     "this repository consumes the shared Search
                                     API - see shared/search/overview.md"

wrong:  the same architecture written out in global/, shared/ and two repository
        files, drifting apart version by version
```

If the knowledge already exists elsewhere, add a reference, not a copy. If it
exists in the *wrong* layer, move it to the canonical owner and leave a pointer -
do not leave both. Genuinely different behaviour between repositories is **not**
duplication; keep both, per `memory-operations.md` §13-14.

### 6 - Cohesion

Adding this must not turn a focused unit into a catch-all. If it would, the
knowledge either goes to its own unit (§20) or triggers a split (§21).

---

## 18. Retrieval Trigger

Every knowledge unit answers one question:

> What kind of future question should cause this file to be loaded?

A good trigger is specific and independently recognisable:

```
good   shared/<domain>/<domain>-indexing.md
       - the datastore was updated but reads still show old data
       - a specific index / projection is out of sync
       - bulk or batch ingestion failures
       - the indexing pipeline owned by <service>

bad    "anything related to <domain>"
```

A new unit without a clear trigger is not a new unit - fold it into the owner. A
unit whose trigger has become "anything about X" has lost cohesion (§21). State the
trigger in the file's header note so future routing can rely on it.

---

## 19. Current Evidence vs Memory

Current evidence always wins (`memory-system.md` §2, §4; SKILL.md HARD RULE 6).
Never reinterpret current code to make it agree with memory. On a conflict:

```
1 flag the conflict
2 verify the current evidence
3 decide whether the memory entry is stale, a different flow, or a real exception
4 update the canonical entry (targeted edit; add the exception rather than
  erasing the general rule)
5 if a previously CONFIRMED entry was actually wrong, or a status must drop,
  load `memory-operations.md` (§9 demotion, §12 corrections) at that point
```

Never leave two entries that both claim to be confirmed and contradict each other.
Investigate a contradiction only as far as this issue needs (§13-14).

---

## 20. Creating A New Knowledge Unit

Allowed only when **all** hold:

1. it passed the admission gate;
2. it has a clear, independent retrieval trigger (§18);
3. no existing unit owns the topic, and extending the nearest one would break its
   cohesion;
4. the name describes the content precisely enough to route on.

Otherwise update the existing owner. A new file is a routing cost as well as a
storage location: more files is not the goal.

---

## 21. Split & Over-Split

**Size alone is never a reason to split.** Weigh size *and* topic cohesion *and*
independent triggerability *and* average retrieval context *and* cross-file
dependency. A 2,500-word file serving one trigger can be correct; a 1,000-word
file covering authentication, search, database and deployment is not.

Split signals - indicators, not thresholds:

1. the file covers three or more clearly independent retrieval triggers;
2. most questions need only a small part of it;
3. different sections are used independently by different domains / repositories;
4. the filename no longer describes the contents;
5. new knowledge only fits by continuing to append;
6. reading it routinely drags in large irrelevant sections.

**Over-splitting is the opposite failure.** If several pieces are normally
retrieved together they belong in one unit - do not produce
`...-query.md`, `...-filter.md`, `...-sort.md`, `...-ranking.md` for knowledge that
is always read at once. The target is high cohesion, a clear trigger, little
unnecessary context and low routing complexity.

After any split: the original keeps only each split topic's name, a 1-3 line
summary and a link; the dedicated file holds the content; never both
(`memory-operations.md` §16, which this generalises to every memory file). Update
every inbound reference in the same change.

---

## 22. Status Lifecycle

`UNKNOWN` and `INFERRED` are staging states, not permanent homes.

```
UNKNOWN  --evidence found-->  write the fact to its canonical owner as CONFIRMED,
                              then resolve/remove that unknowns.md entry
         --still unresolved-> stays UNKNOWN
INFERRED --direct evidence--> promote to CONFIRMED in the canonical owner
```

The same subject must never sit as `UNKNOWN` in `unknowns.md` while a canonical
file already states it as `CONFIRMED`. Resolving an unknown is part of the delta
that confirmed it, not separate housekeeping.

**Corrections are a guard rail, not a changelog.** `corrections.md` exists to stop
a known-wrong understanding being adopted again - not to archive every change.
Supersession rules stay as in §12. An entry becomes a **retirement candidate**
when all hold: the correct fact is fully absorbed into the canonical memory file;
no current memory still carries the old claim; and the old belief is no longer
plausible enough to be re-derived. Retire by removing that single entry, noting
the canonical location in the delta - never by rebuilding the file, and never in
bulk. When in doubt, keep it: a wrong belief that can recur is worth more than the
lines it costs.

---

## Reporting the outcome

The admission decision is `UPDATE` / `CREATE` / `SPLIT` / `REJECT`. When a ticket
reaches Approval Gate #2 it reports a memory delta; the delta vocabulary and the
targeted-edit mechanics live in `memory-operations.md` §10-§11 - load it then, not
to make the decision above. `Memory Delta: NONE` is the expected result whenever
this gate rejected everything.
