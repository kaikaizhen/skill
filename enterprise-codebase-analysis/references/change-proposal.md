# Mode A Output - Change Proposal & Approval

Load when assembling the Mode A report (workflow step 18). Mode A's deliverable is a
**decision-ready engineering proposal**, not an implementation and not a repository
dump. Two audiences read it: an engineer who must understand what will change and
why, and a lead who must decide whether this ticket can be handed to an agent.

Mode A still **never** modifies code, DB, migrations, branches, commits, MRs or
deployments. Those rules are unchanged (HARD RULES 1-5, `git-safety.md`,
`database-safety.md`).

The analysis that feeds this file is already specified elsewhere - requirement
sources (Gate 1), carrier (Gate 2), reuse (Gate 3), consistency (Gate 4), contract
parity (Gate 5), blast radius (P3), validation (`verification.md`), required-vs-
refactor (`development-convention.md` §3). This file only governs **how the result
is presented and what verdict it carries**.

---

## 1. Problem before solution

The report states, in this order, before any file is named:

```
Current Behavior  ->  Problem  ->  Goal  ->  Proposed Change
```

A report that opens with "modify X.cs / add a parameter / change the SQL" has
skipped the part a reviewer needs. If the ticket's intent is clear but its wording
is vague, state the assumption; never invent a business rule to fill a gap - that
is `Unknown / Need Confirmation` (Gate 1).

## 2. Current production behavior is a contract

> Unless the ticket explicitly requires changing it, existing production behaviour
> is a contract that must be preserved.

So the proposal must establish what runs **today** - inputs, conditions, outputs,
side effects, error/exception behaviour - before proposing a change, and then say
which of those are contract. This is the same question Gate 5 answers across its
seven dimensions; do not build a second parity table. The report's
`## Production Behavior Preservation` section is a **reader-facing digest of Gate 5's
table**: one row per behaviour that must stay unchanged, how it is preserved, and
the evidence.

Any behaviour the proposal *does* change is labelled **`INTENTIONAL CHANGE`** with
the requirement that authorises it. Calling a deliberate behaviour change a
"refactor" or "cleanup" is forbidden.

## 3. Required change vs recommended refactor vs out of scope

A scan will surface legacy code, duplication, naming problems, SOLID violations and
technical debt. Each finding is filed as exactly one of:

| Bucket | Meaning | Where it goes |
|---|---|---|
| **Required** | the ticket cannot be delivered without it | Proposed Code Changes |
| **Recommended refactor** | real improvement, not needed for this ticket | a one-line follow-up note |
| **Out of scope** | unrelated to this ticket | `## Implementation Scope` -> Out of Scope |

Discovering debt never converts a ticket into a repository refactor. The bias is the
**smallest safe change** (`development-convention.md` §3b). On an
Optimization/Refactor-classified ticket the design strategy is itself the ticket's
work (§3a) - that is not an exception to this rule, it is a different ticket type.

## 4. Candidate solutions - compare only when there is a real choice

Present alternatives when more than one defensible approach exists, each with
*What / Files / Benefits / Risks / Blast radius*. Order them so the minimal,
existing-capability option is first (Gate 3's `Reuse` verdict decides what
"minimal" means here).

**Do not manufacture a second option for the sake of the format.** When reuse of an
existing seam is the only sane approach, say so in one line and move on. Equally, do
not hide a genuine structural alternative behind a single recommendation.

Where a qualifying SOLID/maintainability alternative exists, this section *is* the
`PATTERN CHOICE` block (`development-convention.md` §3b) - one presentation, not two.

## 4b. Encoded values in the affected code

When the touched path contains a literal carrying meaning the number does not show -
a status code, bit flag or mask, threshold, limit, legacy or protocol code - add
`## Magic Numbers / Encoded Values` plus a short `### Quick Behavior Comparison`, per
`encoded-values.md`. No finding -> the section is absent; never an empty table. It
becomes a Candidate Solution only when the encoding actually drives the choice.
Changing a numeric *value* is a behaviour change, never "removing a magic number".

The same analysis applies when reviewing a change the user brings ("review this
proposed diff", "這樣改會不會有問題") - not only a first proposal.

## 5. Regression risk - graded, with a reason

```
Low      additive and local: no DB/API/shared-contract change, callers unaffected
Medium   shared code with enumerated callers, or a behaviour-adjacent change
High     schema, auth, serialization format, transaction boundary, audit path,
         or any unresolved HIGH row from Gate 5
```

A bare `Risk: Low` is not acceptable - name what makes it that grade. The grade must
agree with Gate 5's risk rows; if they disagree, Gate 5 wins and the report is
corrected (Gate 4).

## 6. Validation plan - how we prove nothing broke

Answers one question: *after the change, how do we show production behaviour is
intact?* Rows of `Validation / Purpose / Expected`, drawn from the Test Plan and
`verification.md` §2 - build, existing tests (the related set, not the suite), new
tests, manual check, DB/API verification where relevant. Include at least one
**before/after behaviour comparison** for each non-`unchanged` Gate 5 row.

---

## 7. Approval Recommendation (required)

Closes every Mode A report that proposes a change. Exactly one verdict:

```
Recommendation:            APPROVE | APPROVE WITH CONDITIONS
                           NEEDS HUMAN DECISION | NOT RECOMMENDED
Reason:                    <one or two lines>
Implementation Confidence: High | Medium | Low
Estimated Blast Radius:    Small | Medium | Large
Production Risk:           Low | Medium | High
Human Decisions Required:  None | <list>
Agent Can Implement:       Yes | Yes after clarification | No
```

Verdict criteria - **all** conditions must hold for `APPROVE`:

- the requirement is clear (no Gate 1 row left `CLARIFICATION`);
- the code flow is confirmed, not inferred, for the path being changed;
- the change scope is bounded and named;
- the production contract can be preserved (no unresolved HIGH Gate 5 row);
- a validation plan exists;
- no unresolved high-risk business decision.

| Verdict | Use when |
|---|---|
| `APPROVE WITH CONDITIONS` | the approach is sound but merge needs an external gate - DBA review, security review, product confirmation. State each condition. |
| `NEEDS HUMAN DECISION` | a business rule has two defensible readings, a migration/back-compat policy is undecided, or the ticket's intent would change existing behaviour and nobody has authorised that. **The agent does not choose.** |
| `NOT RECOMMENDED` | the request conflicts with the current architecture, risk clearly outweighs the ticket's value, required evidence is missing, or the ticket as written breaks a production contract. |

Confidence is about *this analysis*, not about the agent: `Low` whenever a
load-bearing fact is `INFERRED` or the carrier was never confirmed.

## 8. Manager Summary (required, at the top)

Five answers, no implementation detail, readable in under a minute:

```
1 Problem                    2 Proposed change
3 Files / systems affected   4 Production risk
5 Recommendation
```

Plain language. No file-by-file walkthrough, no gate names, no evidence labels. If
it cannot be said without jargon, the analysis is not finished. The whole report's
prose follows `explanation-standard.md` - terms explained on first use, an actor for
every action, provenance for every value.

## 9. Implementation Handoff (only on APPROVE / APPROVE WITH CONDITIONS)

A contract for whoever implements next, so an approved ticket is not re-interpreted
from scratch. **Producing it is not starting implementation.**

```
Goal:                           <the outcome, one or two lines>
Files expected to change:       <paths; mark anything shared>
Behaviors that must not change: <from Production Behavior Preservation>
Implementation constraints:     <pattern to follow, error channel, logger,
                                 convention source>
Tests required:                 <from the Validation Plan>
Do not change:                  <the deliberate no-touch boundaries>
Stop conditions:                <what forces a stop back to the user: a DB write,
                                 no test coverage, a new HIGH Gate 5 row, scope
                                 growth beyond In Scope>
```

Omit it for `NEEDS HUMAN DECISION` and `NOT RECOMMENDED` - there is nothing approved
to hand off.

## 10. Length discipline

Decision-oriented, not a repository dump. Cite `file`, `class`, `method`, `line`
instead of pasting source; include evidence only where it carries a key conclusion.
A simple ticket's proposal is short - Gates 1, 4 and 5 are three to ten lines each
on a small change, and proportionality applies to this report exactly as it does to
the gates (`requirement-evidence-gates.md`).
