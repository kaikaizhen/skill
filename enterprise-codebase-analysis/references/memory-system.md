# Memory System - Trust Model

Local, repository-scoped, incremental, and **advisory only**. Whether a fact is
admitted at all, and where it belongs, is `memory-admission.md`. How memory is
*changed* (promotion, demotion, delta, corrections, conflicts, splitting) is
`memory-operations.md`.

---

## 1. Layout

Memory lives in `<skill>/workspace/memory/`. It holds reusable knowledge only; per-ticket
detail belongs in `<workspace>/issue/<RepoName>/`, never in `<skill>/`. Any older
reference to `.company-skill/memory/` means `<skill>/workspace/memory/`.

```
memory/
├── global/        company-level concepts only
│                  architecture.md  database.md  domains.md  glossary.md
│                  development-workflow.md  environments.md
│                  engineering-standards.md   <- team standards (the organization's engineering-standards source),
│                                                proposal-level only, see
│                                                development-convention.md §1
├── shared/        behaviour PROVEN shared across repositories
│                  one file (or one folder) per domain / infrastructure area,
│                  e.g. routing, caching, search/{hub + per-trigger units},
│                  shared services, authentication, authorization,
│                  domain-entrypoints, logging-troubleshooting
├── repositories/<RepoName>/
│                  overview.md  database.md  routing.md  dependencies.md
│                  patterns.md  business-rules.md
│                  <domain>.md   (optional, only after a split - operations §16)
├── unknowns.md
└── corrections.md
```

---

## 2. Memory Is A Hint, Not The Truth

**This is the central rule.** Memory means *"this is what was observed before"*,
never *"this is still true now"*.

- Memory says `PrimaryDb -> ShardedDb`? That does not let you ignore a direct ShardedDb write
  in the code you are reading right now.
- Memory says `ServiceB uses Redis`? That does not mean this flow touches Redis.

Memory may be used to locate files quickly, suggest candidate components, supply
search keywords, avoid re-learning terminology, and carry past architectural
context. It may never override current evidence.

### When to re-verify (spot-check) a memory fact

Memory is trusted as navigation / context **without re-verifying every fact** -
otherwise it never makes the next ticket faster:

```
wrong:  understand once -> store -> next time re-confirm everything
right:  understand once -> store -> next time go faster
```

Re-verify a fact only when: it materially affects the correctness of the current
implementation; current evidence contradicts it; it looks stale (`INFERRED`, old
`Last Verified`, an area known to have changed); or the ticket specifically
depends on that behaviour.

| Memory | Ticket | Re-verify? |
|---|---|---|
| `userId % 10 -> ShardedDb` | Rename a DTO field | No - does not affect this change |
| `userId % 10 -> ShardedDb` | "ShardedDb reads the wrong shard" | Yes - it is the core logic |
| `ServiceB uses Redis` | Change a validation message | No |
| `ServiceB uses Redis` | "Stale data after update" | Yes - cache is a candidate cause |

A spot-check that confirms the fact updates its `Last Verified` (targeted edit);
one that contradicts it follows section 4.

---

## 3. Lookup Order vs Trust Order

**Lookup order** (only to narrow the search):

```
repository memory -> relevant shared -> relevant global -> this issue's evidence
```

**Trust order** (who wins on disagreement):

```
repository-local instructions (CLAUDE.md, AGENTS.md, .claude/skills/*)
 = current source code / runtime evidence / current config / DB schema / log
 > repository-specific CONFIRMED memory
 > shared CONFIRMED memory
 > global CONFIRMED memory
 > inferred memory
 > unknown
```

### Evidence Hierarchy (what a Fact's `Evidence:` field should cite)

```
1. Current repository code / config / registration (the class, method,
   middleware, filter, route, DI registration - the thing itself)
2. DB object definition / schema, read live (OBJECT_DEFINITION, table, SP)
3. A confirmed cross-repo relationship, citing BOTH sides (calling code and
   receiving endpoint)
4. Repo-specific CONFIRMED memory that already carries code-level evidence
5. Historical analysis docs (`docs/*.md` from a past session) - optional,
   supporting only
```

`current code > memory > historical docs`, always. A historical doc is a
point-in-time snapshot, not a runtime dependency: memory must stay usable when no
such document exists. Prefer levels 1-4 whenever the same fact can be cited that
way; when a doc reference is kept, mark it optional and historical:

```
Source Note: originally derived from docs/<name>.md; this document may not be
distributed with the Skill and is not required to use this entry.
```

If a referenced document is missing from this installation: do not error, do not
guess what it said, keep using the entry's own `Fact` / `Evidence` plus current
code, and note the absence in `Notes`. Escalate to `UNKNOWN` only if the missing
information is actually required for the current ticket and no other source
supplies it. If a doc and current code disagree, **current code wins**.

### Local companion knowledge repository

Some organizations keep a local, versioned knowledge repository alongside the code -
original artifacts, past experiments, terminology, product documents, runbooks. When
`workspace/PROFILE.md` declares one, it is useful at the **navigation** stage, but it
is not a sixth trust level and not a replacement for current evidence.

| Companion material | Initial use in this skill |
|---|---|
| original artifact / raw dump | Candidate source; confirm provenance, path, date and relevance before relying on it |
| summary of a source | Supporting evidence; follow its cited artifact where material to the ticket |
| synthesis / concept page | `INFERRED` until confirmed in the active carrier or an authoritative source |
| index / overview | Navigation only |
| change or operation log | Historical evidence; normally `OUTDATED` context until current state is confirmed |

Only current code/config/schema/runtime evidence, or an authoritative document whose
current applicability has been checked, may promote such a claim to `CONFIRMED`. The
workspace's own bridge procedure, if it declares one, holds the routing and delta
steps.

---

## 4. Memory Never Blocks Re-Verification

If current code disagrees with memory:

```
trust current evidence
  -> investigate the difference only if it is relevant to this issue
    -> update memory locally (targeted edit)
```

Memory: `CONFIRMED - ServiceA writes talent data to PrimaryDb.`
Current code: `FooRepository` writes ShardedDb directly. Correct update:

```
General Flow:  PrimaryDb -> Sync -> ShardedDb
Exception:     FooRepository writes ShardedDb directly.
```

Wrong update: ignoring `FooRepository` because it does not match the memory.

---

## 5. Trust Levels

| Status | Meaning |
|---|---|
| `CONFIRMED` | Direct evidence: source, config, DB schema, runtime result, log, DBA / developer confirmation |
| `INFERRED` | Reasonable inference without sufficient direct evidence |
| `UNKNOWN` | Currently not known |
| `OUTDATED` | Was true once; current code / config has changed. Do not use directly |
| `CONFLICTING` | Different repositories / sources give contradictory evidence. Keep both, pick neither |

Only these five are ever written to a `Status:` field. "grep found nothing" is an
observation, not a trust level - write `NOT FOUND (this search scope)` in
`Notes` / `Evidence`, and never let it silently upgrade into one of the five.

### Common misuses to avoid

- **`NOT FOUND` -> "definitely does not exist".** A search is scoped by what was
  searched. See also SKILL.md -> Evidence & Scope Invariants (negative evidence)
  and Gate 3.
- **`UNKNOWN` -> filled in with a guess.** `UNKNOWN` stays `UNKNOWN` until
  evidence resolves it.
- **One repository's behaviour -> generalised to "the company".** "5 scanned
  repos have no RBAC" is not "the company has no permission system anywhere."
- **A test / stg observation -> written as a permanent architecture fact.** Keep
  the environment qualifier in `Evidence`; do not drop it when the fact is reused.

---

## 6. Memory Entry Format

```
## [Topic]

Fact:
Status:          CONFIRMED / INFERRED / UNKNOWN / OUTDATED / CONFLICTING
Scope:           GLOBAL / SHARED / REPOSITORY
Repository:
Evidence:        - path:line / schema / log / runtime observation
Related Files:
Related Domain:
First Observed:  YYYY-MM-DD
Last Verified:   YYYY-MM-DD
Notes:
Exceptions:
```

---

## 7. Repository Scope Rule

A fact discovered while scanning one repository belongs **only** to that
repository by default. Finding `GetShardConnection(userId)` in `ServiceA` does
not mean `ServiceB` uses it.

```
Repository-specific facts MUST remain repository-scoped
unless evidence proves the behaviour is shared.
```

Forbidden cross-repository inference: repo A has a pattern -> assume repo B has
it; repo A uses Redis -> assume repo B does; repo A writes ShardedDb directly ->
assume every system does. Promotion criteria: `memory-operations.md` §8.

Never store credentials, hosts or connection-string values in memory. Key
**names** are fine.
