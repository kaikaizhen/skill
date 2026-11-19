# Design Review Lens - how a design owner challenges a requirement and a design

Open this when **a requirement or a design draft is being judged before code is
written**: a ticket that depends on an external system, two competing designs for the
same feature, a design owner's review of a plan, or "why does their design differ from
mine?". It is the reasoning behind a good design review, not a procedure - the gates in
`../` still decide what is approved and when.

The lens has two directions. **Challenge the requirement** (can it be done as written?)
and **challenge the design** (does it put state, data and responsibility in the right
place?). Both end the same way: a decision handed to its owner, with a recommendation.

## 1. Challenge the requirement against the real capability

A ticket is the scope authority (HARD RULE 12), but a ticket can ask for something the
integration cannot do. Before implementing, take each requirement line and ask what the
external system's contract really provides.

| Check | Question | Typical finding |
|---|---|---|
| Event it assumes | does the external API expose that event? | "react when the user scans" - the API only says *not yet* until the final result; there is no intermediate state |
| Observability | can we see the failure it describes? | "user cancelled in the app" is indistinguishable from "still waiting" |
| Cadence | is the requested interval compatible with the lifetime it polls? | a 30 s poll against a 5 min window wastes up to 10% of the window on latency |
| Strength of proof | what does the proof actually prove? | the proof carries 5 of 10 digits - it proves "holds *a* number ending like this", not "holds *this* number" |
| Platform limit | can the client even know this? | a browser cannot tell whether an app is installed; the redirect back to the page is not guaranteed |
| Coverage | who can actually succeed? | a credential only some users hold - "partial success" is the common case, not the edge case |
| Governance | does the ticket's own checklist match what it builds? | "no PII, no new external API, no new auth path" ticked on a feature that does all three |

**What to do with a finding** - never silently implement it, never silently drop it:

```
requirement as written -> why the contract cannot do it (evidence) -> recommended change
-> the 2-3 options when it is a product / security call (A accept / B strengthen / C demote)
-> who decides
```

Return it to the requester as a short table (`explanation-standard.md`), recommended
option first. Anything the spec does not define (what the API returns on reject or
expiry) is `UNKNOWN`: use a clock you own until it is confirmed, and list it as an open
question with an owner.

## 2. Challenge the design: where does each piece of state live?

Ask of every piece of data: **how long does it matter, and who needs it afterwards?**

| Kind | Home | Why |
|---|---|---|
| in-flight, short-lived, only the current actor needs it | a cache with a TTL | expiry is automatic - no cleanup job, no trigger, no archive table, no large blob in the relational store |
| terminal fact someone will audit, count or trace | the relational store, **one row per transaction**, written when it reaches a final state | complaint tracing, statistics, "verified but never registered" queries |
| sensitive payload (disclosed claims, holder identity, client address) | **nowhere** | re-query the source if you need it again; if the source forbids that, hold it in the cache with a TTL and delete it after use |
| a token the client holds | hash it in every key | leaked cache content has no usable token |

Design the terminal record **from the questions you will need to answer**, then give
each answer its own value: cancelled vs. timed out, completed-and-used vs.
completed-and-unused. Two outcomes folded into one value cannot be separated later.

Two traps this catches:

- **Two clocks.** When your state outlives a dependency's retention, a "re-check" path
  that asks the dependency again will eventually get *not found* - and must not destroy
  your own state because of it. Decide per path which clock is authoritative.
- **Cleanup that rides on user traffic.** A purge triggered by "the same user's next
  request" never runs for the users who left. Prefer expiry that needs no one to act.

## 3. Responsibility boundaries

- A **shared module** verifies and records; it does not know the caller's business
  rules (who may register, whether a number is already used). The caller owns those and
  asks the module to *confirm* before and *bind* after.
- Caller-only endpoints are protected twice (a shared secret and a source allow-list)
  and answer as if they did not exist when refused.
- A step that happens **after** the main business succeeded (binding, audit, analytics)
  may fail without undoing the business: log a warning, do not roll back, retry or
  compensate - unless a requirement says otherwise.
- The caller must act on what really happened: do not bind a verification that this
  request did not use.
- The client sends only a *name* from a server-side whitelist, never a template
  reference, a field list or an owner id.

## 4. Order of work that follows from the lens

1. Ship the **security fix** that already exists in the codebase first (it is independent
   of the feature), then data objects, then the backend behind a feature flag **off**,
   then the client with the entry hidden, then switch on and watch.
2. Phase the scope: the first phase is the smallest thing that is correct and shared;
   badge display, other clients and optional tables are later phases with their own
   decision.
3. Everything the design cannot decide goes in an **open-questions list** with an owner
   (product, DBA, the external operator, legal), numbered, in the same document.

## 5. Why two sound designs differ

Two designs for the same requirement usually differ because they optimise different
constraints, not because one is wrong. Name the constraint before comparing:

| Constraint | Pushes toward |
|---|---|
| scarce relational-store capacity | cache for transient state, no scheduled jobs |
| an existing component (cache, token pattern, shared backend) | reuse it instead of a new table or mechanism |
| a second client (mobile, partner) will call it later | a shared backend, a transport-neutral token, no client-specific rules inside |
| audit, complaint tracing, statistics | one durable row per transaction with the owner key added at the end |
| privacy review | store nothing that is not needed, store hashes not values |
| the ticket's literal wording | the smallest design that satisfies it |

Write the comparison as **area / design A / design B / the constraint that decides it**,
and say which parts were kept from both. A design that lost on one constraint often
still has parts worth keeping (token hashing, no replication-reserved columns, naming).

## 6. Review checklist (for a plan, before code)

- [ ] every requirement line checked against what the external contract provides
- [ ] anything not provable from the contract is `UNKNOWN`, owner named
- [ ] each piece of state has a lifetime and a home; sensitive payload has none
- [ ] terminal outcomes distinct enough to answer the questions that will be asked
- [ ] the shared module does not carry the caller's business rules
- [ ] post-success steps cannot undo or block the main business
- [ ] two clocks reconciled where state outlives a dependency
- [ ] the ticket's own governance checklist matches what is being built
- [ ] rollout order, feature flag, and the open-questions list exist

This file states how to *think*; it never approves anything. Gates, approvals and the
report shape stay in `../workflow.md`, `../change-proposal.md` and `../code-review.md`.
