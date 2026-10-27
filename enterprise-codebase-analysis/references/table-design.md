# Table Design Standard (SQL Server)

This file defines **how a table should be designed**. The review procedure, document
format and problem-list rules belong to `table-review.md`; the trigger conditions are
shared and live there (§0). Nothing here is repeated by that file.

**Top rule: never emit `CREATE TABLE` / `ALTER TABLE` straight from the column list a
requirement document happens to contain.** The ticket is the level-1 requirement
authority (HARD RULE 12), but it guarantees nothing about types, uniqueness, indexes
or compatibility. Every question below has an answer, or an explicit `❓ 待確認`,
*before* the DDL is written. The review still **always ships runnable DDL** - that is
how a manager and a developer read the result (`table-review.md` §4 -> 五、DDL); the
rule is that the checks come first, not that the statement is withheld.

Depth is proportional to blast radius (`code-quality-gates.md` §0.1): one new
standalone table does not need a full dependency sweep; touching an existing table's
columns, types, constraints or relations runs §6-§8 in full.

Database access follows `database-safety.md`: **read-only by default, every DDL / DML
needs explicit approval.** This standard produces a design and a review - it never
executes `CREATE`, `ALTER` or a data conversion itself.

## 1. Business rules and uniqueness

- What is this table for? **What business fact does one row represent**, and what is
  its life cycle (created when, invalidated when, is history kept)?
- What are the real use cases for insert, read, update and delete, and who triggers
  each one?
- **Separate the technical primary key from the business unique key.** A surrogate
  running number (`sNo`-style identity) only guarantees that *rows* are distinct; it
  says nothing about whether the same *business fact* can be stored twice. **The
  presence of an identity PK is never a reason to skip a uniqueness constraint.**
- May the same business fact appear twice? If not, which column combination defines
  "the same"?
- The behaviour of INSERT, UPDATE and UPSERT, and the overwrite rule (does a later
  write replace an earlier one, and silently?).
- If the same data can arise from different pages, recommendation blocks or business
  contexts, decide whether those **share one row** or get one row each - this changes
  the unique key.
- When the unique key is a business decision, **do not assume**: give the candidate
  combinations, their differences and consequences, and put it in the review's open
  decisions (`table-review.md` §6).

## 2. Consistency with the existing system

Search before designing (this is Gate 3's reuse judgement, `capability-reuse.md`):

| What to find | Why |
|---|---|
| existing similar tables and their columns | the source of naming, type and date conventions |
| existing enums, constants and code tables | so one meaning does not get a second encoding |
| how the same business data is stored elsewhere | one fact should not have two truths |
| the Controller / Service / Repository·DAO involved | who writes, who reads |
| ORM entity, DbContext, mapping (including Database-First generated code) | a column change lands directly in queries |
| related stored procedures, functions, views, triggers | the database's own hidden dependencies |
| existing API request / response fields and types | whether the external contract must change too |

Rules:

- **Prefer an existing, stable business code**; never add a second encoding when an
  enum already exists without a stated reason.
- When adopting an existing enum, confirm **all of its real values** - including
  default, unknown, zero and any special state. The handful of values the ticket
  mentions is not the domain.
- **Never use a UI sort index, an array position or a display name that can change as
  a durable identifier.**
- Follow existing designs, but **do not assume an existing design is correct**. Where
  it conflicts with the new requirement, state the conflict and the concrete
  adjustment - do not silently copy it, and do not silently deviate.

## 3. Column design

Check every column:

- Does the name follow the existing convention (evidence from sibling tables, not
  from framework defaults)?
- Does the type match the real business need: `INT` / `BIGINT` / `TINYINT` / `BIT`
  value range and room to grow; `DECIMAL` precision and scale for money or ratios -
  never a floating type for money.
- `VARCHAR` vs `NVARCHAR`: is Chinese, multi-language or special-character content
  possible? If anything non-ASCII can be stored, it needs the `N` type.
- **Is the string length consistent with the API and the frontend validation?** If
  not, say which side is authoritative.
- Is NULL allowed? **Do NULL, `0` and the empty string carry different business
  meanings?** If they do, the type and constraints must be able to express that; if
  they do not, do not allow three different kinds of "empty".
- Is a DEFAULT needed, and **which layer produces it** - the database or the
  application? Both producing it means they will overwrite each other.
- Date columns: when they are set on create and on update, **where the time comes
  from** (database clock / application clock / user time zone), and whether the
  precision can distinguish two rows created in the same second or minute.
- Are `CHECK`, `UNIQUE` or `FOREIGN KEY` constraints needed?
- Does it involve converting existing data or staying compatible with historical rows
  (the data-population comparison in `code-quality-gates.md` §2)?

**A bitmask column** also needs: the value and business meaning of every bit · whether
multiple selection is allowed · what NULL and `0` actually mean · which combinations
are legal · whether frontend, backend and database use the same definition · and
**whether a bitmask, an enum or a child detail table fits better** (multi-select that
will keep growing is usually a detail table). Present bits in the format of
`encoded-values.md` §5 (decimal, binary, bit position, the operation in words).

**A type named in the requirement document is not automatically a sound design.** If
it is wrong, propose the alternative type and the reason.

## 4. Keys, indexes and performance

- Confirm the primary key, and **separately** the business unique key (§1).
- Design indexes from the **actual** `WHERE` / `JOIN` / `ORDER BY` / `UPDATE`
  predicates - read them out of the code, do not imagine them.
- Decide clustered vs nonclustered deliberately: **never sustain a nonclustered PK
  just because a sibling table has one.** Say what this table's clustered key should
  be (usually what is range-scanned or ordered most).
- For a composite index, is the **column order** right for the query's leftmost
  prefix?
- Batch reads: fetch many rows in one query instead of per row (N+1,
  `code-review-checks.md` §3).
- Weigh data volume, query frequency, write cost and index maintenance cost - more
  indexes is not better.
- **UPSERT** needs concurrency, race conditions, unique-key violations and transaction
  handling considered: two requests can both conclude "it does not exist" and each
  insert, and the unique index is the last line of defence
  (`code-review-checks.md` §4).
- When recommending an index, **name the columns, their order, whether it is unique,
  clustered or not, and the query it serves**. "Optimise the index" is not a
  recommendation (`table-review.md` §5).

## 5. Data integrity and security

- The **trustworthy source** of identifiers such as member id or company id: the
  verified credential, never a request parameter (P1, HARD RULE 14, and the IDOR item
  in `code-review-checks.md` §2).
- Whether personal data, sensitive data or free user input is involved, and whether
  masking or tiered access is needed.
- Authentication and preventing cross-account modification: is ownership checked
  before the write?
- **SQL is always parameterised** (`code-review-checks.md` §2).
- Whether a transaction is needed, and which writes it must span to be consistent.
- The rule for delete, deactivate, and for a missing related row (hard delete vs soft
  delete vs reject).
- Whether logs or analytics could capture data that should not be collected - a new
  column serialised into a log line is the usual way this happens.
- **Whether the database constraints and the application validation agree**; when they
  differ, say which is authoritative (`code-quality-gates.md` §4).

## 6. Dependency analysis for a change to an existing table (mandatory)

Changing an existing table is **never just checking that the `ALTER TABLE` parses**.
Trace the real path:

```
Controller -> Service -> Repository / DAO -> SQL / stored procedure
```

and check: ORM entity / DbContext / mapping · Database-First generated code ·
ADO.NET / Dapper / dynamic SQL · stored procedures, functions, views, triggers ·
**the source table, backup tables, history tables and deletion-record tables** ·
other projects, API consumers and cross-database dependencies · replication,
`rowguid` and other infrastructure-maintained columns.

Tell these cases apart - they are all "related" but their impact differs:

| Case | Impact |
|---|---|
| the model declares the column, the SQL never uses it | a declaration remnant; dropping the column still needs the declaration cleaned up |
| the query projects only some columns | a change to an unprojected column does not affect it |
| the ORM materialises the whole entity | **every mapped column is used** - the column disappearing breaks the query |
| INSERT relies on NOT NULL or a DEFAULT | a new NOT NULL column without a DEFAULT breaks existing inserts |
| UPDATE / DELETE / JOIN references the column | the predicate column disappearing kills the statement |
| another database object depends on it | an SP / view / trigger is not safe just because no application code uses the column |

**Never conclude that a table change affects nothing merely because a search did not
find the column name** (negative evidence: short of the threshold it is
`NOT OBSERVED IN TRACED PATH`, not `CONFIRMED MISSING`). Keep schema-proven facts
apart from code inference, and remember that **verifying one shard proves one shard**
(`e2e-investigation.md` Phase 2). Without database access, write the read-only SQL a
DBA can run and keep the item `❓` - an unrun query's expected output is never a
finding.

## 7. Before / After behaviour and side effects

When dropping a column, changing a type, removing a constraint or changing a relation,
trace the full behaviour on both sides. The seven contract dimensions belong to Gate 5
(`regression-validator.md`); what this section adds is the **functional** Before/After.

**Before**: how the feature works today · which component produces, stores and reads
the data · whether the column is used for lookup, relation, validation, authorization
or backup · what the existing API / SP / other consumers return · whether the current
flow already has known problems.

**After**: who produces, stores and reads the data now · whether a new column or new
logic takes over the old purpose · whether the original feature still exists · which
features are **intended** to be removed · whether any feature is lost
**unintentionally** · whether new bugs, exceptions or inconsistencies appear · the
effect on other APIs, SPs, triggers, tables and consumers · whether old and new code
and schema are compatible during deployment (§8).

**Pre-existing problems.** While tracing, you may find problems that were there
already - SQL injection, a missing required transaction, incomplete backup, duplicate
queries or N+1, incomplete error handling, weak authorization checks, existing logic
that can corrupt data. Include them in the review **by their real impact** - but
**never give them their own category or section**: they use the same three severities,
with "此問題在修改前即存在" stated in the cause/impact column (`table-review.md` §5).
If one is worth fixing here, give the concrete change plus the extra regression scope.
If it is high risk but does not belong to this requirement, recommend a separate
ticket and say why - **never widen the change on your own** (HARD RULE 12).

**Lost functionality.** When dropping a column stops an existing feature from working,
do all six: ① confirm whether the requirement intends that feature to be removed →
② if not, trace the feature's full purpose → ③ identify the actual code or SQL that
breaks (`path:line`) → ④ state the replacement column, query or application logic →
⑤ analyse whether the replacement changes data meaning, permissions or business logic
→ ⑥ give a concrete way to verify the feature is restored with no new side effects.
**Deleting the old logic is not "the feature has been adjusted".**

## 8. Deployment compatibility (changes to an existing table)

Assess all four combinations; never assume that "code first" or "database first" is
inherently safe:

| | Old database | New database |
|---|---|---|
| **Old code** | the current baseline | old code + new schema: does an old SP or old entity still reference the dropped column? |
| **New code** | new code + old schema: can the new entity run against the old DB; does anything fail while the new column does not exist yet? | the target state |

Watch specifically for: code and database shipping in separate releases · some tables
migrated while others still hold the old schema · **whether a NOT NULL column has a
DEFAULT** · source and backup tables having different constraints · old stored
procedures referencing a removed column · locking, transaction-log growth and
conversion time on a large data change · whether a **compatible version must ship
first and the column be dropped in a later phase** (usually: stop the code depending
on it -> update SPs and views -> drop the column last).

State the conclusion as a recommended deployment order plus the list of objects that
must ship together, and carry it into the review's recommendations or open decisions.
