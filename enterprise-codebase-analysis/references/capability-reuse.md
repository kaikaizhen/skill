# Gate 3 - Capability Ownership, Reuse & Negative Evidence

The third of the gates in `requirement-evidence-gates.md`, given its own file
because it carries two questions: *does this capability exist, and who owns it*
(negative evidence), and *can what already exists carry this ticket as it stands*
(Existing Capability First, P5 in `engineering-principles.md`).

Mode A only. Proportionality, the five categories and the other gates stay in
`requirement-evidence-gates.md`.

---


**Trigger** - any of: the ticket reuses or depends on an existing verification /
limit / quota / counter / state machine / shared backend mutation; the analysis is
about to state that a capability is **missing**; or the change is about to add a
method, parameter, overload, wrapper or abstraction, or modify shared code
(P5 - Existing Capability First).

**Not triggered** by display-only, copy, styling or markup-only tickets, nor by "a
reference document mentions this capability" alone.

**Required output** - `## Capability Ownership`:

| Capability | Ticket requires? | Active owner (layer + file) | Authoritative state | Mutation point | Evidence | Result | Reuse |
|---|---|---|---|---|---|---|---|

**Order of work: ask whether the ticket requires it *before* tracing its owner.** A
capability the ticket does not require is named, classified and parked - not traced
through Service, DAO, SP and provider just because it exists.

**Result vocabulary - the negative-evidence threshold:**

```
CONFIRMED EXISTS            direct evidence at the active owner / state path
CONFIRMED MISSING           ALL THREE confirmed - (a) active carrier, (b)
                            capability owner, (c) authoritative state / mutation
                            path - AND that path demonstrably has no such behaviour
NOT OBSERVED IN TRACED PATH a path was searched and nothing found, but (a), (b)
                            and (c) are not all confirmed
UNKNOWN                     owner or active path not confirmed, evidence thin
```

- "I did not find it in this Service / DAO / SP" is `NOT OBSERVED IN TRACED PATH`,
  never `CONFIRMED MISSING`.
- **No new persistence, schema, cache, session or architecture may be proposed on
  `UNKNOWN` or `NOT OBSERVED`.** Even a `CONFIRMED MISSING` must first pass the
  ticket-requirement check before anything is designed for it.
- A `CONFIRMED MISSING` capability the ticket does not require is a **requirement
  decision / follow-up**, never a gap and never a blocker. Which capabilities get
  a row is decided by the ticket, not by a fixed list.

### The `Reuse` column - Existing Capability First (P5)

For every `CONFIRMED EXISTS` row the ticket depends on, answer whether the existing
code already covers this need **as it stands**:

```
SUFFICIENT AS IS  an existing seam already reaches the need - a delegate, callback,
                  strategy, handler, optional argument or fallback the caller
                  already passes. USE IT. Adding a method, overload, parameter,
                  flag or layer for it is scope creep.
CALLER-SIDE       the shared code cannot express it but the CALLER can, with the
                  shared code untouched. Prefer this.
EXTENSION NEEDED  neither works. Name the concrete limitation at path:line - "I did
                  not immediately see how" is not a limitation - then STOP and ask.
                  Never modify shared code on your own initiative, not even a
                  defaulted optional parameter.
```

**How to answer it: enumerate, do not recall.** Open the shared member's signature
and list **every** parameter and extension point it already has, one per line,
with what the caller currently passes to each. A seam may only be ruled out after
it has appeared on that list and been rejected with a reason. Look hardest at the
parameters that already receive the value the ticket cares about - a `fallback` /
`onError` / `onFailure` delegate handed the exception, a strategy or handler
object, an optional logger, a result selector. Reading the signature to copy the
call is not the same as reading it to inventory its seams; only the written list
counts. An `EXTENSION NEEDED` produced without that list is an assumption, not a
verdict, and Gate 4 demotes it.

```
Shared member:   HttpClientExtension.GetSafeResultAsync  (path:line)
Seam inventory:  timeoutSec       - int, caller sets 3
                 requestAsync     - delegate, caller builds the request
                 responseHandler  - delegate, caller parses the response
                 fallback         - Func<Exception?, Task<T?>>  <- RECEIVES THE EXCEPTION
                 logger           - optional ILogger, defaulted null, guarded by logger?.
Verdict:         SUFFICIENT AS IS - the caller can omit logger and log its own
                 level inside fallback; no parameter needs adding
```

`EXTENSION NEEDED` requires this block before any shared code is touched - in the
analysis at Approval Gate #1, or the moment it is discovered:

```
SHARED CAPABILITY EXTENSION APPROVAL REQUIRED
Shared code: <file:line>   Callers: <CONFIRMED SOLE / ENUMERATED (n) / UNKNOWN>
Limitation:  <why the existing seam cannot carry this need, with evidence>
Option A:    solve at the caller - what it costs, what it duplicates
Option B:    extend the shared code - exact change + impact on EACH other caller
             (behaviour, tests, reviewers), per P2 and P3
Recommendation: <A or B> - <one line>
AWAITING USER DECISION
```

Backward compatibility is not an exemption: a defaulted parameter or new overload
still changes a shared contract, still needs this block, and still carries a
P2 / P3 delta per caller.

**Stop condition:** every capability the ticket depends on has a row with an
owner, a result and - when it exists - a `Reuse` verdict. Capabilities it does
not depend on are listed as follow-ups, un-traced. No shared code is modified
while any row sits at `EXTENSION NEEDED` without an answer.
