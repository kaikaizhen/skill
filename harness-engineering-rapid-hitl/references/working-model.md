# Working Model — Current Execution Contract

One artifact. Default location `docs/current-execution-contract.md`, or the
repository's existing sensible location for such a document. Do not scatter the
model across several files, and do not create a full-harness artifact set.

It is a **working model**, not a specification: thin, mutable, evidence-only.

Template: `../templates/current-execution-contract.md`.

## Required sections

### Goal
What this run must actually deliver. One or two sentences.

### Current Understanding
How the feature/project is currently understood. **Only evidence-backed
content**, each item traceable to source text, human clarification, or observed
code/runtime behaviour.

### MUST Behaviors
The core behaviours this run must complete. Every item traces to **source** or
**explicit human clarification**. Nothing else may enter this section — not
inference, not "obviously they'd want", not an assumption promoted because it
felt safe.

### Critical Business Rules
Rules that change meaning if wrong. Typical categories: ownership, isolation,
persistence, state transitions, permission, delete behaviour, ordering, failure
semantics. Only evidence-supported rules are listed.

### Human Clarifications
```text
HC-001
Question: ...
Human Answer: ...
Impact: ...
```
These are **current execution authority** until superseded by a newer human
clarification or by source evidence.

### Safe Assumptions
```text
ASM-001
Assumption: ...
Why Safe: ...
Reversibility: High / Medium / Low
```
An assumption is never written as a requirement, and never migrates into MUST
Behaviors without a human answer or a source citation.

### Deferred Questions
Questions that do not need answering now. Recorded so they are not rediscovered
as surprises, and so the human can see what was set aside.

### Current Implementation Boundary
What this round changes — and, where useful, what it does not touch.

### Current Vertical Slice
The next smallest runnable slice.

### Critical Acceptance Checks
What must be verified once this round completes, with the evidence that would
satisfy each.

## Maintenance rules

- **Append, don't rewrite.** History of clarifications matters; a contract that
  silently loses HC-002 has drifted.
- **Update after every verification** with the evidence learned
  (`../templates/learning-update.md`).
- **Never edit a MUST behaviour or human clarification for implementation
  convenience.** If implementation cannot satisfy it, that is an
  `ARCHITECTURE_CONFLICT` or a new blocking question — stop and say so.
- **Keep unknowns out of MUST.** Unknown != Requirement.
- **Keep it short.** If the contract is longer than the code it governs, the
  balance is wrong for this mode.
