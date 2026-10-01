# Correctness Contract

## What this skill does not claim

It does **not** guarantee correct software. No process can. Any statement like
"this skill ensures the code is correct" is out of bounds.

## What it does claim

> **High-confidence correctness through evidence.**

Confidence is produced by seven mechanisms, and claims nothing beyond them:

```text
Source Fidelity
+ Explicit Human Clarification
+ Explicit Assumptions
+ Small Vertical Slices
+ Actual Build / Runtime Evidence
+ Critical Verification
+ Continuous Re-understanding
```

Remove any one and the confidence claim weakens accordingly — say so rather than
covering the gap with a stronger word.

## The central prohibition

> Time pressure never authorises guessing a requirement that changes core
> product behaviour.

When a blocking unknown cannot be resolved safely:

```text
STOP -> ask the human
```

If the human is unreachable, the output is `NEEDS_ATTENTION` with the open
question stated — never a silent choice presented as a finished feature.

## Distinctions that must not collapse

| | |
|---|---|
| Artifact Exists | != Artifact Trusted |
| Unknown | != Requirement |
| Assumption | != Requirement |
| Requirement | != Architecture != Implementation |
| AI Recommendation | != Human Decision |
| Self Check | != Independent Verification |
| Historical Evidence | != Current State |
| Code compiles | != Behaviour verified |
| Test passes | != Requirement satisfied |

## Protected inputs vs allowed outputs

**Protected inputs** — may not be changed by the implementer:

- source requirement text
- MUST behaviours
- human clarifications (`HC-nnn`)
- critical business rules
- acceptance criteria

**Allowed outputs** — the implementer's own territory:

- code and its internal structure
- tests (subject to `failure-classification.md` § TEST_PROBLEM)
- safe assumptions, recorded
- implementation-level decisions consistent with the contract
- documentation of what was built

Changing a protected input requires a human decision. Doing it while
implementing is **silent contract drift** and is prohibited, even when the drift
would make the code simpler or a test greener.

## No fake PASS

A verification claim requires executed evidence (`evidence-model.md`). Absent
that: `NOT_VERIFIED`.

## Fail closed

Do not emit `DONE`, `SUCCESS`, `COMPLETE`, or `RAPID_DELIVERY_GATE = PASS` when
any of these holds:

- an unresolved blocking question
- the build fails
- the core flow was never executed
- a MUST requirement is missing
- a critical test fails
- an unresolved source contradiction
- a human clarification is contradicted
- a required runtime is unavailable with no valid verification

Emit `INCOMPLETE` or `NEEDS_ATTENTION`, and list the reasons. A partial delivery
reported accurately is a good outcome; a full delivery reported dishonestly is
not a delivery at all.

## Reporting honesty

- Report what was executed, not what was intended.
- Report gaps explicitly, including deferred questions and safe assumptions that
  a reviewer should sanity-check.
- Do not describe an assumption as a requirement in the final summary.
- If something was cut for time, name it.
