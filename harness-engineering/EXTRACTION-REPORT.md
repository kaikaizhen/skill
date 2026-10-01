# Harness Engineering Skill — Extraction Report

Skill: `harness-engineering`
Version: `0.1`
Status: `Experimental`
Extraction Date: 2026-08-25

---

## Extraction Method

The source repository's `.harness/prompts/` directory exists but is **empty** —
the harness prompts were supplied conversationally and were never persisted.

The workflow was therefore reconstructed from the **executed artifacts**
themselves rather than from the prompts that produced them. This turned out to be
the better source: the artifacts record what the process actually did, including
the places where it was corrected mid-execution. A prompt collection would have
recorded what the process was originally intended to do.

Evidence read, in full or in structural detail:

- source extraction and its evaluation
- requirements, open questions, and the requirement evaluation
- glossary, project context, and the context evaluation
- the fresh-agent consumer test's isolated workspace, its response artifact, its
  evaluation, and its integrity clarification
- decision inventory and its evaluation
- two decision analyses (one evaluated and accepted, one drafted and unevaluated)
- the human decision record
- the ADR and its evaluation
- the current architecture state and its evaluation

Gate lines were located by scanning terminal evaluation results across all
evidence.

---

## Source Workflows Studied

### Source Harness — validated

Source intake → extraction → independent extraction evaluation → gate.

Evidence: an extraction of ~42 atomic units with a two-field original/normalized
structure, evaluated across 8 dimensions with per-dimension identifier-level
evidence. Terminal result PASS.

Gate evidence form: `Overall Result: PASS` (unnamed — see Lesson L-004).

### Requirement Harness — validated

Validated extraction → requirements + open questions → independent evaluation →
gate.

Evidence: 15 requirements, 37 acceptance criteria, 7 open questions, evaluated
across 14 dimensions, with a full coverage mapping and a full extraction→open
question→requirement mapping. Terminal result PASS.

Notable: the evaluation records that 5 acceptance criteria attached to engineering
guidance were **removed** during revision — a real FAIL→revise→re-evaluate cycle
that produced Lesson L-010.

Gate evidence form: `Overall Result: PASS` (unnamed).

### Context Harness — validated

Requirements → glossary + project context → artifact evaluation → gate → fresh
agent consumer test → consumer evaluation → gate.

Evidence: 12 glossary terms, a context document with 5 identified critical domain
rules and an answer-free open question index; a 14-dimension artifact evaluation;
an isolated test workspace containing copies of only the permitted inputs; a
two-phase closed-book test with a frozen phase 1; a 10-test consumer evaluation
with a separate integrity record.

Gate evidence: `CONTEXT_CONSUMER_GATE = PASS`, integrity
`PASS_WITH_LIMITATION`.

This stage produced the richest lessons — L-001, L-002, L-003.

### Architecture Decision Harness — validated

Discovery → inventory evaluation → gate → analysis → analysis evaluation → gate →
human decision → gate → ADR → ADR evaluation → gate → promotion → state rebuild →
state evaluation → gate.

Evidence: an 8-decision inventory evaluated across 10 dimensions; a 17-section
decision analysis with criteria stated before scoring and `Human Decision:
PENDING` throughout; a 520-line analysis evaluation; a human decision record
carrying the human's own rationale plus an explicit note that the AI
recommendation is historical evidence only; an ADR with a populated "Not Decided
by This ADR" section; a 489-line ADR evaluation ending in an authority-readiness
block; a derived architecture state document with an explicit architecture
boundary section.

Gate evidence: `ARCHITECTURE_DECISION_INVENTORY_GATE`, `DECISION_ANALYSIS_GATE`,
`HUMAN_DECISION_GATE`, `ADR_GATE`, `ARCHITECTURE_AUTHORITY_GATE` — all PASS, all
explicitly named.

---

## Validated Patterns Extracted

| Pattern | Where it lives in the skill |
|---|---|
| **A** — Generate → Evaluate → Gate → Promote | `references/gate-model.md` |
| **B** — AI recommendation ≠ human accepted decision | `references/authority-model.md`, L-008 |
| **C** — Analysis PASS → human decision → recorded decision → ADR → ADR evaluation → promotion | `references/architecture-harness.md` |
| **D** — Historical artifact vs derived current state | `references/artifact-model.md`, L-006 |
| **E** — Prompt-only guardrails do not substitute for environment isolation | L-002, L-003 |
| **F** — Positive permission enumeration replaces vague prohibition | L-001, both contract templates |

Additional patterns extracted beyond the six named in the extraction brief:

| Pattern | Origin in evidence |
|---|---|
| Two distinct context validations (artifact vs consumer) that must not merge | the context harness ran both, with different ground truths and different gates |
| Original meaning + normalized statement as drift evidence | the extraction's two-field structure, which is what its evaluation compared against |
| Known/Unknown split for partly-defined topics | a real mid-execution correction, visible in both the extraction and requirement evaluations |
| Engineering guidance receives no acceptance criteria | a real revision — 5 criteria removed and re-evaluated |
| "Not Decided by This ADR" as an explicit negative-space section | present and populated in the executed ADR |
| Architecture boundary section refusing over-inference | present in the executed architecture state document |
| Eligibility lists labeled as candidates, not selections | the executed state document says this in its own words |
| Self check present but explicitly non-authoritative | every generator artifact carries one; every gate came from an evaluator |
| Upstream issue reporting without downstream compensation | an `Upstream Issues Found` section in every evaluation |
| Upstream gate confirmation stated at the head of each evaluation | every downstream evaluation opens by confirming the prior gate |

---

## Project-specific Content Excluded

The following were read and deliberately **not** carried into the skill:

| Excluded | Kind |
|---|---|
| The project's domain entity, its actors, and its state model | domain knowledge |
| All requirement, criterion, extraction, term, rule, open question, and decision identifiers and their content | project artifacts |
| The 7 specific open questions and their subjects | project artifacts |
| The 8 specific architecture decision points | project artifacts |
| The presentation-architecture option set and the option the human accepted | decision content |
| Every technology named anywhere in the source or decisions | decision content |
| The source document, its subject, and its non-system content | source material |
| The two large pre-existing architecture guideline documents in the repository (not harness outputs; not part of any evaluated stage) | out of scope |
| The specific integrity-clarification incident's file paths and session details | incident detail — the principle was kept, in L-001 |

Verification performed: a full-text scan of all 21 skill files for the source
project's name, its domain vocabulary, its identifier prefixes with numbers, its
accepted option, and the technologies it considered. No matches.

Where a lesson required a concrete example, it is stated abstractly — "a certain
state must be preserved across a particular transition" rather than the actual
state and transition.

---

## Lessons Incorporated

15 guardrail principles in `references/lessons-learned.md` (L-015 was added
post-extraction — see **Post-extraction Amendments**). Those grounded in a
documented failure or correction visible in the evidence:

| ID | Origin |
|---|---|
| L-001 | An integrity check returned FAIL because the test's own declared output file was counted as an unauthorized modification. A dedicated clarification artifact exists recording this, and the subsequent consumer evaluation explicitly restates the corrected boundary. **This is the single most instructive failure in the repository.** |
| L-002 | Phase-1 isolation was enforced partly by instruction; the consumer evaluation marks the corresponding integrity dimension `UNVERIFIED` rather than PASS. |
| L-003 | No version control baseline existed, so protected-artifact immutability could not be independently verified. Recorded as `Independent Repository Baseline: NOT_AVAILABLE`, resolving integrity to `PASS_WITH_LIMITATION`. |
| L-004 | The first three gates were recorded as an unnamed generic terminal result; named gate identifiers appear only from the consumer gate onward. |
| L-005 | The same context artifact exists at two paths in the repository. Byte-identical today; nothing prevents divergence, and no evaluation covers the difference. |
| L-006 | The decision inventory still records the accepted decision as `Unresolved` — correct behavior, and the clearest demonstration of historical/derived separation available. |
| L-007 | A partly-defined topic was initially recorded as wholly unknown, losing a real requirement. Both the extraction and requirement evaluations record the corrected known/unknown split explicitly. |
| L-010 | 5 acceptance criteria written against engineering guidance were removed; the requirement evaluation names each removed criterion. |
| L-014 | An expected input directory did not exist; the extraction evaluation records the absence and names what was used instead rather than substituting silently. |

Principles L-008, L-009, L-011, L-012, L-013 are extracted from structures the
executed artifacts consistently maintained rather than from recorded failures.
They are enforced practice in the evidence, not corrections.

---

## Not Yet Included

Listed in the skill as **Future Extensions / Not Yet Validated**, with no workflow
designed for any of them:

Planning Harness · Task Planning · Execution Harness · Coding Agent Workflow ·
Tool Harness · Build Harness · Observability Harness · Runtime Verification ·
Test Completion Gate · Requirement-to-Code Verification · Maintenance Harness ·
Long-running Agent Recovery · Task State Maintenance · Project Completion Workflow

No repository evidence exists for any of these. The source project has no source
code, no build, no tests, and no plan — it stopped at architecture decision one.
Designing these would have meant inventing a process and presenting it with the
same authority as the four that were actually executed.

### Validated scope has a known depth limit

The architecture decision loop has been executed **once**, end to end, for a
single decision. What is therefore validated:

- one full pass through all six architecture gates
- promotion of a first ADR into an empty authority set
- construction of a first current architecture state

What is **not** yet exercised:

- a second decision constrained by an accepted first one
- a decision whose dependency was satisfied by a prior acceptance
- supersession of an accepted ADR
- a human REJECT or DEFER outcome
- a state rebuild across multiple ADRs

The loop is documented as general in `architecture-harness.md`, and its steps are
faithful to the executed pass. Its behavior across multiple interacting decisions
is a reasonable extrapolation from one execution, not a validated result. This is
the principal soft spot in v0.1.

A related in-flight signal was found and preserved as guidance rather than
suppressed: a second decision analysis exists in the repository with **no
corresponding evaluation**. Under the skill's own recovery rule that analysis is
`UNVERIFIED` and its recommendation carries no weight — which is exactly the
state the boot sequence is built to detect.

---

## Extraction Confidence

**Medium-High.**

**High** for the four validated harnesses' internal structure. Each stage was
executed with a real generator output, a real independent evaluation containing
per-dimension identifier-level evidence, and a real terminal gate result. The
patterns were read off working artifacts, not inferred from intent. Several were
confirmed by observing the process correct itself — a FAIL→revise→re-evaluate
cycle is stronger evidence for a rule than a clean first pass, because it shows
the rule catching something.

**Medium** for three reasons:

1. **Prompts were unavailable.** The generator and evaluator contracts in
   `templates/` are reconstructed from what the outputs demonstrably enforced.
   The obligations are right — the outputs could not look as they do otherwise —
   but the original contracts may have contained fields whose effects left no
   trace in the artifacts.

2. **Single-project, single-domain evidence.** All four harnesses were executed
   once, on one project, in one domain, from one source document. Stage
   boundaries that held cleanly there may sit differently elsewhere — the
   requirement/architecture boundary in particular was never stress-tested by a
   genuinely ambiguous case.

3. **The architecture loop's depth limit**, described above.

**Deliberately not inflated.** The extraction brief asked for validated capability
only. Where the evidence supports a structure but not its generality, the skill
documents the structure and this report names the limit.

---

## Self Check

| Check | Question | Result |
|---|---|---|
| CHECK-001 | Is the skill project-agnostic? | PASS — full-text scan for domain terms, identifiers, technologies, and the accepted option found no matches |
| CHECK-002 | Are only actually-validated workflows marked Validated? | PASS — four harnesses, each with located PASS gate evidence |
| CHECK-003 | Is the prompt collection abstracted into workflow? | PASS — no prompt-numbered steps; the decision loop is a 12-step semantic workflow |
| CHECK-004 | Is Generator → Evaluator → Gate → Promote preserved? | PASS — `gate-model.md` plus both contract templates |
| CHECK-005 | Is human decision authority preserved? | PASS — hard stop rule in SKILL.md, enforced in the loop, encoded in three artifact templates |
| CHECK-006 | Is the Unknown / Clarification boundary preserved? | PASS — No Guess Rule, the typing table, and the classification test |
| CHECK-007 | Are historical artifacts and current state correctly separated? | PASS — `artifact-model.md`, the immutability rule, and L-006 |
| CHECK-008 | Is the Protected Input / Allowed Output model preserved? | PASS — both contract templates, plus L-001 |
| CHECK-009 | Are fresh agent isolation lessons preserved? | PASS — L-002, L-003, and the isolation section of `context-harness.md` |
| CHECK-010 | Were unvalidated lifecycles kept out? | PASS — listed as Not Yet Validated with no workflow designed |
| CHECK-011 | Is SKILL.md concise, with detail delegated? | PASS — SKILL.md carries purpose, scope, boot sequence, core rules, and routing; the 9 references and 11 templates carry the rest |
| CHECK-012 | Could a different software project use this skill? | PASS — the boot sequence detects state rather than assuming it, and assumes neither a PDF source nor an empty repository |

**Extraction Self Check: PASS**

---

## Files Produced

```
harness-engineering/
├── SKILL.md
├── EXTRACTION-REPORT.md
├── references/
│   ├── lifecycle.md
│   ├── artifact-model.md
│   ├── gate-model.md
│   ├── authority-model.md
│   ├── source-harness.md
│   ├── requirement-harness.md
│   ├── context-harness.md
│   ├── architecture-harness.md
│   └── lessons-learned.md
└── templates/
    ├── generator-contract.md
    ├── evaluator-contract.md
    ├── source-extraction-template.md
    ├── requirement-template.md
    ├── open-question-template.md
    ├── context-template.md
    ├── decision-inventory-template.md
    ├── decision-analysis-template.md
    ├── human-decision-template.md
    ├── adr-template.md
    └── architecture-state-template.md
```

The requested structure was preserved exactly. SKILL.md carries Claude Skill
frontmatter (`name`, `description`, plus `version` and `status`), so the directory
can be moved to `.claude/skills/harness-engineering/` unchanged. The repository
had no existing skill directory convention to conform to.

## Source Repository Modifications

None. No file under `docs/`, `.harness/`, `fresh-context-test/`, or any other
pre-existing path was created, modified, or deleted. All output is confined to
`harness-engineering/`.

---

## Post-extraction Amendments

Changes made to v0.1 after the initial extraction, in response to defects found
by testing the skill itself. The extraction record above is unchanged; amendments
are appended here.

### A-001 — Evaluation History / Current Gate State (Skill Consumer Test T02)

**Found by.** Skill Consumer Test T02. Two independent fresh sessions read the
same evaluation history in the source repository and reached different
conclusions: one resolved an early integrity FAIL as superseded by a later
re-evaluation performed under a corrected contract; the other reported the two
results as an unresolved contradiction.

**Root cause.** Two separate gaps, both in v0.1:

1. The detection procedure asked whether *the* evaluation for a stage passed — in
   the singular. That question has no defined answer when a stage has more than
   one evaluation, which is the normal outcome of any FAIL → revise →
   re-evaluate cycle.
2. The skill had no rule distinguishing **evaluation history** (append-only,
   every run retained) from **current gate state** (resolved across that
   history). It also gave no criteria for when a later evaluation supersedes an
   earlier one — leaving each reader to infer the link from document content.

Both sessions' readings were defensible from what the repository contained. The
correction was real but unwritten, and inference is not reproducible across
readers.

**Resolution.** A rule was added establishing the two as distinct, with an
evidence requirement for supersession (explicit previous-evaluation reference,
Supersedes field, contract version plus a statement of what changed, explicit
reconciliation statement, or version-control evidence) and an explicit
prohibition on inferring it from filename, file existence, or timestamp. Where
evidence is absent, current gate state resolves to `AMBIGUOUS` and the skill
stops for human review rather than choosing.

A forward-looking evaluation metadata block was added to the evaluator contract.
It is explicitly marked as applying to future evaluations only — historical
evaluations lack these fields, that absence is not a defect in them, and
backfilling them is prohibited as an edit to immutable evidence.

**Files amended.** `SKILL.md`, `references/gate-model.md`,
`references/artifact-model.md`, `references/lifecycle.md`,
`references/lessons-learned.md` (L-015 added), `templates/evaluator-contract.md`.

**Scope note.** No My Work Item project artifact, test evidence, or evaluation was
modified. The source repository's own evaluation history — including the early
integrity FAIL that produced this ambiguity — remains exactly as it was.

**Confidence effect.** Extraction confidence is unchanged at **Medium-High**. The
amendment closes a documentation gap in the skill; it does not alter what the
source repository validated.
