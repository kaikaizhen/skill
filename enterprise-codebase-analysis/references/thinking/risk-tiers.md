# Risk Tiers & Progressive Discovery

Decides **how deep to go before deciding anything**. Pick the tier at workflow step
7-9 (Classification / Scope), state it in one line, and let it govern how much of
Gate 7 runs (`consistency-gate.md`).

This refines the existing proportionality rules; it does not replace them. Depth per
issue type stays in `scoped-scan.md` (Depth By Issue Type, Proportionality, Stop
Conditions); depth per blast radius stays in `code-quality-gates.md` §0.1. This file
adds the **named tier, the discovery order, and the escalation rule**.

**The tier is set by real risk and reach, never by diff size.** Not by lines changed,
files touched, or how long the ticket text is. A one-line change to an identifier is
L3; a 300-line copy-text change is L1.

## The three tiers

```
L1 Lightweight   copy / display text · a simple condition fix · a local bug
                 no change to business meaning, API, DB structure or any
                 cross-module contract
      scan       the target file and method · its direct dependencies · just
                 enough similar code to match the house style
      output     one or two lines confirming it follows existing practice.
                 NO architecture analysis, NO cross-repository sweep, NO
                 candidate-solution table

L2 Standard      new or adjusted business logic · a service / repository /
                 controller change · a new shared method · an adjusted data
                 handling flow · a medium refactor
      scan       the modules involved · existing implementations in the same
                 business domain · helpers / services / components that could be
                 reused · the callers and data flow that actually matter
      output     compare the existing approach against the new one - keeping only
                 the genuinely viable options (`../change-proposal.md` §4)

L3 Deep          a column removed or a structure changed · a change to an ID /
                 GUID / key / hash / index mechanism · an API contract or data
                 meaning change · a cross-repository change · data migration,
                 compatibility or a historical-data problem · a high-risk refactor · a
                 core business behaviour that can affect several systems
      scan       the whole affected data flow · related modules and their
                 existing design · the cross-repository dependencies that really
                 exist · external APIs and consumers · DB, DTO, service, frontend
                 and tests
      output     the full Gate 7 block (`consistency-gate.md` §6)
```

**L3 always runs the full Codebase Consistency Gate.** L1 and L2 run the short forms.

Having many checks available is not a reason to run them all: **no tier runs a check
its own scope does not call for.**

## Progressive Discovery

Search outward from what is most relevant, and **stop as soon as the evidence is
sufficient**:

```
1  the target feature and its direct dependencies
2  similar implementations in the same business module
3  related shared design in the same repository
4  other repositories that genuinely share this data or contract
```

This is an **order, not a checklist**: most tasks never reach stage 3, and a task
reaches stage 4 only when a concrete shared contract points there. Widen only when
you hit a real risk, a real dependency, or evidence that is not yet enough.

### Early Exit - stop widening

Stop when all of these hold:

- the existing implementation is enough to carry this change;
- no field's or method's original meaning is being changed;
- no external dependency has turned up that needs tracing;
- no identifier or contract change is involved;
- the evidence is sufficient to decide safely.

Say so in one line (`Early exit at stage <n>: <why>`) and move to the proposal.
Continuing to search after this point is waste, not rigour.

### Escalation - raise the tier, and say why

Raise the tier the moment any of these appears, even mid-analysis:

| Trigger | Raise to |
|---|---|
| a field may end up meaning something different | L3 (`consistency-gate.md` §3) |
| the new design conflicts with an existing convention | L2 or L3 |
| other modules or external consumers are affected | L3 |
| identity, ordering, uniqueness or data lifecycle is involved | L3 (`consistency-gate.md` §4) |
| production behaviour could change | L3 |
| what looked local turns out to cross a layer contract | L3 (`consistency-gate.md` §5) |

Escalation is recorded, not silent: `Escalated L1 -> L3: <trigger, with path:line>`.
It is not a restart - keep the evidence already gathered and extend it.

**Search depth is proportional to reach.** Never widen a scan for the sake of looking
thorough, and never leave a known high-risk question unanswered by burying it under
unrelated searching.

## Evidence labels

Important conclusions rest on **the current repository's code**, not on a document
about it. Organization memory, past scan reports and older analyses are **search
leads**; anything load-bearing is re-checked against current code before it is stated
(HARD RULE 6).

| Label | Means |
|---|---|
| `CONFIRMED` | read in current code / schema / config / runtime output, with `path:line` |
| `INFERRED` | reasoned from confirmed facts, not directly observed |
| `NOT FOUND IN SCOPE` | the search ran and found nothing **in the range searched** - name the range |
| `UNKNOWN` | no evidence either way, and it matters |
| `NOT VERIFIED` | could not be executed or read here (environment, access, runtime-only) |

`NOT FOUND IN SCOPE` and `NOT OBSERVED IN TRACED PATH` are **search outcomes**, not
trust levels: the five memory trust levels stay exactly as they are
(`../memory-system.md` §5). Neither one ever becomes "it does not exist" or
`CONFIRMED MISSING` without Gate 3's threshold.

**Not finding a consumer is not proof there is none; not finding a caller does not
make the code dead.** Without evidence, never recommend removing a feature, dropping
support, or returning a default value (`consistency-gate.md` §5).

## Cost control

1. Look at the code this task actually touches, first.
2. Do not re-scan a path already confirmed in this task.
3. Several repositories existing is not a reason to search them all.
4. Trace a full data flow only when the change reaches that far.
5. A simple requirement needs no candidate-solution evaluation.
6. **Never invent an option or a risk to fill out a report.**
7. When the evidence is sufficient, stop immediately.
8. Unresolved high-risk questions are listed plainly - extra unrelated searching
   never substitutes for admitting uncertainty.
