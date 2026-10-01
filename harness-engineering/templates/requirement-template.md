# Requirement Template

```markdown
# <Project> — Requirements

## Document Role

This document contains structured project requirements derived from the validated
source extraction.

It is not the original source of truth.

Authority order:

Original Source
-> Validated Source Extraction
-> Requirements

If this document conflicts with an upstream artifact, the upstream artifact governs.

---

## REQ-<ACTOR>-001 <Short Behavioral Title>

Actor: <System | the actor this requirement is about>

Source: <EXT identifiers>

Description: <what the system must do>

Rules:

- <constraint that holds for this requirement>

Acceptance Criteria:

### AC-<ACTOR>-001-01

<An externally observable behavior of the running system.>

Source: <EXT identifiers>

### AC-<ACTOR>-001-02

<...>

Source: <EXT identifiers>

Dependencies: <REQ identifiers, or None>

Open Questions: <OPEN identifiers, or None>

---

## Engineering Guidance

Extractions typed SHOULD or OPTION are recorded here. They retain their hedged
modality and receive NO acceptance criteria, because they describe no observable
system behavior.

### REQ-SYSTEM-0nn <Guidance Title>

Actor: System

Source: <EXT identifiers>

Description: <the suggestion or option set, at its original strength>

Nature: Suggestion | Unchosen option set | Illustrative reference

Rules:

- This is guidance, not a selection. Nothing here is a decided technology,
  architecture, or approach.

Dependencies: <REQ identifiers, or None>

Open Questions: <OPEN identifiers, or None>
```

## Field Rules

**Identifier.** Encodes the actor and is stable forever. Acceptance criterion
identifiers encode their parent requirement.

**Actor.** Requirements group by actor. `System` covers cross-actor behavior and
system-level properties.

**Source.** Every requirement cites extraction identifiers that exist. Every
acceptance criterion cites its own extraction support — not merely its parent's.

**Rules.** Constraints that hold for this requirement. They are not acceptance
criteria and are not separately verified; they inform interpretation.

**Dependencies.** Other requirements this relies on. Keeps the set acyclic and
makes ordering visible.

**Open Questions.** Every open question that touches this requirement, by
identifier. This is the link that keeps unknowns visible to anyone reading the
requirement in isolation.

## Acceptance Criterion Test

Before writing one, check all three:

1. Can it be verified by observing the running system? If no — it is not an
   acceptance criterion.
2. Does it describe an internal mechanism? If yes — it belongs to architecture or
   implementation.
3. Does it restate the requirement without adding verifiability? If yes — remove it.

A criterion whose subject is a technology, framework, or architectural form is
almost certainly guidance promoted by accident. See
`references/lessons-learned.md`, L-010.

## Prohibited in This Artifact

- technology, framework, database, or protocol selections
- entities, tables, schemas, contracts
- components, layers, file structure
- answers to any preserved open question
- actors, states, permissions, or business rules with no extraction support
- acceptance criteria attached to engineering guidance
- "obviously missing" features the extraction does not support — search,
  filtering, audit trails, soft deletes, error taxonomies, authentication flows.
  If unsupported, they become open questions or stay absent.
