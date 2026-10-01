# Source Harness

Turn raw source material into an atomic, traceable, evaluated extraction.

```
Source Intake -> Source Extraction -> Source Extraction Evaluation -> SOURCE_EXTRACTION_GATE
```

## Stage 1 — Source Intake

Establish what the source material actually is before reading it for content.

Record:

- every source document, its canonical path, and its extent (page count, length)
- the source's role: is it the specification, background, or an example?
- whether the source mixes the subject system with unrelated material
- reachable vs unreachable sources

**The mixed-source problem.** Source documents frequently contain material about
something other than the system being built — process notes, evaluation criteria,
commercial terms, meeting logistics, author instructions. This material is *in
the source* but is not a requirement of the system.

Segregate it at intake. Record it as source notes, outside the requirement
extraction. An evaluator will check that none of it leaked into the requirement
set.

**Do not invent sources.** If the intake expects a directory or document that
does not exist, record its absence and proceed against what exists. Never
silently substitute a different document and describe it as the expected one.

## Stage 2 — Source Extraction

Decompose the source into atomic, individually identified statements.

### Extraction unit

One extraction = one atomic statement. Each carries:

| Field | Purpose |
|---|---|
| Identifier | stable, unique, citable |
| Type | see classification below |
| Category | subject area |
| Source Location | precise enough to re-find: page, section, heading |
| Original Meaning | what the source says, close to its own wording |
| Normalized Statement | the same content, disambiguated for downstream use |
| Interpretation Required | Yes/No — whether normalization required a judgment call |
| Notes | qualifications, adjacent source wording, tensions |

The pair of *Original Meaning* and *Normalized Statement* is what makes the
extraction auditable. An evaluator compares the normalized form against the
original to detect drift. Collapsing them into one field removes the evidence
that drift would show up in.

### Type classification

| Type | Meaning |
|---|---|
| `PROJECT_GOAL` | overall purpose of the system |
| `MUST` | the source states this as required |
| `SHOULD` | the source suggests, recommends, or prefers this |
| `OPTION` | the source presents this as one of several possibilities, none chosen |
| `DOMAIN` | actors, entities, ownership, and relationships |
| `CONSTRAINT` | a stated boundary or limit |
| `UNKNOWN` | the source raises the topic but does not define it |

**Modality preservation is critical.** A recommendation is not a requirement. An
enumerated set of options is not a selection. If the source lists three possible
approaches without choosing, the extraction records three `OPTION` entries and
records no choice — and the evaluator checks that no option was silently
promoted to a decision.

### The UNKNOWN type

`UNKNOWN` is a first-class extraction, not a gap in the extraction. It records
that the source *raises* a topic and *does not resolve* it.

Split precisely:

```
Known:   what the source does establish about this topic
Unknown: what remains undefined
```

This split matters more than it looks. A topic is frequently part-defined: the
source may require that some state be preserved across a navigation without
defining its representation. The requirement to preserve is **known**; the
representation is **unknown**. Recording the whole topic as unknown loses a real
requirement; recording the whole topic as known fabricates a specification.

### Extraction boundaries

The extraction may not introduce:

- entities, tables, or schemas
- endpoints, contracts, or payload shapes
- layers, components, or code structure
- technology selections
- actors, states, or business rules the source does not support

If the source names a technology as a suggestion, that is a `SHOULD` about a
suggestion — not a selection.

## Stage 3 — Source Extraction Evaluation

Independent. Reads the original source directly. Does not modify the extraction.

**Ground truth:** the original source material.
**Target:** the extraction document.

### Validation dimensions

| Dimension | Question | Critical |
|---|---|---|
| Traceability | Does every extraction trace to a locatable place in the source? | Yes |
| No fabrication | Was anything added that the source does not support? | Yes |
| Modality preservation | Are MUST / SHOULD / OPTION faithful to the source's own strength? | Yes |
| Domain fidelity | Are actors, ownership, and state transitions as the source describes? | Yes |
| No premature design | Are entities, schemas, endpoints, layers, and technologies absent? | Yes |
| Unknown preservation | Is every undefined topic recorded as UNKNOWN rather than answered? | Yes |
| Scope separation | Is non-system source material excluded from the requirement extractions? | Yes |
| Coverage | Are the source's substantive requirements all represented? | Yes |

### Evidence standard

Each dimension records the specific extraction identifiers examined and what in
the source supports the verdict. "Looks correct" is not evidence. A dimension
whose evidence cites no identifiers has not been evaluated.

### Gate

```
SOURCE_EXTRACTION_GATE = PASS
```

Declared by the evaluation when zero FAIL and zero critical failures.

On FAIL: revise the extraction against the classified gaps, then run a new
evaluation. The requirement harness may not begin until this gate is PASS.

## Common Failure Modes

| Failure | Why it happens | Detected by |
|---|---|---|
| A suggested technology becomes a decided one | normalization strengthens hedged language | Modality preservation |
| Options collapse into one recommendation | the extractor forms a preference while reading | Modality preservation |
| Process/meta material enters the requirement set | it appears in the same document | Scope separation |
| A part-defined topic is recorded as fully unknown | the unknown half dominates the reading | Unknown preservation |
| A part-defined topic is recorded as fully known | the known half is extrapolated to fill the rest | No fabrication |
| Source location cited loosely | speed | Traceability |
