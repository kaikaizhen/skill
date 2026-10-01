# Minimum Architecture

Budget: **7 minutes** at a 90-minute total. Decide only what blocks coding.

The test for whether something belongs in this phase:

> If I do not decide this now, can I write the first line of the vertical slice?

If yes, it is not an architecture decision for Fast Mode. Defer it to the moment
the code needs it.

---

## Candidate Concerns

At most five, and only the ones the requirements actually demand:

| Concern | Decide when | Skip when |
|---|---|---|
| Presentation | There is a UI or a client-facing surface | Library / CLI-only task |
| Backend | There is server-side behavior | Pure client-side task |
| Persistence | State must outlive a request or a reload | Everything is ephemeral |
| Identity | Actors, ownership, or permissions exist | Single anonymous user |
| Testing strategy | Anything must be verified (always) | Never skipped |

Do not populate all five to fill the template. An empty concern is recorded as
`N/A — not required by any MUST`, which is itself a decision worth one line.

---

## Selection Rule

Priority order in Fast Mode:

```
Requirement Fit  >  Implementation Speed  >  Testability
                 >  Simplicity  >  Reversibility  >  Extensibility
```

**Requirement Fit is absolute.** A faster option that cannot satisfy a MUST is not
an option.

Below that, speed leads — with one guard: an option that is fast to write and
impossible to verify inside the budget is not fast. Testability sits directly
behind speed for that reason.

**Never** rank future scalability above a current MUST. A 90-minute deliverable
has no future to scale into until it exists.

---

## Overengineering Guardrail

Do not introduce, unless a requirement or the environment explicitly demands it:

- Microservices
- CQRS
- Event sourcing
- Message queues
- Kubernetes / container orchestration
- Deep DDD layering (aggregates, domain events, factories, specifications)
- Repository abstraction over every entity
- Full Clean Architecture with ports and adapters throughout
- Distributed caching
- Custom framework layers, plugin systems, generic abstractions "for later"

Each of these costs implementation time in exchange for properties a 90-minute
deliverable cannot use. "Best practice" is not a requirement, and importing one
uninvited is the same failure as importing an uninvited requirement.

**The concrete test:** name the MUST requirement or environment constraint that
fails without it. No name, no abstraction.

---

## Architecture Must Not Rewrite Requirements

Choosing a technology never edits the Execution Contract.

If a chosen stack makes a MUST awkward, the stack is wrong — not the requirement.
The failure mode is subtle and fast: the framework has a convention, the
convention almost matches the requirement, and the requirement quietly drifts to
match the framework.

If a MUST genuinely cannot be satisfied by any option available in the time
remaining, that is a **delivery shortfall to report**, not a contract edit.
(Full harness: *Requirement != Architecture != Implementation*.)

---

## Time-constrained Engineering Assumption

When the architecture budget expires with the decision unsettled: take the option
with the lowest implementation cost that satisfies every MUST, and record it.

```
TCA-001 — Persistence: single JSON file on disk.
Alternatives considered: SQLite, in-memory only.
Why chosen: satisfies MUST-004 (survives restart); zero setup cost.
Cost accepted: no concurrent-write safety; single-process only.
Revisit trigger: concurrent access requirement, or verification shows data loss.
```

This is an honest record of a decision made under time pressure — not a
recommendation and not a claim that the option is best. It is also not a
requirement, and it never enters the MUST list.

---

## Freeze

Record the decisions with `templates/minimum-architecture.md`, then:

```
ARCHITECTURE_FAST_GATE = PASS
```

Coding starts. At a 90-minute budget that should be at or before T+15.

Reopen only for:

1. The architecture cannot satisfy a MUST requirement.
2. The build or runtime environment does not support it.
3. Critical Verification proves the architecture wrong.
4. Human requirements changed.

Not for elegance, not for consistency with a preferred style, and not because a
better option occurred to you at T+40. Each reopening costs implementation time
that comes out of the same fixed budget.

---

## Quick Sanity Check Before Coding

Four questions, one minute:

1. Can every MUST be implemented on this architecture? (Walk the list.)
2. Can the critical acceptance checks be executed against it?
3. Is there a runnable path from nothing to a working vertical slice?
4. Does the environment actually have what this needs — runtime, package manager,
   network access, ports? (Check, do not assume. A missing toolchain discovered at
   T+40 costs more than every other risk in this phase.)

Any "no" is cheaper to fix now than at T+40.
