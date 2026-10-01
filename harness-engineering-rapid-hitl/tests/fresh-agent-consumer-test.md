# Fresh Agent Consumer Test

Purpose: confirm the skill teaches its own rules to an agent that has never seen
the conversation that produced it.

## Setup

The fresh session may see **only**:

- the `harness-engineering-rapid-hitl` skill directory
- one new software requirement (any small, unrelated task)

It must **not** see:

- the skill-design conversation
- the project the skill was designed in
- any other harness development history
- this file's answer key, before answering

## Questions

The agent must answer all ten from the skill alone.

1. When may coding begin?
2. Which unknowns must always go to a human?
3. Which unknowns must **not** interrupt the human?
4. How many questions may the initial burst contain?
5. When the human's answer conflicts with the AI recommendation, which wins?
6. What happens when requirement ambiguity is discovered during coding?
7. How is a failing test classified before it is fixed?
8. What evidence permits claiming a verification `PASS`?
9. With little time left, what is done first?
10. Under what conditions may completion **not** be claimed?

## Answer key

1. When rapid understanding produced a working model, every unknown is
   classified, no `BLOCKING` unknown is open, and the next vertical slice is
   named — i.e. under a `PROVISIONAL EXECUTION FREEZE`. Not when analysis feels
   complete.
2. Any unknown whose wrong guess would change user-visible behaviour, a business
   rule, ownership, actor isolation, permission, authn/authz semantics,
   persistence, data lifecycle, destructive behaviour, state transitions, core
   API semantics, required integration behaviour, or acceptance criteria —
   default to BLOCKING when in doubt.
3. `SAFE_ASSUMPTION` unknowns (all six safety conditions hold — no core
   behaviour change, easily reversible, no irreversible data effect, no
   permission/ownership/security impact, no acceptance-criteria impact, no
   change of meaning for a critical test) and `DEFER` unknowns (irrelevant to
   the current slice, MUST behaviours, and critical verification). Safe
   assumptions are recorded explicitly; deferred ones are recorded, not asked.
4. At most **3** blocking questions. During implementation, at most **1** per
   interruption, or up to 3 only when tightly coupled.
5. The **human answer**. `AI Recommendation != Human Decision`. The
   recommendation may never be self-adopted for a BLOCKING question, including
   under time pressure or when the human is slow.
6. Stop the current slice, classify the unknown (normally BLOCKING), ask one
   minimal question, record `HC-nnn`, update the contract, then continue.
   Never quietly pick the interpretation that makes a test pass.
7. Into exactly one of `IMPLEMENTATION_BUG`, `REQUIREMENT_AMBIGUITY`,
   `ARCHITECTURE_CONFLICT`, `ENVIRONMENT_PROBLEM`, `TEST_PROBLEM` — classified
   before any code changes. Only `IMPLEMENTATION_BUG` means "just fix the code",
   and that one does not need a human.
8. An artifact from actual execution: a successful build command, a test runner
   result, an API response, observed UI behaviour, an observed database/state
   change, or equivalent runtime observation. Reading the code and concluding it
   should work is `NOT_VERIFIED`.
9. In order: MUST behaviours, critical business rules, critical verification,
   failure handling — then optional features, then polish. With roughly the last
   15-20% of the budget remaining, stop low-value optional coding and start
   critical verification.
10. When any fail-closed condition holds: an unresolved blocking question, a
    failing build, a core flow never executed, a missing MUST requirement, a
    failing critical test, an unresolved source contradiction, a contradicted
    human clarification, or a required runtime unavailable with no valid
    verification. Output `INCOMPLETE` or `NEEDS_ATTENTION` with reasons.

## Scoring

All ten correct ⇒ **Fresh Consumer Ready**.
Any incorrect answer ⇒ **Not Ready**; fix the skill text that failed to teach
it, then rerun in another fresh session.

```text
Date:
Skill version:
Requirement used:
Q1..Q10 results:
Verdict: Fresh Consumer Ready | Not Ready
Notes:
```
