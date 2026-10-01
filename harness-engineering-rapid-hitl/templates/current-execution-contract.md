# Current Execution Contract

> Working model for this delivery round. Evidence-only. Provisional and mutable.
> Default location: `docs/current-execution-contract.md`.
> Rules: `references/working-model.md`.

Status: `PROVISIONAL EXECUTION FREEZE` / `BLOCKED — awaiting human`
Time budget: `<n>` minutes — started `<t0>`

---

## Goal

<What this run must actually deliver, in one or two sentences.>

---

## Current Understanding

Evidence-backed only. Each line names where it came from.

- <statement> — *source: `<requirement text / file:line / observed run>`*
- <statement> — *source: ...*

---

## MUST Behaviors

Each item traces to source or an explicit human clarification. No inference.

| ID | Behavior | Evidence |
|---|---|---|
| MB-001 | <behaviour> | source / HC-001 |
| MB-002 | | |

---

## Critical Business Rules

Only rules with evidence. Categories to consider: ownership, isolation,
persistence, state transitions, permission, delete behaviour, ordering, failure
semantics.

| ID | Rule | Evidence |
|---|---|---|
| BR-001 | <rule> | source / HC-002 |

---

## Human Clarifications

```text
HC-001
Question: <what was asked>
Human Answer: <exactly what the human decided>
Impact: <what this changes in the implementation>
```

*Current execution authority until superseded by a newer clarification or by
source evidence.*

---

## Safe Assumptions

```text
ASM-001
Assumption: <what was assumed>
Why Safe: <fails none of the six safe-assumption conditions>
Reversibility: High / Medium / Low
```

*Never promoted into MUST Behaviors without a human answer or a source citation.*

---

## Deferred Questions

| ID | Question | Why deferred | Revisit when |
|---|---|---|---|
| DQ-001 | <question> | Not in current slice; no MUST depends on it | <trigger> |

---

## Current Implementation Boundary

**Changing this round:** <files / modules / surfaces>
**Explicitly not touching:** <what stays untouched>

---

## Current Vertical Slice

**Slice:** <name>
**Proves:** <which MUST behaviour or business rule>
**Expected feedback within:** <5-20> minutes

---

## Critical Acceptance Checks

| ID | Check | Protects | Evidence required | Status |
|---|---|---|---|---|
| CAC-001 | <what must be true> | MB-001 / BR-001 | <command / observation> | NOT_VERIFIED |

Status values: `PASS` / `FAIL` / `NOT_VERIFIED` / `ENVIRONMENT_BLOCKED`.

---

## Build & Test Commands

| Purpose | Command | Last observed result |
|---|---|---|
| Build | `<cmd>` | <result / not yet run> |
| Test | `<cmd>` | <result / not yet run> |
| Run | `<cmd>` | <result / not yet run> |
