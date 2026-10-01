# Open Question Template

```markdown
# <Project> — Open Questions

This document records what is currently undecided and what downstream agents must
not assume an answer to.

An open question may move to Resolved only when:

- the requirement owner clarifies it, and the requirement set is updated and
  re-evaluated; or
- a formal engineering decision is accepted and reaches a passed ADR.

No downstream artifact resolves an open question by assuming an answer, and no
agent resolves one by observing that the answer is standard practice.

---

## OPEN-001 <Topic>

Status: Open | Resolved

Type: Requirement Clarification | Engineering Decision Needed

Related Requirements: <REQ identifiers>

Source: <EXT identifier>

Known: <what the source and validated upstream DO establish about this topic>

Unknown: <what remains undefined>

Impact: <what downstream work this blocks or shapes>

Do Not Assume: <the specific assumptions forbidden here — named concretely>

---

## OPEN-002 <Topic>

...
```

## Type Classification

| Type | Meaning | Resolved by |
|---|---|---|
| `Requirement Clarification` | The answer changes what the system must do | the requirement owner |
| `Engineering Decision Needed` | The answer changes how it is built | architecture decision harness |

Classify as `Requirement Clarification` if the answer would change any of:

- user-visible behavior
- a business rule
- actor permissions or boundaries
- data lifecycle, including what happens to derived or per-actor records
- required system behavior

**An architecture agent may not resolve a `Requirement Clarification`.** Allowing
it lets a technical stage invent product behavior — which is precisely what this
typing exists to prevent.

When the type is genuinely unclear, classify as `Requirement Clarification`. The
cost of routing an engineering question to the requirement owner is a short
conversation. The cost of routing a product question to an architecture agent is
fabricated behavior that every downstream artifact inherits as fact.

## Known / Unknown Split

Required for every entry, and most important for partly-defined topics.

- **Known** carries forward into requirements as real, verified content.
- **Unknown** stays open.

Recording a partly-defined topic as wholly unknown loses a requirement.
Recording it as wholly known fabricates a specification. See
`references/lessons-learned.md`, L-007.

## Do Not Assume

This field is the operative guardrail — write it as a concrete prohibition list,
not a general caution.

Weak (unenforceable):

```
Do Not Assume: Don't make assumptions about this.
```

Strong (enforceable, and checkable by an evaluator):

```
Do Not Assume: Do not select a provider, a session or token mechanism, an
account model, a storage location, or any framework for this concern. Do not
infer one from any accepted decision about an adjacent concern.
```

Name the specific things a downstream agent must not quietly choose. An evaluator
can then check the downstream artifact against a concrete list.

## Resolution Record

When an open question is legitimately resolved, append rather than overwrite:

```markdown
Status: Resolved

Resolved By: <requirement clarification | ADR identifier>

Resolution Evidence: <path to the clarification record or the passed ADR>

Resolution Date: <date>
```

Retain the original `Known` / `Unknown` / `Do Not Assume` content. It records
what was open, and for how long — which is what makes the resolution auditable.
