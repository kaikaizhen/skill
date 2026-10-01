# Context Harness

Compress validated requirements into orientation knowledge a fresh agent can
actually use — then prove it works by testing a fresh agent on it.

```
Validated Requirements -> Glossary + Project Context
                       -> Context Artifact Evaluation -> CONTEXT_ARTIFACT_GATE
                       -> Fresh Agent Consumer Test
                       -> Context Consumer Evaluation -> CONTEXT_CONSUMER_GATE
```

Entry condition: `REQUIREMENT_GATE = PASS`.

## Why Two Validations

| | Artifact Evaluation | Consumer Evaluation |
|---|---|---|
| Asks | Is it correct? | Is it sufficient? |
| Method | Compare document to requirements | Test a fresh agent that has only the context |
| Catches | Fabrication, distortion, drift, broken citations | Ambiguity, missing orientation, failed navigation, false confidence |

These do not substitute for each other and must never be merged into one pass. A
document can be entirely accurate and still leave a fresh agent unable to act —
or, worse, confidently wrong. Only the consumer test surfaces that.

## Stage 1 — Glossary

Define the domain vocabulary, with emphasis on the distinctions that are easy to
conflate.

| Field | Purpose |
|---|---|
| Identifier | stable, unique, citable |
| Term | the name as used in the project |
| Definition | what it means in this domain |
| Source | requirement, criterion, and extraction identifiers |
| Important Distinction | what it is **not**, and what it is confused with |
| Example | a concrete instance, where it helps |

**The Important Distinction field carries most of the value.** Domain confusion
concentrates in near-synonyms: transient versus persisted state, shared versus
per-actor data, an intent versus its committed effect, a display state versus a
stored state. A glossary that only defines terms lets an agent conflate them. A
glossary that states the contrast prevents it.

The glossary introduces no technology, storage, or structural terms that the
requirements do not support.

## Stage 2 — Project Context

A compressed orientation document. Its job is to let an agent become competent
quickly and then **route** to the detail it needs — not to restate everything.

Required sections:

| Section | Content |
|---|---|
| Document Role | derived status and precedence order |
| Project Purpose | what the system is, with requirement citations |
| Primary Actors | each actor and its responsibility boundary |
| Core Flows | the main paths through the system, one per actor group |
| Critical Domain Rules | identified rules encoding the non-obvious invariants |
| Important Distinctions | the conflation risks, restated at context level |
| Functional Areas | the system's capability groupings |
| Open Questions Index | every open question by identifier and title — **no answers** |
| Detailed Knowledge References | canonical paths to requirements, open questions, glossary, extraction |

### Compression rule

The context document **must not** contain:

- every acceptance criterion
- full open question bodies
- full glossary definitions

It contains what orients, plus pointers to what informs. A context document that
duplicates its downstream artifacts is not compression, and it drifts from them.

### Open Questions Index

List every open question by identifier and title. Provide **no answers, no
leanings, no likely resolutions**. The index exists so an agent knows what is
undecided; adding a suggested answer converts the index into a source of
fabricated requirements.

### Critical Domain Rules

Each rule gets an identifier and states an invariant in one sentence, with
citations. These are the rules an agent must not violate even when nothing in the
immediate task mentions them — actor isolation, state ownership, persistence
boundaries, transition legality.

## Stage 3 — Context Artifact Evaluation

Independent. Ground truth is the validated requirements and open questions.

| Dimension | Question | Critical |
|---|---|---|
| Term traceability | Does every term cite existing requirements/criteria/extractions? | Yes |
| Distinction correctness | Are conflation-prone concepts correctly separated? | Yes |
| No technical decision | Are technology, storage, contract, and structure choices absent? | Yes |
| Purpose fidelity | Does the purpose match the requirements, free of non-system material? | Yes |
| Actor fidelity | Are actor boundaries as the requirements define them? | Yes |
| Flow fidelity | Do the flows match the requirements without invented steps? | Yes |
| Rule fidelity | Do the critical rules encode real requirement invariants? | Yes |
| Known/unknown integrity | Are known requirements not demoted to unknown, and unknowns not answered? | Yes |
| Open question index | Is every open question listed, correctly named, unanswered? | Yes |
| Compression | Is it genuinely compressed rather than a duplicate? | No |
| Reference correctness | Do the reference paths exist and point to canonical locations? | Yes |
| Authority declaration | Does it state precedence and defer to upstream? | No |
| Cross-document consistency | Do glossary and context agree? | Yes |
| Scope purity | Is non-system source material absent? | Yes |

### Gate

```
CONTEXT_ARTIFACT_GATE = PASS
```

## Stage 4 — Fresh Agent Consumer Test

A fresh agent, with **only** the context artifacts, answers questions about the
project. This measures whether the context transfers understanding.

### Isolation

**Prefer physical isolation over prompt-only restriction.** Copy the context
artifacts into a separate workspace and run the test agent there, with no path to
the rest of the repository.

A prompt that says "do not read the requirements file" is a request, not a
boundary. It cannot be verified after the fact, and it produces evidence whose
integrity rests on the tested agent's own report of its behavior.

If physical isolation is not achievable, the test may still run — but the
evaluation **must** record an `INTEGRITY_LIMITATION` naming exactly what could
not be verified. Never present a prompt-isolated test as an independently
verified one.

### Test structure

**Phase 1 — Closed-book understanding.** The agent reads only the context
artifacts and answers questions covering:

- project purpose
- each actor and its boundary
- each conflation-prone distinction
- each critical domain rule
- what persists and what does not
- which topics are undecided
- questions whose answers are *deliberately absent* from the context

That last category is the most informative test in the set. The correct answer is
"the context does not determine this." An agent that instead supplies a plausible
answer has revealed that the context invites fabrication — which is a context
defect, not merely an agent error.

**Phase 1 answer freeze.** Phase 1 answers are recorded and then frozen. They may
not be revised after any later phase. Without the freeze, phase 2 knowledge
retroactively improves phase 1 and the test measures nothing.

**Phase 2 — Navigation.** Give the agent a knowledge need. Using only the
context's reference section, it must locate the governing requirement, retrieve
its acceptance criteria, and confirm their traceability. This tests whether the
context routes correctly — the property that makes compression safe.

### Test outputs

The test produces its own output files. Declare them explicitly in advance as
allowed writes. See "Protected Inputs vs Allowed Outputs" below.

## Stage 5 — Context Consumer Evaluation

Independent. Compares the fresh agent's answers against the ground truth the
agent could not see.

### Per-question record

```
Result:              PASS | WARNING | FAIL
Critical:            Yes | No
Fresh Agent Answer:  <summary of what the agent said>
Ground Truth:        <what the requirements establish>
Evidence:            <requirement / rule / criterion identifiers>
Gap Classification:  <see below>
Problem:             <what went wrong, or None>
Recommended Action:  <how to fix the context, or None>
```

### Consumer gap classification

| Classification | Meaning | Fix |
|---|---|---|
| `CONSUMER_ERROR` | Context was sufficient; the agent misread it | No context change |
| `CONTEXT_MISSING` | Context omits knowledge the agent needed | Add it |
| `CONTEXT_AMBIGUOUS` | Context supports more than one reading | Disambiguate |
| `CONTEXT_CONTRADICTION` | Context contradicts itself or upstream | Repair |
| `CONTEXT_ROUTING_FAILURE` | Agent could not navigate to the detail | Fix references |
| `UPSTREAM_ISSUE` | The defect is in the requirements | Escalate upstream |

The `CONSUMER_ERROR` category is what keeps this evaluation honest in both
directions. Not every wrong answer is a context defect — and classifying agent
error as context error produces bloated context that over-corrects for one
agent's mistake.

### Test integrity record

The evaluation records integrity separately from correctness:

```
Phase 1 Knowledge Isolation:      PASS | FAIL | UNVERIFIED
Phase 1 Answer Freeze:            PASS | FAIL | UNVERIFIED
Restricted Files Read:            PASS | FAIL | UNVERIFIED
Protected Artifacts Modified:     PASS | FAIL | UNVERIFIED
Test Outputs Only:                PASS | FAIL
Independent Repository Baseline:  AVAILABLE | NOT_AVAILABLE
Integrity Result:                 PASS | PASS_WITH_LIMITATION | FAIL
```

`PASS_WITH_LIMITATION` requires naming the limitation. An unverifiable dimension
is `UNVERIFIED`, never `PASS`.

**Independent repository baseline.** Verifying that protected artifacts were not
modified requires a baseline the tested agent did not produce — a version control
diff, or checksums captured before the test. Where no such baseline exists, an
agent's own report about its own writes is the only available evidence, and that
is a limitation to record, not a verification.

### Protected Inputs vs Allowed Outputs

**The test's own outputs are not integrity violations.**

State the boundary explicitly before the test runs:

```
Protected Inputs      the canonical knowledge artifacts and source material;
                      readable per phase rules, never writable

Allowed Reads         phase 1: the context artifacts only
                      phase 2: additionally, whatever the context routes to

Allowed Writes        the declared test output paths, enumerated in full

Expected Outputs      the phase response file, the consolidated evidence file

Forbidden Artifacts   any write outside Allowed Writes; any modification of a
                      Protected Input
```

Integrity fails when a **protected input** is modified. It does not fail because
the test wrote the files the test was asked to produce.

An integrity rule phrased as "no other files may be modified" will flag the test's
own evidence as a violation, because the test's outputs are, literally, other
files. Enumerate allowed writes instead of prohibiting a vague remainder.

### Gate

```
CONTEXT_CONSUMER_GATE = PASS
```

Requires: zero critical failures, and an integrity result of `PASS` or
`PASS_WITH_LIMITATION` with the limitation stated.

The architecture decision harness may not begin until this gate is PASS. Context
that has not been consumer-tested is not verified context, however accurate it is.
