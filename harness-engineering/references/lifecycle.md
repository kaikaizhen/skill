# Harness Lifecycle

Stage order, detection, and resume rules for the validated scope of v0.1.

## Full Validated Lifecycle

```
[ Source Harness ]
Source Intake
  -> Source Extraction
  -> Source Extraction Evaluation
  -> SOURCE_EXTRACTION_GATE

[ Requirement Harness ]
Validated Source Extraction
  -> Requirement Generation
  -> Open Question Preservation
  -> Requirement Evaluation
  -> REQUIREMENT_GATE

[ Context Harness ]
Validated Requirements
  -> Glossary
  -> Project Context
  -> Context Artifact Evaluation
  -> CONTEXT_ARTIFACT_GATE
  -> Fresh Agent Context Consumer Test
  -> Context Consumer Evaluation
  -> CONTEXT_CONSUMER_GATE

[ Architecture Decision Harness ]
Validated Context
  -> Architecture Decision Discovery
  -> Decision Inventory Evaluation
  -> ARCHITECTURE_DECISION_INVENTORY_GATE
  -> [ ARCHITECTURE_DECISION_LOOP, per decision ]
       Decision Analysis
       -> Decision Analysis Evaluation
       -> DECISION_ANALYSIS_GATE
       -> Human Decision
       -> HUMAN_DECISION_GATE
       -> ADR Generation
       -> ADR Evaluation
       -> ADR_GATE
       -> Architecture Authority Promotion
       -> Current Architecture State (rebuild)
       -> Architecture State Evaluation
       -> ARCHITECTURE_AUTHORITY_GATE
```

Each arrow is a hard dependency. A stage may not begin until the gate immediately
upstream of it is PASS.

## Stage Dependency Rules

| Stage | Requires |
|---|---|
| Source Extraction | Source material identified and reachable |
| Requirement Generation | `SOURCE_EXTRACTION_GATE = PASS` |
| Glossary / Project Context | `REQUIREMENT_GATE = PASS` |
| Consumer Test | `CONTEXT_ARTIFACT_GATE = PASS` |
| Decision Discovery | `CONTEXT_CONSUMER_GATE = PASS` |
| Decision Analysis | `ARCHITECTURE_DECISION_INVENTORY_GATE = PASS` |
| Human Decision | `DECISION_ANALYSIS_GATE = PASS` for that decision |
| ADR Generation | `HUMAN_DECISION_GATE = PASS` for that decision |
| Promotion | `ADR_GATE = PASS` for that ADR |
| Next decision analysis | `ARCHITECTURE_AUTHORITY_GATE = PASS` after the previous promotion |

## Two Different Context Validations

The context harness runs **two** evaluations that must never be merged.

| | Artifact Evaluation | Consumer Evaluation |
|---|---|---|
| Question | Is the context correct against ground truth? | Is the context *sufficient* for a fresh agent? |
| Method | Compare document to upstream requirements | Give a fresh agent only the context, then compare its understanding to ground truth |
| Detects | Fabrication, contradiction, drift, missing traceability | Ambiguity, missing orientation, broken navigation, false confidence |
| Gate | `CONTEXT_ARTIFACT_GATE` | `CONTEXT_CONSUMER_GATE` |

A context document can be perfectly accurate and still fail to make a fresh agent
competent. Only the consumer test detects that.

## Detection Procedure

For each stage, in order:

1. Does the stage's output artifact exist?
2. Do **any** independent evaluations of that artifact exist? Collect **all** of
   them — do not stop at the first one found, or at the newest.
3. Resolve the current gate state from that set.

Step 2 is where detection most often goes wrong. A stage with two evaluations —
an early FAIL and a later PASS — is a normal, healthy history, not a
contradiction. A reader who finds only one of them, or who finds both and treats
them as irreconcilable, reaches a different answer than a reader who resolves
them properly.

Classify each stage:

| Artifact | Evaluations | Resolved result | Stage status |
|---|---|---|---|
| absent | — | — | `NOT_STARTED` |
| present | none | — | `UNVERIFIED` |
| present | one or more | FAIL | `FAILED` |
| present | one or more | PASS / PASS_WITH_LIMITATION | `VERIFIED` |
| present | one or more, latest is stale | any | `UNVERIFIED` |
| present | multiple, supersession unestablished | AMBIGUOUS | `AMBIGUOUS` |

An evaluation is **stale** when the artifact has been modified since the
evaluation was written, or when the evaluation names sections or identifiers that
the artifact no longer contains.

**`AMBIGUOUS` is not resumable.** It is not the same as `UNVERIFIED`, and it is
not repaired by re-running the stage — re-running simply adds a third evaluation
to an already-undetermined history. Stop, report both results and what evidence is
missing, and request human review.

Resolution rules, including what counts as supersession evidence:
`gate-model.md`, **Evaluation History vs Current Gate State**.

## Resume Rule

```
Resume at the earliest stage that is not VERIFIED.
```

Not the latest artifact present. The **earliest unverified** stage.

If a late-stage artifact exists over an unverified early stage, the late artifact
inherits the early stage's untrusted status. Repair upstream first, then
re-evaluate downstream — upstream repair may invalidate downstream content.

## Reporting Detected State

Before acting, report to the user:

```
Stage                      Artifact   Evals   Gate                   Status
Source Extraction          present    1       PASS                   VERIFIED
Requirements               present    1       PASS                   VERIFIED
Project Context            present    1       PASS                   VERIFIED
Context Consumer Test      present    2       PASS_WITH_LIMITATION   VERIFIED
Decision Inventory         present    1       PASS                   VERIFIED
Decision <id> Analysis     present    0       -                      UNVERIFIED  <- resume here
```

Where a stage shows more than one evaluation, expand it — the resolution is the
part a later reader cannot re-derive on their own:

```
Context Consumer Test — 2 evaluations
  <earlier evaluation>  FAIL
      superseded: evaluation contract defect corrected, per <later evaluation>
  <later evaluation>    PASS_WITH_LIMITATION  (<limitation>)
  Current Gate State:   PASS_WITH_LIMITATION
  Basis:                explicit reconciliation statement in <later evaluation>
```

Report `AMBIGUOUS` the same way, naming what evidence is absent, and stop there.

Then state which stage you will run and what it will produce.

## In-flight Decisions

Within the architecture decision loop, individual decisions have their own status.
An analysis drafted for a decision that has not been evaluated is `UNVERIFIED` —
it is a draft, and its recommendation carries no weight. Do not present an
unevaluated analysis to the human as if it were decision-ready.
