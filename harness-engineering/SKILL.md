---
name: harness-engineering
description: Build trustworthy project knowledge, context, and architecture decision authority BEFORE coding starts. Use when starting a new software project, setting up an AI coding environment, building a harness, deriving requirements from source material, preparing reliable context for a coding agent, or establishing an architecture decision workflow. Enforces Generator -> Evaluator -> Gate -> Promote, and stops for human decisions.
version: 0.1
status: experimental
---

# Harness Engineering

## Purpose

This skill establishes **trustworthy upstream knowledge** for a software project
before any planning or implementation begins.

It answers one question:

> Can a downstream agent rely on this artifact?

The answer is never "yes, because the file exists."
The answer is only "yes, because the artifact passed an independent evaluation gate."

The skill produces four layers of verified authority:

```
Source Material
   -> Validated Source Extraction
      -> Validated Requirements + Preserved Open Questions
         -> Validated Project Context (artifact-verified AND consumer-verified)
            -> Accepted Architecture Decisions (human-owned, ADR-backed)
```

## Version and Status

Version: `0.1`
Status: `Experimental`

Only the capabilities listed under **Validated Capabilities** have been executed
end-to-end and confirmed with PASS gate evidence. Everything else is out of scope.

## Validated Capabilities

| Harness | Covers | Reference |
|---|---|---|
| Source Harness | Source intake, extraction, extraction evaluation, source gate | `references/source-harness.md` |
| Requirement Harness | Requirement generation, open-question preservation, evaluation, gate | `references/requirement-harness.md` |
| Context Harness | Glossary, project context, artifact evaluation, fresh-agent consumer test, consumer gate | `references/context-harness.md` |
| Architecture Decision Harness | Decision discovery, inventory evaluation, decision analysis, analysis evaluation, human decision gate, ADR, ADR evaluation, promotion, current architecture state, authority gate | `references/architecture-harness.md` |

## Unsupported / Not Yet Validated

Do **not** claim, plan, or improvise these as harness capabilities in v0.1:

- Planning Harness / Task Planning
- Execution Harness / Coding Agent Workflow
- Tool Harness
- Build Harness
- Observability Harness
- Runtime Verification / Test Completion Gate
- Requirement-to-Code Verification
- Maintenance Harness / Long-running Agent Recovery
- Task State Maintenance
- Project Completion Workflow

If the user asks for one of these, say plainly that it is outside validated scope,
and offer the validated stages that must exist first.

## Activation

Use this skill when the user asks to:

- start a new software project on a reliable footing
- build an AI coding environment or "harness"
- turn source material (spec, PDF, brief, ticket, transcript) into requirements
- build reliable context for a coding agent
- establish an architecture decision workflow
- resume or repair a partially built knowledge pipeline

Do not use it to write application code, plan tasks, or design implementation details.

---

## Repository Boot Sequence

**Always run this first.** Never assume the project starts from a blank slate,
and never assume it starts from a PDF.

1. **Inspect repository.** Enumerate the directory tree. Locate any existing
   knowledge, requirement, context, analysis, or architecture directories.
2. **Detect source artifacts.** Is there original source material under the
   project's authority (spec documents, briefs, transcripts, tickets)?
3. **Detect derived artifacts.** Extraction, requirements, open questions,
   glossary, context, decision inventory, analyses, human decisions, ADRs,
   current architecture state.
4. **Detect evaluation evidence.** For each derived artifact, collect **every**
   independent evaluation of it — not just the first or the newest. A stage may
   legitimately have several.
5. **Resolve current gate state.** Read each evaluation's terminal result. Where
   a stage has more than one, resolve current state across them rather than
   reading it off a single file. A historical FAIL is not automatically a current
   FAIL; a later PASS does not automatically clear an earlier FAIL. Record which
   gates are PASS, FAIL, AMBIGUOUS, or without evidence.
6. **Detect current authority state.** Which artifacts have actually been promoted?
7. **Determine the earliest unverified stage.** Walk the lifecycle in order and
   stop at the first stage whose gate is missing or not PASS.
8. **Resume from that stage.** Report the detected state to the user before acting.

Detection is cheap. Trust is not. When detection is ambiguous, treat the stage as
unverified.

See `references/lifecycle.md` for the full stage order and resume rules.

---

## Core Rule

> **Never trust an artifact merely because it exists.**

Trust is a product of three things:

```
Artifact  +  Independent Evaluation  +  Passed Gate
```

Remove any one of them and the artifact is a draft, not an authority.

The third term is **current gate state**, resolved from the stage's full
evaluation history — not the result printed in whichever evaluation file you
happened to open. See `references/gate-model.md`.

Concrete consequences:

- Requirements without a requirement evaluation are **not** validated requirements.
  Run the evaluation before consuming them.
- Project context without a **consumer test** is not verified context.
  Do not proceed to architecture.
- An ADR without ADR gate evidence is **not** an active architecture authority.
  Do not treat its decision as settled.
- A generator's own Self Check is **not** a gate. See `references/gate-model.md`.

---

## Authority Model

Existence is not promotion. Keep these pairs distinct at all times:

| Not authoritative | Authoritative after |
|---|---|
| Generated extraction | extraction evaluation PASS |
| Generated requirement | requirement evaluation PASS |
| Generated context | context artifact evaluation PASS **and** consumer evaluation PASS |
| AI recommendation | explicit human decision |
| Human decision | ADR generated and ADR evaluation PASS |
| ADR document | promotion into current architecture state, authority gate PASS |

Full precedence order and conflict handling: `references/authority-model.md`.

---

## Human Stop Rule

When the workflow reaches a decision whose owner is human — in the validated
scope this is every architecture decision that changes architecture authority —
**STOP**.

- Present the evaluated analysis, the candidate options, the AI recommendation,
  and the confidence level.
- Ask the human to choose explicitly.
- Do not proceed to ADR generation on an unanswered decision.
- Never convert an AI recommendation into an accepted decision by omission,
  by inference, or because the recommendation was well argued.

Required sequence:

```
AI Analysis -> Analysis Evaluation -> HUMAN DECISION -> Recorded Decision
   -> ADR -> ADR Evaluation -> Promotion
```

---

## No Guess Rule

If the source does not support a piece of knowledge, **preserve the unknown**.

Never close a gap with general engineering common sense. Doing so silently
converts an assumption into a requirement, and every downstream artifact
inherits it as fact.

Distinguish, and keep distinguishing:

| Kind | Meaning | Resolved by |
|---|---|---|
| `Unknown` | Source is silent; nothing is derivable yet | Better source, or reclassification |
| `Requirement Clarification` | Answer changes what the system must do | The requirement owner |
| `Engineering Decision Needed` | Answer changes how it is built | Architecture decision harness |

**Classification test.** If the answer would change any of the following, classify
it as *Requirement Clarification* and do not let an architecture agent resolve it:

- user-visible behavior
- a business rule
- actor permissions or boundaries
- data lifecycle
- required system behavior

Open-question preservation format: `templates/open-question-template.md`.

---

## Requirement / Architecture Boundary

```
Requirement            = WHAT the system must do
Architecture Decision  = HOW, at direction level
Implementation         = concrete realization
```

Rules:

- Do not re-ask a requirement as if it were an architecture decision.
- Do not, in the decision stage, design controllers, services, entities, schemas,
  endpoints, folder structures, or source code — unless the decision under
  analysis *is* that level of concern.
- Acceptance criteria describe externally observable behavior, not internals.

---

## Stage Routing

Route by the earliest unverified stage found in the boot sequence.

| Detected state | Route to |
|---|---|
| Source material exists, no extraction | `references/source-harness.md` |
| Extraction exists, no extraction evaluation | Source evaluation |
| Extraction gate PASS, no requirements | `references/requirement-harness.md` |
| Requirements exist, no requirement evaluation | Requirement evaluation |
| Requirement gate PASS, no glossary/context | `references/context-harness.md` |
| Context exists, no artifact evaluation | Context artifact evaluation |
| Context artifact gate PASS, no consumer test | Fresh agent consumer test |
| Consumer gate PASS, no decision inventory | `references/architecture-harness.md` |
| Inventory gate PASS, decisions unresolved | Architecture decision loop |
| Any current gate FAIL | Revise the artifact, then re-evaluate. Never edit the gate. |
| Any current gate AMBIGUOUS | **Stop.** Request human review — do not resume, and do not re-run the stage. `references/gate-model.md` |

---

## Recovery Behavior

Common repository states and the required response:

- **Artifact present, evaluation absent.** Do not consume it. Run the evaluation
  for that stage first. The artifact may still be fine — but that must be proven.
- **Artifact present, evaluation present, result FAIL.** Revise the artifact,
  then re-run the full evaluation. A FAIL is never resolved by rewriting the
  evaluation.
- **Downstream artifact present, upstream gate missing.** Repair upstream first.
  Downstream trust cannot exceed upstream trust.
- **Evaluation references an artifact version that no longer matches.** The
  evaluation is stale. Re-evaluate. See the Immutability Rule.
- **A stage has several evaluations with different results.** This is normal
  history, not necessarily a contradiction. Resolve current gate state across all
  of them under the Supersession Evidence Rule in `references/gate-model.md`.
  Never delete or rewrite the earlier result.
- **Supersession cannot be established from evidence.** Current gate state is
  `AMBIGUOUS`. Do not resolve it by preferring the newer file, and do not re-run
  the stage — that adds a third result to an undetermined history. Stop, report
  both results and the missing evidence, and request human review.
- **Duplicate copies of the same artifact in different directories.** Establish
  which path is canonical, record it, and evaluate only the canonical path.
  Divergent copies are a silent authority split.

---

## Immutability Rule

Historical artifacts that have passed evaluation are **not** rewritten to keep
current state in sync.

- Decision inventories, analyses, human decision records, ADRs, and evaluation
  evidence are historical records of what was known and decided at that time.
- Current status (what is accepted, what is unresolved, what is eligible next)
  lives in a **derived** current-state document.

Rationale: editing a passed artifact detaches it from the evaluation that
validated it. The evaluation then attests to content that no longer exists.

Current state is a derived index. It never replaces requirements, ADRs, human
decisions, or evaluation evidence. See `references/artifact-model.md`.

**Evaluation evidence is append-only.** A stage accumulates a history of
evaluation runs, and every entry stays — including the failures. A new evaluation
is added alongside the old; an old FAIL is never deleted or rewritten so that it
reads as though it never failed. The record of what was wrong is what later shows
that it was corrected.

---

## Generator and Evaluator Contracts

Every generation step and every evaluation step is written against an explicit
contract. Never issue a vague instruction like "other files must not be modified."

Generators declare: Input, Allowed Reads, Protected Inputs, Allowed Writes,
Expected Output, Forbidden Output, Source Authority, Self Check, Stop Condition.
→ `templates/generator-contract.md`

Evaluators declare: Ground Truth, Target Artifact, Validation Dimensions,
Critical Validations, Gap Classification, Evaluation Summary, Gate Rule,
No Modification Rule.
→ `templates/evaluator-contract.md`

**Evaluators read, compare, validate, and report. Evaluators do not edit.**
An agent that fixes an artifact and then declares its own fix PASS has produced
no evidence.

---

## Reference Routing

| Need | Read |
|---|---|
| Stage order, resume rules | `references/lifecycle.md` |
| Artifact kinds, historical vs derived | `references/artifact-model.md` |
| Gate mechanics, self check, evaluation history vs current gate state | `references/gate-model.md` |
| Precedence, promotion, conflict handling | `references/authority-model.md` |
| Source intake and extraction | `references/source-harness.md` |
| Requirements and open questions | `references/requirement-harness.md` |
| Glossary, context, consumer test | `references/context-harness.md` |
| Decision loop, ADRs, architecture state | `references/architecture-harness.md` |
| Guardrail principles learned from real failures | `references/lessons-learned.md` |

Output skeletons live in `templates/`. They define required sections, not content.

---

## Future Extensions

All **Not Yet Validated**. Do not design or claim them in v0.1.

| Candidate | Target | Status |
|---|---|---|
| Planning Harness | v0.2 | Not Yet Validated |
| Execution Harness | v0.2 | Not Yet Validated |
| Tool Harness | v0.5 | Not Yet Validated |
| Observability Harness | v0.5 | Not Yet Validated |
| Runtime Verification / Test Completion Gate | v0.5 | Not Yet Validated |
| Requirement-to-Code Verification | v0.5 | Not Yet Validated |
| Guardrail Harness | v0.5 | Not Yet Validated |
| Maintenance Harness | v0.5 | Not Yet Validated |
| Fresh Agent Continuation / Long-running Recovery | v0.5 | Not Yet Validated |
