---
name: harness-engineering-fast
description: Deliver a correct, verified, small software task inside a hard time budget (60-180 minutes, default 90). Use for timed coding challenges, take-home exercises, MVP spikes, technical prototypes, and small bounded features. Enforces Source Fidelity, explicit assumptions, blocking-question stops, a single execution contract, minimum architecture, early implementation, and reserved risk-based verification. Fails closed.
version: 0.1
status: experimental
---

# Harness Engineering — Fast Mode

## Purpose

This skill delivers a **working, verified** software task when the total time
available is 60-180 minutes.

It answers one question:

> With the time that remains, what is the smallest amount of upstream rigor that
> still prevents me from confidently shipping the wrong thing?

Fast Mode is not a lighter coat of paint on the full harness. It is a different
instrument for a different constraint: **time is an architecture constraint**, and
every artifact that does not change what gets built or verified is cut.

## Version and Status

Version: `0.1`
Status: `Experimental`

## Correctness Principle — read this first

This skill does **not** guarantee that the delivered software is correct. No
process can. What it targets is:

> **High-confidence correctness under time constraint.**

It lowers risk through six mechanisms and claims nothing beyond them:

| Mechanism | Prevents |
|---|---|
| Source Fidelity | Building requirements the source never stated |
| Explicit Assumptions | Assumptions silently hardening into requirements |
| Blocking Question Handling | Guessing on semantics that change core behavior |
| Critical Acceptance Checks | Declaring done without knowing what done means |
| Risk-based Verification | Spending the test budget on the wrong risks |
| Fresh-agent / independent check | Confusing "I wrote it" with "it works" |

If information is insufficient to implement core behavior safely, **STOP and ask
the human**. Time pressure never authorizes guessing a requirement that changes
core behavior. See `references/correctness-contract.md`.

---

## Scope

**Intended for:**

- 60-180 minute development tasks (default budget: **90 minutes**)
- Coding challenges and timed take-home exercises
- MVP spikes and technical prototypes
- Small bounded feature implementation

**Explicitly not intended for:**

- Production architecture governance
- Full requirement systems for long-lived projects
- Full ADR lifecycle and architecture review
- Enterprise architecture review
- Long-term maintenance orchestration
- Full security review
- Production readiness certification

If the task plainly needs those capabilities, say so and recommend switching to
the full `harness-engineering` skill. Do not pretend Fast Mode is sufficient.
Escalation triggers: `references/lifecycle.md` § Mode Switching.

---

## Inherited Principles

Fast Mode keeps these validated principles from the full harness, unchanged:

- **Artifact Exists != Artifact Trusted**
- **AI Recommendation != Human Decision**
- **Unknown != Assumption**
- **Requirement != Architecture != Implementation**
- **Protected Inputs vs Allowed Outputs** (declare boundaries positively)
- **Generator Self Check != Independent Evaluation**
- **Historical Artifact != Current Derived State**
- **Source-supported knowledge outranks engineering inference**

What Fast Mode changes is the **weight of the evidence**, not the direction of
these rules. A rapid review is still a review; it is simply scoped to the checks
that can invalidate the delivery.

---

## Lifecycle

```
SOURCE
  -> Rapid Requirement Scan
     -> Execution Contract
        -> Blocking Question Check      (STOP if BLOCKING unresolved)
           -> Requirement Freeze         REQUIREMENT_FAST_GATE = PASS
              -> Minimum Architecture
                 -> Architecture Freeze  ARCHITECTURE_FAST_GATE = PASS
                    -> Implementation
                       -> Critical Verification
                          -> Fix Critical Failures
                             -> Final Acceptance  FAST_DELIVERY_GATE = PASS
```

Do not expand this into a large artifact set. Details: `references/lifecycle.md`.

---

## Time Budget (90-minute default)

| Window | Phase |
|---|---|
| T+0 - T+8 | Rapid Requirement Scan + Execution Contract |
| T+8 - T+15 | Minimum Architecture |
| T+15 - T+65 | Implementation |
| T+65 - T+82 | Critical Verification + Fix |
| T+82 - T+90 | Final Acceptance / README / Cleanup |

Scale proportionally for 60 or 180 minute budgets. Announce the wall-clock
mapping at the start (`T+0 = 14:05`, etc.) so the budget is checkable, not
notional.

### Time Budget Guardrail

- Requirement analysis over budget -> continue only on **BLOCKING** ambiguity;
  stop processing non-blocking ambiguity.
- Architecture discussion over budget -> pick the lowest-implementation-cost
  option that satisfies every MUST, record it as a
  **Time-constrained Engineering Assumption**, and start coding.
- **Never** use the time budget to skip a blocking question that changes core
  requirement semantics. That is the one thing the clock does not buy.

---

## Single Artifact Strategy

The requirement and boundary phase produces exactly one document:

```
docs/execution-contract.md
```

Unless the repository already has an established document structure, or the user
explicitly asks for Full Mode, do **not** create `source-extraction.md`,
`source-evaluation.md`, `requirements.md`, `requirement-evaluation.md`,
`context.md`, `context-evaluation.md`, `decision-inventory.md`, or multiple ADRs.

The goal is **Minimum Sufficient Evidence** — enough written down that a fresh
reader can tell what was required, what was assumed, and what was verified.

Later phases add at most: a minimum-architecture section (inside the contract or
its own short file), a critical test plan, and a final acceptance record.

Templates: `templates/`.

---

## Unknown Classification

Every unknown is classified as exactly one of:

```
BLOCKING           unresolved -> core implementation may be wrong
SAFE_ASSUMPTION    does not change core behavior; cheap to change later
OUT_OF_SCOPE       deliberately not done in the available time
```

Never convert "should", "probably", "usually", or "typically" into a requirement.
Classification rules and the BLOCKING test: `references/ambiguity-classification.md`.

**Default to BLOCKING** when the unknown could change user-visible behavior, a
business rule, actor permission, ownership, data persistence, data lifecycle, a
state transition, a security boundary, destructive behavior, or core API
semantics — unless there is a solid reason it cannot affect acceptance.

---

## Human Stop Rule

When BLOCKING ambiguity exists, ask the **fewest necessary** questions. Do not
dump fifteen questions on the human.

```
BLOCKING QUESTION

Question:
...

Why it matters:
...

Possible interpretations:
A ...
B ...

Implementation impact:
...
```

Then wait. Do not pick A or B yourself. After the answer: update the Execution
Contract, freeze requirements, continue.

If the human is unavailable and the clock is running, say so explicitly, record
the question as `BLOCKING — UNANSWERED`, and either implement the interpretation
the human is asked to confirm **while marking the delivery `NEEDS_ATTENTION`**, or
stop. Never present a guessed interpretation as a settled requirement.

---

## Gates

Fast Mode has three named gates. Each ends with an explicit terminal line so a
resuming agent can detect state without inference.

```
REQUIREMENT_FAST_GATE  = PASS | FAIL
ARCHITECTURE_FAST_GATE = PASS | FAIL
FAST_DELIVERY_GATE     = PASS | NEEDS_ATTENTION | INCOMPLETE
```

- `REQUIREMENT_FAST_GATE` — after the Rapid Requirement Review
  (`references/requirement-fast-loop.md`). Critical check FAIL -> no coding.
- `ARCHITECTURE_FAST_GATE` — after Minimum Architecture
  (`references/minimum-architecture.md`). Then coding starts, around T+15.
- `FAST_DELIVERY_GATE` — after Final Acceptance
  (`templates/final-acceptance.md`).

---

## Freeze Rules

**Requirement Freeze** (after `REQUIREMENT_FAST_GATE = PASS`) means: do not
reopen requirement analysis unless one of these appears —

1. Source contradiction
2. Missing blocking requirement
3. New human clarification
4. Acceptance failure traced to a requirement defect

**Architecture Freeze** (after `ARCHITECTURE_FAST_GATE = PASS`) means: do not
redesign unless —

1. The architecture cannot satisfy a MUST requirement
2. The build/runtime environment does not support it
3. Critical Verification proves the architecture wrong
4. Human requirements changed

"Another option is more elegant" is not a reason to reopen either freeze.

---

## Implementation

Priority order — cut from the **bottom** when time runs short, never the top:

1. Critical business rules
2. MUST happy path
3. Persistence / state correctness
4. Failure behavior
5. Core navigation / interaction
6. Critical validation
7. UI clarity
8. Polish
9. Optional enhancement

Build a **vertical slice first** (UI -> application -> persistence -> result), not
all layers with nothing runnable. Checkpoints A (core flow executable), B
(critical business rule working), C (critical tests runnable).

Details: `references/implementation-strategy.md`.

### Verification Reserve Rule

At least **15 minutes** is reserved for verification and fixing. When coding runs
long, drop low-priority features. "Finish all the features first, then test" is
not an available option.

---

## Verification

Fast Mode does not chase maximum coverage. It chases **highest-risk requirement
coverage**. Every critical test must answer:

> What requirement or risk does this test protect?

If it cannot, it is not a priority test. Risk ordering, verification types, and
failure handling: `references/risk-based-verification.md`.

### No Fake Verification

"The code looks right, so the test passes" is prohibited. A PASS requires real
evidence: a command run, a test executed, an API response, observed application
behavior, or equivalent verifiable output. Where the environment cannot execute
it, mark `NOT_VERIFIED` — never `PASS`.

### Fail-Closed Rule

Never output `DONE`, `SUCCESS`, or `PASS` when any of these is true:

- build not verified
- a MUST requirement is knowingly incomplete
- a blocking ambiguity is unanswered
- a critical test fails
- a source contradiction is unresolved
- the core flow was never actually executed
- the application fails to start

Output `NEEDS_ATTENTION` or `INCOMPLETE` instead, and state why.

---

## Resuming an Existing Project

Fast Mode must be able to take over work in progress. Do not regenerate documents
by reflex. Inspect first:

1. Source / requirement material
2. Existing implementation
3. Build state (does it build? does it run?)
4. Existing tests and their results
5. Existing execution contract
6. Known failures
7. **Remaining time**

Then find the **earliest blocking delivery gap** and resume there.
See `references/lifecycle.md` § Resume.

---

## Reference Routing

| Need | Read |
|---|---|
| Phase order, time budget, resume, mode switching | `references/lifecycle.md` |
| Rapid Requirement Review checks and gate | `references/requirement-fast-loop.md` |
| BLOCKING / SAFE_ASSUMPTION / OUT_OF_SCOPE rules | `references/ambiguity-classification.md` |
| What architecture to decide, and what not to | `references/minimum-architecture.md` |
| Priority order, vertical slice, checkpoints | `references/implementation-strategy.md` |
| What to test and what evidence counts | `references/risk-based-verification.md` |
| Definition of correctness, fail-closed rules | `references/correctness-contract.md` |
| Guardrails learned from real fast-mode failures | `references/lessons.md` |

| Output | Template |
|---|---|
| `docs/execution-contract.md` | `templates/execution-contract.md` |
| Rapid requirement review record | `templates/rapid-requirement-review.md` |
| Minimum architecture record | `templates/minimum-architecture.md` |
| Critical test plan | `templates/critical-test-plan.md` |
| Final acceptance record | `templates/final-acceptance.md` |

Skill behavior tests: `tests/test-matrix.md`.
