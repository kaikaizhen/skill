# Provisional Execution Freeze

Rapid HITL does not use a permanent requirement freeze. It uses a
**PROVISIONAL EXECUTION FREEZE**.

## Meaning

> No blocking unknown is currently open, therefore implementation may proceed
> under the current interpretation.

It does **not** mean:

- the requirements are final
- the understanding is proven correct
- requirements may never be reopened
- the human may not be asked again

This is the `COMMIT` step of the core loop: **Current Interpretation
Commitment**, not a git commit and not a guarantee.

## Entering the freeze

Enter when all hold:

- every detected unknown is classified
- no `BLOCKING` unknown is unanswered
- MUST behaviours trace to source or human clarification
- safe assumptions are recorded with reversibility
- the next vertical slice is named
- the critical acceptance checks for this round are named

Then state it plainly, e.g.:

```text
PROVISIONAL EXECUTION FREEZE
No blocking unknown open. Proceeding with slice: <name>.
Reopen triggers: <the specific things that would force a re-ask>
```

## Reopening

Reopening is normal, not a process failure. Reopen when:

- implementation reveals ambiguity in core behaviour
- a test or runtime result contradicts the current understanding
- source evidence is found that conflicts with the contract
- a `DEFER` unknown becomes relevant to the current slice
- the existing architecture cannot satisfy a MUST behaviour

Procedure:

```text
Stop the current slice
  -> classify the new unknown
  -> if BLOCKING: one short question (budget: 1 per interruption)
  -> record HC-nnn, update the contract
  -> re-enter the freeze
  -> continue
```

Do not carry on coding "around" an open blocking unknown in the hope it
resolves itself. Do not restart the whole understanding phase either — reopen
narrowly, on the specific unknown.

## Freeze integrity

While frozen:

- MUST behaviours are protected inputs; the implementation may not weaken them
- human clarifications are protected inputs
- critical business rules are protected inputs
- code, tests, internal structure and safe assumptions are allowed outputs

Changing a protected input requires a human, not a decision made while typing.
