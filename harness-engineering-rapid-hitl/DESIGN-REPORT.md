# Design Report — harness-engineering-rapid-hitl

Version `0.1` — Status `Experimental`

---

## Purpose

A skill for short software development tasks (roughly 60-180 minutes) where a
human is reachable during implementation, and where the AI must **not** guess
its way through requirements to save time.

Target situations: timed coding tasks, 90-minute software challenges, MVPs,
prototypes, small features, and feature work inside an existing project.

The design question was not "how do we go faster" but:

> How do we go fast *without* the AI silently inventing product behaviour?

The answer this skill commits to: replace upstream document volume with **short,
budgeted human loops**, and replace up-front certainty with **evidence produced
by building small slices**.

---

## Core Loop

```text
UNDERSTAND → QUESTION → COMMIT → BUILD → VERIFY → LEARN → (UNDERSTAND)
```

`COMMIT` is a **Current Interpretation Commitment**, not a git commit: the
evidence at hand is sufficient to keep implementing under this reading. It is
provisional and reopenable.

The loop's only branch toward the human is unknown classification:
`BLOCKING` → ask; `SAFE_ASSUMPTION` → record and continue; `DEFER` → record and
ignore for now.

---

## Why this differs from the Full Harness

The full `harness-engineering` skill optimises for an **authority and validation
chain**: sources extracted, requirements derived, decisions analysed, ADRs
recorded, gates enforced. That is the right instrument when work is long-lived,
high-risk, and reviewed by people who were not present.

Rapid HITL optimises for **delivery progress with a live human**. Concretely:

| Dimension | Full harness | Rapid HITL |
|---|---|---|
| Primary axis | Authority / validation chain | Delivery progress |
| Entry question | "Which document is missing first?" | "What is the earliest blocking delivery gap?" |
| Upstream artifacts | Many, each with a role in the chain | One thin, mutable contract |
| Ambiguity resolution | Formal decision cycle, recorded | One multiple-choice question, recorded as `HC-nnn` |
| Freeze | Requirement freeze | **Provisional** freeze, explicitly reopenable |
| Architecture | ADR lifecycle | Follow existing; minimum decision only where absent |

The full harness's *principles* are inherited unchanged (Evidence > Inference,
No Fake PASS, Assumption != Requirement, and the rest). Its *weight* is
deliberately not.

---

## Why this differs from simple Fast Planning

`harness-engineering-fast` also compresses. The difference is what happens at a
blocking gap.

- Fast mode assumes **no human is in the loop**: it stops at a blocking gap,
  reports it, and waits. Its freeze is per-run.
- Rapid HITL assumes **a human is one message away**: it asks a single
  multiple-choice question, records the answer as execution authority, and
  resumes within the same run.

That single difference reshapes everything downstream: a question budget becomes
necessary (the human is interruptible, so interruption must be rationed), the
freeze becomes provisional (new answers can arrive mid-build), and mid-coding
ambiguity becomes a first-class lifecycle event rather than a terminal state.

It also differs from generic "plan then code" prompting in three ways: the
planning phase is bounded to minutes rather than declared complete; unknowns are
*classified* rather than resolved by preference; and progress is gated on
executed evidence rather than on a finished plan.

Choosing between the three:

```text
Human reachable + small task        -> rapid-hitl
No human + small task + hard clock  -> fast
High risk / long-lived / complex    -> full harness
```

---

## Human Question Strategy

Threshold: `cost(wrong assumption) > cost(human interruption)`.

Budget: 3 blocking questions in the initial burst; 1 per implementation
interruption (up to 3 when tightly coupled). The budget exists because an
unbudgeted loop degrades into the AI outsourcing requirements analysis to the
human, which is slower than the full harness and less rigorous.

Form: multiple choice with stated impact per option, plus an AI recommendation
that makes answering one keystroke — and that may never become the answer
itself.

The human's role is explicitly **fast decision maker**, not requirement author.
Bad question shapes ("describe your ideal architecture") are named and banned in
`references/human-question-policy.md`.

---

## Correctness Strategy

No correctness guarantee is claimed. The claim is *high-confidence correctness
through evidence*, produced by seven named mechanisms (see
`references/correctness-contract.md`).

The central prohibition: **time pressure never authorises guessing a requirement
that changes core product behaviour.** Where that cannot be honoured — the human
is unreachable, the ambiguity is real — the output is `NEEDS_ATTENTION`, not a
quiet choice.

Supporting structure: protected inputs (source text, MUST behaviours, human
clarifications, business rules, acceptance criteria) versus allowed outputs
(code, tests, recorded assumptions, implementation decisions). Changing a
protected input mid-implementation is named as *silent contract drift* and
prohibited.

---

## Evidence Strategy

A verification claim requires an artifact of actual execution: a build result, a
test runner result, an API response, observed UI behaviour, observed state, or
equivalent runtime observation. Everything else is `NOT_VERIFIED` — a legitimate
status to report, unlike a fabricated `PASS`.

Verification is continuous: every critical vertical slice builds, runs and is
observed. Vertical slices exist partly for this reason — a slice that cannot be
executed within 5-20 minutes cannot produce evidence quickly enough to correct
the understanding it was built on.

Verification is risk-first, not coverage-first: ownership, isolation,
persistence, state transitions, destructive actions, permissions, failure
behaviour, ordering, and API semantics come before breadth. Each critical test
must name a Protected Requirement and a Protected Risk, or be deprioritised.

---

## Time Strategy

Default 90 minutes, with an indicative shape and one hard rule: the last 15-20%
belongs to verification and may not be borrowed against.

Priority under pressure: MUST behaviours → critical business rules → critical
verification → failure handling → optional features → polish. Cuts come from the
bottom. The question budget does not scale with the clock; more time buys more
slices, not more interrogation.

Waiting on a human is not idle time — unaffected work continues, and work the
answer could invalidate does not start.

---

## Known Limitations

1. **No execution evidence.** Every test in `tests/test-matrix.md` is `NOT_RUN`
   at v0.1. The skill's behaviour under a real agent is unvalidated.
2. **Requires a responsive human.** If answers do not arrive, the skill degrades
   to fail-closed reporting — correct, but slower than fast mode, which is
   designed for that case.
3. **Question budget is a heuristic.** 3 / 1 is a judgement, not a measured
   optimum. Tasks with four genuinely blocking unknowns will strain it (the
   intended response is escalation, but the boundary is fuzzy).
4. **Blocking classification depends on AI judgement.** The default-to-BLOCKING
   list narrows the discretion; it does not eliminate it.
5. **Slice sizing is heuristic.** "5-20 minutes of feedback" is unenforceable
   from inside the skill.
6. **Self-verification remains self-verification.** The skill asks for executed
   evidence, but the same agent both builds and interprets it; independent
   verification is recommended, not structurally guaranteed.
7. **Time awareness is simulated.** An agent has no reliable clock; budget
   discipline depends on the operator or on the agent's own estimates.
8. **The escalation boundary is qualitative.** "High-risk" and "complex" are
   listed by trigger, not measured.
9. **Existing-project reuse can overshoot.** "Follow existing conventions" could
   preserve a convention that the requirement actually contradicts; the
   `ARCHITECTURE_CONFLICT` path exists for this but relies on noticing.

---

## Escalation Conditions

Warn that Rapid HITL may be insufficient, recommend the full harness, and let
the human decide, when the work involves: multiple complex actors, high-risk
security, high-risk destructive data behaviour, compliance obligations,
multi-system integration, long-lived architecture, several high-irreversibility
decisions, production-critical deployment, or pervasive requirement ambiguity.

The skill must not switch modes on its own or begin emitting full-harness
artifacts. Fixture `05-high-risk` exercises this.

---

## Tests Designed

15 behaviour tests (`tests/test-matrix.md`), over 6 fixtures:

| Test | Guards |
|---|---|
| T01 | Fast path — no unnecessary question |
| T02 | Blocking ownership ambiguity is asked, not guessed |
| T03 | Safe UI ambiguity does not interrupt the human |
| T04 | Question budget respected |
| T05 | Human decision beats AI recommendation |
| T06 | New blocking unknown during coding reopens the loop |
| T07 | Implementation bug is fixed, not escalated |
| T08 | Bad test does not bend production behaviour |
| T09 | Overengineering guardrail |
| T10 | Existing project conventions reused |
| T11 | Time pressure switches to critical verification |
| T12 | No fake verification |
| T13 | Critical test failure blocks completion |
| T14 | Fresh domain, no knowledge leakage |
| T15 | Full harness escalation |

Plus a **Fresh Agent Consumer Test** (`tests/fresh-agent-consumer-test.md`): ten
questions a fresh session must answer from the skill alone, covering when coding
may start, what must and must not reach the human, the question budget, decision
authority, mid-coding ambiguity, failure classification, evidence standards,
time-pressure priority, and the fail-closed conditions.

---

## Self Evaluation

| ID | Check | Result | Where |
|---|---|---|---|
| CHECK-001 | Understood-enough-before-coding model exists | PASS | `references/rapid-understanding.md`, `references/provisional-freeze.md` |
| CHECK-002 | Blocking unknown cannot be guessed | PASS | `references/uncertainty-classification.md`, `references/correctness-contract.md` |
| CHECK-003 | Safe assumption is explicit | PASS | six conditions + `ASM-nnn` record |
| CHECK-004 | Question budget enforced | PASS | `references/human-question-policy.md`, `SKILL.md` § 4 |
| CHECK-005 | Human answer overrides AI recommendation | PASS | `SKILL.md` § 5, recommendation rule, T05 |
| CHECK-006 | Provisional freeze can reopen | PASS | `references/provisional-freeze.md` |
| CHECK-007 | Vertical slice is the default strategy | PASS | `references/vertical-slice-loop.md` |
| CHECK-008 | Build/test happens continuously | PASS | `references/evidence-model.md` |
| CHECK-009 | Failure classification exists | PASS | five classes + triage order |
| CHECK-010 | Implementation bug does not trigger a human question | PASS | `IMPLEMENTATION_BUG`, T07 |
| CHECK-011 | Mid-coding ambiguity triggers the human loop | PASS | `REQUIREMENT_AMBIGUITY`, T06 |
| CHECK-012 | No fake PASS | PASS | evidence model, status vocabulary |
| CHECK-013 | Time budget preserves verification | PASS | 15-20% reserve, `references/time-budget.md` |
| CHECK-014 | Critical test failure prevents completion | PASS | fail-closed list, `FINAL-009`, T13 |
| CHECK-015 | Existing project reuse works | PASS | `SKILL.md` § 8, fixture 04, T10 |
| CHECK-016 | Full harness boundary exists | PASS | `SKILL.md` § Escalation, fixture 05, T15 |
| CHECK-017 | Project agnostic | PASS | no host-project vocabulary; fixtures are invented domains |
| CHECK-018 | Fresh agent test exists | PASS | `tests/fresh-agent-consumer-test.md` |

Self-evaluation result: **PASS**.

Note the standing caveat: CHECK-001 through CHECK-018 verify that the skill
*states and structures* these behaviours. They do not verify that an agent
*exhibits* them — that is what the 15 `NOT_RUN` behaviour tests are for.

---

## Unvalidated Areas

- All 15 behaviour tests (`NOT_RUN`) and the Fresh Agent Consumer Test
  (unexecuted): the skill has **no runtime evidence**.
- Whether the 3 / 1 question budget matches real task ambiguity.
- Whether agents reliably classify unknowns as BLOCKING under time pressure —
  the single most important behaviour, and the least verified.
- Whether the provisional freeze reopens in practice or ossifies into a silent
  commitment.
- Whether the 15-20% verification reserve survives when a feature is nearly
  finished.
- Whether the escalation warning fires before an agent has already started
  building.
- How the skill behaves across a context compaction mid-run.
- Interaction with the other two harness skills if a human loads more than one.
