# Thinking - analysis principles, diagnostic order, decision basis

Entry point for `references/thinking/`. **Read this when the problem is one you have
not seen before**, or when you are unsure which principle applies. It routes; it does
not restate the rules, and no rule is defined twice.

| Layer | Owns | Where |
|---|---|---|
| router | core responsibility, trigger conditions, document routing | `../../SKILL.md` |
| known problems | fast localisation of a symptom already catalogued | `../problem-map.md` |
| **thinking** | **reusable analysis principles, diagnostic order, decision basis** | this folder |
| procedure | this skill's own mechanics - step order, gates, approvals, memory, git / DB safety, output formats | `../` |

**A symptom missing from `problem-map.md` means nothing.** That table is a shortcut
for problems already met. An unfamiliar problem is handled by the order below, which
is what makes this skill work on things nobody has catalogued yet.

## The diagnostic order for a problem you have not seen

Six questions, always in this order. Each one names the single file to open if the
answer is not already obvious - **open nothing else**.

```
1 WHAT IS ACTUALLY TRUE?     separate observation from inference before anything
                             -> ../thinking/risk-tiers.md  (evidence labels)
2 HOW DEEP DOES THIS GO?     set the tier from real risk and reach, not diff size;
                             search outward only as far as evidence requires
                             -> risk-tiers.md  (L1/L2/L3, early exit, escalation)
3 WHAT IS THE REAL PATH?     which carrier / entry point actually runs, which code
                             really executes, and what must NOT be concluded from
                             a search that found nothing
                             -> scoped-scan.md  (stop conditions, negative evidence)
4 WHAT DOES THIS RISK?       read the change through the five risk lenses, then the
                             seven quality dimensions
                             -> engineering-principles.md (P1-P5)
                             -> code-quality-gates.md (reachability, compatibility,
                                boundaries, cross-layer, errors, maintainability, tests)
5 DOES IT FIT WHAT EXISTS?   what already solves this, is it genuinely reusable,
                             does any meaning get overloaded, is a new mechanism
                             really needed
                             -> consistency-gate.md (Gate 7)
                             -> data-strategy.md (existing strategy first)
6 WHAT WOULD IT BREAK?       compare against the authoritative baseline on the
                             contract dimensions before proposing anything
                             -> regression-validator.md (Gate 5)
```

Then write it down for a reader who has never seen the system:
`explanation-standard.md`.

## When each principle file fires

| Open this | When |
|---|---|
| `risk-tiers.md` | choosing depth; deciding whether to widen or stop; labelling evidence; escalating mid-analysis |
| `scoped-scan.md` | deciding what to read; a search found nothing; "is this attribute / handler / caller really unused?" |
| `engineering-principles.md` | P1 server-side authority · P2 contract parity · P3 blast radius · P4 state safety · P5 existing capability first - the risk lens behind everything else |
| `code-quality-gates.md` | writing or judging a diff: the seven dimensions, and Gate 6 self-review |
| `consistency-gate.md` | before proposing a change: existing implementation first, semantic integrity, identifier lifecycle, cross-layer meaning, solution comparison (Gate 7) |
| `data-strategy.md` | an identifier / update / delete / copy / restructure strategy is in question; whole-collection replacement; is a new identity mechanism justified |
| `regression-validator.md` | any change to an existing flow - the seven contract dimensions, run twice (Gate 5) |
| `capability-reuse.md` | reusing a capability, claiming something is missing, or touching shared code (Gate 3) |
| `duplicate-write-defence.md` | the same request can be processed twice, or a duplicate / half-written row was observed |
| `table-design.md` | a table or column is created or changed |
| `code-review-checks.md` | reviewing a diff - the six mandatory check categories |
| `encoded-values.md` | status codes, bit flags / masks, thresholds, limits, legacy codes |
| `explanation-standard.md` | writing any reply or report - shape, tables, clarity |

## What belongs in this folder - and what does not

**In**: a principle that would still be true at a different company, with a different
stack. A way of reasoning, a decision basis, a diagnostic order, a named trap.

**Out**: this skill's own procedure (step order, approval gates, memory mechanics,
git / DB safety, output templates) - those stay in `../`. Organization facts - those
live in `workspace/`, never here. A single ticket's findings - those are task output.

**Where candidates come from** - one line, same rule everywhere:

```
Thinking Candidate: NONE | <the reusable principle, one sentence>
```

- Asked at the end of **Mode A** (the Approval Gate #2 report, `../verification.md`
  §4), at the end of **Mode R** (the review file, `../code-review.md` §6), and by a
  requested retrospective.
- **Default `NONE`, and most tasks are honestly `NONE`** - never invent one to fill
  the field.
- Write it as the engineering concept, never as that task's method, endpoint, table
  or class name.
- It **proposes only**. Nothing reaches this folder without passing the criteria
  below, and the edit itself is a separate task with its own approval.
- **Not `NONE` -> it must reach the chat reply, with an explicit ask.** One line
  stating the principle, then asking whether to write it into `references/thinking/`
  (noting that doing so is a separate task that first passes the criteria below).
  Leaving it only inside the local file is not enough - in Mode R especially, the
  file may never be opened (`explanation-standard.md` §6).
- **`NONE` -> say nothing at all.** No line in the reply, no "no candidate this
  time". Most tasks are `NONE`, and announcing it every time is the noise this rule
  is designed to avoid.

**Adding a principle** (this folder is meant to grow):

1. it must be reusable - a one-off finding is task output, not a principle;
2. it must have one owner - extend the file that already owns the topic rather than
   adding a near-duplicate, and cite instead of copying;
3. it must have a firing trigger, listed in the table above and routed from
   `../../SKILL.md`;
4. it must be organization-neutral and stack-neutral in wording;
5. it must stay inside the 250-line budget (`engineering-principles.md` §5);
6. where a real case motivated it, generalise the lesson and leave the case out.
