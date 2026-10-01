# Evaluator Contract Template

Every evaluation step declares this contract before it runs.

An evaluator **reads, compares, validates, and reports**. It does not edit.

---

## Evaluator

Stage:
`<lifecycle stage being evaluated>`

Gate Declared:
`<STAGE>_GATE`

---

## Evaluation Metadata

Record this block at the head of every evaluation. It is what lets a later reader
resolve current gate state from an evaluation history without guessing.

```
Evaluation ID:              <stable, unique identifier for this evaluation run>
Target Artifact:            <path>
Target Artifact Version:    <commit, hash, or dated revision marker — or UNVERSIONED>
Evaluation Contract Version: <version of the contract this run applied>
Previous Evaluation:        <evaluation ID / path of the prior run on this stage, or None>
Supersedes Evaluation:      <evaluation ID this run supersedes, or None>
Supersession Basis:         <why — required whenever Supersedes is not None>
Gate Result:                <STAGE>_GATE = PASS | PASS_WITH_LIMITATION | FAIL
```

**This is a forward-looking contract improvement.** Evaluations written before
this block existed do not carry these fields, and their absence is not a defect
in those evaluations. Never backfill them into a historical evaluation — that
edits immutable evidence. Resolve older histories from whatever evidence they do
carry, and record `AMBIGUOUS` when they carry none.

### When this run supersedes an earlier one

If `Supersedes Evaluation` is set, the evaluation must also carry an explicit
reconciliation statement in its body:

```
## Supersession and Reconciliation

Superseded Evaluation:
<evaluation ID / path>

Prior Result:
FAIL | PASS_WITH_LIMITATION

Reason for Re-evaluation:
<artifact revised after FAIL | evaluation contract defect corrected | other>

What Changed:
<if the artifact was revised: which gaps were addressed>
<if the contract was defective: what it checked incorrectly, and what the
 corrected contract checks instead>

Scope Applicability:
<confirmation that this run covers everything the prior run failed on>

Effect on Prior Result:
The prior evaluation is retained unmodified as history. Its result stands as the
result of that run. Current gate state is determined by this evaluation.
```

The prior evaluation is **not** edited. The statement lives here, in the newer
document, and points backward. See `references/gate-model.md`,
**The Contract-Defect Case**.

---

## Ground Truth

The artifacts this evaluation compares against. These are the authority, not the
target artifact's own account of them.

- `<path>` — `<what it establishes>`

Upstream Gate Confirmation:
`<GATE_NAME> = PASS`, evidenced at `<path>`

State this confirmation explicitly in the evaluation output. An evaluation run
against unverified ground truth carries no more trust than its ground truth does.

---

## Target Artifact

- `<path>`

If the target spans multiple documents, list all of them. An evaluation that
names one document but validates two has ambiguous scope.

---

## Validation Dimensions

One row per dimension. Every dimension gets an identifier, a question, and a
criticality mark.

| ID | Dimension | Question | Critical |
|---|---|---|---|
| VAL-001 | `<name>` | `<the question this check answers>` | Yes / No |
| VAL-002 | | | |

Dimensions are fixed **before** the evaluation runs. Adding, narrowing, or
removing a dimension during evaluation to accommodate the artifact invalidates
the gate.

---

## Critical Validations

List the dimension identifiers whose failure forces overall FAIL regardless of
other results.

- `VAL-00x` — `<why a defect here propagates silently>`

Typically: fabrication, broken traceability, an answered unknown, a stage
boundary violation, an unauthorized modification.

---

## Per-Dimension Record

Each dimension is recorded in this form:

```
## VAL-00x

Result:
PASS | WARNING | FAIL

Critical:
Yes | No

Evidence:
<the specific identifiers, sections, and upstream content examined, and what
about them supports this verdict>

Problem:
<what is wrong, or None>

Gap Classification:
<see below, or None>

Related Items:
<identifiers touched by this check>

Recommended Action:
<how to fix the artifact, or None>
```

**Evidence standard.** Evidence names specific identifiers and specific upstream
content. A verdict whose evidence cites nothing has not been evaluated.

---

## Gap Classification

Every non-PASS finding is classified so it routes to the right owner.

| Classification | Meaning |
|---|---|
| `FABRICATION` | Content with no upstream support |
| `OMISSION` | Upstream content that should have been carried, and was not |
| `DISTORTION` | Upstream content carried, but its meaning changed |
| `SCOPE_VIOLATION` | The artifact decided something outside its stage |
| `TRACEABILITY_BREAK` | Citation to a nonexistent or mismatched upstream unit |
| `AMBIGUITY` | Correct, but readable more than one way |
| `UPSTREAM_ISSUE` | The defect is upstream, not in this artifact |
| `INTEGRITY_LIMITATION` | The method could not verify this dimension |

Extend with stage-specific classifications where the stage needs them (the
consumer evaluation adds sufficiency classifications — see
`references/context-harness.md`).

---

## Upstream Issues Found

```
## Upstream Issues Found

<UPSTREAM_ISSUE findings, or None>
```

Report defects found in passed upstream artifacts. Do **not** compensate for them
in the target artifact. Patching downstream hides the defect from every other
consumer of that upstream artifact.

---

## Evaluation Summary

```
## Evaluation Summary

PASS:              <n>
WARNING:           <n>
FAIL:              <n>
Critical Failures: <n>

Overall Result:
PASS | PASS_WITH_LIMITATION | FAIL
```

`PASS_WITH_LIMITATION` requires naming the limitation explicitly. A dimension the
method could not verify is `UNVERIFIED`, never `PASS`.

Add any stage-specific summaries the gate requires — coverage mappings, open
question mappings, integrity records, promotion readiness blocks.

---

## Gate Rule

```
Overall PASS                 <- zero FAIL, zero critical failures
Overall PASS_WITH_LIMITATION <- zero FAIL, method limitation named
Overall FAIL                 <- any FAIL, or any critical failure
```

Terminal line, stated by the evaluation and nowhere else:

```
<STAGE>_GATE = PASS
```

The gate is declared by the evaluation. An artifact never declares its own gate.

---

## No Modification Rule

This evaluator:

- **may read** the target artifact and all ground truth
- **may write** only its own evaluation document, at `<path>`
- **must not modify** the target artifact under any circumstance
- **must not modify** any ground truth artifact
- **must not modify** any prior evaluation

On FAIL, the evaluator reports classified gaps and recommended actions. A
separate revision pass fixes the artifact, and a **new** evaluation is then run.
The failing evaluation is retained as history.

The gate line this evaluation declares is **the result of this run**. It is not a
claim about the stage's whole history. Where earlier evaluations exist, current
gate state is resolved across all of them under the Supersession Evidence Rule.

Explicitly forbidden:

- editing an evaluation to turn FAIL into PASS
- narrowing a dimension so the artifact passes it
- deleting a failing dimension
- fixing the artifact and then declaring the fix PASS — an artifact and its
  verification with the same author share the same blind spots
- deleting a historical FAIL because a later PASS exists
- backfilling evaluation metadata into a historical evaluation that never had it
- claiming supersession of an earlier evaluation without recording the basis
