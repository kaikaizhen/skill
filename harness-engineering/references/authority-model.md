# Authority Model

Who or what gets to be believed, and in what order.

## The Central Distinction

```
Artifact exists   !=   Artifact has authority
```

Every stage of the harness has an unpromoted form and a promoted form. They look
identical on disk. Only the evaluation evidence distinguishes them.

| Unpromoted | Promoted by |
|---|---|
| Generated Extraction | extraction evaluation PASS |
| Generated Requirement | requirement evaluation PASS |
| Generated Context | context artifact evaluation PASS **and** consumer evaluation PASS |
| AI Recommendation | an explicit human decision |
| Human Decision | ADR generated, ADR evaluation PASS |
| ADR | promotion into current architecture state, authority gate PASS |

Read that table as a chain of non-equivalences:

```
Generated Requirement   != Validated Requirement
Generated Context       != Trusted Context
AI Recommendation       != Architecture Decision
Human Decision          != Passed ADR Authority
ADR                     != Active Architecture Authority
```

Each `!=` is closed by exactly one thing: the corresponding evaluator plus a
PASS gate.

## Precedence Order

When two artifacts conflict, the higher one wins:

```
1. Original Source Material
2. Validated Source Extraction
3. Validated Requirements  (and preserved Open Questions)
4. Validated Project Context
5. Passed, Accepted ADR
6. Current Architecture State   (derived)
7. Validated Decision Analysis
8. Decision Inventory
9. Engineering inference        (lowest; never a substitute for the above)
```

Notes on this ordering:

- **Requirements outrank ADRs.** An ADR that contradicts a validated requirement
  is not a valid decision. Do not "resolve" it by reinterpreting the
  requirement — stop and report an upstream conflict to the human.
- **Current architecture state ranks below the ADRs it derives from.** If they
  disagree, the ADR is right and the state document is regenerated.
- **Decision analysis outranks the inventory** because the analysis was evaluated
  against a broader ground truth.
- **Engineering inference is last** and may never fill a gap that a preserved
  open question already marks as unresolved.

## Conflict Handling

When an agent detects a conflict between two artifacts:

1. **Stop.** Do not choose the more convenient one.
2. Identify each artifact's rank in the precedence order.
3. If the lower-ranked artifact is derived, regenerate it from the higher one.
4. If both are at authority rank and genuinely contradict — for example a passed
   ADR against a validated requirement — this is an **upstream conflict**.
   Report it to the human. Do not resolve it autonomously.

Never silently prefer one authority over another. A silent preference is
indistinguishable from a fabrication two stages later.

## Decision Ownership

Each decision point declares an owner. In the validated scope, architecture
decisions that change architecture authority are owned by the human, with AI
providing analysis.

| Role | May do | May never do |
|---|---|---|
| AI Analyst | enumerate options, evaluate against criteria, recommend, state confidence, list open issues | select the option, mark a decision accepted |
| Evaluator | verify the analysis is complete, traceable, unbiased, and free of premature design | change the recommendation, make the decision |
| Human Decision Owner | accept, reject, defer, or choose an unrecommended option | (nothing is withheld — this is the deciding authority) |

An AI recommendation is **historical analysis evidence**. It records what the
analysis concluded. It never becomes a decision through the passage of time,
through absence of objection, or through downstream artifacts citing it.

Record this explicitly in every decision artifact:

```
AI Recommendation: <option>     (analysis evidence only, not decision authority)
Human Decision:    PENDING | ACCEPT | REJECT | DEFER
```

## Promotion

Promotion is the act that gives an artifact authority. It requires:

1. The artifact exists in its canonical location.
2. An independent evaluation of that artifact exists.
3. That evaluation records PASS (or PASS_WITH_LIMITATION with the limitation
   stated and accepted).
4. The upstream gate for the stage is PASS.
5. For architecture decisions: a recorded human decision precedes the ADR.

Promotion produces:

- gate evidence naming the artifact and the result
- for architecture decisions, a regenerated current architecture state, which is
  itself evaluated

Promotion is never implicit. An artifact does not become authoritative because
downstream artifacts started citing it.

## Authority Declaration in Artifacts

Every derived artifact states its own place in the chain, near the top:

```
## Document Role

This document is <what it is>, derived from <upstream>.

It is not the source of truth.

Authority order:
  Original Source -> Validated Extraction -> Validated Requirements -> This Document

If this document conflicts with an upstream artifact, the upstream artifact governs.
```

This makes the precedence order legible to any agent that opens the file in
isolation — which is the normal case, not the exception.
