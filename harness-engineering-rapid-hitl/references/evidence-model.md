# Evidence Model

`Evidence > Inference`. A verification claim requires an artifact produced by
**executing something**.

## Verification must be continuous

Never code for an hour and build once at the end. At minimum, after each
critical vertical slice: **build / run / test**.

Late first-build is the most reliable way to convert a 5-minute problem into a
40-minute one.

## What counts as evidence

- a successful build command, with its output
- a test runner result (counts, names, pass/fail)
- an actual API response (status, body)
- observed UI behaviour
- an observed database/state change
- observed application runtime behaviour
- an equivalent executable observation

## What does **not** count

- "I read the code and it looks correct"
- "this pattern usually works"
- "the types line up"
- "the previous version of this worked"
- "the test should pass"
- a build that succeeded **before** the last change

Any of those ⇒ `NOT_VERIFIED`. Not `PASS`.

## Status vocabulary

| Status | Meaning |
|---|---|
| `PASS` | Executed, observed, matched the expectation |
| `FAIL` | Executed, observed, did not match |
| `NOT_VERIFIED` | Not executed, or executed without a usable observation |
| `ENVIRONMENT_BLOCKED` | Could not execute for environmental reasons |

`NOT_VERIFIED` is an honest, acceptable state to report. A fabricated `PASS` is
not, under any time pressure.

## No fake PASS

Prohibited:

- reporting a check as passed because the code "should" satisfy it
- reporting a test suite as passing without running it
- reporting a partial run as a full run
- hiding a failing test by narrowing the run and not saying so
- describing an expected output as an observed one

If a check cannot be executed, say why, and mark it `NOT_VERIFIED` or
`ENVIRONMENT_BLOCKED`.

## Self check != independent verification

Re-reading your own code is a self check. Evidence comes from execution, which
is indifferent to what you intended. Where the stakes justify it, a fresh-eyes
pass (a fresh session, or a test written from the requirement rather than from
the implementation) is stronger still.

## Recording evidence

For each critical check record:

```text
Check: <what was verified>
Command / Action: <what was actually executed>
Observed: <the actual output, quoted or summarised faithfully>
Result: PASS / FAIL / NOT_VERIFIED / ENVIRONMENT_BLOCKED
Protects: <requirement or business rule>
```

Faithful means faithful: if 9 of 10 tests passed, the evidence says 9 of 10.

## Historical evidence != current state

A passing run from twenty minutes and four edits ago is history. Before the
final gate, re-run the critical checks against the code as it now stands.
