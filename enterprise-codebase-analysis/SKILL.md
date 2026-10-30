---
name: enterprise-codebase-analysis
description: Reusable analysis engine for organization-specific codebase work, backed by a persistent organization workspace. Use when repository evidence, architecture knowledge, historical context, business rules, cross-repository relationships or accumulated organization memory are material to the task - a repository under this skill's workspace/memory/repositories/, a repository the user calls an organization/company repo, or one whose own instructions identify it as such. Four modes. Mode A (Ticket) - ticket / bug / feature / optimization / refactor / migration / root cause / impact analysis / implementation - scoped scan, plan, human approval, local implementation, self-review, approval, local commit. Every Mode A task first picks an analysis tier - L1 lightweight (copy text, a simple condition, a local bug), L2 standard (business logic, a service / repository change, a new shared method), L3 deep (a column or structure change, an ID / GUID / key / hash / index mechanism, an API contract or data-meaning change, cross-repository work, migration or compatibility) - by real risk and reach, never by diff size, and searches outward only as far as the evidence requires. Before proposing a change it runs a codebase-consistency gate: what already implements this and whether it is genuinely reusable, whether any field's business meaning would be overloaded (same data type is not same meaning; a hash, GUID or index is not automatically a durable identifier), whether meaning survives the whole layer contract, and a comparison of only the real options - verdict PASS / PASS WITH CONDITIONS / NEEDS HUMAN DECISION / BLOCKED feeding the existing approval recommendation. A missing consumer is never treated as proof the code is dead. Mode A also covers SQL Server table design and review: whenever a task actually involves CREATE TABLE / ALTER TABLE, adding renaming or dropping a column, changing a type, length, NULL or DEFAULT, changing a primary key, unique key, index or constraint, refactoring a Schema or relation, reviewing an unimplemented table design, or judging whether a Schema change breaks existing behaviour, it applies the table design standard and emits a fixed-format table review (field table, index table, runnable commented DDL, one problem list graded only 🔴 / 🟡 / 🟢, open decisions) - and for a change to an existing table it also traces dependencies, Before / After behaviour, side effects and deployment compatibility. Explaining a SELECT / JOIN, answering SQL syntax, or reviewing ordinary application code never forces that document. Mode A also covers E2E / end-to-end anomalies and deep root cause analysis: an E2E run showing a user-visible defect, a wrong business result behind a success screen, data inconsistency, duplicate / lost / overwritten data, a cross-system side effect or a concurrency / timing defect escalates to a full cross-layer investigation (user symptom, database facts, whole call path, how the wrong state forms, write-by-write interruption point, root cause vs trigger vs amplifier vs missing guard, prioritised fixes, regression suite) and a developer-ready report; investigation is read-only and a green HTTP 200 is never treated as a pass. Mode B (Repository Onboarding) - "scan / understand this repo", architecture, domains, endpoints - read-only, inline summary, seed memory, STOP. Mode C (Scoped Explanation) - "what does this API / service / DB flow do" - direct answer first, then business meaning, technical flow, where to look; no branch, no code change. Mode R (Code Review) - "review this MR / branch / diff", "does this change have problems" - resolves the diff range with the user, traces the call path down to the code that really performs I/O, and by default checks correctness, security (injection / authorization / IDOR / secrets), performance and I/O, asynchrony and transactions, partial-success handling and project convention - not just the diff's own lines; separates introduced from pre-existing (high-risk pre-existing reported with a hotfix recommendation), grades severity by real impact, and never guesses: an unverifiable point becomes a to-confirm question, not a defect. Read-only, changes no file. Every reply is conclusion-first and sized to the question (tables where they help, no cross-references); full gate records go to local files. Memory is a hint, current code wins. Never pushes, never creates MR/PR, never mutates a DB without explicit approval. Do NOT use for generic technology questions (what is Redis / OpenSearch / EF Core / async, Kafka vs RabbitMQ) or for repositories outside the organization workspace.
version: 4.2
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
`workspace/memory/repositories/`, a namespace or marker in `workspace/PROFILE.md`,
repository-local instructions saying so, or the user saying so. A generic technology
is never evidence - generic technology questions ("what is Redis / async", "Solr vs
Elasticsearch"), greenfield work, tooling questions and anything needing a push /
MR / PR are **not** this skill. The task must actually turn on this organization's
repositories, architecture, business flow, current implementation, cross-repository
relationships or memory. Routing: `~/.claude/CLAUDE.md`; detail: `usage.md`.

**Engine / workspace boundary.** `SKILL.md`, `references/` and `templates/` are the
reusable engine and never depend on one organization's facts; inside it,
`references/thinking/` holds the transferable analysis principles (start at
`thinking/README.md` when a problem is new) and `references/` this skill's procedure. Everything specific to
this organization - architecture, repositories, domains, business rules,
infrastructure, corrections, unknowns, organization-only tooling - lives under
`workspace/`, replaced wholesale when the engine is pointed at another organization.
Start at `workspace/PROFILE.md` when you need that map; skip it when routing already
names the target.

**Runtime / model boundary.** A model-agnostic methodology, not a model
integration: it never selects, names, configures or calls a model - the host's own
picker is the mechanism, and no provider framework is built beside it. No provider,
model, endpoint, host, port or token count appears in `SKILL.md` / `references/` /
`templates/` (HARD RULE 15); the engine assumes only a declared `context_limit` and
`capabilities`, and derives its context budget from those. Switching model
mid-ticket replaces the reasoner and nothing else - state, evidence, diff and passed
gates survive. Detail: `runtime-contract.md`; declared runtime:
`workspace/references/runtime.yaml`.

**Repository-local rules win** - a repository's own `CLAUDE.md`, `AGENTS.md` or
`.claude/skills/*` outranks this skill on what it defines (branch naming, commit
format, coding conventions); this skill supplies scoped analysis, memory and gates.
Exception: HARD RULES, which a repository file may only make stricter.

## Modes

Pick the mode first; it sets scan depth, output and which references load. All four
end with `STOP`. Code changes happen in Mode A only, after Approval Gate #1 - B, C
and R never change code, never branch, never ask for a ticket number, AC or approval.

```
A Ticket      ticket / bug / feature / refactor / migration / a reported problem's
              root cause / a requirement's impact / an E2E run that exposed a
              user-visible defect / a table or Schema change.  Scope to the issue.
              analysis + change proposal -> (approval) -> implementation
              -> self-review -> (approval) -> local commit
              loads workflow.md, change-proposal.md, code-quality-gates.md, gates
B Onboarding  "先掃 <repo>", "幫我理解這個專案", onboarding, build this repo's
              knowledge, architecture / domains / endpoints.  Breadth-first then
              core flows, read-only. -> inline summary + seeded memory
              loads repository-onboarding.md
C Scoped      "這支 API 在做什麼", "幫我追這段 call flow" - no ticket behind it. Scan
  Explanation only what answers the question. -> direct answer -> business meaning
              -> technical flow -> where to look.   loads explanation-standard.md
R Review      "review 這個 MR / branch / diff", "這段改動有沒有問題" - code that
              already exists. Diff is the scope, widened only where it asks ->
              verdict + findings table, zero file changes (HARD RULE 16).
              loads code-review.md + code-review-checks.md (repo chapter wins)
```

**A vs C**: a ticket / bug / requirement is **Mode A** even when only diagnosis is
wanted; "explain this code" with nothing reported behind it is **Mode C**. Unsure ->
Mode C; it becomes A the moment a change is asked for. **A vs R**: judging a diff /
MR / branch that exists is **Mode R**; asking for the fix is Mode A with its own
Approval Gate #1 - a review never slides into editing. **Analysis-only (in Mode A)**:
stop after the analysis - no `AWAITING USER APPROVAL TO IMPLEMENT`, no offer to
implement. **Mode C** labels every statement `CONFIRMED` / `INFERRED` / `UNKNOWN`
and confirms the carrier in a multi-carrier domain, but runs no gate paperwork and
produces no diff.

## Response Invariants (every reply, every mode)

Full analysis is the agent's job; the reply's job is to be understood fast. These
govern **presentation only** - they never shorten a scan, skip a gate, drop an
evidence label or an approval line. Detail and per-task table shapes:
`thinking/explanation-standard.md`.

- **Conclusion first** - line one answers the question, then cause -> concrete fix -> next step. No narrative before it.
- **Size follows the question** - 1-3 sentences for a simple one; a review or analysis shows its 3-5 most important items, full detail only on request. Never widen an asked question into a research report.
- **Tables first, not tables always** - status (✅ ❌ ❓), review findings (嚴重度 🔴 🟡 🟢 · 驗證 ✅ ❓ · 新舊 - three axes never merged), test plans and troubleshooting use `thinking/explanation-standard.md` §4's shapes; a short answer stays prose.
- **Concrete** - name the API, method, mechanism or `path:line`, never "improve the validation".
- **Plans are rows, not reasoning** - | 需求 | 目標 | 修改位置 | 修改方式 | 可安全執行 |, no "because ..., therefore ..." prose; anything unconfirmed tells the user exactly what to run or open (command / SQL / file -> key).
- **Every item stands alone** - no "see C-02 / finding #3 / Gate 5 row"; each row states its own problem, cause and fix.
- **Reply is the digest, the file is the record** - templates and gate blocks go to the local issue / review file; the reply carries what the user must understand and decide, the file path, and any required `AWAITING ...` line.
- **No chasing** - one short gloss per project-specific term on first use, every action names its actor and a value its provenance, only where the reader would otherwise get stuck.

## Evidence & Scope Invariants

`SCOPE FIRST / EVIDENCE ENOUGH / STOP WHEN SUFFICIENT`. Detail lives in
`thinking/scoped-scan.md`, `thinking/capability-reuse.md` and `thinking/engineering-principles.md`.

- Scope this issue first, at a depth proportional to it, and stop scanning the moment you can implement safely. `Unknown != Blocking`.
- **Negative evidence**: "I did not find it" is not "it is not there". `CONFIRMED MISSING` needs the active carrier, the capability owner and the authoritative mutation path all confirmed; short of that it is `NOT OBSERVED IN TRACED PATH` (Gate 3).
- Use what exists before writing anything new; before touching code with more than one caller, prove in writing that no existing seam reaches the need (Gate 3). **Understand the existing design before deciding a new one is needed**, and never move a new concept into a field that means something else - same data type is not same meaning (Gate 7, `thinking/consistency-gate.md`).
- Same business domain is not the same execution path; a shared Service / DAO / table proves a dependency, not a shared flow (Gate 2).
- "No `[Attribute]` anywhere" is not "unused" - global filters, startup wiring, DI and middleware are live registration paths.
- An analysis states **one** version of the truth; superseded conclusions are deleted, not left beside the newer one (Gate 4).
- Engineering risk is reasoned through **P1** server-side authority · **P2** contract parity (the same method call is not the same contract) · **P3** blast radius · **P4** state safety · **P5** existing capability first - never per-ticket checklists.

## Quality Invariants (write it right, do not review it in afterwards)

**Compiling is not working, and an implemented method is not a working business
flow.** Design inputs while the diff is written, confirmed once at **Gate 6**,
applied to an existing diff in Mode R. Depth follows blast radius, never a
repository sweep for a small fix. Seven dimensions in full: `thinking/code-quality-gates.md`;
the six checks a review always runs: `thinking/code-review-checks.md`.

- **Reachability** - name the real caller at `path:line` and the business condition reaching the new code; a return value nobody reads validates nothing.
- **Backward compatibility** - compare behaviour per data population (new record, old member, historical / imported data, existing caller, partial update). A rule tightened with no requirement behind it is forbidden (HARD RULE 12); a needed break is proposed with a migration or grace path, never done silently.
- **Boundaries** - `null`, empty, whitespace, format, extremes, overflow; a date against the range its type *and* its column allow.
- **One rule, one condition** - the same business rule must not disagree between frontend, backend, DB, preview and status calculation without a requirement.
- **Verification honesty** - every test claim is `EXECUTED AND PASSING`, `STATIC REVIEW ONLY` or `NOT VERIFIED`; never the first without the command.

## HARD RULES (never weakened, never overridden)

1. **NO REMOTE GIT MUTATION** - no push, `gh pr create`, `glab mr create`, MR / PR,
   remote merge or remote branch change; never commit onto `develop` / `main` /
   `master`. The user runs those.
2. **DB MUTATION REQUIRES EXPLICIT USER APPROVAL** - every time, "transaction +
   rollback" and test-data writes included.
3. **SKILL DOCUMENTS ARE LOCAL ONLY, NEVER INSIDE THE REPOSITORY** - zero repository
   diff: no `.company-skill/`, no `.gitignore` edit, and no rule / review document
   authored into a repository. Reusable knowledge -> `<skill>/workspace/memory/**`,
   per-ticket and review output -> `<workspace>/issue/<RepoName>/`, code changes
   only in the target repository. **Never store credentials, hosts or
   connection-string values in memory** (key *names* are fine). Locations:
   `usage.md` -> Output Locations.
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
    fails at the Gate 5 baseline is pre-existing, reported not fixed.
12. **THE TICKET IS THE SCOPE AUTHORITY** - its requirement and AC alone decide
    scope; a designated baseline, reference docs and memory navigate but never add a
    requirement, gap, blocker or data design. The repository's existing pattern is
    the default implementation.
13. **NO SILENT CONTRACT REGRESSION** - compare against the authoritative baseline on
    all seven contract dimensions; an unresolved HIGH regression the user has not
    accepted **blocks Approval Gate #2**.
14. **THE FRONTEND IS NOT A SECURITY BOUNDARY** - confirm authoritative server-side
    enforcement; removing a UI entry does not close the route behind it.
15. **THE ENGINE IS MODEL-AGNOSTIC** - no provider, model, endpoint, host, port,
    token count or API key name in `SKILL.md` / `references/` / `templates/`; that
    belongs to `workspace/references/runtime.yaml`. A model's own claim is never
    evidence (rule 10), tool execution is always local, and no gate is skipped or
    shortened because the selected model is small.
16. **A REQUESTED REVIEW IS READ-ONLY** - Mode R reports findings and changes no
    file, not even an "obvious" fix; applying them is a new Mode A ticket through
    Approval Gate #1. It never assumes a branch name when resolving its diff range,
    never escalates a pre-existing defect into a blocker for this change, and never
    states an unverifiable suspicion as a defect - ❓ 待確認 instead.

Each rule's procedure is in the reference the routing table below names.

## Reference Routing

Load a file when its trigger fires - not before, not all of them. The first rows
cover Mode A's seven gates; each has a trigger, a required output and a stop
condition. Proportionality decides a gate's *length*, never whether it runs, and
**no gate authorises tracing to the DB / SP / external provider "for completeness"**.

| Load when | Reference |
|---|---|
| **The problem is unfamiliar**, or which principle applies is unclear - the diagnostic order (what is true -> how deep -> the real path -> what it risks -> does it fit what exists -> what it would break) and which principle fires when. A symptom met before can be located faster in `problem-map.md`, whose **absence of a row means nothing** | `thinking/README.md` |
| **Gate 1** Requirement Resolution (every ticket) · **Gate 2** Active Carrier (page / "比照 X" / multi-carrier) · **Gate 4** Final Consistency (before Approval #1) | `requirement-evidence-gates.md` |
| **Gate 3** Capability Ownership - reuse, a MISSING claim, or any new method / parameter / abstraction / shared-code change | `thinking/capability-reuse.md` |
| **Gate 5** Contract Preservation - any change to an existing flow; runs TWICE | `thinking/regression-validator.md` |
| An E2E run shows a user-visible anomaly, data inconsistency, duplicate / lost / overwritten data, a cross-system side effect, or the user asks for a deep root cause analysis | `e2e-investigation.md` (+ `templates/e2e-bug-report.md`) |
| A table / Schema change is involved - `CREATE TABLE`, `ALTER TABLE`, a column, type, NULL, DEFAULT, PK / unique key / index / constraint, a relation or Schema refactor, a design draft, or "does this Schema change break existing behaviour" | `thinking/table-design.md` (design rules) + `table-review.md` (fixed review format) |
| The change must stop the same request being processed twice, or a duplicate / half-written row was observed - layered lock + idempotent write + transaction, where to place the guard, how to verify under real concurrency | `thinking/duplicate-write-defence.md` |
| **Gate 7** Codebase Consistency - before the solution: existing implementation first, semantic integrity, identifier lifecycle, cross-layer meaning, solution comparison; verdict feeds the Approval Recommendation | `thinking/consistency-gate.md` |
| Choosing analysis depth - the L1 / L2 / L3 tier, outward search order, early exit, escalation triggers, evidence labels, cost control | `thinking/risk-tiers.md` |
| **Gate 6** Self-Review - every Mode A implementation, after Gate 5 run 2 - and the write-time quality rules used from analysis onward | `thinking/code-quality-gates.md` |
| The user asks for a **review** of an existing MR / branch / diff / commit range (Mode R) - procedure, then the six checks every review runs by default | `code-review.md` + `thinking/code-review-checks.md` |
| Mode A starts - step order, both approval gates | `workflow.md` |
| Assembling the Mode A report - proposal shape, regression grade, approval verdict, manager summary, implementation handoff | `change-proposal.md` |
| The affected flow (or a change under review) contains encoded literals - status codes, bit flags/masks, thresholds, limits, legacy codes | `thinking/encoded-values.md` |
| Writing any reply or report for a reader - shape, length, table formats, no cross-references, clarity rules | `thinking/explanation-standard.md` |
| Scan depth, stop conditions, carrier / registration traps | `thinking/scoped-scan.md` |
| Writing code after Approval #1 - convention order, refactor vs bug/feature strategy, error handling, logging | `development-convention.md` |
| P1-P5 need depth, or a new rule is proposed for this skill | `thinking/engineering-principles.md` |
| Build verification, which tests to run, **the Fix Loop** after a failure, 驗收標準 / retrospective documents | `verification.md` |
| Context budget is tight, context is being trimmed / summarised, the model was switched mid-ticket, or the question is about provider / endpoint / retrieval / decision seams | `runtime-contract.md` |
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

- Memory is navigation and historical knowledge; **current evidence is
  authoritative for current behaviour**. Load the ticket's repository folder plus
  only the `shared/` + `global/` entries it touches - never every repository's.
- Trust levels are `CONFIRMED` `INFERRED` `UNKNOWN` `OUTDATED` `CONFLICTING` - these five only. "grep found nothing" is not one of them.
- Trusted as navigation **without re-verifying every fact**; spot-check one only
  when it affects this change's correctness, current evidence contradicts it, it
  looks stale, or the ticket depends on it.
- **Do not automatically persist task findings** - `Memory Delta: NONE` is a normal
  result. Before writing, run the admission gate (`memory-admission.md`):
  reusability -> evidence -> scope -> owner -> duplication -> cohesion. Update the
  canonical owner where one exists; create a unit only for a clear independent
  retrieval trigger. One canonical owner per fact - reference, never copy.
  Non-blocking gaps -> `workspace/memory/unknowns.md`, `Blocking Now: NO`.
- Which repositories are onboarded, which domain lives where, and any
  organization-only tooling or companion source are in `workspace/PROFILE.md`.
  Entering a repository, read its `overview.md` first.
- A domain split across several units has a hub file routing to exactly one of
  them; enter at the hub rather than loading the family.
- A companion knowledge source declared in the workspace is **candidate evidence**
  only - never an extra memory tier, and never enough on its own to set scope,
  carrier, root cause or a design.
