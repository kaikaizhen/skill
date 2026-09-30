---
name: enterprise-codebase-analysis
description: Reusable analysis engine for organization-specific codebase work, backed by a persistent organization workspace. Use when repository evidence, architecture knowledge, historical context, business rules, cross-repository relationships or accumulated organization memory are material to the task - a repository under this skill's workspace/memory/repositories/, a repository the user calls an organization/company repo, or one whose own instructions identify it as such. Three modes. Mode A (Ticket) - ticket / bug / feature / optimization / refactor / migration / root cause / impact analysis / implementation - scoped scan, plan, human approval, local implementation, approval, local commit. Mode B (Repository Onboarding) - "scan / understand this repo", architecture, domains, endpoints - read-only, inline summary, seed memory, STOP. Mode C (Scoped Explanation) - "what does this API / service / DB flow do" - business meaning first, then technical flow, then where to look; no branch, no code change. Memory is a hint, current code wins. Never pushes, never creates MR/PR, never mutates a DB without explicit approval. Do NOT use for generic technology questions (what is Redis / OpenSearch / EF Core / async, Kafka vs RabbitMQ) or for repositories outside the organization workspace.
version: 4.0
status: stable
---

# Enterprise Codebase Analysis & Safe Implementation

**Router only**: applicability, mode selection, never-violated invariants, memory
scope, and which reference to load when. Each procedure is owned by exactly one
reference - here the rule, there the how; on any detail that reference wins.
**Load a reference only when its trigger fires**: never read all of `references/`,
never pre-load every repository's memory. Goal: understand enough to implement
safely -> propose -> approval -> implement -> approval -> local commit -> `STOP`;
never "understand the whole system first".

## Applicability

Organization repositories only. Evidence: a folder under
`workspace/memory/repositories/`, a namespace or marker recorded in
`workspace/PROFILE.md`, repository-local instructions saying so, or the user saying
so. A generic technology is never evidence - generic technology questions ("what is
Redis / OpenSearch / async", "Solr vs Elasticsearch"), greenfield work, tooling
questions and anything needing a push / MR / PR are **not** this skill. The task
must actually turn on this organization's repositories, architecture, business flow,
current implementation, cross-repository relationships or accumulated memory.
Routing: `~/.claude/CLAUDE.md`; detail: `usage.md`.

**Engine / workspace boundary.** `SKILL.md`, `references/` and `templates/` are the
reusable engine and never depend on one organization's facts. Everything specific to
this organization - architecture, repositories, domains, business rules,
infrastructure, corrections, unknowns, and organization-only tooling procedures -
lives under `workspace/`, which is replaced wholesale when the engine is pointed at
a different organization. Start at `workspace/PROFILE.md` when you need to know what
this organization is or where its knowledge lives; skip it when routing already
names the target.

**Repository-local rules win** - a repository's own `CLAUDE.md`, `AGENTS.md` or
`.claude/skills/*` outranks this skill on what it defines (branch naming, commit
format, coding conventions); this skill supplies scoped analysis, memory and gates.
Exception: HARD RULES, which a repository file may only make stricter.

## Modes

Pick the mode first; it sets scan depth, output and which references load. All three
end with `STOP`. Code changes happen in Mode A only, after Approval Gate #1 - B and C
never change code, never branch, never ask for a ticket number, AC or approval.

```
A Ticket      ticket / bug / feature / refactor / migration / a reported problem's
              root cause / a requirement's impact.  Scan scoped to the issue.
              analysis -> (approval) -> implementation -> (approval) -> local commit
              loads workflow.md + whichever gates fire
B Onboarding  "先掃 <repo>", "幫我理解這個專案", onboarding, build this repo's
              knowledge, architecture / domains / endpoints.  Breadth-first then
              core flows, read-only. -> inline summary + seeded memory
              loads repository-onboarding.md
C Scoped      "這支 API 在做什麼", "幫我追這段 call flow" - no ticket behind it. Scan
  Explanation only what answers the question. -> business meaning -> technical flow
              -> where to look.   loads this file
```

**A vs C**: a ticket / bug / requirement is **Mode A** even when only diagnosis is
wanted; "explain this code" with nothing reported behind it is **Mode C**. Unsure ->
Mode C; it becomes A the moment a change is asked for. **Analysis-only (in Mode A)**:
stop after the analysis - no `AWAITING USER APPROVAL TO IMPLEMENT`, no offer to
implement. **Mode C** labels every statement `CONFIRMED` / `INFERRED` / `UNKNOWN`
and confirms the carrier in a multi-carrier domain, but runs no gate paperwork and
produces no diff.

## Evidence & Scope Invariants

`SCOPE FIRST / EVIDENCE ENOUGH / STOP WHEN SUFFICIENT`. Detail lives in
`scoped-scan.md`, `capability-reuse.md` and `engineering-principles.md`.

- Scope this issue first, at a depth proportional to it, and stop scanning the
  moment you can implement safely. `Unknown != Blocking`.
- **Negative evidence**: "I did not find it" is not "it is not there".
  `CONFIRMED MISSING` needs the active carrier, the capability owner and the
  authoritative mutation path all confirmed; short of that it is
  `NOT OBSERVED IN TRACED PATH` (Gate 3).
- Use what exists before writing anything new; before touching code with more than
  one caller, prove in writing that no existing seam reaches the need (Gate 3).
- Same business domain is not the same execution path; a shared Service / DAO /
  table proves a dependency, not a shared flow (Gate 2).
- "No `[Attribute]` anywhere" is not "unused" - global filters, `Startup` /
  `Global.asax`, DI and middleware are live registration paths.
- An analysis states **one** version of the truth; superseded conclusions are
  deleted, not left beside the newer one (Gate 4).
- Engineering risk is reasoned through **P1** server-side authority · **P2**
  contract parity (the same method call is not the same contract) · **P3** blast
  radius · **P4** state safety · **P5** existing capability first - never
  per-ticket checklists.

## HARD RULES (never weakened, never overridden)

1. **NO REMOTE GIT MUTATION** - no push, `gh pr create`, `glab mr create`, MR / PR,
   remote merge or remote branch change; never commit onto `develop` / `main` /
   `master`. The user runs those.
2. **DB MUTATION REQUIRES EXPLICIT USER APPROVAL** - every time, "transaction +
   rollback" and test-data writes included.
3. **SKILL DOCUMENTS ARE LOCAL ONLY, NEVER INSIDE THE REPOSITORY** - zero repository
   diff: no `.company-skill/`, no `.gitignore` / `.git/info/exclude` edit. Reusable
   knowledge lives in `<skill>/workspace/memory/**`, per-ticket output in
   `<workspace>/issue/<RepoName>/`, code changes only in the target repository.
   **Never store credentials, hosts or connection-string values in memory** (key
   *names* are fine). Never run `scripts/legacy/init-company-skill.*` (superseded).
   Paths, templates and output locations: `usage.md` -> Output Locations.
4. **IMPLEMENTATION REQUIRES USER APPROVAL** (Approval Gate #1).
5. **LOCAL COMMIT REQUIRES USER APPROVAL** (Approval Gate #2) - the end point.
6. **MEMORY IS REFERENCE ONLY; CURRENT EVIDENCE OVERRIDES MEMORY.**
7. **REPOSITORY MEMORY IS ISOLATED BY DEFAULT** - no cross-repo inference.
8. **MEMORY IS UPDATED INCREMENTALLY** - targeted edits only; never regenerate a file.
9. **LOCAL DESTRUCTIVE GIT REQUIRES EXPLICIT USER APPROVAL** - `reset --hard`,
   `clean -f/-fd`, `checkout -- <f>`, `restore <f>`, `stash drop/clear`, `branch -D`.
10. **NO COMPLETION CLAIM WITHOUT A PASSING BUILD** - otherwise report
    `VERIFICATION INCOMPLETE`, with the reason.
11. **EXISTING TEST COVERAGE IS PRESERVED** - never delete, disable or weaken a test
    to make a run green; run the set *related to this change*; a failure that also
    fails at the Gate 5 baseline is pre-existing, not fixed here.
12. **THE TICKET IS THE SCOPE AUTHORITY** - its requirement and AC alone decide scope;
    a designated baseline, reference docs and memory navigate but never add a
    requirement, gap, blocker or data design. The repository's existing pattern is
    the default implementation.
13. **NO SILENT CONTRACT REGRESSION** - compare against the authoritative baseline on
    all seven contract dimensions; an unresolved HIGH regression the user has not
    accepted **blocks Approval Gate #2**.
14. **THE FRONTEND IS NOT A SECURITY BOUNDARY** - confirm authoritative server-side
    enforcement; removing a UI entry does not close the route behind it.

Each rule's procedure is in the reference the routing table below names.

## Reference Routing

Load a file when its trigger fires - not before, not all of them. The first three
rows are Mode A's five gates; each has a trigger, a required output and a stop
condition. Proportionality decides a gate's *length*, never whether it runs, and
**no gate authorises tracing to the DB / SP / external provider "for completeness"**.

| Load when | Reference |
|---|---|
| **Gate 1** Requirement Resolution (every ticket) · **Gate 2** Active Carrier (page / "比照 X" / multi-carrier) · **Gate 4** Final Consistency (before Approval #1) | `requirement-evidence-gates.md` |
| **Gate 3** Capability Ownership - reuse, a MISSING claim, or any new method / parameter / abstraction / shared-code change | `capability-reuse.md` |
| **Gate 5** Contract Preservation - any change to an existing flow; runs TWICE | `regression-validator.md` |
| Mode A starts - step order, both approval gates | `workflow.md` |
| Scan depth, stop conditions, carrier / registration traps | `scoped-scan.md` |
| Writing code after Approval #1 - convention order, refactor vs bug/feature strategy, error handling, logging | `development-convention.md` |
| P1-P5 need depth, or a new rule is proposed for this skill | `engineering-principles.md` |
| Build verification, which tests to run, 驗收標準 / retrospective documents | `verification.md` |
| Any git step beyond `status` / `diff` / `log`, or a branch / commit message | `git-safety.md` |
| Any DB access, and always before any write | `database-safety.md` |
| **Writing** new reusable knowledge - admitted at all? which layer, which unit, update / create / split / reject | `memory-admission.md` (sufficient on its own) |
| **Reading / locating** memory - trust model, layout, when to re-verify | `memory-system.md` |
| Evidence conflict, demotion, correction, promotion, delta reporting - only when that situation occurs | `memory-operations.md` |
| Mode B - phases, repository kind, memory seeding | `repository-onboarding.md` |
| The task needs an organization-only tool, ticket system or companion knowledge source | `workspace/PROFILE.md` -> Organization-Specific Procedures |
| Unsure whether to invoke, what the user is asked, where output goes | `usage.md` |
| A worked end-to-end example is genuinely needed | `examples.md` |

## Memory Routing

```
Lookup (to narrow the search only)
  repository -> relevant shared -> relevant global -> this issue's evidence
Trust (who wins on disagreement)
  repository-local instructions = current source / runtime / config / schema / log
   > repository CONFIRMED > shared CONFIRMED > global CONFIRMED > inferred > unknown
```

- Memory is navigation and historical knowledge; **current evidence is authoritative
  for current behaviour**. Load the ticket's repository folder plus only the
  `shared/` + `global/` entries it actually touches - never every repository's memory.
- Trust levels are `CONFIRMED` `INFERRED` `UNKNOWN` `OUTDATED` `CONFLICTING` - these
  five only. "grep found nothing" is not one of them.
- Trusted as navigation **without re-verifying every fact**; spot-check one only when
  it affects this change's correctness, current evidence contradicts it, it looks
  stale, or the ticket depends on it.
- **Do not automatically persist task findings** - a completed ticket often has
  `Memory Delta: NONE`. Before writing, run the admission gate
  (`memory-admission.md`): reusability -> evidence -> scope -> owner -> duplication
  -> cohesion. Update the canonical owner where one exists; create a new unit only
  when it has a clear independent retrieval trigger. One canonical owner per fact -
  reference it elsewhere, never copy it. Non-blocking gaps -> `workspace/memory/unknowns.md`
  with `Blocking Now: NO`.
- Which repositories are onboarded, which domain lives where, and any
  organization-only tooling or companion knowledge source are recorded in
  `workspace/PROFILE.md` - read it when you need that map. Entering a repository,
  read its `overview.md` first.
- When a domain's knowledge is split across several units it has a hub file that
  routes to exactly one of them; enter at the hub rather than loading the family.
- A companion knowledge source declared in the workspace is **candidate evidence**
  only - never an extra memory tier, and never enough on its own to set scope,
  carrier, root cause or a design.

