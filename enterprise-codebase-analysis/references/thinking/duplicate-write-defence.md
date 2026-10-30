# Duplicate & Concurrent Write Defence

Loaded when a change must stop **the same request being processed twice** - a
double-click, a retry, a resend, a refresh, two tabs, a client-side retry on timeout -
or when a duplicate / half-written row has already been observed in production.

This is the implementation pattern for **P4 State Safety**
(`engineering-principles.md`); P4 says the guard must be named, this file says what a
sound guard looks like. It is also the concrete form of the two hardest preconditions
in `data-strategy.md` §2 - the transaction (#5) and the concurrent-overwrite window
(#6) - which is where a "delete the whole set, then insert it again" flow breaks.

## 1. Why one guard is never enough

The classic failure, and the reason a single layer does not hold:

```
flow      delete every existing row for this parent, then insert the new set
request A   DELETE ......................... INSERT A1 A2
request B            DELETE ...... INSERT B1 B2
result    B's DELETE removed part of A's work; both sets of INSERTs survive
          -> duplicated rows, and neither request reports an error
```

Each layer catches exactly what the one before it misses:

| Layer | Catches | How |
|---|---|---|
| ① a short-lived lock per subject | two requests arriving at the same time | only one request per subject is admitted at a time |
| ② an idempotent write | the same row written twice when the lock did not hold | re-running produces the same result - `INSERT ... WHERE NOT EXISTS`, a unique constraint, a conditional update, an upsert on a real key |
| ③ a transaction around delete + insert | a failure between the two leaving half the data | all-or-nothing on one connection; roll back and log on error |

**Report all three, and state which ones this change actually implements.** A guard
at only one layer is recorded with the window it leaves open.

## 2. The lock layer

- **Scope the key to the subject, not the endpoint**: the identity whose data is
  being written (member + record, order, document), so two different members are
  never blocked by each other.
- **Normalise every part of the key.** A key built from a value that can be `null`
  or absent - a brand-new record with no id yet - produces a *different key per
  request*, so the lock never collides and the guard silently never fires. Map the
  empty case to one fixed value and say so.
- **Give it a short expiry** so a crashed request cannot block the subject forever,
  and **release it in a `finally`** so a thrown exception still frees it.
- **Decide fail-open vs fail-closed explicitly.** Letting the request through when
  the lock store is unavailable (fail-open) is only acceptable **because layers ②
  and ③ exist**; without them, fail-open means no guard at all. State the choice,
  the reason, and log the event so the fallback is visible.
- The rejection must be an honest, actionable response ("already being processed,
  please retry"), not a silent success and not a 500.

## 3. The idempotency layer

- Prefer a **database constraint** - it is the only guard that holds no matter which
  process, service or script writes. Recommend it by name
  (`table-design.md` §1, §4).
- **No unique constraint available?** Then the second line of defence moves into
  application code - for example "read the current set, treat a row whose defining
  fields all match as the same row, skip the insert". This is legitimate, but it is
  a **weaker guarantee**: it only protects callers that go through this code path,
  and it still races without layer ①. Say so, and raise the missing constraint as a
  follow-up item rather than treating the code check as equivalent.
- An equality rule used as a guard must **name its fields and its normalisation**:
  which columns define "the same row", and what is trimmed, case-folded or
  null-coalesced before comparing. An unstated normalisation is how two rows that
  look identical to a user are stored twice.
- Idempotency means **running it again changes nothing** - verify that claim against
  the actual statement, not against the intent.

## 4. The transaction layer

- Put the delete and the inserts of one logical set **in one transaction on one
  connection**, commit at the end, roll back and log on error.
- **One connection to one database keeps it a local transaction**; spanning two
  connections or two resource managers can escalate to a distributed transaction.
  Prefer one connection (`code-review-checks.md` §4).
- **Say explicitly which writes are inside the boundary and which are not.** Sibling
  tables reached through a different driver or connection cannot join a local
  transaction - that is a bounded, stated gap, not something to leave unsaid.
- External effects (mail, push, queue, HTTP) cannot be rolled back: place them after
  the commit or make them compensatable (P4).

## 5. Guard the real entry point, not the suspected one

The highest-value lesson of this pattern, and the one that costs a second fix:

- **Confirm from runtime evidence which endpoint was actually resubmitted** - the
  access log, the request log, a trace id - before deciding where the guard goes.
- A page may offer several save paths: a per-block partial save *and* a whole-record
  save. Guarding the block endpoints while the whole-record endpoint stays open
  leaves the defect live, and the symptom is unchanged, which reads as "the fix did
  not work".
- This is Gate 2's active-carrier question (`../requirement-evidence-gates.md`) applied
  to concurrency: **the carrier is decided by evidence of the real request, not by
  which handler looks related.**
- After identifying it, check every other write path to the same data for the same
  exposure, and list the ones you did not guard with the reason.

## 6. Verification

A duplicate-write fix is **not** verified by clicking twice slowly.

| Case | Expected |
|---|---|
| two genuinely simultaneous requests for the same subject | exactly one succeeds; the other is rejected with the actionable message; **no duplicate rows** |
| the same request replayed after the first completes | the data is unchanged (idempotency), not a second row |
| the lock store unavailable | the request still completes and layers ②③ prevent duplication; the fallback is logged |
| failure injected between delete and insert | the whole set rolls back; the data equals its pre-change state |
| each guard in isolation | unit tests covering the lock acquire/release and the dedup rule - a guard with no test is unverified |

Make the guard **observable**: tests need the lock primitives to be substitutable,
and attributing writes at the data store (a connection application name, a caller
tag) is what lets anyone answer "which process wrote this row" later.

Label every claim `EXECUTED AND PASSING` / `STATIC REVIEW ONLY` / `NOT VERIFIED`
(`code-quality-gates.md` §7).

## 7. What a code fix does not do

Keep three separate things separate, and say which are in scope:

```
the code fix        stops new duplicates from today
the constraint      the durable guarantee; usually a DBA task, usually not same-day
existing duplicates already in the table - a code fix never cleans them
```

Report the count of existing duplicates when it can be read, and treat the cleanup
as its own authorised work (HARD RULE 2 - any data repair needs explicit approval).
A business rule still undecided (a maximum row count, which row wins a merge) stays
an open decision; the agent does not choose it (HARD RULE 12).
