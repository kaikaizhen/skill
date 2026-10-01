# Context Templates

Two artifacts: a glossary and a project context document.

---

## Glossary

```markdown
# <Project> — Glossary

## TERM-001 <Term>

Definition: <what it means in this domain>

Source: <REQ / AC / EXT identifiers>

Important Distinction: <what it is NOT, and what it is commonly confused with>

Example: <a concrete instance, where it helps>

## TERM-002 <Term>

...
```

### Glossary rules

**Important Distinction carries most of the value.** Domain confusion
concentrates in near-synonyms:

- transient state vs persisted state
- shared data vs per-actor data
- an intent vs its committed effect
- a display state vs a stored state
- one actor's view of an entity vs the entity itself

A glossary that only defines terms permits conflation. A glossary that states the
contrast prevents it. Write the distinction for every term where a plausible
confusion exists.

**Source.** Every term cites requirement, criterion, or extraction identifiers
that exist. An evaluator verifies the citations resolve.

**Prohibited:** technology, storage, or structural terms the requirements do not
support. A glossary is domain vocabulary, not a technical dictionary.

---

## Project Context

```markdown
# <Project> — Project Context

## Document Role

This is a compressed orientation context derived from validated requirements.

It is not the requirement source of truth.

Authority order:

Original Source
-> Validated Source Extraction
-> Validated Requirements
-> Project Context

If this document conflicts with a requirement or upstream source, the upstream
artifact governs.

## Project Purpose

<What the system is and what it must provide, in a short paragraph.>

Source: <REQ identifiers>

## Primary Actors

- <Actor> — <responsibility boundary>. Source: <REQ identifiers>
- <Actor> — <responsibility boundary>. Source: <REQ identifiers>

## Core <Actor> Flow

<Actor>
-> <step>
-> <step>
-> <step>

Source: <REQ identifiers>

## Critical Domain Rules

### RULE-001 <Short name>

Statement: <one-sentence invariant>

Source: <REQ / TERM identifiers>

### RULE-002 <Short name>

...

## Important Distinctions

| Concept | Is | Is Not |
|---|---|---|
| <concept> | <what it is> | <what it is confused with> |

## Important Functional Areas

- <capability grouping>
- <capability grouping>

## Open Questions

| ID | Topic |
|---|---|
| OPEN-001 | <title> |
| OPEN-002 | <title> |

These are undecided. This document provides no answers, leanings, or likely
resolutions for any of them. Full detail: `<path to open questions>`.

## Detailed Knowledge References

| Need | Path |
|---|---|
| Full requirements and acceptance criteria | `<path>` |
| Full open questions | `<path>` |
| Domain glossary | `<path>` |
| Validated source extraction | `<path>` |
```

### Context rules

**Compression is the point.** The document must NOT contain every acceptance
criterion, full open question bodies, or full glossary definitions. It contains
what orients, plus pointers to what informs.

A context document that duplicates its downstream artifacts is not compression —
and it drifts from them, producing two versions of the same knowledge with only
one under evaluation.

**Critical Domain Rules** encode the invariants an agent must not violate even
when the immediate task does not mention them: actor isolation, state ownership,
persistence boundaries, transition legality. Each gets an identifier so that
downstream artifacts and the consumer evaluation can cite it.

**The Open Questions index provides no answers.** Not a suggested resolution, not
a leaning, not a "probably." The index tells an agent what is undecided; adding
an answer converts it into a source of fabricated requirements — and because it
sits in the orientation document, it propagates fastest.

**Detailed Knowledge References must point to canonical paths that exist.** This
section is what the consumer test's navigation phase exercises. Broken or
non-canonical references make compression unsafe, because the detail is then
unreachable from the orientation.

### Prohibited in this artifact

- technology, storage, contract, or structural decisions
- answers to open questions
- non-system material from the original source
- content that contradicts a validated requirement
- restating itself as requirement authority
