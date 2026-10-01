# Decision Analysis Template

This artifact analyzes and recommends. **It does not decide.**

```markdown
# DEC-0nn — Decision Analysis

## Analysis Metadata

Decision ID:
DEC-0nn

Decision:
<title>

Status:
Analysis

Decision Status:
Unresolved

Decision Owner:
<Human with AI Analysis>

Analysis Status:
IN_PROGRESS | READY_FOR_HUMAN_DECISION

## 1. Decision Question

<restated neutrally from the inventory>

## 2. Why This Decision Matters

<what it governs, what it blocks, what it constrains downstream>

## 3. Source Constraints

| Constraint | Source | Implication |
|---|---|---|
| <what upstream fixes> | <REQ / EXT / OPEN identifiers> | <what it rules in or out> |

## 4. Existing Accepted Architecture Constraints

| Rule | Source ADR | Impact on This Decision |
|---|---|---|
| <ARCH-RULE identifier and statement> | <ADR identifier> | <how it constrains the option space> |

<If none: None. No architecture decision has been accepted yet.>

## 5. Dependencies

Dependency:
<DEC identifiers, or None>

Status:
<Accepted / Unresolved, per dependency>

Impact on Analysis:
<whether this analysis can proceed meaningfully, and under what constraint>

## 6. Candidate Options

## Option A — <name>

### Description

<what this option is>

### Origin

<Named upstream at <identifier> | Added by analysis, justified by <reason>>

## Option B — <name>

...

## 7. Evaluation Criteria

State the criteria BEFORE analyzing options.

| Criterion | What it measures |
|---|---|
| Requirement Fit | Does it satisfy the validated requirements? |
| Implementation Complexity | Effort and coordination cost for this scope |
| Maintainability | Cost of change over time |
| Testability | How verifiable the resulting system is |
| Operational Complexity | Deployment, running, and diagnosing cost |
| Extensibility | Cost of accommodating plausible future requirements |
| Risk | What could go wrong, and how visibly |
| Reversibility | Cost of changing this decision later |
| <decision-specific criterion> | <...> |

## 8. Option Analysis

## Option A — <name>

### Requirement Fit
<assessment, citing requirement identifiers>

### Implementation Complexity
<assessment>

### Maintainability
<assessment>

### Testability
<assessment>

### Operational Complexity
<assessment>

### Extensibility
<assessment>

### Risk
<assessment>

### Reversibility
<assessment>

### <decision-specific criterion>
<assessment>

### Main Advantages
- <...>

### Main Disadvantages
- <...>

### Requirement Concerns
<any requirement this option strains, or None>

## Option B — <name>

<every criterion, again — no option is assessed on a subset>

## 9. Comparison Matrix

| Criterion | Option A | Option B | Option C |
|---|---|---|---|
| Requirement Fit | | | |
| ... | | | |

## 10. Trade-off Summary

<What is genuinely being traded. Not a restatement of the matrix — the shape of
the choice.>

## 11. Project-fit Analysis

<Fit against THIS project's validated scope: its actual requirements, its actual
open questions, its actual accepted constraints. Not general industry preference.>

## 12. AI Recommendation

Recommended Option:
<option>

Confidence:
High | Medium | Low

Why:
<reasoning, tied to the criteria and the project-fit analysis>

This recommendation is analysis evidence. It is not a decision and carries no
authority.

## 13. Consequences if Recommended

If the human accepts <option>:

### Positive Consequences
- <...>

### Negative Consequences
- <...>

### Future Constraints
- <what this would constrain later>
- Accepting this option must not be read as deciding <adjacent open decisions>.

## 14. Rejected-by-Analysis Options

<Options that violate a hard constraint, each with the constraint NAMED.>

<If none: None. Options not recommended remain viable; they are not rejected.>

## 15. Open Issues

| Issue | Type | Source | Blocking |
|---|---|---|---|
| <issue> | Requirement Clarification / Engineering Decision Needed | <OPEN identifier> | Yes / No — <why> |

## 16. Human Decision

Decision:
PENDING

Selected Option:
PENDING

Decision Reason:
PENDING

Accepted By:
PENDING

Decision Date:
PENDING

## 17. Next Step

Human Decision Required

## Analysis Self Check

CHECK-001: Does the analysis address the inventory's question, unchanged?
CHECK-002: Are all upstream-named options present?
CHECK-003: Were criteria stated before options were assessed?
CHECK-004: Is every option assessed against every criterion?
CHECK-005: Are source constraints cited to real upstream identifiers?
CHECK-006: Are accepted architecture constraints honored?
CHECK-007: Is component / schema / endpoint design absent?
CHECK-008: Is every rejection tied to a named hard constraint?
CHECK-009: Is confidence consistent with the evidence and open issues?
CHECK-010: Is Human Decision recorded as PENDING throughout?

Overall: PASS | FAIL

<Self check is a drafting aid, not a gate.>
```

## Critical Rules

**Rejected vs not recommended.** A viable option that loses on trade-offs is
**not recommended**. It is not rejected. Recording it as rejected removes a real
choice from the human by presenting it as already eliminated. Reserve rejection
for options that violate a named hard constraint.

**Confidence honesty.** Low confidence is useful information for the decision
owner. Inflating confidence to appear decisive corrupts the very input the human
is deciding on.

**Direction, not realization.** The analysis decides direction. It does not design
components, services, entities, schemas, endpoints, or file structure — unless the
decision under analysis is itself at that level.

**Human Decision stays PENDING.** In this artifact, always. The decision is
recorded in a separate artifact authored on the human's explicit answer.
