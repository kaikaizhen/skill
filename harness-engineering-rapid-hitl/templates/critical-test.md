# Critical Test

> Risk-first, not coverage-first. Selection rules:
> `references/risk-based-verification.md`.

```text
CRITICAL TEST — CT-001

Name:
<what it checks, in plain language>

Protected Requirement:
<MB-00n / BR-00n / HC-00n>

Protected Risk:
<what goes wrong for a real user if this breaks>

Evidence form:
unit test | integration test | API request | executed flow | observed state

Setup:
<preconditions>

Action:
<what is executed>

Expected:
<the observable expectation>
```

If **Protected Requirement** or **Protected Risk** cannot be answered, this test
is low priority — write it only after the critical set is green.

## Result record

```text
Command / Action:
<exactly what was executed>

Observed:
<the actual output, faithfully — if 9 of 10 passed, say 9 of 10>

Result:
PASS | FAIL | NOT_VERIFIED | ENVIRONMENT_BLOCKED
```

`PASS` requires an execution that actually happened. Reading the code and
concluding it should work is `NOT_VERIFIED`.

## Priority reminder

High-risk areas that usually deserve a critical test: ownership, per-actor
isolation, persistence, reload behaviour, state transitions, destructive
actions, undo/reversal, permission, failure behaviour, ordering, pagination,
critical navigation, API semantics.

Low priority: styling, wording, layout, helpers already exercised by the core
flow.
