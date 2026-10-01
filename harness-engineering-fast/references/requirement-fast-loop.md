# Rapid Requirement Review

A single review pass over `docs/execution-contract.md`, run once, before any
coding. Budget: **3-5 minutes**.

This is **not** a full independent evaluation. The full harness separates
generator and evaluator into different agents with different contracts. Fast Mode
cannot afford that, and does not claim it. What it does claim:

> Every check below was actually performed against the source, and its result is
> recorded.

Where an independent reviewer (a fresh agent, a second person) is available, use
one — the checks are written so an outsider can run them. Where not, run them
yourself and record `Independence: SELF_REVIEW` in the result. Do not describe a
self-review as an independent evaluation. (Full harness: *Generator Self Check !=
Independent Evaluation*.)

Record the outcome with `templates/rapid-requirement-review.md`.

---

## Checks

Each check is `PASS` or `FAIL`. Every `FAIL` names the offending item.

### REQ-CHECK-001 — MUST traceability *(critical)*

Every MUST requirement traces to a source location or a recorded human
clarification.

**Method.** Walk the MUST list. For each, point at the source fragment. An item
you cannot point at is a FAIL, no matter how obviously true it seems.

**Typical FAIL.** "Users can log out." — reasonable, universal, and absent from
the source.

---

### REQ-CHECK-002 — No hidden requirements *(critical)*

Nothing in the contract is unsupported by source or clarification.

**Method.** Read the contract as an outsider and ask of each behavior: *who asked
for this?* Watch for requirements that arrived through architecture (a chosen
framework's conventions), through UX instinct, or through completeness pressure.

**Typical FAIL.** Source says "list the items"; contract says "list the items,
sorted by creation date, paginated at 20."

---

### REQ-CHECK-003 — Blocking ambiguity resolved or explicitly stopped *(critical)*

Every `BLOCKING` item is either answered by a human, or the delivery is explicitly
marked as proceeding under an unanswered blocking question.

**Method.** No `BLOCKING` item may be silently downgraded to `SAFE_ASSUMPTION`
between drafting and review. If a reclassification happened, it must carry a
written justification against the BLOCKING test in
`ambiguity-classification.md`.

---

### REQ-CHECK-004 — Assumptions not written as requirements *(critical)*

No entry in MUST Requirements or Critical Business Rules is actually an
assumption.

**Method.** For each MUST, ask: *if this turns out to be wrong, was it the
source's fault or mine?* If mine, it is an ASSUMPTION and belongs in the
Safe Assumptions section, labelled.

---

### REQ-CHECK-005 — Out of Scope contains no MUST *(critical)*

Nothing that the source requires has been parked in Out of Scope.

**Method.** Read Out of Scope against the source, not against the contract. The
failure mode is scope shrinking under time pressure and the contract being edited
to match — which makes the delivery self-consistent and wrong.

---

### REQ-CHECK-006 — Acceptance checks cover the MUSTs *(critical)*

Every MUST requirement and every Critical Business Rule maps to at least one
Critical Acceptance Check.

**Method.** Build the mapping explicitly. An unmapped MUST means the delivery has
no way to know whether it succeeded.

---

### REQ-CHECK-007 — No missing core business rule

Re-scan the source for rules that would constitute a requirement failure even
when the screen looks correct: ownership, isolation, persistence, ordering,
destructive behavior, state transitions, authorization boundaries.

**Method.** Take that list, and for each item ask whether the source says anything
about it. Silence is `UNKNOWN` (classify it), not "not applicable".

This check is not marked critical because a missed non-core rule should not block
the clock — but a FAIL here is the most common cause of a delivery that demos
perfectly and is rejected.

---

## Gate Rule

```
All critical checks PASS (001-006)  ->  REQUIREMENT_FAST_GATE = PASS
Any critical check FAIL             ->  REQUIREMENT_FAST_GATE = FAIL
```

On FAIL: revise the **contract**, then re-run the failed checks. Never revise the
review result to match the contract. Coding does not start on a FAIL.

REQ-CHECK-007 FAIL does not by itself block the gate, but the missing rule must be
added to the contract (as a requirement or a classified unknown) before coding.

---

## What this review deliberately does not do

- It does not evaluate architecture. That is `minimum-architecture.md`.
- It does not verify implementation. That is `risk-based-verification.md`.
- It does not produce a separate requirements document. The contract is the
  requirements document.
- It does not re-derive the source. It checks the contract *against* the source.
