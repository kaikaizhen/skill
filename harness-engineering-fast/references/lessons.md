# Lessons — Fast Mode Guardrails

Two kinds of entry, and they are labelled, because provenance matters:

- **INHERITED** — carried from `harness-engineering/references/lessons-learned.md`,
  where the originating failure is recorded. Restated here in fast-mode terms.
- **DESIGN** — a guardrail written into v0.1 from the constraints of the mode,
  **not yet confirmed by a recorded fast-mode failure**. Treat as a working
  hypothesis; promote it with evidence when a real run confirms it.

The full harness earns its lessons from failures. This skill is at v0.1 and has
not yet accumulated its own. Saying so is cheaper than pretending otherwise.

---

## F-001 — Time pressure converts inference into requirement *(DESIGN)*

Under a clock, the gap between "the source doesn't say" and "obviously it must
work like this" closes almost invisibly. The inference feels like efficiency: you
save four minutes by not asking.

**Guardrail.** The BLOCKING test runs regardless of remaining time. The clock buys
you the right to *defer non-blocking* analysis. It never buys the right to guess a
core semantic.

**Detection.** Search your own contract for "should", "probably", "usually",
"typically". Each hit is an unclassified unknown wearing a requirement's clothes.

Related: full harness *No Guess Rule*.

---

## F-002 — Verification budget is spent before it is defended *(DESIGN)*

The verification reserve is the easiest thing in the plan to borrow from, because
at T+62 the borrowing feels temporary and the feature feels nearly done.

**Guardrail.** The reserve is not borrowable. Overrun is resolved by cutting from
the bottom of the implementation priority list, never by shortening verification.

**Detection.** At each checkpoint ask: *if I stop coding now, can I still verify
what exists?* The first "no" means you are already over budget, not approaching
it.

---

## F-003 — Horizontal building leaves nothing to deliver *(DESIGN)*

Building all models, then all services, then all controllers, then the UI leaves
nothing runnable until the final layer lands. If the clock expires at 80%, a
horizontal build delivers zero working features and has all its integration risk
still ahead of it.

**Guardrail.** Vertical slice first. One complete path through every layer before
broadening.

**Detection.** At T+35 (90-min budget): has the application started and executed a
real flow? If not, stop broadening.

---

## F-004 — "Best practice" is an uninvited requirement *(DESIGN)*

Importing CQRS, a repository layer over every entity, or full Clean Architecture
into a 90-minute task is the same failure as importing a feature the source never
requested: unrequested scope, funded from the same budget, justified by
convention rather than by the source.

**Guardrail.** Every abstraction names the MUST requirement or environment
constraint that fails without it. No name, no abstraction.

Related: full harness L-010 — guidance-level content must not acquire acceptance
criteria. Architectural taste is guidance, not requirement.

---

## F-005 — The demo-correct delivery *(DESIGN)*

The failures that reject a delivery are usually invisible on screen: wrong
ownership, missing isolation, state that does not persist, a destructive action
that is not reversible where it should be. Everything looks right in the demo.

**Guardrail.** Critical Business Rules are their own section in the contract, they
lead the implementation priority list, and they lead the verification risk
ordering.

**Detection.** For each rule ask: *could this be wrong while the screen looks
perfect?* Every yes is a mandatory verification target.

---

## F-006 — Scope shrinks and the contract follows *(DESIGN)*

Under pressure, a MUST that turns out to be expensive drifts into Out of Scope.
The contract is then internally consistent and wrong, and nothing on disk records
that a requirement was dropped.

**Guardrail.** Out of Scope is validated against the **source**, not against the
contract (REQ-CHECK-005). A MUST that cannot be delivered is a reported delivery
shortfall, never a scope edit.

---

## F-007 — Self-review is not independent evaluation *(INHERITED, L-012)*

Fast Mode collapses the generator and evaluator into one agent because the budget
allows nothing else. That is a real compromise, and it must be named rather than
papered over.

**Guardrail.** The Rapid Requirement Review records
`Independence: SELF_REVIEW | INDEPENDENT`. A self-review is never described as an
independent evaluation. Where a fresh agent or second person is available, use
one — the checks are written to be runnable by an outsider.

---

## F-008 — A passing-looking test with no execution *(INHERITED, L-002 / L-003)*

"The code looks right, so this passes" produces a verification record that
attests to reasoning, not behavior — and a reader cannot tell the difference
afterwards.

**Guardrail.** A `PASS` requires executed evidence. Where the environment cannot
run the check, `NOT_VERIFIED`, with the reason.

**Corollary.** An overstated verification claim is more damaging than an
acknowledged limitation, because downstream decisions rely on it.

---

## F-009 — Architecture quietly rewrites the requirement *(INHERITED, boundary rule)*

A framework has a convention; the convention almost matches the requirement; the
requirement drifts to match the framework. Nobody decides this, and no gate fires.

**Guardrail.** Architecture never edits the Execution Contract. If a stack cannot
satisfy a MUST, the stack is wrong. If nothing available can satisfy it in the
time remaining, that is a shortfall to report.

---

## F-010 — The final report understates what is broken *(DESIGN)*

At T+88, with a mostly working delivery, the pull toward `DONE` is strong, and a
failure gets softened into a Known Limitation near the bottom of a README.

**Guardrail.** Fail-closed. A failed MUST appears in the first paragraph of the
delivery report. The gate result is `NEEDS_ATTENTION` or `INCOMPLETE`, and the
reasons are named.

**Test.** Would a reviewer running the software be surprised by anything? If yes,
the report is wrong.

---

## Adding to this file

When a real fast-mode run produces a failure or near-failure:

1. Record what happened, why it happened, and the abstract guardrail.
2. Label it `CONFIRMED` with the date, and keep the originating project's domain
   out of it.
3. If it confirms an existing `DESIGN` entry, promote that entry rather than
   adding a new one.
