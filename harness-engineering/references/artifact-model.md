# Artifact Model

What kinds of artifacts exist, how they relate, and which ones may change.

## Artifact Classes

### 1. Source Artifact

Original material the project did not author as part of the harness: specs,
briefs, transcripts, tickets, diagrams, standards documents.

- **Immutable.** Never edited by any harness stage.
- The ultimate ground truth for the source and requirement harnesses.
- If a source artifact is wrong, that is escalated to the human, not corrected
  in place.

### 2. Derived Artifact

Produced by a generator from a validated upstream artifact: extraction,
requirements, open questions, glossary, context, decision inventory, decision
analysis, ADR.

- Mutable **only** in response to a FAIL evaluation, before the gate passes.
- After the gate passes, treat as historical (see below).
- Every derived artifact declares its upstream authority chain.

### 3. Evaluation Evidence

An independent assessment of one derived artifact against its ground truth.

- **Immutable once written.** Never edited to change an outcome.
- A superseded evaluation is replaced by a *new* evaluation of the revised
  artifact, not by editing the old one.
- Carries the gate result **as of its own run**, not necessarily the current one.

Evaluation evidence is **append-only**. A stage accumulates a history of
evaluations, and every entry stays — including, and especially, the failures.

```
Append:  a new evaluation is written alongside the old ones
Never:   edit an old FAIL so that it reads as PASS
Never:   delete an old FAIL because a later PASS exists
Never:   backfill an old evaluation with fields it never had
```

Deleting or rewriting a historical FAIL destroys the record of what was wrong and
what fixed it. That record is the only thing that later distinguishes "this stage
was corrected" from "this stage was never really tested" — and a repository that
cannot show its failures cannot show its corrections either.

**A historical FAIL is not a current gate FAIL, and a later PASS does not by
itself clear an earlier one.** Current gate state is *resolved from* the history
under the Supersession Evidence Rule; it is never read off a single file. See
`gate-model.md`, **Evaluation History vs Current Gate State**.

When supersession cannot be established from evidence, the repair is a **new**
reconciliation record — never an edit to an existing evaluation.

### 4. Human Decision Record

An explicit, attributed choice made by the human decision owner.

- **Immutable.** Only a human may author or supersede it.
- Never generated, inferred, or defaulted by an agent.

### 5. Derived Current State

A regenerated index of what is currently true, computed from passed authority
artifacts.

- **Fully regenerated** on each promotion. Not hand-patched.
- Never the authority for anything. Always a view.
- Carries no information that is not derivable from passed artifacts.

## Historical vs Current State

This separation is the single most important structural rule in the artifact
model.

```
HISTORICAL (append-only, never rewritten)
  Decision Inventory      -- what was discovered, and when
  Decision Analysis       -- what options were considered, and how
  Human Decision Record   -- what was chosen, by whom, and why
  ADR                     -- the formal record of the accepted decision
  Evaluation Evidence     -- what was verified, against what

DERIVED (regenerated)
  Current Architecture State -- what is accepted right now,
                                what is still unresolved,
                                which decisions are eligible next
```

### Why not just update the inventory?

Because a decision inventory that passed an inventory gate is *evidence of
discovery at a point in time*. Rewriting every entry's status as decisions get
made produces a document that its own evaluation no longer describes. The
evaluation attests to content that has been overwritten — and nothing announces
that it went stale.

So: a decision may still read `Unresolved` in the historical inventory long
after it has been accepted. That is correct. The current state document is where
"accepted" lives.

### What the current state document is for

- letting a downstream agent see, in one read, what is decided
- letting it see what is explicitly **not** decided
- listing which decisions are now eligible for analysis
- listing the architecture rules currently in force

### What it must never do

- restate a requirement as if it were the requirement
- replace an ADR as the reason for a decision
- record a decision that has no passed ADR behind it
- introduce a constraint that no passed artifact supports

If the current state document conflicts with a passed ADR, the ADR wins and the
current state document is regenerated.

## Identifier Discipline

Every atomic knowledge unit gets a stable, unique identifier so that downstream
artifacts can cite it and evaluators can verify the citation.

Recommended prefix families (adapt names to the project, keep the discipline):

| Prefix | Unit |
|---|---|
| extraction | one atomic statement pulled from source |
| requirement | one requirement |
| acceptance criterion | one verifiable behavior, child of a requirement |
| open question | one preserved unknown |
| term | one glossary definition |
| rule | one critical domain rule in context |
| decision | one architecture decision point |
| ADR | one accepted decision record |
| architecture rule | one constraint in force from a promoted ADR |
| validation | one evaluation check |

Rules:

- Identifiers are unique within their family and never reused.
- Child identifiers encode their parent.
- Every derived unit cites at least one upstream identifier.
- An evaluator verifies that every cited identifier **actually exists upstream**.
  A citation to a nonexistent identifier is a critical failure, because it looks
  like traceability and is not.

## Canonical Path Rule

Each artifact has exactly one canonical location.

If the same artifact appears at more than one path:

1. Determine which path downstream artifacts and evaluations cite.
2. Declare that path canonical and record the decision.
3. Remove or clearly mark the duplicate as a non-authoritative copy.
4. Evaluate only the canonical path.

Duplicated artifacts drift. Once they drift, two agents reading "the context"
read different things, and no evaluation covers the difference.

Exception: deliberate, labeled copies made as **isolated test inputs** (see the
fresh agent consumer test) are not authority splits, provided they are copied
from the canonical artifact at test time and are never edited.
