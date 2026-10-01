---
name: harness-engineering-rapid-hitl
description: Deliver a small software task fast WITHOUT guessing requirements, by keeping a live human in the loop. Use for 60-180 minute coding tasks, 90-minute software challenges, MVPs, prototypes, small features, and feature work inside an existing project, whenever a human is reachable for quick decisions. Understands just enough to start safely, asks only genuinely blocking questions (max 3 up front, 1 per interruption), commits to a current interpretation, builds a small vertical slice, verifies with real build/run/test evidence, and re-understands from what it learns. Fails closed.
version: 0.1
status: experimental
---

# Harness Engineering — Rapid Human-in-the-Loop

## Purpose

Deliver a small software task quickly, in a setting where **a human is available
to answer short questions during implementation**.

The question this skill answers is not:

> How do I analyse this project completely before writing code?

It is:

> What is the least understanding that lets me start safely, and which unknowns
> must a human resolve before I am allowed to guess?

Speed here comes from **short human loops**, not from guessing. Time pressure
never authorises inventing a requirement that changes core product behaviour.

Version: `0.1` — Status: `Experimental`

---

## Correctness Philosophy — read this first

This skill does **not** guarantee the delivered software is correct. No process
does. What it targets is:

> **High-confidence correctness through evidence.**

Confidence comes from, and only from:

| Mechanism | Prevents |
|---|---|
| Source Fidelity | Building behaviour the source never stated |
| Explicit Human Clarification | Guessing semantics that change product behaviour |
| Explicit Assumptions | Assumptions silently hardening into requirements |
| Small Vertical Slices | Discovering the misunderstanding only at the end |
| Real build / run / test evidence | Confusing "I read it" with "it works" |
| Critical Verification | Spending the test budget on the wrong risks |
| Continuous Re-understanding | Acting on a model the code already disproved |

If a blocking unknown cannot be resolved safely: **STOP and ask the human.**

Details: `references/correctness-contract.md`.

---

## Inherited Principles

Carried unchanged from the validated harness family:

- Artifact Exists != Artifact Trusted
- Unknown != Requirement
- Assumption != Requirement
- Requirement != Architecture != Implementation
- AI Recommendation != Human Decision
- Self Check != Independent Verification
- No Fake PASS
- Protected Inputs vs Allowed Outputs
- Evidence > Inference
- Earliest Blocking Gap / Earliest Unverified
- Historical Evidence != Current State

Carried in **spirit but not in weight**: the full harness's authority chain,
artifact set, ADR lifecycle, and gate hierarchy are deliberately not reproduced
here. Rapid HITL replaces upstream document volume with **live human answers**.

---

## Scope

**Use when all of these hold:**

- The task is roughly 60-180 minutes of work (default budget: **90 minutes**)
- The scope is a small feature, MVP, prototype, challenge, or bounded change
- **A human is reachable during implementation** for short decisions

**Do not use when:**

- No human is reachable — then blocking questions cannot be answered; use
  `harness-engineering-fast`, which stops at blocking gaps instead of looping.
- The work is production-critical, high-risk, or architecturally long-lived —
  see § Escalation.

---

## Core Loop

```text
UNDERSTAND → QUESTION → COMMIT → BUILD → VERIFY → LEARN
     ↑                                               │
     └───────────────────────────────────────────────┘
```

`COMMIT` is **not** a git commit. It means **Current Interpretation
Commitment**: the evidence on hand is now sufficient to keep implementing under
this reading. It is provisional and may be reopened by new evidence.

Full lifecycle, including the unknown-classification branch:
`references/lifecycle.md`.

---

## Mode Boundary

| | Full harness | Fast mode | **Rapid HITL** |
|---|---|---|---|
| Optimises for | Authority / validation chain | Time budget, no human | Delivery progress with a live human |
| Upstream artifacts | Many | One contract | One contract, kept thin and mutable |
| Blocking unknown | Formal decision cycle | Stop, report, wait | Ask one short question, continue |
| Requirement freeze | Yes | Yes, per run | **Provisional** — reopenable |

Do not silently switch modes or start emitting full-harness artifact sets.

---

## Operating Rules

### 1. Understand just enough

Spend **1-5 minutes** building a Working Model before coding, not a full
analysis. What to inspect and in what order: `references/rapid-understanding.md`.

### 2. Write one thin contract

`docs/current-execution-contract.md` (or the repo's equivalent location) is the
single working artifact. Template: `templates/current-execution-contract.md`.
Structure and rules: `references/working-model.md`.

### 3. Classify every unknown

Exactly three classes — `BLOCKING`, `SAFE_ASSUMPTION`, `DEFER`. There is no
fourth "just try something" state. Definitions and the default-to-BLOCKING list:
`references/uncertainty-classification.md`.

**Default to BLOCKING** when a wrong guess would change: user-visible behaviour,
a business rule, ownership, actor isolation, permission, authn/authz semantics,
persistence, data lifecycle, destructive behaviour, state transitions, core API
semantics, required integration behaviour, or acceptance criteria.

### 4. Question threshold

Ask the human only when:

```text
cost(wrong assumption) > cost(human interruption)
```

**Budget:** at most **3** blocking questions in the initial burst; at most **1**
new blocking question per implementation interruption (up to 3 only if they are
tightly coupled and must be answered together). Never dump 10-20 requirement
questions on a human. The human is a **fast decision maker**, not a requirement
author. Format and etiquette: `references/human-question-policy.md`, template:
`templates/blocking-question.md`.

### 5. Human answer wins

An AI recommendation is a recommendation. Once a question is BLOCKING, the AI's
preferred option **never** becomes the decision. After an answer: record the
clarification, update the contract, check whether the block cleared, continue —
do not rerun the whole analysis.

### 6. Commit provisionally, then build

No blocking unknown open ⇒ **PROVISIONAL EXECUTION FREEZE** ⇒ keep coding. New
blocking unknown ⇒ reopen, ask, update, continue.
See `references/provisional-freeze.md`.

### 7. Build in vertical slices

Default strategy is a small end-to-end slice (action → interface → application
behaviour → persistence → result → verification), sized to give **real feedback
in 5-20 minutes**. Never build all layers and integrate at the end.
See `references/vertical-slice-loop.md`.

### 8. Follow what already exists

If the project already has a framework, persistence approach, testing convention
or structure, and nothing in the requirement conflicts with it — follow it. Do
not reopen architecture. Only make a minimum architecture decision where the
project genuinely lacks direction. Never introduce microservices, CQRS, event
sourcing, message queues, Kubernetes, heavy DDD, blanket generic repositories,
distributed caching or full Clean Architecture unless the source, the existing
architecture, or the human requires it.

### 9. Classify failures before fixing

On any build/test/runtime failure, classify first:
`IMPLEMENTATION_BUG` · `REQUIREMENT_AMBIGUITY` · `ARCHITECTURE_CONFLICT` ·
`ENVIRONMENT_PROBLEM` · `TEST_PROBLEM`. Only the first is "just fix the code".
Never make a test pass by quietly picking a requirement interpretation.
See `references/failure-classification.md`.

### 10. Verify continuously with real evidence

Never code for an hour before the first build. A verification claim requires an
executed artifact: build output, test runner result, API response, observed UI
behaviour, database state, or runtime behaviour. Anything else is
`NOT_VERIFIED`, never `PASS`. See `references/evidence-model.md` and
`references/risk-based-verification.md`.

### 11. No silent contract drift

MUST behaviours, human clarifications and critical business rules may not be
changed for implementation convenience. Conflict ⇒ stop, explain, ask.

### 12. Learn

After each verification, update the Working Model with the new **evidence only**
— observed context is not a new requirement.
Template: `templates/learning-update.md`.

---

## Human Stop Conditions

Stop and ask the human when:

- A BLOCKING unknown is open and unanswered.
- Implementation reveals ambiguity in core behaviour (stop the slice first).
- The existing architecture cannot satisfy a MUST requirement
  (`ARCHITECTURE_CONFLICT`) and the fix is materially irreversible.
- Source evidence contradicts a human clarification, or two sources contradict.
- The environment is blocked with no safe fallback.

---

## Time Behaviour

Default 90 minutes. Indicative shape — **not** a rigid schedule:

| Window | Focus |
|---|---|
| 00-05 | Rapid understanding |
| 05-10 | Initial blocking questions + contract |
| 10-15 | Minimum implementation direction |
| 15-65 | Vertical slice implementation |
| 65-82 | Critical verification + fixes |
| 82-90 | Final acceptance + cleanup |

The one hard rule: **reserve the last 15-20% for verification.** Under pressure,
cut from the bottom — polish, then optional features — never critical business
rules, MUST behaviour, or critical verification.
See `references/time-budget.md`.

---

## Final Gate — RAPID_DELIVERY_GATE

Before claiming completion, evaluate every check in
`templates/final-acceptance.md`:

`FINAL-001` MUST behaviours implemented · `FINAL-002` no unresolved blocking
question · `FINAL-003` critical business rules verified · `FINAL-004` project
builds · `FINAL-005` core flow actually executed · `FINAL-006` critical tests
actually executed · `FINAL-007` safe assumptions documented · `FINAL-008`
limitations documented · `FINAL-009` no critical test failing · `FINAL-010` no
human clarification silently contradicted.

`RAPID_DELIVERY_GATE = PASS` only when every critical check passes with evidence.

### Fail closed

If any of the following holds, output `INCOMPLETE` or `NEEDS_ATTENTION` with
reasons — **never** `DONE`, `SUCCESS`, `COMPLETE`, or `PASS`:

- a blocking question is unresolved
- the build fails
- the core flow was never executed
- a MUST requirement is missing
- a critical test fails
- an unresolved source contradiction exists
- a human clarification is contradicted
- a required runtime is unavailable and no valid verification exists

---

## Escalation

Warn the human that **Rapid HITL may be insufficient** and recommend the full
`harness-engineering` skill when the work shows: multiple complex actors,
high-risk security, high-risk destructive data behaviour, compliance
obligations, multi-system integration, long-lived architecture, several
high-irreversibility decisions, production-critical deployment, or pervasive
requirement ambiguity.

State the warning and let the human decide. Do not switch modes unilaterally,
and do not start generating full-harness artifacts.

---

## Reference Loading

Load on demand; do not preload everything.

| Situation | Read |
|---|---|
| Starting any task | `references/lifecycle.md` |
| First contact with the project | `references/rapid-understanding.md` |
| Writing / updating the contract | `references/working-model.md` |
| An unknown appeared | `references/uncertainty-classification.md` |
| Considering asking the human | `references/human-question-policy.md` |
| Deciding whether coding may continue | `references/provisional-freeze.md` |
| Planning the next slice | `references/vertical-slice-loop.md` |
| Build/test/runtime failed | `references/failure-classification.md` |
| Claiming something works | `references/evidence-model.md` |
| Choosing what to test | `references/risk-based-verification.md` |
| Time is short | `references/time-budget.md` |
| Tempted to guess a requirement | `references/correctness-contract.md` |

Templates: `templates/`. Skill behaviour tests: `tests/test-matrix.md`.
Design rationale and known limitations: `DESIGN-REPORT.md`.
