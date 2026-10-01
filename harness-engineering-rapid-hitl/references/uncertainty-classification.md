# Uncertainty Classification

Every unknown is assigned exactly one class:

```text
BLOCKING          -> a human must answer before implementation depends on it
SAFE_ASSUMPTION   -> decide it, record it explicitly, keep going
DEFER             -> irrelevant to this slice; record, do not ask, do not analyse
```

There is no fourth class. "I'll just try something and see" is not a
classification — it is an unrecorded guess, and it is exactly what this skill
exists to prevent.

## BLOCKING

An unknown is BLOCKING **by default** if a wrong guess would affect any of:

- user-visible behaviour
- a business rule
- ownership
- actor isolation (who can see or affect whose data)
- permission
- authentication semantics
- authorization semantics
- persistence
- data lifecycle
- destructive behaviour (delete, overwrite, irreversible transition)
- state transitions
- core API semantics
- required integration behaviour
- acceptance criteria

The AI may **not** resolve a BLOCKING unknown by itself — not by picking the
most common convention, not by copying a similar project, not because time is
short, and not because one option makes a test pass.

Default direction under doubt: **treat it as BLOCKING**. Asking one short
question is cheaper than building the wrong product behaviour.

## SAFE_ASSUMPTION

Permitted only when **all** of these are true:

1. It does not change core product behaviour.
2. It is easy to change if wrong.
3. It causes no irreversible data effect.
4. It does not touch permission, ownership, or a security boundary.
5. It does not affect the main acceptance criteria.
6. It does not give a critical test a different meaning.

Typical legitimate cases: non-core UI wording, button styling, a small internal
naming choice, an easily reversible implementation detail (which internal helper
to use, file layout within an existing convention).

Every safe assumption is **recorded explicitly** as `ASM-nnn` in the contract,
with why it is safe and its reversibility. An unrecorded assumption is a guess.

Failing even one condition ⇒ it is BLOCKING, not safe.

## DEFER

Defer when the unknown:

- does not affect the current slice, **and**
- does not affect a MUST behaviour, **and**
- does not affect critical verification.

Deferred unknowns are recorded under Deferred Questions. Do not ask the human,
and do not spend analysis time on them now. A deferred unknown is re-checked
when a later slice actually touches it.

## Worked triage examples

| Unknown | Class | Reason |
|---|---|---|
| Can a user see other users' records? | BLOCKING | Actor isolation |
| Does delete remove data or soft-delete? | BLOCKING | Destructive / data lifecycle |
| Must items survive a restart? | BLOCKING | Persistence semantics |
| What is the button label? | SAFE_ASSUMPTION | Non-core wording, trivially reversible |
| Which colour for the badge? | SAFE_ASSUMPTION | Styling, no behavioural meaning |
| Should the list paginate at 1000 items? | DEFER | Not in this slice; no MUST depends on it |
| What happens on the second page of results? | DEFER | Only if pagination is in scope now |
| Which order does the list use? | BLOCKING if the source implies an order; otherwise ask once or defer by slice relevance |

## Classification discipline

- Classify **when the unknown appears**, including mid-implementation.
- Re-classify when the situation changes: a DEFER becomes BLOCKING the moment a
  slice depends on it.
- Record the class alongside the unknown, so a reader can audit the judgement
  rather than trusting it.
