# Lessons Learned — Guardrail Principles

Every principle here was produced by an actual failure or near-failure during a
real harness execution. They are recorded as abstract guardrails; the originating
project's domain is deliberately absent.

---

## L-001 — Allowed test output is not an integrity violation

**What happened.** A fresh-agent isolation test was governed by an integrity rule
of the form *"no other project files may be modified."* The test produced the
output files it had been asked to produce. The integrity check then flagged those
outputs as unauthorized modifications and returned FAIL — even though no
protected artifact had been touched. A valid test result was invalidated by its
own evidence.

**Why it happened.** "Other files" is a negative-space rule. Its meaning depends
entirely on an unstated boundary between the artifacts under protection and the
artifacts the task is meant to create. The rule silently classified the task's
deliverables as violations.

**Principle.** Never define permissions by prohibiting a vague remainder. Declare
the boundary positively and completely:

```
Protected Inputs      what must not change
Allowed Reads         what may be read, per phase
Allowed Writes        the exact paths that may be written
Expected Outputs      what the task must produce
Forbidden Artifacts   what must never be produced
```

Integrity fails when a **protected input** changes. It never fails because the
task produced its declared outputs.

**Generalization.** This is not specific to tests. Every generator contract in
this skill uses the same positive enumeration for the same reason.

---

## L-002 — Prompt-only restriction is not isolation

**What happened.** A closed-book test's knowledge boundary was enforced by
instruction: the agent was told not to read certain files. Afterwards, the only
evidence that it had complied was the agent's own account of its behavior.

**Why it happened.** An instruction constrains intent, not capability. A boundary
that the constrained party also attests to is not independently verifiable.

**Principle.** When a reading boundary determines whether a result means
anything, enforce it structurally — a separate workspace containing only the
permitted inputs, with no path to the rest.

Where structural isolation is not available, the test may still run, but its
evaluation must record an explicit `INTEGRITY_LIMITATION` naming what could not
be verified. Mark the unverifiable dimension `UNVERIFIED`, never `PASS`.

**Corollary.** Do not describe a prompt-isolated result as independently
verified. An overstated integrity claim is more damaging than an acknowledged
limitation, because downstream stages will rely on it.

---

## L-003 — Verifying immutability requires an external baseline

**What happened.** An integrity check needed to establish that protected
artifacts were unmodified. The working directory was under no version control, so
no independent baseline existed. The check fell back to the acting agent's own
operation record — the same agent whose behavior was in question.

**Principle.** Immutability verification requires a baseline the verified party
did not produce: a version control diff, or checksums captured before the work
began.

Establish this **before** running any stage whose evidence depends on it. Where
absent, record `Independent Repository Baseline: NOT_AVAILABLE` and resolve the
integrity result to `PASS_WITH_LIMITATION` at best.

---

## L-004 — Naming gates late leaves earlier stages ambiguous

**What happened.** Early harness stages ended with a generic terminal result
line. Explicit, named gate identifiers were introduced only at later stages. The
earlier stages had genuinely passed, but their evidence did not say *which* gate
had passed — so a later agent had to infer the mapping between an evaluation
document and the stage it authorized.

**Principle.** Fix the gate vocabulary before the first stage runs. Every
evaluation ends with an explicit, named terminal line:

```
<STAGE>_GATE = PASS
```

Detection depends on this. An agent resuming a partially built repository scans
for gate lines; a generic "Overall Result: PASS" requires it to guess what was
authorized.

**Retrofit rule.** When adopting this skill on a repository with unnamed early
gates, do not edit the historical evaluations to insert gate lines — that breaks
the immutability rule. Record the artifact-to-gate mapping in the detection
report instead, and use named gates for everything from that point forward.

---

## L-005 — Duplicated artifacts split authority silently

**What happened.** The same knowledge artifact came to exist at more than one
path. The copies were identical at the time, so nothing failed. Nothing prevented
them from diverging later, and no evaluation covered the difference.

**Principle.** Each artifact has exactly one canonical location. Where duplicates
appear, determine which path downstream artifacts and evaluations cite, declare
it canonical, and remove or clearly mark the rest.

Divergence between copies produces the worst failure mode available: two agents
each read "the context," reach different conclusions, and both are consistent
with something on disk.

**Exception.** A labeled copy made as an isolated test input is not an authority
split, provided it is copied from the canonical artifact at test time and never
edited.

---

## L-006 — Historical artifacts must not be resynchronized

**What happened.** After a decision was accepted, the natural instinct was to
update its status in the historical discovery inventory. Doing so would have
detached the inventory from the evaluation that validated it — the evaluation
would then attest to content that had been overwritten, with nothing marking it
stale.

**Principle.** Separate the two roles:

```
Historical (never rewritten)  what was discovered, analyzed, decided, verified
Derived    (regenerated)      what is true right now
```

A decision may read `Unresolved` in the historical inventory long after it is
accepted. The current-state document is where the present status lives.

**Consequence.** Any agent reading a historical artifact must read the derived
current state alongside it. Historical status fields are not current status.

---

## L-007 — Partly-defined topics are neither known nor unknown

**What happened.** A source raised a topic and defined it partially: it
established that a certain state must exist and be preserved across a particular
transition, while leaving the state's representation and controls undefined.

The first extraction recorded the whole topic as `UNKNOWN` — losing a real
requirement. Correcting it introduced the opposite risk: recording the topic as
known would have fabricated a specification that the source never gave.

**Principle.** For every partly-defined topic, split explicitly:

```
Known:   what the source does establish
Unknown: what it leaves undefined
```

The known half becomes a requirement. The unknown half becomes an open question.
Both are recorded, and each evaluation checks both directions — nothing known
demoted to unknown, nothing unknown promoted to known.

**Detection heuristic.** A topic phrased as a single yes/no ("is this concern
defined or not?") is usually a partly-defined topic being forced into a binary.
Ask instead: what *exactly* does the source establish, and what *exactly* does it
leave open?

---

## L-008 — A recommendation is evidence, never a decision

**What happened.** An analysis produced a well-argued recommendation with stated
confidence. The path from "recommended" to "accepted" is short enough that
nothing structural prevented an agent from treating the recommendation as the
outcome — particularly when the human later agreed with it.

**Principle.** Encode the separation in the artifacts themselves:

- The analysis records `Human Decision: PENDING` as a required field.
- The human decision record marks the recommendation explicitly as *historical
  analysis evidence, not decision authority*.
- The decision record captures the human's own rationale, not the analysis's —
  even when they agree.
- Alignment is recorded as a fact ("accepted the recommendation" / "diverged from
  the recommendation"), never as a validation of the analysis.

Agreement is the dangerous case. When the human and the analysis reach the same
conclusion, the record must still show that the human decided — otherwise a later
reader cannot distinguish a decision from a default.

---

## L-009 — Accepting one decision must not imply the rest

**What happened.** Accepting a single architectural direction created immediate
pressure to treat adjacent, still-open questions as resolved by implication —
because a coherent architecture "obviously" follows from the accepted direction.

**Principle.** Every accepted decision record carries an explicit **Not Decided
by This ADR** list, enumerating the decisions it does not settle. The derived
current state carries a matching **Architecture Boundary** section refusing the
same inference.

State the negative space. Without it, one accepted decision silently resolves an
entire inventory through plausible reasoning, and no gate ever fires.

---

## L-010 — Guidance-level content must not acquire acceptance criteria

**What happened.** Source material contained hedged technical suggestions and
unchosen option sets. These were carried into the requirement set, where the
document's structure invited acceptance criteria for every entry. Criteria were
written for the guidance items — which converted suggestions into verifiable
mandates.

**Principle.** Separate product requirements from engineering guidance
structurally. Guidance retains its hedged modality and receives **no acceptance
criteria**, because there is no observable system behavior to verify.

If an item cannot be checked by observing the running system, it is not an
acceptance criterion.

**Detection.** Any acceptance criterion whose subject is a technology, a
framework, or an architectural form is almost certainly guidance that was
promoted by accident.

---

## L-011 — Evaluators must not repair what they evaluate

**Principle.** An evaluator reads, compares, validates, and reports. It does not
edit the artifact under evaluation.

An agent that fixes a defect and then declares its own fix PASS has produced no
evidence — the artifact and its verification have the same author and the same
blind spots. The defect classes an evaluator exists to catch are precisely those
the generator could not see.

**Corollary.** When an evaluator finds a defect in a passed **upstream** artifact,
it reports `UPSTREAM_ISSUE` and does not compensate in the artifact under
evaluation. Patching downstream to work around an upstream defect hides that
defect from every other consumer of the upstream artifact.

---

## L-012 — Self check is a drafting aid, not a gate

**Principle.** A generator's self check records intent. It carries no
verification weight and never authorizes promotion.

An evaluator that encounters `Self Check: PASS` ignores it and performs the checks
itself. Where the self check claims PASS on a dimension the evaluator finds FAIL,
that discrepancy is itself worth recording — it indicates the generator could not
see its own defect, which is exactly why the independent stage exists.

---

## L-013 — Eligibility is a candidate set, not a selection

**What happened.** A derived state document listed which decisions were eligible
for analysis next. The list reads naturally as a queue, which invites an agent to
take the top entry and proceed.

**Principle.** Label candidate lists explicitly as candidates, in the document
itself. Ordering decisions has consequences the decision owner should weigh —
earlier decisions constrain later ones, and the sequence is itself a choice.

Present the eligible set; let the human direct the order.

---

## L-014 — Absent expected inputs are recorded, not substituted

**What happened.** A stage was written expecting input at a particular location.
That location did not exist. The available material was at a different path and
was a different kind of artifact.

**Principle.** When an expected input is absent, record its absence explicitly in
the evidence, state what was used instead, and proceed against what actually
exists.

Never silently substitute a different artifact and describe it as the expected
one. The substitution is invisible to every downstream reader, and the evidence
then documents a process that did not occur.

---

## L-015 — An evaluation history needs its resolution written down

**What happened.** A stage accumulated two evaluations. An early integrity check
returned FAIL because the evaluation contract itself was defective — it was
checking the wrong thing (see L-001). The contract was corrected and the stage
re-evaluated, returning PASS_WITH_LIMITATION.

Two independent fresh sessions then read the same repository and reached
different conclusions. One resolved the history correctly: the later evaluation
addressed the earlier contract problem, so the current gate state was
PASS_WITH_LIMITATION. The other saw two evaluations with conflicting results and
reported an unresolved contradiction.

**Why it happened.** Both readings were defensible from what was on disk. The
correction was real, but the *link* between the two evaluations was not written
anywhere — a reader had to infer it by comparing the documents and reconstructing
what had happened between them. Inference is not reproducible across readers.

The skill also asked the wrong question during detection: whether *the*
evaluation passed, in the singular. That framing has no answer when a stage has
two.

**Principle.** Separate two things that look like one:

```
Evaluation History   append-only; every run retained, failures included
Current Gate State   resolved ACROSS the history, never read off one file
```

A historical FAIL is not automatically a current FAIL. A later PASS does not
automatically clear an earlier FAIL. Resolution requires evidence — an explicit
previous-evaluation reference, a Supersedes field, a contract version with a
statement of what changed, an explicit reconciliation statement, or version
control history. **Never filename, file existence, or a newer timestamp.**

Where that evidence is absent, the current gate state is `AMBIGUOUS`, and the
correct action is to stop and request human review — not to prefer the newer
file, and not to re-run the stage, which only adds a third result to an
already-undetermined history.

**The fix belongs in the newer document.** When a re-evaluation supersedes an
earlier result, it says so itself, and says why. The earlier FAIL is retained
unmodified. Repairing an ambiguous history means writing a *new* reconciliation
record, never editing either existing evaluation.

**Generalization.** Any append-only evidence chain has this failure mode. The
record of what happened does not, by itself, establish what is currently true —
and if the resolution is left implicit, each reader derives their own.
