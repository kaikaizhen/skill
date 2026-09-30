# Development Convention (Mode A)

How a change is written, once Approval Gate #1 has been passed. Mode B and Mode C
never reach these gates - they do not modify source. Mode C may *report* a
convention it observed; it never applies one.

This file holds the **generic rule**. Concrete type names, failure codes,
middleware / controller / logger names, build and test commands are
repository-specific and live in `workspace/memory/repositories/<Repo>/patterns.md`. Nothing
in this file may be promoted into a company-wide mechanism.

---

## 1. Convention Resolution (before writing any code)

Part of the scoped scan, completed before the Implementation Plan (workflow steps
14-17) is written. Its result goes into the analysis document under
`## Convention Baseline`.

For the files this ticket actually touches, resolve four things - **coding /
style**, **error handling**, **logging**, **testing** - using this order. First
source that actually speaks on the question wins:

```
1. the target repository's own live rule files
   (CLAUDE.md, AGENTS.md, .claude/rules/*, .claude/skills/*, .editorconfig,
    analyzer / StyleCop config, lang-version settings)
2. the code actually surrounding the change
   (the method/class being changed, and the nearest sibling that does the same job)
3. repository-specific CONFIRMED memory
   (workspace/memory/repositories/<Repo>/patterns.md)
4. team technical standards
   (the organization's standards source, summarised in\n    workspace/memory/global/engineering-standards.md)
5. general best practice (SOLID, design patterns, framework idiom)
```

- **1 beats 2.** When a repository rule file forbids something a handful of old
  call sites still do, new code follows the rule file, not the old call sites.
- **2 beats 3.** Memory is a navigation hint; current code wins.
- **4 and 5 never silently override 1-3.** A team standard or a SOLID argument
  can only produce a *proposal* (section 3) - never a unilateral change to how
  this repository writes code.
- A level that is silent on the question is skipped. Two sources disagreeing at
  the same level is the one case where you ask instead of choosing.

Minimum evidence: cite a file (path, and line/section when it is a rule file) for
each of the four, or write `UNKNOWN` for that one. Never infer a convention from
the framework alone ("it's ASP.NET Core, so it must use ...").

Scanning cost stays proportional (`scoped-scan.md`): the convention that matters
is the one governing the files in this ticket's diff, not the repository's entire
style guide.

---

## 2. Existing-Capability-First, Existing-Pattern-First (the default, no approval)

The default implementation is **the smallest safe change, written the way this
repository already writes this kind of code**:

- **use what already exists before writing anything new.** Before adding a method,
  parameter, overload, wrapper or abstraction, establish what the existing shared
  code already supports and whether an existing seam - a delegate, callback,
  strategy, handler, optional argument or fallback the caller already passes -
  already reaches the need. If it does, use it: adding a second way to do the same
  thing is scope creep, not thoroughness (P5, resolved in Gate 3's `Reuse` column);
- reuse the flow's existing return type / result contract / DTO shape;
- reuse the existing validation, mapping, logging and helper entry points instead
  of introducing new ones;
- keep the existing layering - do not add a layer, an abstraction, an interface
  or a package for one ticket;
- no drive-by rename, reformat, package upgrade or redesign.

**Modifying shared code is never the default.** When the existing capability
genuinely cannot carry the need, the concrete limitation is named first, the
caller-side alternative is checked, and the extension is proposed with its impact
on every other caller for the user to decide - `SHARED CAPABILITY EXTENSION
APPROVAL REQUIRED` (`capability-reuse.md`, Gate 3). A defaulted
optional parameter is still a shared-contract change, not a local edit.

Scope authority is the ticket. A change that the ticket's acceptance criteria do
not need does not belong in this diff.

---

## 3. Design & implementation strategy - by ticket classification

This is P5 in `engineering-principles.md`. The classification fixed at workflow
steps 7-9 (`scoped-scan.md` -> Depth By Issue Type) decides which of the two
postures below applies. Neither is optional once the classification is set.

### 3a. Optimization / Refactor - strategy is mandatory, before writing a diff

When the classification is Optimization or Refactor, the design decision **is**
the ticket's scope, not scope creep. After the scoped scan
(`scoped-scan.md` -> Optimization/Refactor depth) and before Pseudocode/Plan
(workflow steps 14-17), produce a short **Design & Implementation Strategy** in
the analysis document:

1. **Current structure and its concrete problem** - name what actually hurts
   (duplication, a class doing three jobs, a hidden coupling), with evidence
   (`path:line`), never "it's old" or "it's ugly" on its own.
2. **Candidate approach(es)**, weighed against common engineering principles:
   readability, maintainability, testability, low coupling, reusability /
   extensibility - and against this repository's own convention (§1). The
   repo's existing idiom beats a textbook pattern it does not otherwise use.
3. **Chosen approach and why**, naming a design pattern only when it earns its
   place against a **concrete, present** need this ticket actually has - never
   a hypothetical future variant, never "in case we need it later"
   (over-engineering guard; the same ordering as P5's Existing Capability
   First: use what exists, then the smallest structure that solves the actual
   problem, before reaching for a named pattern).
4. **What stays untouched** - the refactor's own boundary; "while I am here"
   widening is still forbidden regardless of how tidy it would look.

This strategy is part of the plan presented at Approval Gate #1 - it is *not*
the `PATTERN CHOICE` block in §3b (that block is for a structural improvement
volunteered *inside* a ticket that is not itself a refactor). A refactor still
owes the full P2 contract comparison (`engineering-principles.md`) -
behaviour-preserving refactors are exactly where contract loss hides.

### 3b. Bug / Feature / Migration - existing-pattern-first, no deliberate pattern

The default is §2's existing-pattern-first change: do not deliberately
introduce a design pattern the surrounding code does not already use. Decide
the shape of the diff in this order - **readability** (a reviewer unfamiliar
with this ticket can follow it) > **maintainability** (the next change stays
this small) > **consistency with the existing architecture/convention** (§1)
> **minimal necessary change** (only what the acceptance criteria require).

"It would be more SOLID" is never on its own a sufficient reason to restructure
legacy code inside this kind of ticket: if the current code can carry this
ticket safely, it is not refactored.

Never widen scope on your own initiative. A better-structured option is offered
to the user, and only when **all four** preconditions hold:

1. it is confirmed not to change existing business behaviour - state the evidence
   (callers, tests, contract), not the hope;
2. it is confined to this ticket's own code path, not a repository-wide refactor;
3. the existing tests of that path still express the same requirements afterwards
   (`verification.md` -> Test Preservation);
4. there is a concrete future-maintenance benefit that can be named (a specific
   principle from `workspace/memory/global/engineering-standards.md` and the specific pain
   it removes), not "cleaner".

If any precondition fails, do not offer it: implement the existing pattern and
record the idea as a one-line follow-up note in the analysis document. A refactor
that *is* accepted still owes the full contract comparison in
`regression-validator.md` - a behaviour-preserving refactor is exactly where a
silent loss of a side effect, an audit record or an auth check hides.

When all four hold, present both options - at Approval Gate #1 if it was already
visible during analysis, otherwise stop at the moment it is discovered and ask
before writing it:

```
PATTERN CHOICE REQUIRED

Option A - Existing pattern (default)
  What:            ...
  Files touched:   ...
  Risk:            ...

Option B - Improvement (<principle, e.g. SRP / OCP / DIP>)
  What:            ...
  Extra files:     ...
  Maintenance gain: ...
  Impact on existing behaviour: NONE (evidence: ...) | <what changes>
  Extra risk / extra test surface: ...

Recommendation: <A or B> - <one line>
AWAITING USER PATTERN CHOICE
```

Silence is not a choice; without an explicit answer, implement Option A. Never
implement Option B and mention it afterwards.

---

## 4. Error handling - the target repository's native pattern

The rule is about *channel*, not about a named type:

> An **expected business failure** travels by whatever channel this repository
> already uses for expected business failures. An **unexpected exception** is
> left to this repository's global handler.

Resolve the channel at level 1/2 of the convention order, per repository. Never
carry another repository's mechanism across.

- **Repository whose services return a result/failure type**: build the failure
  through that repository's own failure factory and let its controller / base
  failure flow map it to a response. Do **not** convert an expected business
  failure into a thrown exception, and do **not** wrap it in a local try/catch
  that swallows it.
- **Repository whose native convention is try/catch + logger + an existing return
  model** (a base return model, a `status`/`message` JSON contract, model-state
  validation, a tuple): keep that. Do **not** introduce a result/failure type
  into it for one ticket.
- **Unexpected exceptions**: never an empty catch, never a broad catch that hides
  a defect. Let them reach the repository's global handler / middleware / filter
  - unless that repository's own rule file mandates something else for a specific
  case (e.g. a timeout-bounded defensive fallback around an external dependency).
- **Adding a new failure code / status mapping**: follow that repository's own
  mapping table, and update the mapping in the same change if the new code needs
  a non-default status.

Classification aid (the organization's logging standard, if it has one):

| | Meaning | Handling |
|---|---|---|
| Component fault | expected: dependency timeout, rule violated, no data | handled path - failure channel, fail-early, or a deliberate degradation |
| Design fault | a defect in our own logic | fix the code; never hide it behind a catch |

A failure channel carries component faults. It is not a place to absorb design
faults, and degradation is a last resort, not a default design.

---

## 5. Logging

Follow the repository's logger, its placeholder / interpolation rule, its level
choices for non-critical side-effect failures, and the language its messages are
written in - resolved at level 1/2/3, not assumed. Non-critical failures are
logged at the level that repository already uses; nothing is silently swallowed.

---

## 6. Testing convention

Framework, naming, folder mirroring, isolation requirements and whether tests are
mandatory are level-1/2/3 questions, per repository. What must happen to
*existing* tests, and what to do when none exist, is
`verification.md` -> Test Preservation.

---

## Output of this file

| Where | What |
|---|---|
| `<workspace>/issue/<RepoName>/<Ticket>.md` | `## Convention Baseline`; `## Design & Implementation Strategy` on a Refactor/Optimization ticket (§3a); `## Pattern Choice` when §3b applied |
| Approval Gate #1 | the strategy (§3a) or the pattern choice block (§3b), whichever applied |
| Approval Gate #2 report | `Convention Source` |
| `workspace/memory/repositories/<Repo>/patterns.md` | any newly confirmed, reusable repository convention (memory delta rules apply) |
