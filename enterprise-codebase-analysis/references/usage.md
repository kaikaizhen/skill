# Usage & Triggers

This skill has four modes - see SKILL.md -> "Modes" for the authoritative
table and disambiguation rules. Summary for trigger-matching:

- a ticket / bug / feature / requirement behind the request -> **Mode A**
- understanding the repository / project as a whole -> **Mode B**
- understanding one existing piece of code, no ticket or change behind it -> **Mode C**
- judging a diff / MR / branch that already exists -> **Mode R** (read-only)

## Mode A - Ticket Workflow

Invoke when a ticket / issue arrives against an existing company repository:

- a bug report in any onboarded repository
- a new feature on an existing service
- an optimization or a scoped refactor
- a migration
- root cause or impact analysis for a reported problem or requirement

Example phrasings that should trigger it:

```
T12345 talent profile returns not found for some ids
幫我看這張單 T12800
Add an endpoint to ServiceA that returns ...
ServiceB resume update is slow, please investigate
```

## Mode B - Repository Onboarding

Invoke in Mode B (read-only, no ticket questions, no approvals) for:

```
先掃 <repo>
幫我理解這個專案 / 新人快速上手
產生 PROJECT-QUICK-GUIDE
```

See `repository-onboarding.md`.

## Mode C - Scoped Explanation

Invoke in Mode C (read-only, no ticket, no branch, no approval) when the user wants
to understand one existing piece of company code and there is **no** ticket, bug
report or requirement behind the question:

```
這支 API 在做什麼
這個 Service 怎麼跑
why does X behave like this?
幫我追這段 call flow
```

If the same question is asked *because of* a reported bug or requirement, that is
Mode A, not Mode C - see SKILL.md -> "Choosing between Mode A and Mode C".

### Analysis-only (within Mode A)

A ticket / bug / requirement that the user only wants analysed / diagnosed, with no
change requested, still runs Mode A up to the analysis and stops there. It does not
ask for approval to implement. This is different from Mode C: Mode A analysis-only
still starts from a ticket/problem and follows Mode A's scope and evidence rules;
Mode C starts from "explain this code" with no ticket at all.

### E2E anomaly / deep root cause analysis (within Mode A)

An E2E run that exposes something a user could notice - a wrong business result
behind a success screen, data inconsistency, a duplicate / lost / overwritten row,
a cross-system side effect, a concurrency or timing defect - is a **Mode A bug with
escalated depth**, not a new mode: `e2e-investigation.md` Phases 1-8, reported on
`templates/e2e-bug-report.md`. The same escalation serves an explicit request for a
deep root cause analysis. Investigation is read-only; implementing a fix still goes
through Approval Gate #1.

### Table design / table review (within Mode A)

A task that actually involves a database structure change - `CREATE TABLE`,
`ALTER TABLE`, adding / dropping / renaming a column, a type, length, NULL or DEFAULT,
a primary key, unique key, index or constraint, a relation or Schema refactor, an
unimplemented design draft, or "does this Schema change break existing behaviour" -
applies `thinking/table-design.md` and emits the fixed-format review on
`templates/table-review.md` (rules: `table-review.md`). Changing an existing table
also traces dependencies, Before / After behaviour, side effects and deployment
compatibility. Read-only: DDL / DML and code changes still need Approval Gate #1.
SQL syntax questions, explaining a `SELECT` / `JOIN`, and reviewing ordinary
application code never force that document.

## Mode R - Requested Code Review

Trigger: the user asks for a review of code that **already exists** - an MR / PR,
a branch, a commit range, a pasted diff ("幫我 review 這個 MR", "這段改動有沒有問題",
"看一下這個分支的變更"). Read-only: findings only, no file changed (HARD RULE 16).

The user is asked for the **two ends of the diff** if they are not already clear -
source branch and target branch - because a review of the wrong range is worse
than none; a branch name is never assumed. Procedure: `code-review.md`. Output:
`templates/code-review.md`, written to `<workspace>/issue/<RepoName>/<Ticket>/`; the reply
is the verdict plus the top findings table (`code-review.md` §6).

Wanting the findings fixed is a **new Mode A ticket** with its own Approval Gate #1.
Merging, approving, pushing and posting MR comments stay with the user.

## When NOT To Invoke

- Greenfield projects with no legacy context
- A style / formatting opinion with no code to look at (Mode R needs a real diff)
- Anything that needs a push, MR, PR or remote merge - this skill stops at the
  local commit, always
- Questions about the tooling itself

## Setup (once per repository)

**This installation:** memory lives in `<skill>/workspace/memory/`, issue analyses in
`<workspace>/issue/<RepoName>/` (see SKILL.md -> HARD RULE 3). No
per-repository setup is needed; create
`<skill>/workspace/memory/repositories/<RepoName>/` from the repository template, or run
Mode B. Do not run the init scripts below against a repository.

Original per-repository setup (superseded, moved to `scripts/legacy/`, kept only
for historical reference - **do not run**):

```powershell
# from the repository root
.\<skill>\scripts\legacy\init-company-skill.ps1 -SkillDir <skill> -Repos ServiceA
```

```bash
bash <skill>/scripts/legacy/init-company-skill.sh <skill> ServiceA
```

This creates `.company-skill/` inside the target repository and adds it to
`.git/info/exclude` - both actions this installation's Hard Rules now forbid
(memory lives in `<skill>/workspace/memory/`, issue analyses in
`<workspace>/issue/<RepoName>/`, and the skill never edits a repository's
`.gitignore` or `.git/info/exclude`).

## What The User Will Be Asked

Mode B (onboarding) and analysis-only requests ask for none of these.

For a ticket that requests a change, two main implementation approvals, always:

```
1. AWAITING USER APPROVAL TO IMPLEMENT       (after the analysis)
2. AWAITING USER APPROVAL TO LOCAL COMMIT    (after build / test / diff)
```

The analysis itself closes with an **Approval Recommendation** - one of `APPROVE`,
`APPROVE WITH CONDITIONS`, `NEEDS HUMAN DECISION`, `NOT RECOMMENDED` - plus a
Manager Summary and, when approved, an Implementation Handoff. It is a
recommendation, never a self-approval: gate 1 above is still the user's
(`change-proposal.md`).

Plus conditional approvals and decisions, only when that situation actually arises:

```
DATABASE MUTATION APPROVAL REQUIRED         (a DB write becomes unavoidable)
TICKET-SYSTEM WRITE APPROVAL REQUIRED       (creating/changing a ticket record,
                                             e.g. `work task add` / `update`)
LOCAL DESTRUCTIVE GIT APPROVAL REQUIRED     (reset --hard, clean -f, restore <file>,
                                             stash drop, branch -D, ... - the normal
                                             workflow never needs one)
REQUIREMENT CLARIFICATION NEEDED            (the ticket and a designated baseline /
                                             reference document disagree on scope -
                                             the requirement owner decides, not a
                                             technical judgement call)
AWAITING USER PATTERN CHOICE                (a SOLID / maintainability alternative
                                             qualifies - existing pattern vs
                                             improvement; silence = existing pattern)
SHARED CAPABILITY EXTENSION APPROVAL        (the existing shared code cannot carry
  REQUIRED                                   the need as it stands - Gate 3's Reuse
                                             verdict is EXTENSION NEEDED. Nothing
                                             shared is modified until the user
                                             picks caller-side vs extension; a
                                             defaulted optional parameter counts)
AWAITING USER DECISION ON TEST COVERAGE     (no existing test covers the changed
                                             method / flow)
EXISTING TEST CONTRADICTS TICKET            (an existing test's requirement and the
                                             ticket genuinely disagree)
FIX LOOP EXHAUSTED                          (a build / test / lint / acceptance
                                             failure's Fix Loop stopped producing
                                             new information about the cause, or
                                             the real cause sits outside the
                                             approved scope - verification.md §3.5)
REGRESSION RISK - HIGH - UNRESOLVED         (Gate 5 found a HIGH security,
                                             server-side enforcement, data-integrity,
                                             transaction or audit-loss regression
                                             against the authoritative baseline -
                                             blocks Approval Gate #2 until resolved
                                             or explicitly accepted)
```

The skill also asks, once, at the very end and only if the user wants it: whether
the feature works. `<Ticket>驗收標準.md` is written only after that confirmation.

A `STATUS: BLOCKED` stop can also occur before analysis, but only when safe
implementation is genuinely impossible without an answer. Needing a DB write is
**not** a block - it is the separate Database Mutation approval above.

## What The User Still Does Themselves

```
git push
MR / PR creation
remote merge
deployment
```

These are never performed by the skill, in any circumstance.

## Output Locations

**Every file goes in a per-ticket folder.** Create
`<workspace>/issue/<RepoName>/<Ticket>/` **first**, then write inside it - never a
loose file directly under `<RepoName>/`. One flat directory holding several tickets'
analyses, plans, SQL, screenshots and review notes becomes unusable within weeks.

```
<workspace>/issue/<RepoName>/<Ticket>/      <- create this before the first file
    <Ticket>.md                             the analysis
    <Ticket>執行計畫.md  <Ticket>測試教學.md  ... anything else for this ticket
    temp/                                   scratch notes
```

- `<Ticket>` is the id exactly as the tracking system writes it (`7398`, `T12876`) -
  no prefix invented, no description appended to the folder name.
- **No ticket id yet?** Ask for one. If the user says there is none, use a short
  kebab-case topic folder (`resume-status-fn/`) and say in the reply that it should
  be renamed once a ticket exists.
- Material that outlives any single ticket - a schema reference, a field table, a
  shared function's notes - goes in `<RepoName>/_reference/`, not in a ticket folder
  and not loose at the top.
- Never reorganise or move a user's existing files unless they ask.

| Output | Location (inside `<workspace>/issue/<RepoName>/<Ticket>/`) | Committed? |
|---|---|---|
| Issue analysis | `<Ticket>.md` | Never (outside repository and skill) |
| Acceptance test cases | `<Ticket>驗收標準.md` - only after the user confirms the feature works | Never |
| Code review (Mode R) | `<branch-or-MR>-review.md` | Never |
| Table review | `<table>-資料表Review.md` | Never |
| E2E / root-cause investigation | `<Ticket>-調查報告.md` | Never |
| Skill retrospective | `<Ticket>skill待優化項目.md` - only on explicit request | Never |
| Scratch notes | `temp/` | Never |
| Cross-ticket reference material | `../_reference/<topic>.md` | Never |
| Memory | `<skill>/workspace/memory/**` (this installation) | Never (outside the repository) |
| Unknowns / corrections | `<skill>/workspace/memory/unknowns.md`, `corrections.md` | Never |
| Onboarding summary (Mode B) | inline in the reply, always | - |
| `PROJECT-QUICK-GUIDE.md` (Mode B) | only if the user asks for a file, at the requested location | Never |
| Code changes | the repository itself | Yes, after Approval #2 |
