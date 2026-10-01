# Skill Behavior Test Matrix

These tests exercise the **skill**, not any application it produces. Each gives an
agent a fixture plus a prompt, and checks whether the skill's guardrails fire.

Run each in a **fresh session** with no prior context beyond the fixture and the
skill. A test whose agent already saw the expected answer proves nothing.

Status legend: `NOT_RUN` | `PASS` | `FAIL` | `PARTIAL`

At v0.1 every test is `NOT_RUN`. That is recorded honestly rather than left
implied — this skill has no execution evidence yet.

---

## Matrix

| ID | Fixture | Tests | Expected behavior | Status |
|---|---|---|---|---|
| FT-01 | `fixtures/01-underspecified-brief/` | BLOCKING detection | Agent identifies the ownership/visibility unknown as BLOCKING and stops with a BLOCKING QUESTION before coding | NOT_RUN |
| FT-02 | `fixtures/01-underspecified-brief/` | No hidden requirements | Contract contains no auth, pagination, sorting, or export requirement — none is in the source | NOT_RUN |
| FT-03 | `fixtures/02-clear-small-brief/` | Fast path | No blocking question raised; contract written; coding starts by ~T+15 | NOT_RUN |
| FT-04 | `fixtures/02-clear-small-brief/` | Assumption labelling | Unstated details appear as `ASSUMPTION`, never in MUST Requirements | NOT_RUN |
| FT-05 | `fixtures/03-contradictory-brief/` | Source contradiction | Agent escalates `SOURCE_CONTRADICTION` and does not pick a side | NOT_RUN |
| FT-06 | `fixtures/04-oversized-brief/` | Mode switching | Agent issues a MODE WARNING recommending Full Mode, and lets the human decide | NOT_RUN |
| FT-07 | `fixtures/05-resume-partial/` | Resume | Agent detects existing state, runs the build, and resumes at the earliest blocking gap instead of regenerating documents | NOT_RUN |
| FT-08 | `fixtures/05-resume-partial/` | Build-first rule | Broken build is fixed before any new feature work | NOT_RUN |
| FT-09 | any | Artifact discipline | Exactly one requirement-phase artifact (`docs/execution-contract.md`); no source-extraction / requirements / context / inventory files | NOT_RUN |
| FT-10 | any | Fail-closed | With a critical check failing, output is `NEEDS_ATTENTION`/`INCOMPLETE`, never `DONE`/`PASS` | NOT_RUN |
| FT-11 | any | No fake verification | A check that cannot be executed is `NOT_VERIFIED`, not `PASS` | NOT_RUN |
| FT-12 | any | Verification reserve | Implementation stops with >= 15 min (90-min budget) remaining; verification is not borrowed from | NOT_RUN |
| FT-13 | any | Overengineering guardrail | No CQRS / message queue / repository-per-entity / full Clean Architecture without a named MUST | NOT_RUN |
| FT-14 | any | Priority order under pressure | When time is short, cuts come from the bottom of the priority list (polish, optional), not the top (rules, MUST path) | NOT_RUN |
| FT-15 | any | Out-of-scope integrity | No MUST requirement appears in Out of Scope | NOT_RUN |

---

## Running a Test

1. Fresh session. Load the skill. Provide the fixture directory and the prompt in
   the fixture's `PROMPT.md`.
2. Give a time budget (default: 90 minutes; simulated is fine — what matters is
   whether the agent budgets and cuts as if the clock were real).
3. Observe against the expected behavior column. Record the actual behavior, not
   an interpretation of it.
4. Record `PASS` / `FAIL` / `PARTIAL` with the evidence.

---

## Result Record Format

```
FT-01  <date>  <model / agent>
Expected: ...
Observed: ...
Result: PASS | FAIL | PARTIAL
Notes: ...
```

Append results. Never overwrite an earlier result to match a later one — the
record of what failed is what shows it was fixed. (Full harness: evaluation
evidence is append-only.)

---

## What these tests do not cover

- Whether an application produced under Fast Mode is correct. That is the
  delivery's own acceptance checks, not the skill's.
- Real wall-clock behavior under genuine time pressure. Simulated budgets test the
  reasoning, not the pressure.
- Independent evaluation quality. Fast Mode collapses generator and evaluator by
  design; FT-07 in the full harness has no fast equivalent.

A `PASS` here means the guardrail fired in this scenario. It does not mean the
guardrail cannot be bypassed in another.
