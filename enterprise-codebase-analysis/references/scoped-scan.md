# Scoped Scan

The scan exists to answer exactly one question:

> Do I understand enough to safely implement **THIS** issue?

`YES` -> **STOP SCANNING.**
`NO` -> investigate only the missing piece, then ask again.

---

## Forbidden

- Full repository scan
- Scanning the whole company source
- Scanning all databases, all Redis nodes, all OpenSearch indices
- Loading every repository's memory
- Building a complete architecture document for a single bug
- "Let me first understand the system, then start" - the scan is driven by the
  ticket, not by curiosity

---

## Stop Conditions

Stop scanning as soon as **all** of these are true:

1. You can name the entry point and the code path that must change.
2. You can name the data source(s) that path reads or writes.
3. You know which existing pattern the change should follow.
4. You can state the impact of the change on known callers.
5. For a bug: you have a root cause that is `CONFIRMED`, or a `CANDIDATE` with a
   cheap test that settles it.

6. Every gate this ticket **triggered** has produced its required output
   (`requirement-evidence-gates.md`): Gate 2's carrier identity cards when the
   ticket targets a page / designates a baseline / lands in a multiple-carrier
   domain, and Gate 3's ownership rows when it reuses an existing capability or
   you are about to call something missing. A triggered gate without its output
   means the scan is not yet sufficient - an untriggered gate means nothing.
7. When an existing flow is being changed: you know what the **authoritative
   baseline** does on each of the seven contract dimensions it touches, or you
   know which of them is `UNKNOWN` and what would settle it
   (`regression-validator.md`). "The feature still works" is not this answer.

Anything you still do not know at that point goes to
`<skill>/workspace/memory/unknowns.md` with `Blocking Now: NO`.

---

## Existing Mechanism Gap Check

If the mechanism the ticket asks for **already exists** in the code before any
change, do not immediately assume a different endpoint, layer or repository is
missing it. Widening scope too early is itself a scope violation - it just points
outward instead of sideways.

Check the **local neighborhood** of the mechanism first, in this order:

```
1. Sibling helpers / adjacent methods in the same file or class
2. Related constants, regex, enums, config values the mechanism reads
3. Existing unit tests - what do they assert, and what case is missing?
4. Input variants the ticket does not name but share the same input type
   (e.g. the ticket lists punctuation but not whitespace - same input, same
   preprocessing step, still worth checking)
```

Only widen to caller / endpoint / cross-repository integration once this local
check finds no plausible gap. Most "this must be missing somewhere else" guesses
are wrong when the mechanism is this close to already working - the actual gap is
usually one character class, one missing case, one stale constant, right next to
code that already works.

This is `SCOPE FIRST` / `EVIDENCE ENOUGH` applied one level more precisely: scope
the *investigation*, not just the *issue*, to the smallest neighborhood that could
plausibly hold the gap before expanding it.

The symmetric rule applies to the *negative* conclusion: having looked in the
neighborhood and found nothing is `NOT OBSERVED IN TRACED PATH`, not
`CONFIRMED MISSING`. The threshold for the stronger claim - and the ban on
designing new persistence or architecture below it - is
`requirement-evidence-gates.md` -> Gate 3.

### Same Domain, Multiple Carriers

A legacy repository frequently has **more than one implementation of the same
business concept** that never merged: an old path beside a new-architecture path
for the same feature, a table whose name matches the domain word but serves a
different feature, or a mobile variant beside a web variant of what the ticket
calls by one name. Landing on the first file that matches the ticket's domain
keyword (a grep hit, a class name, a table name) is not the same as confirming it
is the file the ticket's *specific* endpoint or page goes through - a validated
batch of real tickets against this repo found the wrong-carrier version of this
mistake three times more often than every other kind of miss combined.

Before treating a domain-keyword match as the target, trace the actual caller
chain **from the user-facing entry point named in the ticket** (the controller
action, the page, the specific button/flow) down through its own service/helper
to its own DAO/repository. If the trace lands somewhere other than the first
match, that is worth a one-line memory note in `<RepoName>/patterns.md` once
confirmed, so the next ticket does not repeat the guess.

When the ticket targets a page / app flow, designates a baseline ("比照 X"), or
lands in one of the domains below, this is not optional guidance: it becomes
**Gate 2 - Active Carrier Confirmation**, whose identity cards must exist before
any downstream trace. A shared Service / DAO / table between two carriers proves
a dependency and never that they are the same flow.

**Known multiple-carrier domains (confirmed 2026-09-21, this company's five
scanned repositories)**: 履歷、企業通知、收藏職缺、職缺搜尋/推薦、應徵/主投、面試/邀約、
E-chat. The current carrier list per domain lives in
`workspace/memory/shared/domain-entrypoints.md` - read it before assuming a domain has
only one implementation. For a ticket in one of these domains:

1. Use the ticket's surface / endpoint / stack trace to identify the actual
   carrier being hit - not "which repo has a similarly-named Service".
2. Only after that, decide whether any *other* carrier needs a matching change.
3. Never assume all carriers must be updated together just because the ticket
   names the shared domain word.
4. Never skip a carrier that is genuinely active just because a differently
   named repo already has a similarly-named method - "same name" is not "same
   carrier" and "different name" is not "unrelated".

### Attribute / Filter / Middleware: "Zero Usage" Means Zero *Registration*

Concluding that an `Attribute` / `Filter` / `Middleware` class is unused ("dead
code, not wired in") from a search for `[Attribute]` on controllers/actions is
not sufficient, and has produced a confirmed false negative: a filter judged dead
because no controller carried its annotation was in fact registered globally in
`FilterConfig.RegisterGlobalFilters` (called unconditionally from
`Global.asax`'s `Application_Start`) and ran on **every** request.

A class can be "used" through any of these registration paths, none of which show
up in a per-annotation grep:

```
1. Per-attribute usage       [Attribute] on a controller / action / class
2. Global filter collection  GlobalFilters.Filters.Add(...), FilterConfig,
                             config.Filters.Add(...) (Web API), or equivalent
3. Startup / Global.asax     confirm the registration method above is actually
                             CALLED (not just defined) and unconditionally
4. DI / service registration app.Use..., services.AddScoped/AddSingleton +
                             [ServiceFilter]/[TypeFilter], AddAuthentication /
                             AddAuthorization policy handlers
5. Middleware pipeline       app.UseMiddleware<T>(), custom middleware chains
6. Convention-based wiring   naming/reflection-based auto-registration (rarer,
                             but check before ruling it out)
```

Before writing "zero usage" / "dead code" / "not wired in" as a Fact (memory or
analysis document), check all of the paths above that the framework in question
supports - not only path 1. If a class implements a framework interface that is
normally supplied through global/DI registration (`IAuthenticationFilter`,
`IActionFilter`, `IAuthorizationFilter`, `IMiddleware`, `IAuthorizationHandler`,
etc.), path 1 alone is not enough evidence to call it dead, regardless of how
many controllers/actions you checked.

---

## Depth By Issue Type

**Bug - scoped deep scan.** `Entry point -> related code -> service ->
repository -> the relevant DB / cache / search -> existing flow -> root cause ->
fix`. Root cause is mandatory, labelled `CONFIRMED` / `CANDIDATE` / `UNKNOWN`.

**Optimization / Refactor - scoped deep scan.** Current flow, bottleneck
(measured or clearly reasoned), relevant dependency, impact, proposed change,
risk. The refactor stays inside the ticket's boundary; "while I am here" is not a
reason to touch a file. A behaviour-preserving refactor still owes the full
contract comparison (`regression-validator.md`). Once this scan is done, the next
required step is the mandatory **Design & Implementation Strategy**
(`development-convention.md` §3a) - written before Pseudocode/Plan, not after.

**Migration - scoped deep scan.** Both sides of the move, plus: source behaviour
today, target behaviour, coexistence (do old and new run together, for how
long?), data compatibility (schema, shard routing, sync), and the rollback path.
Migrations touching data go through the **Database Mutation Approval Gate**.

**Feature - minimal integration scan.** Only what is needed to integrate cleanly:

```
Authentication      API convention       An existing similar feature
Service pattern     Repository pattern   Relevant DB
Logging             Error handling       Shared library      Config
Redis / OpenSearch / Queue   (only if the feature actually uses them)
```

Once integration is understood - **stop**. A feature does not require a root
cause, a bottleneck analysis, or a full data-flow map.

---

## Proportionality

| Ticket | Expected output |
|---|---|
| Simple bug (one file, clear cause) | Short analysis: requirement, root cause, fix, test. No diagram |
| Normal feature | Requirement, integration points, pseudocode, plan, test plan |
| Cross-system bug | Add Mermaid, DB flow, sync analysis, cross-repository impact |
| Migration | Add coexistence and rollback analysis |

Analysis cost must be proportional to problem complexity. A 10-file memory
update and an architecture diagram for a one-line fix is a failure of this skill,
not a success.

---

## During The Scan

- Prefer targeted search (`grep` for the symbol, the route, the column name) over
  reading directories.
- Follow the call chain the ticket implicates; do not explore adjacent chains.
- Use memory to skip re-scanning known architecture. Open the file memory points
  at only when the fact it holds materially affects this change, looks stale, or
  is contradicted by what you are already reading. Do not re-verify unrelated
  memory just because it was loaded.
- Record each confirmed fact with its file path; that path becomes the evidence
  in both the analysis document and any memory delta.
- Before the solution is designed, the scan must also have answered how this
  repository writes this kind of code (coding / error handling / logging /
  testing) and which tests already cover the target - only for the files in this
  ticket's diff, not the repository's whole style guide. Rules and order:
  `development-convention.md` §1; output: `workflow.md` step 13.5.

---

## Establishing a Pre-Change Baseline

Any point-in-time read ("the code as it stood before change X") uses the
authoritative-baseline procedure in `regression-validator.md`, not environment
merge history. A branch can already carry an earlier pass at the same change, so
"the first merge into the target branch" is not reliably the change's first
appearance - walk the **file's** own history and confirm the candidate ref is
clean before relying on it.
