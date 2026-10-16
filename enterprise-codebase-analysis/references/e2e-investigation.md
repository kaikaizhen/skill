# E2E Anomaly -> Root-Cause Investigation

Loaded when an **end-to-end (E2E) run** - a real user-level pass through the running
system - shows something a user could notice, or when the user asks for a deep root
cause analysis. It is a **depth escalation on Mode A's bug path**
(`workflow.md` §12-13), not a separate workflow: the same gates, approval and safety
rules apply, and implementing any fix still needs Approval Gate #1.

**A green signal is not a pass.** HTTP 200, a success screen, a finished test step
and "no error in the console" prove only that nothing threw. The verdict comes from
the **business result and the data** the operation was supposed to produce.

## 0. Depth by scenario (what triggers what)

| Scenario | Do |
|---|---|
| **A** - E2E all pass, business result and data verified | the normal test report (`verification.md`). No investigation report |
| **B** - something looks wrong but is not established | collect evidence, re-run, localise. Still unestablished -> report as **疑似問題 (suspected)**, naming exactly which evidence is missing. Never write an assumption as a confirmed root cause |
| **C** - a user-visible defect is established | full Phases 1-8 + the report (`templates/e2e-bug-report.md`) |
| **D** - data inconsistency, duplicate / lost / overwritten rows, cross-system side effect, or concurrency | scenario C **plus** mandatory Phase 2 and Phase 5 depth: every write in order, every constraint, the exact interruption point |
| **E** - the user asks for a deep root cause analysis (no E2E behind it) | the same Phases 1-8, scoped to what they reported |

A simpler defect may use fewer report sections (`templates/e2e-bug-report.md` is
twelve sections at full depth), but **root cause, evidence, impact, fix and
acceptance are never dropped**.

## Phase 1 - Record the anomaly as a user sees it

Before any code is opened:

```
Feature / action        what the user was doing, in their words
Expected               what should have happened (business result, not HTTP)
Observed               what actually happened
Reproduction            numbered steps anyone can follow
Special conditions      double-click, concurrency, specific data, time boundary,
                        retry, slow network - or NONE OBSERVED
Blast radius            which users / rows / downstream systems
User-noticeable?        yes / no - and if no, how it would ever surface
Context                 environment, build or commit, timestamp, request id,
                        test account identifier (masked)
```

Classify the shape - they investigate differently:

| Shape | What it usually means |
|---|---|
| the screen shows an error | the failure is on the visible path |
| the screen shows success, the data is wrong | the write path diverged from the read path |
| some data written, some not | an interrupted multi-step write (Phase 5) |
| no error, but a row is duplicated, overwritten or missing | identity / selection / uniqueness defect (Phase 2) |
| only under timing - repeat submit, concurrency, same-minute | a race or a precision collision (Phase 4) |

## Phase 2 - Establish what the database actually did

Read-only, under `database-safety.md`. Investigate, for the tables this feature
touches: which database / shard / server; what rows were added, changed or removed
around the action; primary key, foreign keys, unique and ordinary indexes, check
constraints; column type, length, precision, nullability and default; triggers,
stored procedures, functions and jobs that touch them; whether the code's own
WHERE / ORDER BY can select the wrong row; and whether duplicates, orphans, partial
writes or cross-database divergence already exist.

Pay specific attention to the defects that hide here:

- **Non-deterministic ordering** - `ORDER BY` on a non-unique column (or none at
  all) makes "the latest row" arbitrary.
- **Time precision** - a column that stores to the second or minute cannot
  distinguish two rows created inside the same tick, so a lookup keyed on it
  collides.
- **A lookup that can match more than one row** - and what the code does then
  (first? last? throws?).
- **Write identity** - does each `INSERT` / `UPDATE` / `DELETE` identify its target
  by a key that is actually unique?
- **Whether a unique constraint really prevents the bad state**, or merely turns it
  into an exception after other rows are already committed.
- **Transaction scope** - is there one, does it span every write that must be
  atomic, and is there rollback or compensation when a later step fails?

Three rules, non-negotiable:

1. **Separate "proven by the schema / data" from "inferred from code."** Label each
   statement `CONFIRMED` (with the query or definition you read) or `INFERRED`.
2. **No access?** Write the read-only SQL a DBA can run, say which database it must
   run against and what each result would mean - and leave the item `❓ 待確認`.
   Never present an unrun query's expected output as a finding.
3. **Verifying one shard proves one shard.** Never generalise a schema, an index or
   a data state to the other shards or servers without reading each one.

## Phase 3 - Trace the whole execution path

From the user's entry point down to the I/O, and back. Follow the layers this
repository actually has - typically frontend -> API / controller -> service /
business logic -> repository / DAO -> SQL / database -> response -> frontend - and
do not stop at the line that threw.

For each significant step state: the file, class and method; who calls it and when;
the parameters and **where each value came from**; how it chooses the rows it reads
or writes; whether it generates a new identifier; which tables it touches; what a
success changes; what a failure does; and what else depends on it.

Then follow the **indirect** effects, but only those with real evidence: logs,
cache, message queue, background job, points / bonus, notification, external
service, and chained stored procedures. Show how data moves between modules - a
list of method names is not a trace. **A method name, a comment or a stored
procedure's name is never evidence of behaviour; read the body.**

## Phase 4 - Reconstruct how the wrong state forms

The core of the investigation. Chain the evidence into causation:

```
user action -> code executed -> data changed -> wrong state formed -> what the user gets
```

Walk it with **two concrete cases** (call them A and B) carrying real-looking values
and timestamps, step by step: what request A inserted, what request B inserted, why
both can satisfy the same lookup condition, whether B's child rows can therefore
attach to A's parent, which tables accept the duplicate, which reject it on a unique
constraint, what stays committed when the exception fires, and why the user sees
success, an error, or nothing at all.

"Probably a race condition" and "no transaction" are **not** findings. Name where
the race is, what state is shared or mistakenly reused, and how that produces this
exact result. **Deriving is not proving**: anything not reproduced or not backed by
evidence is labelled a `❓ 待驗證假設` with the test or query that would settle it.

## Phase 5 - Write-by-write result and interruption point

When the feature writes to several tables or systems in sequence, list the whole
sequence - never only the step that threw:

| # | 程式位置 | 資料表／外部系統 | 操作 | 正常結果 | 異常結果 | 中斷條件 |
|---|---|---|---|---|---|---|

Answer explicitly: which steps committed · which wrote duplicate or wrong data ·
where it first went wrong · which step aborted the flow · what never ran · what is
left half-written · what reached another database or external system. Where the data
shape changes the outcome (with an attachment vs without, first row vs later rows),
analyse each branch separately.

## Phase 6 - Root cause vs the things around it

Keep four categories apart; they are not equally to blame and they get different
fixes:

```
A 直接根因        the logic that actually produces the wrong data or behaviour
B 觸發條件        what has to be true - same name, same minute, repeat submit,
                  concurrent requests
C 擴大因素        what turns a small error into a bigger one - no transaction, no
                  unique constraint, no compensation after an exception
D 防護缺口        what should have stopped it and did not - no resubmit guard, no
                  idempotency key, no integrity validation
```

A missing frontend guard is a `D`, never the root cause of a server-side
concurrency defect: removing a button does not close the route behind it
(HARD RULE 14).

## Phase 7 - Fixes, in priority order

| | Scope |
|---|---|
| **P0** | eliminate the direct root cause - name the file and method |
| **P1** | data integrity - transaction, rollback, idempotency, unique constraint, concurrency control, compensation |
| **P2** | user-level protection - resubmit guard, loading state, actionable error, retry |
| **P3** | separate defects found on the way, unrelated to the main one |

Each one states: purpose · where to change · the problem before · the expected
behaviour after · which existing features it could affect · deployment and
compatibility risk · how to prove it worked. Prefer the **smallest verifiable**
root-cause fix; do not restructure an architecture to close one bug
(`development-convention.md` §3b). Where a fix spans databases or servers, read the
actual transaction capability and configuration before claiming a distributed
transaction is possible or impossible.

## Phase 8 - Regression suite for what was found

Every confirmed defect gets executable acceptance cases covering: the original
reproduction · normal operation · repeated operation · concurrent operation ·
special data and boundaries · failure midway · rollback or compensation · the
neighbouring features that share the path.

Each case states preconditions, steps, test data, expected screen / API result,
**expected database state**, actual result and status. Give read-only verification
SQL where it is safe to do so. **Checking the screen is not enough - the final data
state must be correct.**

## Safety limits (investigation, not repair)

- Test environment, test accounts and test data first. Production is **read-only
  and only when authorised**; never create dirty data in production to reproduce
  something.
- No `INSERT` / `UPDATE` / `DELETE` / `TRUNCATE` / `DROP` / `ALTER` and no data
  clean-up without explicit approval (HARD RULE 2, `database-safety.md`). No change
  to production code, schema or deployment configuration.
- Fault injection, concurrency stress and data-destruction tests only in an
  environment the user has said may be used that way.
- Mask personal data, cookies, tokens and connection secrets in the report; record
  a key's **name**, never its value (HARD RULE 3).
- Never carry one project's database names, table names, topology or implementation
  detail into another repository's investigation.
- Not enough access or no way to verify? List the missing evidence and how to obtain
  it. Never widen your own permissions, and never fabricate a test result, a schema,
  a line number or a user case.
