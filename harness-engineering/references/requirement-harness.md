# Requirement Harness

Turn a validated extraction into structured requirements, while preserving every
unknown as an explicit open question.

```
Validated Extraction -> Requirement Generation
                     -> Open Question Preservation
                     -> Requirement Evaluation
                     -> REQUIREMENT_GATE
```

Entry condition: `SOURCE_EXTRACTION_GATE = PASS`.

Ground truth for this stage is the **validated extraction**, not the original
source. The extraction has already been verified against the source; re-deriving
from the source here would bypass that verification and produce a second,
unevaluated reading.

## Stage 1 — Requirement Generation

### Requirement unit

| Field | Purpose |
|---|---|
| Identifier | stable, unique, citable; encodes the actor |
| Title | short behavioral name |
| Actor | who the requirement is about |
| Source | the extraction identifiers this derives from |
| Description | what the system must do |
| Rules | constraints that hold for this requirement |
| Acceptance Criteria | verifiable behaviors, individually identified |
| Dependencies | other requirements this relies on |
| Open Questions | open questions that touch this requirement |

Group requirements by actor. Split by capability, not by document layout —
one requirement per coherent capability, so that traceability and verification
stay meaningful.

### Acceptance criteria

An acceptance criterion describes **externally observable behavior of the running
system**. It is a child of exactly one requirement, cites its own extraction
support, and can be verified without reading source code.

Test each criterion:

- Can it be checked by observing the running system? If no, it is not an
  acceptance criterion.
- Does it describe an internal mechanism? If yes, it belongs to architecture or
  implementation, not here.
- Does it restate the requirement without adding verifiability? If yes, remove it.

**Engineering guidance produces no acceptance criteria.** Extractions typed
`SHOULD` or `OPTION` — a suggested technology, a set of unchosen approaches — are
recorded in a separate *Engineering Guidance* section. They keep their hedged
modality and they get no acceptance criteria, because there is no observable
system behavior to verify. Writing acceptance criteria for guidance is how a
suggestion silently becomes a requirement.

Separate the two sections explicitly:

```
## Requirements              <- product behavior, has acceptance criteria
## Engineering Guidance      <- SHOULD / OPTION extractions, no acceptance criteria
```

### Requirement boundaries

The requirement stage does not:

- select technologies, frameworks, databases, or protocols
- define entities, tables, schemas, or contracts
- specify components, layers, or file structure
- answer any preserved unknown
- add actors, states, permissions, or business rules with no extraction support

### Do not add "obviously missing" requirements

Search, filtering, audit trails, soft deletes, pagination sizes, error taxonomies,
and authentication flows are all things a real system usually needs. If the
extraction does not support them, they do not become requirements here. They
become open questions, or they stay absent.

## Stage 2 — Open Question Preservation

Every `UNKNOWN` extraction becomes exactly one open question. None may be
dropped, merged into vagueness, answered, or widened.

### Open question unit

| Field | Purpose |
|---|---|
| Identifier | stable, unique, citable |
| Title | the topic |
| Status | `Open` / `Resolved` |
| Type | see classification below |
| Related Requirements | which requirements this touches |
| Source | the extraction identifier |
| Known | what the source does establish |
| Unknown | what remains undefined |
| Impact | what downstream work this blocks or shapes |
| Do Not Assume | the specific assumptions forbidden here |

### Type classification

| Type | Meaning | Resolved by |
|---|---|---|
| `Requirement Clarification` | The answer changes what the system must do | the requirement owner |
| `Engineering Decision Needed` | The answer changes how it is built | architecture decision harness |

Classify as `Requirement Clarification` if the answer would change any of:

- user-visible behavior
- a business rule
- actor permissions or boundaries
- data lifecycle (including what happens to derived or personal records)
- required system behavior

An architecture agent may not resolve a `Requirement Clarification`. Doing so
would let a technical stage invent product behavior.

### The Do Not Assume field

This field is the operative guardrail. Write it as a concrete prohibition list,
not a general caution. It names the specific things a downstream agent must not
quietly choose — provider, model, framework, storage mechanism, protection scheme.

### Resolution rule

An open question moves to `Resolved` only when:

- the requirement owner clarifies it, and the requirement set is updated and
  re-evaluated; **or**
- a formal engineering decision is accepted through the architecture decision
  harness and reaches a passed ADR.

An open question is never resolved by a downstream artifact quietly assuming an
answer, nor by an agent noting that the answer is "standard practice."

## Stage 3 — Requirement Evaluation

Independent. Ground truth is the validated extraction and its evaluation.
Does not modify the requirements.

Confirm first that the upstream gate is PASS. State that confirmation in the
evidence.

### Validation dimensions

| Dimension | Question | Critical |
|---|---|---|
| Requirement traceability | Does every requirement cite existing extraction identifiers? | Yes |
| Criterion traceability | Does every acceptance criterion cite existing extractions and a real parent? | Yes |
| Coverage | Is every substantive extraction represented? | Yes |
| No fabrication | Were capabilities, actors, states, or rules added without support? | Yes |
| No premature design | Are entities, schemas, contracts, technologies, and structure absent? | Yes |
| Unknown conversion | Does every UNKNOWN map to exactly one open question, unanswered? | Yes |
| Open question completeness | Does each open question carry all required fields, with a correct Known/Unknown split? | Yes |
| Criterion verifiability | Is every criterion externally observable, with no guidance criteria present? | Yes |
| Actor boundaries | Are actor responsibilities and isolation preserved? | Yes |
| Internal consistency | Do any requirements, criteria, or open questions contradict each other? | Yes |
| Decomposition | Is the split by capability sound enough for traceability and verification? | No |
| Identifier integrity | Are all identifiers unique, and do children match their parents? | Yes |
| Known/unknown placement | Is anything known recorded as unknown, or vice versa? | Yes |
| Authority declaration | Does the document state its derived role and precedence? | No |

### Required summaries

The evaluation ends with two mappings that make the gate auditable:

- **Coverage summary** — extraction identifiers to the requirements that carry them
- **Open question summary** — extraction identifiers to open questions to affected
  requirements, plus an explicit statement that no unknown was wrongly resolved,
  omitted, or widened

### Gate

```
REQUIREMENT_GATE = PASS
```

The context harness may not begin until this gate is PASS.

## Common Failure Modes

| Failure | Why it happens | Detected by |
|---|---|---|
| Acceptance criteria written for engineering guidance | criteria feel mandatory for every requirement | Criterion verifiability |
| An unknown answered "sensibly" in passing | the gap is small and the answer is obvious | Unknown conversion |
| A known constraint filed as unknown | a part-defined topic reads as undefined | Known/unknown placement |
| Requirements added for standard features | domain instinct fills perceived gaps | No fabrication |
| Criteria describing internals | the writer already has an implementation in mind | No premature design |
| Actor isolation blurred | shared and per-actor state look similar | Actor boundaries |
