# Workflow (Mode A - Detailed)

One ticket, one pass, two hard stops. Mode B (`repository-onboarding.md`) scans a
repo; Mode C (SKILL.md) explains existing code. Order of work and output per step
below - rules live in their own reference, not repeated here.

```
Ticket -> Repo (tentative) -> Parse Ticket
  -> Domain / Evidence / Auth Navigation -> Repository Memory      (Ticket Triage)
  -> [GATE 1] Requirement Resolution -> Classify -> Blocking -> Scope
  -> [GATE 2] Active Carrier Confirmation (conditional)
  -> Scoped Scan -> Existing Flow
  -> [GATE 3] Capability Ownership + Reuse + Negative Evidence (conditional)
  -> Root Cause -> Impact -> Convention Baseline + Existing Test Coverage
  -> Solution -> Pseudocode -> Plan -> Test Plan
  -> [GATE 5 run 1] Contract Preservation -> [GATE 4] Final Consistency
  == APPROVAL GATE #1 ==   (+ PATTERN CHOICE if one qualifies)
  -> Branch -> Implement -> [DB write? -> approval] -> [no tests? -> ask]
  -> Build / Test -> Diff -> [GATE 5 run 2] -> Memory Delta
  == APPROVAL GATE #2 ==   -> Local Commit -> [驗收標準] -> STOP
```

If the user asked only for analysis, stop after step 18 - Gates 4 and 5 run 1
still happen, but no approval to implement is requested.

---

## 0-2. Bootstrap, Repository (tentative), Parse Ticket

On the first ticket in a repository, create its memory folder from
`templates/workspace/memory/repositories/_REPO_TEMPLATE/` and `<workspace>/issue/<Repo>/`.
Never create `.company-skill/` or touch `.gitignore` / `.git/info/exclude`.

```
Repository Scope: ServiceA          |  Frontend -> ServiceB -> ServiceA -> ShardedDb
```
A first guess from what the ticket states; step 3 may confirm, narrow or replace
it. Load only the repositories in this flow and only the `shared/` + `global/`
entries it touches. When the workspace declares a ticket-system CLI (`workspace/PROFILE.md`), fetch a
ticket number / URL with it read-only rather than asking the user to retype it,
including the ticket's comments - the description field is often empty.
Extract only what the ticket contains; leave a missing field blank, not invented:

```
Requirement / Current Behavior / Expected Behavior / Issue Type / Domain
Surface / Symptom / HTTP Status / Endpoint / Exception / Identifier
Environment / Acceptance Criteria / Possible Components / Known Constraints
```
A blank field is not blocking (steps 7-9); if the ticket is vague but the intent
is clear, state the assumption and continue.
## 3-6. Ticket Triage

Three or four short shared-memory files read **before any code is opened**, so a
ticket starts with "which repo, which carrier, which known gate" rather than a full-text search. Each is a hint; `current code > memory` once scanning begins.

| Step | Read | When | For |
|---|---|---|---|
| 3 Domain | `shared/domain-entrypoints.md` | always | first repo to inspect, candidate entry point, whether the domain has **multiple carriers**, known cross-repo calls |
| 4 Evidence | `shared/logging-troubleshooting.md` | 500 / 401 / 403 / timeout / exception / 偶發 | which sink holds this failure, whether a trace id exists, whether this path is a known silent failure |
| 5 Auth | `shared/authentication.md` = who is this request; `shared/authorization.md` = is it allowed | login / cookie / token / 401 / 403 / "logged in but blocked" | do not conflate the two; check Account Status -> Technical Access Control -> Business Eligibility -> Role/Permission in that order |
| 6 Repo memory | `repositories/<Repo>/overview.md`, `patterns.md`, `dependencies.md` (+ `database.md` / `routing.md` if sharded) | after 3-5 narrowed the repo | record under `## Memory References` with "memory is advisory only" |

In a multi-carrier domain the ticket's own `Surface` / `Endpoint` / `Exception`
decides the carrier, never "which repo has a same-named Service"; re-verify a memory fact only under `memory-system.md` §2's four conditions.
## 6.5 GATE 1 - Requirement Resolution

Before classifying or scoping. Produces `## Requirement Resolution`, whose rows
come from the **ticket's own** explicit behaviours - never from a reference
document. Three lines when there is no designated baseline and no reference
document (`requirement-evidence-gates.md`).

## 7-9. Classification, Blocking Check, Scope

Classification decides scan depth (`scoped-scan.md`): **Bug** (root cause
mandatory) / **Optimization / Refactor** (flow, bottleneck, dependency, impact,
risk) / **Migration** (both sides, coexistence, rollback) / **Feature** (minimal
integration scan).

Blocking means "cannot safely continue without it": a contradictory requirement, a
missing business rule the change depends on, an unknown critical data source, a
needed product decision, a security risk.

```
STATUS: BLOCKED  -> list what needs confirmation, then STOP | READY FOR ANALYSIS
```
Two things that are **not** blockers: **a needed DB write** (the separate Database
Mutation Approval - `database-safety.md` - escalates to BLOCKED only if the user
declines, no read-only alternative exists, and root cause can't be found without
it), and **a requirement decision** ("product hasn't decided beyond the baseline"
doesn't block a ticket whose level-1 requirements are clear).

Keep the five categories apart: requirement / baseline / gap / technical blocker /
requirement decision (`requirement-evidence-gates.md`). Non-blocking unknowns go to
`workspace/memory/unknowns.md` with `Blocking Now: NO`. Write In Scope / Out of Scope - Out
of Scope is what stops the scan spreading; if step 3 flagged a multi-carrier
domain, say whether any *other* carrier is in scope.
## 9.5 GATE 2 - Active Carrier Confirmation (conditional)

Triggered by a page / screen / app-flow target, a designated baseline ("比照 X"), a
known multi-carrier domain, or more than one plausible same-named handler. Runs
**before any downstream trace** into Service / DAO / DB, producing a carrier
identity card per involved carrier (`requirement-evidence-gates.md`).

## 10-11. Scoped Scan and Existing Flow

`scoped-scan.md`. Stop the moment "can I implement this safely?" is yes.

- A stack trace in the ticket **is** the scan: walk it frame by frame against
  current code; do not add a repository-wide architecture scan on top.
- Before calling any Attribute / Filter / Middleware unused, check every
  registration path, not just `[Attribute]` usage.
- Write only this issue's flow. When Gate 2 ran, keep the carriers apart - ticket
  target / designated baseline / legacy-or-alternate / shared dependencies -
  labelling shared dependencies as dependencies, never as proof of the same flow.
- Mermaid only when it earns its place (multiple services / DBs, sync, cache,
  search, legacy-new coexistence, cross-repository).

## 11.5 GATE 3 - Capability Ownership, Reuse & Negative Evidence (conditional)

Triggered when the ticket reuses an existing verification / limit / quota /
counter / state machine / shared mutation, when the analysis is about to call
something missing, or when the change is about to add a method, parameter,
overload or abstraction, or modify shared code. Ask "does the ticket require it?"
**before** tracing the owner, then give each existing capability a `Reuse`
verdict - `SUFFICIENT AS IS` / `CALLER-SIDE` / `EXTENSION NEEDED`, built from a
written seam inventory. Shared code is not modified while a row sits at
`EXTENSION NEEDED` without a user decision (`capability-reuse.md`).
## 12-13. Root Cause (bug only) and Impact Analysis

```
Root Cause: CONFIRMED | CANDIDATE | UNKNOWN
Evidence:   file / code / config / DB / log / runtime behaviour
```
Never label a hypothesis `CONFIRMED`. Impact lists actual callers, shared
services, other repositories, DB writes, cached values, indexed fields and jobs -
not every theoretical consumer. In a multi-carrier domain, state explicitly
whether another active carrier needs a matching change, or why not, using Gate 2's
identity cards rather than a shared Service as the argument. A change to shared
code owes P3 (`engineering-principles.md`): enumerate the callers, and say
`UNKNOWN CALLERS` when the repository cannot prove there are none.

## 13.5 Convention Baseline + Existing Test Coverage

Before designing the solution, record how this repository already writes this kind
of code and what already tests it: coding / error handling / logging / testing,
each with the file it came from and its source level, or `UNKNOWN`; plus which
tests cover the method or flow and where you looked. Never infer a convention from
the framework, and cover only the convention governing this ticket's diff
(`development-convention.md` §1, `verification.md` §2).

## 14-17. Solution, Pseudocode, Plan, Test Plan

Bias: small, safe, existing-capability-first (`Understand -> Verify -> Modify`).
**Bug/Feature/Migration**: existing-pattern-first, no deliberately-introduced
pattern (`development-convention.md` §3b) - a more SOLID alternative is only an
**option presented to the user**, when it passes all four §3b preconditions,
otherwise a one-line follow-up note. **Optimization/Refactor**: this step *is*
the mandatory Design & Implementation Strategy (§3a) - write it before the
Pseudocode below. Neither path adds a method, parameter or abstraction for
something an existing seam already reaches (Gate 3's `Reuse` column), or a
drive-by rename, package upgrade or redesign outside that plan. Test plan
minimum: happy path, original bug reproduction, regression, boundary - plus a
case for every non-`unchanged` row of Gate 5's table, including each side
effect firing once on success and not at all on failure. A test needing a DB
write goes through the Database Mutation Approval Gate first.

## 17.4-18. GATE 5 run 1, GATE 4, then APPROVAL GATE #1

**Gate 5 run 1** compares the **planned** change against the authoritative
baseline (main / the authoritative branch as of the ticket's start - never the
feature branch's previous commit) across the seven contract dimensions, after a
Side-effect Discovery sweep of the mutation's success **and** failure paths.
Every unintended delta is resolved in the plan, or carried to the approval gate
as an explicit decision. Table, baseline rules, the six side-effect attributes
and risk levels: `regression-validator.md`.

**Gate 4** is then a recompute, not a rewrite or a rescan: superseded conclusions
are **deleted**, not annotated; every plan item traces to a level-1 requirement;
every blocker really blocks; every MISSING meets Gate 3's threshold. Output a
short `## Consistency Pass`. Runs for analysis-only requests too
(`requirement-evidence-gates.md`).

**Approval Gate #1** happens only when a change was asked for. Present the
analysis, then `AWAITING USER APPROVAL TO IMPLEMENT` - plus
`AWAITING USER PATTERN CHOICE` if step 14 produced a qualifying option
(`development-convention.md` §3). "Looks good" is approval; silence is not;
silence on the pattern choice means Option A. No branch before this gate.

## 19-20. Branch and Implement

Branch name by the 5-level priority in `git-safety.md` (live repository rule file
first, memory second); never branch off or commit onto `develop`/`main`/`master`.
Implement existing-pattern-first per the Convention Baseline: smallest reasonable
diff, the repository's native error-handling channel, its logger and placeholder
rule, no new abstraction or package the ticket does not need
(`development-convention.md` §2, §4, §5).

```
DB write needed?          -> DATABASE MUTATION APPROVAL REQUIRED, then wait
No test covers the flow?  -> NO RELEVANT TESTS FOUND, ask the user, wait
```
No local destructive git without approval; no push / MR / PR / remote or
production mutation at any point.

## 21. Build / Test / Diff  (`verification.md` §1-§3)

```
<build command>  <relevant test command>  git status  git diff
git add <specific ticket files>           git diff --cached
```
Build is reported as exactly one of `PASS` / `FAILED` / `NOT RUN` with the command
run; only `PASS` permits saying the work is complete. Run tests **related to this
change** - Existing Test Coverage + Impact Scope + one per non-`unchanged` Gate 5
row + what you added - via the runner's own filter, not the whole suite. A
failure also failing at the Gate 5 baseline is `PRE-EXISTING FAILURE`, reported
not fixed. Existing tests are preserved; never run a deploy/push target; confirm
no skill document is staged.

## 21.5 GATE 5 run 2 - Contract Preservation on the real diff

Re-run the table against `baseline -> final working tree`, not against run 1 and
not against the previous commit, re-applying the five checks (sync -> background;
exception swallowed but success returned; effect lost or duplicated; logging /
audit downgraded; other callers affected). **Calling the same method is not the
same contract.** A HIGH security, server-side enforcement, data-integrity,
transaction-atomicity, audit-loss, lost-required-side-effect or changed-failure-
semantics regression that is unresolved and not explicitly accepted by the user
**blocks Approval Gate #2**: report `REGRESSION RISK - HIGH - UNRESOLVED` and
stop for a decision (`regression-validator.md`, HARD RULE 13).

## 22-24. Memory Delta, APPROVAL GATE #2, Local Commit, STOP

Run the admission gate (`memory-admission.md`) - `Memory Delta: NONE` is a normal
result needing nothing further. If something is admitted, report targeted `ADD` /
`UPDATE` / `CORRECT` / `PROMOTE` / `DEMOTE` by file + section, never a regenerated file (`memory-operations.md` §10-§11).
Report with `templates/implementation-result.md` - build status with its command,
test results with counts, the test-preservation statement, the convention source
and Gate 5 run 2's result - ending `AWAITING USER APPROVAL TO LOCAL COMMIT`.
Commit message format follows the same 5-level priority as the branch
(`git-safety.md`). Then stop: push, MR, PR and merge belong to the user.

## 25. Post-Completion Documents (conditional)

Neither is automatic; both are local-only (HARD RULE 3, `verification.md` §4).
`<Ticket>驗收標準.md` only after implementation + a passing build + the user
**explicitly** confirming the feature works (a green build is not confirmation).
`<Ticket>skill待優化項目.md` only when the user asks for a retrospective - and any
rule it proposes goes through "Adding a rule" in `engineering-principles.md`
before it is written into this skill.
