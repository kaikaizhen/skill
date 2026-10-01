# Failure Classification

When a build, test, or runtime failure occurs, **classify before changing
anything**. Treating every failure as "fix the code" is how a requirement
ambiguity gets silently resolved in favour of whatever makes the test green.

Five classes:

```text
IMPLEMENTATION_BUG
REQUIREMENT_AMBIGUITY
ARCHITECTURE_CONFLICT
ENVIRONMENT_PROBLEM
TEST_PROBLEM
```

## IMPLEMENTATION_BUG

The requirement is clear, the architecture is legal, the code simply does not do
what it should.

**Action:** fix the code, re-run the verification.
**Do not ask the human.** Debugging is the AI's job; a human question here
wastes the budget that real ambiguity needs.

## REQUIREMENT_AMBIGUITY

Implementation revealed that source plus human evidence do not determine a core
behaviour.

**Action:**

1. **Stop the current slice.**
2. Classify the unknown (it is almost always `BLOCKING`).
3. Ask **one** minimal question (`human-question-policy.md`).
4. Record `HC-nnn`, update the contract, resume.

**Prohibited:** quietly choosing whichever interpretation makes the test pass.
That converts an unknown into a fabricated requirement, and it will be invisible
in the diff.

## ARCHITECTURE_CONFLICT

The existing architecture cannot satisfy a MUST requirement.

**Action:** state

- the problem
- the constraints (what cannot move)
- minimal options (usually 2-3)
- the recommended option, with reasoning

Then: if the choice causes a **major or irreversible direction change**, it
needs a human decision. If it is small and reversible and consistent with the
existing project, take it and record it as a decision in the contract.

Do not silently rewrite the project's architecture to fit a slice.

## ENVIRONMENT_PROBLEM

Database unavailable, dependency missing, build environment broken, external API
down, credentials absent.

**Action:**

- record `ENVIRONMENT_BLOCKED` with the observed error
- if a **safe** fallback exists (in-memory store for a local run, stub for an
  external API), state it explicitly, note what it means for verification
  fidelity, and continue
- otherwise `STOP` / `NEEDS_ATTENTION`

**Never** report an environment-blocked check as `PASS`. An unrunnable check is
`NOT_VERIFIED`.

## TEST_PROBLEM

The test itself disagrees with the requirement.

**Action:** establish ground truth first —

```text
Requirement evidence (source / human clarification)
        vs
Test expectation
```

- If the **requirement** is right: the test is wrong. Fix or replace the test,
  and say plainly that a test was changed and why.
- If the **test** is right: the implementation (or your reading) is wrong; fix
  the code.
- If the two are irreconcilable and the requirement evidence is itself
  contradictory: that is a blocking question for the human.

**Prohibited:** changing production behaviour to satisfy a test that contradicts
valid requirement evidence.

## Triage order

1. Is the environment healthy? (else `ENVIRONMENT_PROBLEM`)
2. Does the test encode the actual requirement? (else `TEST_PROBLEM`)
3. Is the requirement determinate? (else `REQUIREMENT_AMBIGUITY`)
4. Can the architecture express it? (else `ARCHITECTURE_CONFLICT`)
5. Otherwise `IMPLEMENTATION_BUG` — fix it.

Record the classification alongside the fix, so the reasoning is auditable and
so repeated failures in one class become visible.
