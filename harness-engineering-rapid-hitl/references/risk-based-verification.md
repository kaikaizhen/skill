# Risk-based Verification

The goal is **not** maximum coverage. It is: the highest-risk requirements have
real execution evidence before the deadline.

## Priority

Test the requirements whose failure would be worst and least visible. In
practice, prioritise anything involving:

- ownership
- per-user / per-actor isolation
- persistence
- reload / restart behaviour
- state transitions
- destructive actions
- undo / reversal
- permission and access control
- failure behaviour (what happens when it goes wrong)
- ordering
- pagination
- critical navigation
- API semantics (status codes, shapes, idempotency)

Deprioritise: styling, wording, layout, incidental helpers, trivially observable
behaviour already exercised by the core flow.

## Traceability

Every critical test answers two questions:

```text
Protected Requirement: <which MUST behaviour or business rule>
Protected Risk:        <what goes wrong in production if this breaks>
```

If neither can be answered, the test is low priority — write it only if time
remains after the critical set is green.

Template: `../templates/critical-test.md`.

## Choosing the form of evidence

A unit test is not always the right instrument.

| Requirement kind | Best evidence |
|---|---|
| Business rule / calculation | Unit test |
| Persistence / reload | Run, restart or re-read, observe state |
| Ownership / isolation | Two-actor scenario test or run |
| API semantics | Actual request and response |
| Core user flow | Execute the flow end to end |
| Destructive behaviour | Execute it, then observe what remains |

Pick the cheapest form that produces a real observation.

## Core flow execution

At least once before the final gate, the **core application flow must actually
be executed** — not merely unit tested. `FINAL-005` is not satisfiable by test
coverage alone.

## Under time pressure

Keep, in order:

1. Critical business rule verification
2. Core flow execution
3. MUST behaviour checks
4. Failure-path checks

Cut, in order (from the bottom):

1. Polish and cosmetics
2. Optional feature tests
3. Broad coverage of low-risk paths
4. Edge cases with no requirement behind them

Never cut into item 1 or 2 to finish an optional feature.

## Reporting

Report the critical set with evidence, and report what was **not** verified just
as explicitly. An honest gap list is part of the deliverable; a silent gap is a
defect in the report.
