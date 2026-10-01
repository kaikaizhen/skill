# Source Extraction Template

```markdown
# <Project> — Source Extraction

Source: `<canonical path>` (`<extent — pages, sections, length>`)

<Scope statement: what this extraction covers, and what material in the source is
deliberately excluded as non-system content.>

## Source Notes

<Material present in the source that is NOT a requirement of the system:
process, evaluation criteria, commercial terms, logistics, author instructions.
Recorded here so an evaluator can confirm it did not leak into the extractions.>

## Project Requirement Extractions

## EXT-001

Type: PROJECT_GOAL | MUST | SHOULD | OPTION | DOMAIN | CONSTRAINT | UNKNOWN

Category: <subject area>

Source: <precise location — page, section, heading, quoted phrase>

Original Meaning: <what the source says, close to its own wording>

Normalized Statement: <the same content, disambiguated for downstream use>

Interpretation Required: No | Yes

Notes: <qualifications, adjacent source wording, tensions, or —>

## EXT-002

...
```

## Field Rules

**Type.** Preserve the source's own modality. A recommendation stays `SHOULD`. An
enumerated set of possibilities stays as multiple `OPTION` entries with no
selection. Strengthening modality during normalization is the most common
extraction defect.

**Source.** Precise enough for an evaluator to re-find the passage independently.
A page number alone is usually not enough.

**Original Meaning vs Normalized Statement.** Keep both. Their difference is the
evidence an evaluator uses to detect drift. Collapsing them into one field removes
the only artifact that would show normalization went too far.

**Interpretation Required.** `Yes` whenever normalization required a judgment
call. This flags exactly the entries an evaluator should scrutinize first.

**Notes.** Use for source wording that qualifies the statement, for tension with
another passage, and for observations that a term appears without being defined.

## UNKNOWN Entries

For a topic the source raises but does not resolve:

```markdown
## EXT-0nn

Type: UNKNOWN

Category: <subject area>

Source: <where the source raises the topic>

Original Meaning: <what the source says about it>

Normalized Statement: <the topic, stated as undefined>

Known: <what the source DOES establish about this topic>

Unknown: <what remains undefined>

Interpretation Required: No

Notes: <why this cannot be resolved from the source>
```

The `Known` / `Unknown` split is required for every partly-defined topic. A topic
recorded as wholly unknown loses a real requirement; a topic recorded as wholly
known fabricates a specification. See `references/lessons-learned.md`, L-007.

## Prohibited in This Artifact

- entities, tables, schemas
- endpoints, contracts, payload shapes
- layers, components, file structure
- technology selections (a suggested technology is a `SHOULD` about a suggestion)
- actors, states, or business rules the source does not support
- answers to any `UNKNOWN`
- non-system source material inside the requirement extractions
