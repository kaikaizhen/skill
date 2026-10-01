# Vertical Slice Loop

Default implementation strategy: **small end-to-end vertical slices**.

Forbidden by default: building every layer first and integrating at the end.
That pattern hides both misunderstanding and breakage until the moment there is
no time left to fix either.

## What a slice is

One user-meaningful path, thin but complete:

```text
User action
  -> UI / API surface
  -> application behaviour
  -> persistence
  -> result returned / rendered
  -> verification
```

A slice must be possible to **build, run, observe, and test**. If any of those
four is missing, it is a layer, not a slice.

## Slice size

Target: **real feedback within 5-20 minutes.**

If a slice would take ~40 minutes before you learn whether it works, split it.
Splitting suggestions:

- narrow the data (one field instead of the whole entity)
- narrow the path (create-only, before read/update/delete)
- narrow the actor (the happy path, before permission variants)
- hardcode a non-critical edge, record it as `ASM-nnn`, and revisit

Never split by layer ("do all the models this slice") — that recreates the
integrate-at-the-end failure.

## Slice ordering

1. The slice that proves the **riskiest** MUST behaviour or business rule.
2. The slice that unblocks the most downstream work.
3. Remaining MUST behaviours.
4. Optional behaviour.
5. Polish.

Order by risk retired per minute, not by architectural tidiness.

## The per-slice loop

For each slice:

1. **State the objective** — what this slice proves, in one sentence.
2. **State the requirements protected** — which MUST behaviours / business
   rules / human clarifications this slice must not violate.
3. **Implement the smallest useful change.**
4. **Build.**
5. **Run the relevant tests** (and the flow itself, where a test is not the
   right evidence).
6. **Observe the result** — actual output, not expectation.
7. **Classify any failure** (`failure-classification.md`) before changing code.
8. **Update the Working Model** with what was learned.
9. **Continue or ask the human.**

Template: `../templates/vertical-slice.md`.

## Rules

- **Follow existing project structure.** A slice inside an existing codebase
  should look like the code around it.
- **No speculative generality.** Build what this slice needs. Extension points
  without a requirement are cost, not foresight.
- **Do not skip the run.** A slice that compiled is not a slice that works.
- **Do not batch verification.** Verifying three slices at once loses the
  attribution that makes failures cheap to diagnose.
- **A slice that reveals a blocking unknown stops** — it does not get a quiet
  interpretation so that it can finish.

## Definition of done for a slice

- builds
- runs
- the protected requirements still hold, with observed evidence
- the Working Model reflects what was learned
- the next slice is named, or the round moves to critical verification
