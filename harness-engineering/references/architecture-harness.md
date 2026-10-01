# Architecture Decision Harness

Discover the decisions a project must make, analyze them without making them, put
each to the human decision owner, and promote the accepted ones into architecture
authority.

```
Validated Context -> Decision Discovery -> Inventory Evaluation
                  -> ARCHITECTURE_DECISION_INVENTORY_GATE
                  -> [ ARCHITECTURE_DECISION_LOOP ]
```

Entry condition: `CONTEXT_CONSUMER_GATE = PASS`.

## Stage 1 — Architecture Decision Discovery

Enumerate the open engineering decision points. Discovery **finds** decisions; it
does not analyze, rank by preference, or resolve them.

Sources of decision points:

- open questions typed `Engineering Decision Needed`
- requirements that present unchosen options
- requirements whose realization is undetermined
- boundaries between subsystems that the requirements imply but do not specify

**Open questions typed `Requirement Clarification` do not become architecture
decisions.** They go back to the requirement owner. Converting one into an
architecture decision lets a technical stage invent product behavior — the exact
failure the open-question typing exists to prevent.

### Decision unit

| Field | Purpose |
|---|---|
| Identifier | stable, unique, citable |
| Title | the decision, named neutrally |
| Status | `Unresolved` / `Accepted` / `Superseded` |
| Category | subject area |
| Priority | relative urgency |
| Question | the question, phrased without implying an answer |
| Why Decision Is Needed | what is blocked while it is open |
| Source | requirement, extraction, and open question identifiers |
| Known Constraints | what upstream already fixes |
| Known Options | options the upstream names, if any — not an exhaustive design space |
| Affected Areas | what the decision governs |
| Dependencies | decisions that must be settled first |
| Blocking | whether downstream work is blocked |
| Decision Owner | who decides |

### Neutral phrasing

Write the question so that no option is favored by its wording. "Which
persistence approach should be used?" is neutral. "Should we use the standard
persistence approach?" is not — it has already recommended.

### Known Options is not the option space

`Known Options` records only what upstream artifacts actually name. It is not a
pre-filtered candidate list and it does not bound what the analysis may consider.
The analysis stage may add options with justification.

## Stage 2 — Decision Inventory Evaluation

Independent. Ground truth is the validated requirements, open questions, and
context.

| Dimension | Question | Critical |
|---|---|---|
| Coverage | Is every engineering-decision open question represented? | Yes |
| No requirement smuggling | Are requirement clarifications excluded? | Yes |
| Traceability | Does every decision cite existing upstream identifiers? | Yes |
| Neutrality | Is every question phrased without implying an answer? | Yes |
| No premature analysis | Is the inventory free of option analysis and recommendation? | Yes |
| Constraint correctness | Do the known constraints match upstream? | Yes |
| Dependency correctness | Are inter-decision dependencies accurate and acyclic? | Yes |
| No fabricated decisions | Is every decision backed by a real upstream gap? | Yes |
| Identifier integrity | Are identifiers unique and consistently referenced? | Yes |
| Ownership | Does every decision declare an owner? | Yes |

### Gate

```
ARCHITECTURE_DECISION_INVENTORY_GATE = PASS
```

---

## ARCHITECTURE_DECISION_LOOP

Run once per decision. Never batch multiple decisions through a single human gate.

```
 1. Select an eligible unresolved decision
 2. Check its dependencies are satisfied
 3. Generate candidate option analysis
 4. Evaluate the analysis                -> DECISION_ANALYSIS_GATE
 5. STOP for human decision
 6. Record the explicit human decision    -> HUMAN_DECISION_GATE
 7. Generate the ADR
 8. Evaluate the ADR                      -> ADR_GATE
 9. Promote the passed ADR
10. Rebuild current architecture state
11. Evaluate current architecture state   -> ARCHITECTURE_AUTHORITY_GATE
12. Continue with the next eligible decision
```

### Step 1 — Eligibility

A decision is eligible for analysis when it is `Unresolved` and every decision it
depends on has been accepted through a passed ADR.

Eligibility lists are **candidate sets, not selections**. Presenting the eligible
set is correct; choosing which to analyze next without asking is not, when the
ordering has consequences the human should weigh.

### Step 2 — Dependencies

If a dependency is unresolved, the analysis may proceed only if it can do so
without presupposing the dependency's outcome — and it must state that
constraint. If the analysis cannot be meaningful without the dependency, defer
the decision.

### Step 3 — Decision Analysis

The analysis presents options fairly and recommends. **It does not decide.**

Required sections:

| Section | Content |
|---|---|
| Analysis Metadata | decision identifier, status, owner, analysis status |
| Decision Question | restated neutrally |
| Why This Decision Matters | what it governs and blocks |
| Source Constraints | what upstream requirements fix, with citations |
| Existing Accepted Architecture Constraints | rules already in force from passed ADRs |
| Dependencies | each dependency, its status, its impact on the analysis |
| Candidate Options | each option with a description and its origin |
| Evaluation Criteria | the criteria, stated before the options are scored |
| Option Analysis | each option against every criterion |
| Comparison Matrix | side-by-side |
| Trade-off Summary | what is genuinely being traded |
| Project-fit Analysis | fit against *this* project's validated scope |
| AI Recommendation | recommended option, confidence, and why |
| Consequences if Recommended | positive, negative, and future constraints |
| Rejected-by-Analysis Options | options that fail a hard constraint — with the constraint named |
| Open Issues | unresolved matters, typed and marked blocking or not |
| Human Decision | `PENDING` |
| Next Step | `Human Decision Required` |

Minimum criteria set — extend per decision, never reduce:

```
Requirement Fit         Complexity          Maintainability
Testability             Operational Complexity   Extensibility
Risk                    Reversibility
```

### Analysis boundaries

The analysis stage decides **direction**, not realization. It does not design
components, services, entities, schemas, endpoints, or file structure — unless
the decision under analysis is itself at that level.

State evaluation criteria **before** analyzing options. Criteria derived after
the fact tend to describe the preferred option.

### Rejected vs not recommended

Keep these apart:

- **Rejected by analysis** — the option violates a hard constraint. Name the
  constraint.
- **Not recommended** — the option is viable; the trade-offs favor another for
  the current scope.

A viable option is never recorded as rejected. Doing so removes a real choice
from the human by presenting it as already eliminated.

### Confidence

State confidence honestly. Low confidence is useful information for the decision
owner. Inflating it to appear decisive corrupts the input the human is deciding on.

### Step 4 — Analysis Evaluation

Independent. Verifies the analysis is complete, traceable, fair, and free of
premature design and of a concealed decision.

| Dimension | Question | Critical |
|---|---|---|
| Question fidelity | Does the analysis address the inventory's question? | Yes |
| Constraint traceability | Do the source constraints cite real upstream identifiers? | Yes |
| Accepted-constraint respect | Does it honor rules from passed ADRs? | Yes |
| Option completeness | Are the upstream-named options all present? | Yes |
| Criteria adequacy | Are the minimum criteria covered, stated before scoring? | Yes |
| Analysis fairness | Is each option assessed against every criterion without bias? | Yes |
| No premature design | Is component/schema/endpoint design absent? | Yes |
| No unauthorized decision | Does the analysis stop at recommendation? | Yes |
| Rejection validity | Is every rejection tied to a named hard constraint? | Yes |
| Confidence honesty | Is confidence consistent with the evidence and open issues? | No |
| Open issue typing | Are open issues correctly typed and marked blocking or not? | Yes |
| Human decision pending | Is the human decision recorded as PENDING? | Yes |

```
DECISION_ANALYSIS_GATE = PASS
```

### Step 5 — STOP

**Hard stop.** Present to the human:

- the decision question
- the candidate options with their trade-offs
- the AI recommendation and its confidence
- the open issues
- what accepting each option would constrain going forward

Then wait. Do not continue the loop on an unanswered decision.

Never:

- treat the recommendation as accepted by default
- infer acceptance from silence, from a general instruction to proceed, or from
  the recommendation's strength
- generate an ADR for a decision the human has not answered

### Step 6 — Record the Human Decision

A separate artifact, authored on the human's explicit answer.

| Field | Content |
|---|---|
| Decision Metadata | identifier, title, status, authority, date |
| Decision Question | restated |
| Analysis Evidence | analysis path, evaluation path, analysis gate result |
| AI Recommendation | recorded, explicitly marked as historical evidence only |
| Human Decision | `ACCEPT` / `REJECT` / `DEFER`, selected option, reason, attribution, date |
| Recommendation Alignment | accepted / diverged from the recommendation |
| Decision Consequences | positive, negative, future constraints |
| Affected Decisions | other decisions this changes |
| Gate Result | `HUMAN_DECISION_GATE = PASS` |

The human's reason is recorded in the human's terms. Do not substitute the
analysis's reasoning for the human's stated rationale — even when they agree.
The record must show what the deciding authority actually weighed.

**Divergence is normal.** When the human chooses against the recommendation,
record it plainly as a divergence, without argument or re-litigation. The
recommendation was advice.

`HUMAN_DECISION_GATE = PASS` records that an explicit, attributed human decision
exists — not that anyone agrees it was correct.

### Step 7 — ADR Generation

The formal record of the accepted decision. Sections:

| Section | Content |
|---|---|
| Status | `Accepted` / `Superseded` |
| Decision Metadata | ADR identifier, decision identifier, date, accepted by, authority |
| Context | why this decision was required, from validated upstream |
| Decision | the accepted option, stated plainly |
| Decision Rationale | the human rationale first; supporting analysis second, marked as support |
| Requirement Drivers | which requirements drove this, and how |
| Considered Options | every analyzed option, summarized fairly |
| Selected Option | the choice, its basis, and its alignment with the recommendation |
| Consequences | positive, negative, constraints introduced |
| Not Decided by This ADR | explicit list of decisions this does **not** settle |
| Dependencies | ADRs this relies on |
| Affected Areas | what it governs |
| Implementation Guidance | direction only — no component or schema design |
| Supersession Rule | supersedes / superseded by |
| Traceability | paths to inventory, analysis, analysis evaluation, human decision |

**The "Not Decided by This ADR" section is load-bearing.** Accepting one
architectural direction creates strong pressure to treat adjacent questions as
settled by implication. Enumerating what remains open is what prevents a single
decision from silently resolving the rest of the inventory.

The ADR does not claim its own gate has passed. Only its evaluation can declare
that.

### Step 8 — ADR Evaluation

| Dimension | Question | Critical |
|---|---|---|
| Human decision match | Does the ADR record the option the human actually selected? | Yes |
| Rationale fidelity | Is the human's rationale preserved as the primary rationale? | Yes |
| Authority correctness | Is decision authority attributed to the human? | Yes |
| Requirement traceability | Do the drivers cite real requirements and hold? | Yes |
| No requirement contradiction | Does the decision contradict any validated requirement? | Yes |
| Option fidelity | Are considered options represented as the analysis found them? | Yes |
| Scope containment | Does "Not Decided" correctly exclude unresolved decisions? | Yes |
| No premature design | Is implementation guidance directional only? | Yes |
| Consequence accuracy | Are consequences supported by the analysis and decision? | Yes |
| Traceability completeness | Do all cited paths exist and match? | Yes |
| Gate honesty | Does the ADR avoid asserting its own gate result? | Yes |

The evaluation ends with an **Architecture Authority Readiness** block:

```
Human Decision Gate:                 PASS
ADR Content Valid:                   Yes
Critical Gaps:                       0
Ready to Promote to Architecture Authority:  Yes

ADR_GATE = PASS
```

### Step 9 — Promotion

The passed ADR becomes an active architecture authority. Record the promotion
evidence: the decision, the ADR, the evaluation path, the gate result, and the
promotion result.

### Step 10 — Rebuild Current Architecture State

**Fully regenerate** from all passed ADRs. Do not hand-patch.

| Section | Content |
|---|---|
| Document Role | derived index; not requirement, ADR, analysis, or human decision |
| Source Authority | the precedence order, and what to do on conflict |
| Active Architecture Authorities | each accepted decision, its ADR, accepted option, gate, status |
| Active Architecture Rules | identified constraints in force, each citing its ADR and scope |
| Unresolved Architecture Decisions | still-open decisions with priority and blocking status |
| Decision Status Rules | what accepted / unresolved / superseded require |
| Explicitly Not Decided | plain list of what is not settled |
| Architecture Boundary | what the accepted decisions may **not** be read to imply |
| Next Decision Candidates | eligible decisions with the reason for eligibility |
| Promotion Evidence | what was promoted in this cycle |

**Do not update the historical inventory to match.** The inventory records
discovery at its point in time and remains attached to the evaluation that
validated it. A decision may read `Unresolved` there while reading `Accepted` in
the current state. That is the design, not a defect. See
`artifact-model.md`.

**The Architecture Boundary section** states explicitly that an accepted decision
must not be used to infer that related decisions are settled. Without it, a
downstream agent reasons from one accepted direction to a whole implied
architecture.

**Next Decision Candidates is a candidate list**, not a selection. Say so in the
document.

### Step 11 — Architecture State Evaluation

| Dimension | Question | Critical |
|---|---|---|
| Authority accuracy | Does every active authority have both human decision and ADR gates PASS? | Yes |
| No unpromoted authority | Is any decision listed active without a passed ADR? | Yes |
| Rule derivation | Does every architecture rule derive from a passed ADR's constraints? | Yes |
| Unresolved accuracy | Are all still-open decisions listed, with correct priority and dependencies? | Yes |
| Boundary correctness | Does the boundary section correctly refuse over-reading? | Yes |
| Eligibility correctness | Are candidates eligible per real dependency status? | Yes |
| No requirement replacement | Does the state document avoid restating itself as requirement authority? | Yes |
| Derivation purity | Is every statement derivable from passed artifacts? | Yes |
| Precedence declaration | Does it state the precedence order and defer to ADRs? | Yes |
| Promotion evidence | Is the promotion recorded with its gate evidence? | Yes |

```
ARCHITECTURE_AUTHORITY_GATE = PASS
```

### Step 12 — Continue

Return to step 1. Report the updated state and the eligible candidate set, and
let the human direct which decision comes next.

## Supersession

Changing an accepted decision requires a **new** ADR that supersedes the old one,
through the full loop: new analysis, new evaluation, new human decision, new ADR,
new evaluation, promotion, state rebuild.

The superseded ADR's status changes to `Superseded` with a pointer to its
replacement. Its content is not rewritten — it remains the record of what was
decided and why, at the time it was decided.
