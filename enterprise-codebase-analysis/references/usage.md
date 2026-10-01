# Usage & Triggers

This skill has three modes - see SKILL.md -> "Modes" for the authoritative
table and disambiguation rules. Summary for trigger-matching:

- a ticket / bug / feature / requirement behind the request -> **Mode A**
- understanding the repository / project as a whole -> **Mode B**
- understanding one existing piece of code, no ticket or change behind it -> **Mode C**

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

## When NOT To Invoke

- Greenfield projects with no legacy context
- Pure code review with no change intended
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

| Output | Location | Committed? |
|---|---|---|
| Issue analysis | `<workspace>/issue/<RepoName>/<issue>.md` (e.g. `<workspace-root>/issue/<RepoName>/`) | Never (outside repository and skill) |
| Acceptance test cases | `<workspace>/issue/<RepoName>/<issue>驗收標準.md` - only after the user confirms the feature works | Never |
| Skill retrospective | `<workspace>/issue/<RepoName>/<issue>skill待優化項目.md` - only on explicit request | Never |
| Memory | `<skill>/workspace/memory/**` (this installation) | Never (outside the repository) |
| Unknowns / corrections | `<skill>/workspace/memory/unknowns.md`, `corrections.md` | Never |
| Onboarding summary (Mode B) | inline in the reply, always | - |
| `PROJECT-QUICK-GUIDE.md` (Mode B) | only if the user asks for a file, at the requested location | Never |
| Scratch notes | `<workspace>/issue/<RepoName>/temp/` | Never |
| Code changes | the repository itself | Yes, after Approval #2 |
