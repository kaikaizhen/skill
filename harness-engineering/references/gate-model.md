# Gate Model

A gate is the point at which an artifact stops being a draft and becomes usable
by downstream stages.

## The Gate Pattern

```
Artifact Generated
       |
       v
Independent Evaluation      <-- different agent/context from the generator
       |
   +---+---+
   |       |
 PASS    FAIL
   |       |
   |       v
   |   Artifact Revision
   |       |
   |       v
   |   Re-evaluation  ---> (loop)
   v
Promotion
```

Nothing may skip the middle box.

## What Makes an Evaluation Independent

An evaluation is independent when the evaluating pass:

- did not author the artifact under evaluation
- does not modify the artifact under evaluation
- reads the upstream ground truth directly rather than trusting the artifact's
  own summary of it
- records evidence, not just a verdict

The weakest acceptable form is a separate evaluation pass with an explicit
no-modification constraint. The strongest is a separate agent with a restricted
workspace. When the strong form is unavailable, record the limitation in the
evidence — see `lessons-learned.md`.

## Self Check Is Not a Gate

A generator may end its output with a self check. That self check:

- is a **drafting aid** for the generator
- is **evidence of intent**, not evidence of correctness
- **never** authorizes promotion

```
Self Check: PASS   ->   still UNVERIFIED
Independent Evaluation: PASS   ->   VERIFIED
```

An evaluator that finds `Self Check: PASS` on an artifact must ignore it and
perform the checks itself. If the self check claims PASS on a dimension the
evaluator finds FAIL, that discrepancy is itself worth recording.

## Result Vocabulary

Each validation dimension resolves to exactly one of:

| Result | Meaning |
|---|---|
| `PASS` | The dimension is satisfied, with cited evidence |
| `WARNING` | A non-blocking concern, or a verified limitation of the method |
| `FAIL` | The dimension is not satisfied |

The evaluation as a whole resolves to:

| Overall | Condition |
|---|---|
| `PASS` | Zero FAIL, zero critical failures |
| `PASS_WITH_LIMITATION` | Zero FAIL, but a method limitation prevented full verification. Must name the limitation. |
| `FAIL` | One or more FAIL, or one or more critical failures |

The gate line is the terminal statement of the evaluation:

```
<STAGE>_GATE = PASS
```

The gate is declared **by the evaluation**, never by the artifact.

That line records **the result of this evaluation run**. It is not a claim about
the stage's whole history. Where a stage has more than one evaluation, current
gate state is resolved across all of them — see **Evaluation History vs Current
Gate State** below.

`AMBIGUOUS` is **not** in this vocabulary. An evaluation always reaches a definite
result about what it examined; an evaluator that cannot verify a dimension marks
it `UNVERIFIED` and resolves overall to `PASS_WITH_LIMITATION` or `FAIL`.
`AMBIGUOUS` describes only a *resolved current gate state* across a history that
does not determine itself. No evaluation ever emits it.

## Critical Validations

Some validation dimensions are marked `Critical`. A FAIL on any critical
dimension forces overall FAIL regardless of how many other dimensions pass.

Critical dimensions are typically those where a defect silently propagates:

- fabrication (content with no upstream support)
- broken traceability (citation to a nonexistent upstream identifier)
- a preserved unknown that was quietly answered
- a boundary violation (a stage deciding something owned by another stage)
- an unauthorized modification of a protected input

## Gap Classification

Every non-PASS finding is classified so that it can be routed to the right owner.

| Classification | Meaning | Route to |
|---|---|---|
| `FABRICATION` | Content with no upstream support | Regenerate the artifact |
| `OMISSION` | Upstream content that should have been carried and was not | Regenerate the artifact |
| `DISTORTION` | Upstream content carried, but its meaning changed | Regenerate the artifact |
| `SCOPE_VIOLATION` | The artifact decided something outside its stage | Regenerate; route content to the correct stage |
| `TRACEABILITY_BREAK` | Citation to a nonexistent or mismatched upstream unit | Regenerate the artifact |
| `AMBIGUITY` | Content is correct but readable more than one way | Revise for precision |
| `UPSTREAM_ISSUE` | The defect is in the upstream artifact, not this one | Escalate; repair upstream |
| `INTEGRITY_LIMITATION` | The method could not verify a dimension | Record; do not silently pass |

Consumer evaluations add classifications specific to sufficiency; see
`context-harness.md`.

### Upstream Issues

An evaluator that discovers a defect in a **passed upstream artifact** must
report it as `UPSTREAM_ISSUE` and must not fix it in the artifact under
evaluation. Patching a downstream artifact to compensate for an upstream defect
hides the defect from every other consumer of that upstream artifact.

## FAIL Handling

On FAIL:

1. The **artifact** is revised. Never the evaluation.
2. Revision addresses the classified gaps, and only those, unless the fix
   surfaces further defects.
3. A **new** evaluation is run against the revised artifact.
4. The prior evaluation is retained as history.

Explicitly forbidden:

- editing an evaluation to turn FAIL into PASS
- narrowing a validation dimension so the artifact passes it
- deleting a failing dimension
- promoting on `PASS_WITH_LIMITATION` without stating the limitation to the human

## Evaluation History vs Current Gate State

A stage may accumulate **more than one** evaluation over its lifetime — because
the artifact was revised after a FAIL, or because the evaluation contract itself
was found defective and corrected.

These are two different questions, and conflating them is a known ambiguity:

```
Evaluation History   what was evaluated, when, under which contract, with what result
                     -> append-only, immutable, every entry retained

Current Gate State   whether this stage is passed RIGHT NOW
                     -> resolved from the history, never read off a single file
```

**A historical FAIL is not, by itself, a current gate FAIL.** It is the permanent
record that an evaluation run returned FAIL at a point in time. Whether the gate
is currently passed depends on what happened *after* it.

Equally: **a later PASS does not automatically clear an earlier FAIL.** Newer is
not authoritative. Resolution requires evidence, not chronology.

### Resolving Current Gate State

For a stage with more than one evaluation, resolve as follows:

1. **Collect** every evaluation that targets this stage. Do not stop at the first
   or the newest one found.
2. **Order** them by their own recorded evidence — evaluation identifiers,
   explicit previous-evaluation references, contract versions, repository
   history. Not by filename and not by filesystem timestamp.
3. For each earlier non-PASS result, ask: does a later evaluation **supersede or
   reconcile** it, under the Supersession Evidence Rule below?
4. Resolve:

| Condition | Current Gate State |
|---|---|
| Latest applicable evaluation is PASS, and every earlier non-PASS is superseded or reconciled with evidence | `PASS` |
| Latest applicable evaluation is PASS_WITH_LIMITATION, limitation named, earlier non-PASS results superseded or reconciled | `PASS_WITH_LIMITATION` |
| Latest applicable evaluation is FAIL | `FAIL` |
| An earlier non-PASS exists and supersession **cannot be established from evidence** | `AMBIGUOUS` |
| No evaluation exists | `UNVERIFIED` |

`AMBIGUOUS` is a real state, not a tie-break. It means the repository does not
determine the answer. Do not resolve it by judgment, by preferring the newer
file, or by reading the artifacts and forming an opinion about which evaluation
was probably right. **Stop and request human review**, reporting both results and
what evidence is missing.

### Supersession Evidence Rule

An evaluation supersedes or reconciles an earlier one only when at least one of
these is present and verifiable:

- an **explicit previous-evaluation reference** naming the earlier evaluation
- an explicit **Supersedes** field
- an **evaluation contract version** showing the later run used a corrected
  contract, together with a statement of what changed
- an explicit **reconciliation statement** — the later evaluation addresses the
  earlier result directly and says how it is resolved
- **repository or version-control evidence** establishing the order and the
  re-run
- equivalent documented authority evidence

Never infer supersession from any of these alone:

| Not sufficient | Why |
|---|---|
| Filename (`-v2`, `-final`, `-revised`) | Naming is a convention, not a claim about scope |
| A file simply existing | Existence has never implied authority anywhere in this skill |
| A newer modification timestamp | Timestamps change for unrelated reasons; a later file may evaluate a different artifact, or a narrower one |
| Ordering in a directory listing | Not evidence of anything |
| "The later one is more thorough" | An assessment, not evidence |

The later evaluation must also be **applicable**: it targets the same artifact or
stage, and its scope covers what the earlier one failed on. A later evaluation of
a *different* dimension does not supersede an earlier FAIL — it sits alongside it,
and the earlier FAIL still stands.

### The Contract-Defect Case

The case that produces the most disagreement between readers: an early evaluation
returns FAIL because the **evaluation contract** was defective — it was checking
the wrong thing — rather than because the artifact was defective.

When the contract is corrected and the stage re-evaluated:

- the original FAIL is **retained**, unmodified, as history
- the re-evaluation states which contract defect was corrected and what the
  corrected contract now checks
- the re-evaluation's result becomes the current gate state
- the earlier FAIL is marked superseded **by the later evaluation's own record**,
  never by editing the earlier document

Without that explicit statement in the later evaluation, two readers of the same
history will reasonably disagree: one sees a corrected process, the other sees an
unresolved contradiction. The statement is what makes the history determinate.

If the later evaluation does not carry it, the current gate state is `AMBIGUOUS`,
and the repair is a **new** reconciliation record — not an edit to either
existing evaluation.

### Reporting

Whenever a stage has more than one evaluation, report the resolution, not just
the conclusion:

```
Stage:                <stage>
Evaluations found:    <n>
  <evaluation>  ->  FAIL   (superseded: contract defect corrected, per <later evaluation>)
  <evaluation>  ->  PASS_WITH_LIMITATION  (<limitation>)
Current Gate State:   PASS_WITH_LIMITATION
Basis:                explicit reconciliation statement in <later evaluation>
```

A conclusion offered without its basis is exactly what leaves the next reader to
re-derive it — and to reach a different answer.

## Gate Evidence Requirements

A gate result is only usable if the evidence records:

- the target artifact (path)
- the ground truth consulted (paths)
- confirmation that the upstream gate was PASS
- each validation dimension with its result and cited evidence
- the counts of PASS / WARNING / FAIL and critical failures
- any upstream issues found
- the terminal gate line

A bare "PASS" with no evidence is not gate evidence.
