# ADR Template

The formal record of an accepted architecture decision. Generated only after
`HUMAN_DECISION_GATE = PASS`.

```markdown
# ADR-0nn — <Decision Title>

## Status

Accepted | Superseded

---

## Decision Metadata

ADR ID:
ADR-0nn

Decision ID:
DEC-0nn

Decision Date:
<date>

Accepted By:
<attribution>

Decision Authority:
Human

---

## Context

<Why this decision was required, drawn from validated upstream artifacts. What
the requirements establish, and what they leave undetermined.>

## Decision

We will use:

<the accepted option, stated plainly>

## Decision Rationale

### Human Rationale

<The human's own reason, carried from the human decision record.>

### Supporting Analysis

<What the evaluated analysis found in favor of this option. This is supporting
evidence for the human decision; it does not replace human authority.>

## Requirement Drivers

| Source | Relevance |
|---|---|
| <REQ identifier> | <why this requirement drove the decision> |

## Considered Options

### Option A — <name>

Summary:
<fair summary of what the analysis found, including its strengths>

### Option B — <name>

Summary:
<...>

## Selected Option

Selected:
<option>

Decision Basis:
Human Decision

AI Recommendation Alignment:
Accepted AI Recommendation | Diverged from AI Recommendation

## Consequences

### Positive
- <...>

### Negative
- <...>

### Constraints Introduced
- <constraint now in force, stated so it can become an architecture rule>

## Not Decided by This ADR

This ADR does not decide:

- <DEC identifier> — <title>
- <DEC identifier> — <title>

## Dependencies

<ADR identifiers this relies on, or None>

## Affected Areas

- <what this decision governs>

## Implementation Guidance

<Direction only. No controller, service, entity, schema, endpoint, or project
structure design.>

## Supersession Rule

Supersedes:
<ADR identifier, or None>

Superseded By:
<ADR identifier, or None>

## Traceability

Decision Inventory:
`<path>` — <DEC identifier>

Decision Analysis:
`<path>`

Decision Analysis Evaluation:
`<path>`

Human Decision:
`<path>`

## ADR Self Check

CHECK-001: Does the ADR record the option the human actually selected?
CHECK-002: Is the human's rationale preserved as the primary rationale?
CHECK-003: Is decision authority attributed to the human?
CHECK-004: Do the requirement drivers cite real requirements that hold?
CHECK-005: Does the decision contradict any validated requirement?
CHECK-006: Are considered options represented as the analysis found them?
CHECK-007: Does "Not Decided" correctly list every still-unresolved decision?
CHECK-008: Is implementation guidance directional only?
CHECK-009: Are all traceability paths present and correct?
CHECK-010: Does the ADR avoid asserting its own gate result?

Overall: PASS | FAIL

<Self check is a drafting aid, not a gate.>
```

## Critical Rules

**"Not Decided by This ADR" is load-bearing.** Accepting one architectural
direction creates strong pressure to treat adjacent questions as settled by
implication — a coherent architecture appears to follow from the accepted
direction. Enumerating what remains open is what prevents one decision from
silently resolving an entire inventory through plausible reasoning, with no gate
ever firing. See `references/lessons-learned.md`, L-009.

**Considered options are summarized fairly.** Including their strengths. An ADR
that portrays the unselected options as obviously inferior misrepresents the
analysis and makes a future reconsideration harder than it should be.

**The ADR does not declare its own gate.** No `ADR_GATE = PASS` line appears in
this artifact. Only the independent ADR evaluation declares that. An artifact
asserting its own verification is a critical evaluation failure.

**Implementation guidance is directional.** It states the direction subsequent
work should follow. It does not design components, services, entities, schemas,
endpoints, or project structure — unless the decision itself was at that level.

**Status is `Accepted` because a human accepted it**, not because the ADR passed
evaluation. Evaluation verifies that the ADR faithfully records the decision;
acceptance came from the human.

## Supersession

Changing an accepted decision requires a **new** ADR through the full loop: new
analysis, new evaluation, new human decision, new ADR, new evaluation, promotion,
state rebuild.

The superseded ADR's `Status` becomes `Superseded` with a pointer to its
replacement. Its content is **not** rewritten — it remains the record of what was
decided and why, at the time it was decided. This status change is the one
permitted edit to a passed ADR.
