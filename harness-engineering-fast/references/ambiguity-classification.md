# Ambiguity Classification

Every unknown gets exactly one classification. There is no fourth bucket, and
there is no unclassified unknown.

```
BLOCKING           unresolved -> core implementation may be wrong
SAFE_ASSUMPTION    does not change core behavior; cheap to change later
OUT_OF_SCOPE       deliberately not done within the available time
```

---

## The Language Rule

These words do not create requirements:

> "should", "probably", "usually", "typically", "normally", "of course",
> "obviously", "any reasonable system would"

When you catch yourself writing one while describing what the system must do, you
have found an unknown, not a requirement. Classify it.

The full harness states this as **Unknown != Assumption** and **Source-supported
knowledge outranks engineering inference**. Fast Mode does not relax it — a
90-minute budget makes inference *more* tempting and its consequences no smaller.

---

## The BLOCKING Test

An unknown is `BLOCKING` **by default** if resolving it differently would change
any of:

| Dimension | Example question |
|---|---|
| User-visible behavior | Does deleting hide the item or remove it? |
| Business rule | Can an item be reassigned after completion? |
| Actor permission | Can any user edit, or only the creator? |
| Ownership | Is data per-user or shared? |
| Data persistence | Must state survive a restart? |
| Data lifecycle | Is deletion soft or hard? |
| State transition | Can a closed item reopen? |
| Security boundary | Is any endpoint unauthenticated? |
| Destructive behavior | Is a destructive action reversible? |
| Core API semantics | Is the operation idempotent? |

To downgrade a default-BLOCKING unknown, you must be able to state **why it cannot
affect acceptance**. "It's probably fine" is not that statement. Write the reason
down; if you cannot write it, it stays BLOCKING.

### Two useful tie-breakers

**The rework test.** If the answer arrived after implementation, how much would
change? A different label -> SAFE_ASSUMPTION. A different data model, a different
permission check, a different persistence story -> BLOCKING.

**The demo test.** Could the delivery look completely correct in a demo and still
be wrong on this point? If yes, it is BLOCKING — invisible wrongness is exactly
what acceptance checks exist to catch, and you cannot write an acceptance check
for an unknown.

---

## SAFE_ASSUMPTION

An unknown may be recorded as a safe assumption only when **all three** hold:

1. It does not change core product behavior.
2. It is cheap to change later (localized, no data-model or contract impact).
3. It does not affect any Critical Acceptance Check.

Every entry is written with the literal marker `ASSUMPTION` and reads as a
decision you made, not as something the source said:

```
ASSUMPTION A-001 — Item titles are capped at 200 characters.
Source: silent.
Why safe: no stated rule depends on length; changing the cap is a one-line edit;
no acceptance check involves title length.
```

Never phrase an assumption as a requirement. `The system must cap titles at 200
characters` is a lie about the source's contents. Downstream, nobody can tell the
difference.

---

## OUT_OF_SCOPE

An explicit decision not to build something in the available time.

Legitimate entries: nice-to-have features, non-required polish, optional
enhancements, capabilities the source lists as optional or future.

**Illegitimate:** anything the source requires. A MUST does not become out of
scope because it is expensive. If a MUST cannot be delivered in the time
available, that is a delivery shortfall reported at the final gate — not a scope
edit.

Each entry names why it is out of scope, and whether the source required it:

```
OUT-003 — CSV export.
Source support: mentioned as "nice to have".
Reason: not a MUST; ~20 min to implement; verification budget protected.
```

---

## Partly-Defined Topics

A source often defines half of something. Recording the whole topic as UNKNOWN
loses a real requirement; recording it as known fabricates a specification.

Split it:

```
Known   (-> requirement): state must survive a page reload
Unknown (-> classify):    whether it survives a server restart
```

Both halves are recorded. The known half becomes a MUST; the unknown half gets a
classification and, usually, the BLOCKING test.

---

## Contradictions Inside the Source

Two source statements that conflict are **not** an unknown to be classified — they
are a `SOURCE_CONTRADICTION`, and they are always escalated to the human. Do not
pick the more recent, more detailed, or more convenient statement.

```
SOURCE CONTRADICTION

Statement A: <quote + location>
Statement B: <quote + location>
Affected requirement: ...
Cannot proceed on: ...
```

An unresolved source contradiction blocks `FAST_DELIVERY_GATE = PASS`.

---

## Recording Format

Inside `docs/execution-contract.md`:

```
BLOCKING B-001 — <question in one line>
Why it blocks: <which implementation decision cannot be made>
Interpretations: A ... / B ...
Status: PENDING | RESOLVED (human, <what they said>) | UNANSWERED (proceeding under A)

ASSUMPTION A-001 — <the assumption>
Source: silent | partially states <x>
Why safe: <all three conditions>

OUT-001 — <what is not being built>
Source support: <required | optional | absent>
Reason: <why>
```

Every one of these carries an ID so verification, the final acceptance record, and
the README can cite them.
