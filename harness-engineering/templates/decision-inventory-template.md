# Decision Inventory Template

```markdown
# <Project> — Architecture Decision Inventory

## Document Role

This document lists the currently open engineering decision points. It is not a
requirement, an architecture design, or an ADR. A decision becomes an accepted
architecture decision only after formal analysis and an explicit human decision.

This is a HISTORICAL artifact. It records what was discovered, when it was
discovered. It is not resynchronized as decisions are made — current status lives
in the derived architecture state document.

---

## Decision Summary

| ID | Decision | Category | Priority | Blocking | Status |
|---|---|---|---|---|---|
| DEC-001 | <title> | <category> | P0 | Yes | Unresolved |
| DEC-002 | <title> | <category> | P0 | Yes | Unresolved |

---

## Decisions

## DEC-001 <Decision Title>

Status:
Unresolved

Category:
<subject area>

Priority:
P0 | P1 | P2

Question:
<the decision question, phrased so that no option is favored by its wording>

### Why Decision Is Needed

<What is blocked or undetermined while this stays open.>

### Source

<REQ identifiers>

<OPEN identifiers>

<EXT identifiers>

### Known Constraints

- <what validated upstream already fixes about this decision>

### Known Options

- <option the upstream actually names>

<If upstream names none, state: None named upstream.>

### Affected Areas

- <what this decision governs>

### Dependencies

<DEC identifiers that must be settled first, or None>

### Blocking

Yes | No

### Decision Owner

<Human with AI Analysis | other>

## DEC-002 <Decision Title>

...
```

## Field Rules

**Question neutrality.** Phrase so that no option is favored by the wording.

```
Neutral:      Which persistence approach should be used?
Not neutral:  Should the standard persistence approach be used?
Not neutral:  Is a lightweight store sufficient here?
```

The second and third have already recommended. An evaluator checks this
dimension explicitly, because a leading question shapes every downstream stage.

**Known Options is not the option space.** It records only what upstream
artifacts actually name. It is not a pre-filtered candidate list and does not
bound what the analysis may consider. When upstream names no options, say so
rather than inventing a plausible set — inventing one here performs analysis in
the discovery stage, unevaluated.

**Source.** Every decision traces to a real upstream gap: an open question typed
`Engineering Decision Needed`, a requirement presenting unchosen options, or a
requirement whose realization is undetermined. A decision with no upstream
support is a fabricated decision.

**Open questions typed `Requirement Clarification` never appear here.** They go
back to the requirement owner. Converting one into an architecture decision lets
a technical stage invent product behavior.

**Dependencies.** Must be accurate and acyclic. They determine eligibility, and an
incorrect dependency either blocks an available decision or permits one that
presupposes an unmade choice.

**Status.** Set at discovery time and **not** updated as decisions are accepted.
A decision may read `Unresolved` here long after acceptance. See
`references/lessons-learned.md`, L-006.

## Prohibited in This Artifact

- option analysis, comparison, or scoring
- recommendations of any kind
- decisions the human has not made
- requirement clarifications recast as engineering decisions
- fabricated decisions with no upstream gap
- leading question phrasing
