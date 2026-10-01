# Architecture State Template

A **derived index**, fully regenerated from all passed ADRs after each promotion.
Never hand-patched, never an authority.

```markdown
# <Project> — Current Architecture State

## Document Role

This document is a derived index of the current architecture decision state.

It is not a requirement, an ADR, a decision analysis, or a human decision. Formal
authority for an architecture decision remains the ADR that passed ADR_GATE. This
document exists so a downstream agent can quickly determine what is accepted,
what is unresolved, and where the architecture boundary lies.

## Source Authority

Precedence:

Validated Requirements
> Passed Accepted ADR
> Current Architecture State
> Validated Decision Analysis
> Decision Inventory
> Engineering inference

If this document conflicts with a passed ADR, the ADR governs and this document
is regenerated. If an ADR conflicts with a validated requirement, do not choose
between them — stop and report an upstream conflict.

## Active Architecture Authorities

| Decision ID | ADR | Decision | Accepted Option | ADR Gate | Status |
|---|---|---|---|---|---|
| DEC-0nn | ADR-0nn | <title> | <option> | PASS | Active |

## Active Architecture Rules

## ARCH-RULE-001

Source:
ADR-0nn

Rule:
<the constraint now in force, stated as a rule>

Scope:
<what work this rule governs>

## ARCH-RULE-002

...

## Unresolved Architecture Decisions

| Decision ID | Decision | Priority | Blocking | Status |
|---|---|---|---|---|
| DEC-0nn | <title> | P0 | Yes | Unresolved |

## Decision Status Rules

- **Accepted** — has both HUMAN_DECISION_GATE = PASS and ADR_GATE = PASS.
- **Unresolved** — no passed ADR exists.
- **Superseded** — only when a formal replacement ADR exists.

## Explicitly Not Decided

- <concern>
- <concern>

## Architecture Boundary

<Accepted decision> decides only <its scope>. It must not be used to infer that
<adjacent concerns> have been decided. Each of those becomes an active
architecture authority only when its own ADR has passed ADR_GATE.

## Next Decision Candidates

| Decision | Eligibility | Reason |
|---|---|---|
| DEC-0nn — <title> | Eligible for analysis | <priority, blocking status, dependencies satisfied> |
| DEC-0nn — <title> | Not yet eligible | <which dependency is unresolved> |

These are eligible candidates. This is not a selection of the next decision, and
the ordering is itself a choice for the decision owner.

## Promotion Evidence

Target Decision:
DEC-0nn

Target ADR:
ADR-0nn

ADR Evaluation:
`<path>`

ADR Gate:
PASS

Promotion Result:
PROMOTED

## Architecture State Self Check

CHECK-001: Does every active authority have both gates PASS?
CHECK-002: Is any decision listed active without a passed ADR?
CHECK-003: Does every architecture rule derive from a passed ADR's constraints?
CHECK-004: Are all still-open decisions listed with correct priority and dependencies?
CHECK-005: Does the boundary section correctly refuse over-reading?
CHECK-006: Are candidates eligible per real dependency status?
CHECK-007: Does the document avoid restating itself as requirement authority?
CHECK-008: Is every statement derivable from passed artifacts?
CHECK-009: Is the precedence order declared?
CHECK-010: Is the promotion recorded with its gate evidence?

Overall: PASS | FAIL

<Self check is a drafting aid, not a gate. ARCHITECTURE_AUTHORITY_GATE is
declared by the independent architecture state evaluation.>
```

## Critical Rules

**Full regeneration.** Rebuild from all passed ADRs after each promotion. Do not
hand-patch entries. A hand-patched state document diverges from its derivation and
becomes a second, unevaluated authority.

**Do not resynchronize the historical inventory.** A decision may read
`Unresolved` in the discovery inventory while reading `Accepted` here. That is the
design: the inventory records discovery at a point in time and stays attached to
the evaluation that validated it. See `references/lessons-learned.md`, L-006.

**Derivation purity.** Every statement in this document must be derivable from
passed artifacts. It introduces no constraint, no rule, and no status that a
passed ADR does not support. Anything not so derivable is fabricated authority in
the document downstream agents read first.

**The Architecture Boundary section is required**, and must be specific — naming
the concerns that must not be inferred, not offering a general caution. Without
it, an agent reasons from one accepted direction to a whole implied architecture,
and every step of that reasoning looks sound.

**Next Decision Candidates is a candidate list.** Label it as one in the document
itself. It reads naturally as a queue, which invites an agent to take the top
entry and proceed — but ordering decisions has consequences the decision owner
should weigh, since earlier decisions constrain later ones. See L-013.

**This document is never cited as the reason for a decision.** The reason is in
the ADR and the human decision record. This document says only *what* is decided,
never *why*.
