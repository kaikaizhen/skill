# Gate 5 - Regression / Contract Preservation Validator

The only gate that runs **twice**: once on the plan, once on the real diff. It
turns `engineering-principles.md` into a checkable output with a stop condition.

It answers one question: *what did the authoritative baseline do that the final
change no longer does, or now does differently?*

---

## Trigger

Runs whenever the change touches an **existing** flow, endpoint, service, filter,
config, schema or shared component - modified, replaced, re-routed, re-pointed at
a different backend, or refactored.

Purely additive work (a new endpoint with no existing caller and no shared code
touched) runs the short form: rows 1, 2 and 4-6 for the *new* path only, which is
a few lines.

Not triggered by: Mode B, Mode C, or a change with no diff.

---

## The authoritative baseline (non-negotiable)

```
baseline  =  the state of main / the authoritative branch when this ticket started
final     =  the final working tree of this ticket
compare      baseline  ->  final          (the whole ticket, in one diff)
```

- **Never** compare only against the previous commit on the feature branch. An
  adjacent-commit diff shows one step; it cannot show what the ticket as a whole
  removed. Adjacent diffs are a debugging aid inside a step, never the Gate 5
  comparison.
- A ticket whose branch already carried earlier work (a reopened ticket, a
  withdrawn attempt, a cherry-pick, a merge from another environment branch) is
  exactly the case where the branch tip lies and the baseline does not.

Establishing the baseline ref:

```
1. git merge-base <authoritative branch> HEAD          # the usual answer
2. If the branch history is suspect, walk the FILE's own history instead:
   git log --oneline -- <path>   ->  first commit where the change's marker
   appears  ->  use THAT commit's parent
3. Confirm it is clean: git show <ref>:<path> (or git grep at <ref>) for the
   change's marker must come back empty. If it does not, keep walking back.
```

Use `git diff <baseline>...HEAD` plus the unstaged working tree, never
`git diff HEAD~1`. If the repository has no usable baseline ref (new file, no
history), say so - `BASELINE: N/A (new code)` - and run the short form.

---

## Side-effect Discovery (before the table)

Dimension 5 cannot be filled from the diff alone, so it gets its own sweep. Walk
the changed operation's **success paths and failure paths**, on the baseline and
on the final version, and list every effect beyond the primary record write:

```
notification / mail / SMS / push      audit, history and domain-event records
downstream service or API calls       cache invalidation, index or search updates
queue / bus messages                  counters, quotas, flags on other tables
scheduled or deferred work            anything a service, DAO, trigger, handler
                                      or domain hook fires downstream (indirect)
```

- Indirect effects count. Trace one level into the services the changed code
  calls; stop when the next level cannot fire an effect this ticket can change.
- An effect that no success path still reaches is **lost**, even if its code
  remains. An effect reachable from a new path is **added**.
- Scope stays proportional: only the operations in this ticket's diff, plus the
  other callers of anything shared that the diff touched (P3).

## Required output - the Contract Parity Table

One row per P2 dimension. `unchanged` is a complete answer for a dimension the
change does not touch.

```
## Contract Parity  (Gate 5, run <1 pre-impl | 2 post-impl>)
Baseline: <ref> (<how it was chosen>)   Compared: <what was diffed>
```

| # | Dimension | Baseline behaviour (`path:line`) | Final behaviour | Delta | Intended? | Risk |
|---|---|---|---|---|---|---|
| 1 | Security / auth / CSRF | | | | ticket AC #n / NO | |
| 2 | Server-side validation | | | | | |
| 3 | Data integrity | | | | | |
| 4 | Transaction / ACID | | | | | |
| 5 | Side effects (success + failure) | | | | | |
| 6 | Logging / audit / trace | | | | | |
| 7 | Caller compatibility / blast radius | | | | | |

Plus, when P4 applies:

```
Duplicate submission guard: <authoritative guard, path:line>  | NONE - <window>
Concurrency guard:          <guard>                            | NONE - <race>
Transaction boundary:       <what is inside>                   | NONE - N writes
```

Plus, whenever Side-effect Discovery found anything, row 5 expands into one row
per effect, on its six identity attributes (`engineering-principles.md` -> P2):

| Side effect | Trigger (success/failure branches) | Count | Order | Sync / async | Failure semantics | Reliability | Intended? | Risk |
|---|---|---|---|---|---|---|---|---|
| <effect> | baseline -> final | | | | | | AC #n / NO | |

**Same method call is not the same contract.** Never write `unchanged` because
the callee is the same symbol: compare all six attributes. A wrapper, a helper, a
`catch`, a queue or a background task changes several of them at once while the
method name in the diff stays identical.

**"Intended?"** is answered from the ticket / authoritative requirement, never
from convenience. Each delta lands in exactly one of three classes:

```
REQUIRED BEHAVIOUR    the baseline behaviour the system still depends on, or a
                      confirmed engineering invariant (see below) -> must hold
TICKET CHANGE         the ticket / AC explicitly asks for this difference -> keep
                      it, cite the AC, and test it
NEEDS DECISION        a difference nobody asked for -> a regression until the
                      requirement owner removes it or accepts it in writing
```

- Legacy behaviour is **not** preserved for its own sake. "The old version did X"
  is not by itself a reason to require X of the new one (HARD RULE 12).
- **A confirmed engineering invariant is not negotiable that way.** Once the
  repository, a team standard or the requirement owner has established a rule -
  an audit record for every change to this data, server-side enforcement of a
  mutation, a notification the business relies on - it is `REQUIRED BEHAVIOUR`,
  and dropping it silently is a regression regardless of what the ticket says
  about it.
- An unrequested change to *how reliably* a required effect happens is itself
  `NEEDS DECISION`, even when the effect is still nominally present.

---

## The five checks that a passing build never catches

Run these on every expanded row-5 effect - each leaves the feature working and the
tests green:

```
1  Sync -> background       an inline effect moved onto a task, thread, queue or
                            fire-and-forget helper no longer shares the request's
                            context, transaction or lifetime, and can be lost on
                            process recycle. Confirm the platform's durability,
                            not the wrapper's intent.
2  Swallowed exception,     the effect throws, it is caught and logged, and the
   success still returned   operation still reports success. The baseline failed
                            loudly; the new version fails silently. This is a
                            change of failure semantics, not "defensive coding".
3  Lost or duplicated       an effect no success path reaches any more, or one
                            reachable twice (two call sites, a retry, a shared
                            method invoked at two layers).
4  Logging / audit          a record downgraded in level, detail, correlation id
   downgraded               or destination, or moved where its consumers do not
                            read. Losing request/trace correlation counts.
5  Other callers of shared  the effect was added, removed or re-wrapped inside
   code affected            shared code, so every other caller changed too (P3),
                            including sites the diff left inline - now differing
                            from the ones it touched.
```

An **encoded value** (DB status code, bit flag/mask, protocol code) is itself contract -
assessed on rows 3 and 7, never separately. Naming it is safe; changing it is a behaviour change with its own row and grade (`encoded-values.md` §9).

## Risk levels

```
HIGH    Security / auth / CSRF / ownership weakened or removed;
        server-side enforcement lost or never existed on a mutation path;
        data integrity, transaction atomicity or an audit/history record lost;
        a REQUIRED BEHAVIOUR side effect lost, duplicated, or made best-effort
        where it was guaranteed; failure semantics changed so a failed effect
        reports success; a shared contract tightened with UNKNOWN callers; an
        unguarded duplicate-submission or race window on a mutation.

MEDIUM  Observability reduced but not lost; a non-critical side effect changed;
        ordering changed with an unconfirmed consumer; a caller set enumerated
        but not all verified; a guard weaker than the baseline's; a recoverable
        partial-failure state.

LOW     Cosmetic, message text, ordering with no observable consumer, a
        defensive improvement, or a delta the ticket explicitly required.
```

A `NEEDS DECISION` delta on a required side effect, or any change to failure
semantics, **cannot be reported as "no regression" while unresolved** - it is an
open item with its risk level, not summarised away.

---

## Run 1 - Pre-Implementation (before Approval Gate #1)

Filled from the **planned** change against the baseline, from reading code. It is
a prediction, and it is what makes the plan reviewable:

- Every `NO` in "Intended?" is resolved in the plan, or carried to Approval Gate
  #1 as an explicit decision for the user - never left implied.
- A HIGH row with no plan item is a plan defect, not a follow-up.
- A row that cannot be filled because the baseline behaviour is not confirmed is
  `UNKNOWN` with what would settle it - not an assumption of parity.

---

## Run 2 - Post-Implementation (before Approval Gate #2)

Re-run against the **actual** `baseline -> final` diff, not against run 1. Run 1
was a prediction; the diff is the fact. Rows that the diff contradicts are
corrected, and rows the diff added (something touched that was not planned) are
added. The five checks above are re-applied here - a green build and a green test
run are evidence about the primary write, not about the side effects.

**Release rule:**

```
Any HIGH row on security, server-side enforcement, data integrity, transaction
atomicity, audit loss, a lost/duplicated required side effect, or a changed
failure semantic, that is unresolved and not explicitly accepted by the user
  ->  DO NOT proceed to Approval Gate #2 as complete.
Report it as  REGRESSION RISK - HIGH - UNRESOLVED  and stop for a decision.
```

MEDIUM and LOW rows are reported with the change and do not block. Every row's
delta feeds the regression section of the test plan and of
`<Ticket>驗收標準.md`.

---

## Relationship to the other gates

```
Gate 1  what the ticket requires           -> decides "Intended?" in this table
Gate 2  which carrier is actually active   -> decides whose baseline is compared
Gate 3  does a capability exist at all     -> supplies rows 2 and 5
Gate 4  one version of the truth           -> runs after run 1, before Approval #1
Gate 5  what the change silently removed   -> runs 1 and 2, this file
P2      the seven dimensions and the six side-effect attributes
P3      who else runs the shared code an effect was added to or wrapped inside
```

Gate 5 never authorises a wider scan "for completeness". It is scoped to what the
diff touches, plus the callers of what the diff touches.
