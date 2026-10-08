# Mode B - Repository Onboarding

Read-only reconnaissance of one repository, so that a backend engineer (or a later
Mode A ticket) can navigate it quickly. **Not** a ticket workflow and **not** a full
architecture audit.

```
SCOPE FIRST - EVIDENCE ENOUGH - STOP WHEN SUFFICIENT
```

---

## When

- "先掃 <repo>" / "幫我理解這個專案" / "新人快速上手" / "產生 project guide"
- A Mode A ticket arrives for a repository that has **no** folder under
  `<skill>/workspace/memory/repositories/` and the user asks to set one up first.

Never ask for an issue number, acceptance criteria, or approval to implement.

---

## Repository Kind (decide before Phase 2)

Not every repository serves requests. Decide from evidence, before choosing a
memory template or interpreting "endpoint":

```
Service        has routes/controllers that ANSWER inbound requests - a web
               framework, DB access owned by this repo, a deployable API/app.
               -> templates/workspace/memory/repositories/_REPO_TEMPLATE/

Caller /       exists to CALL another system, not to serve one - load/perf test
Tooling        scripts (k6, JMeter, Gatling), an integration/E2E test suite
               against a deployed target, a data pipeline or one-off migration
               tool, a CLI. No inbound route to document; "endpoint inventory"
               means the TARGET system's endpoints, not this repo's own.
               -> templates/workspace/memory/repositories/_LOAD_TEST_TEMPLATE/
               (generic enough for any caller/tooling repo, not k6-specific)
```

Mixed repos exist (a service repo with a `/scripts` folder of one-off tools) -
classify by what the ticket or the onboarding request is actually about, and
say so. When genuinely unclear, `UNKNOWN` and default to `_REPO_TEMPLATE`; do
not invent a third template for a single ambiguous case.

---

## Allowed / Forbidden

| Allowed | Forbidden |
|---|---|
| Read source, config key names, csproj, Dockerfile, CI, k8s manifests | Modifying source / config |
| Read-only git: `status`, `branch`, `log`, `rev-parse`, `show` | Branch, commit, push, MR / PR |
| Read-only DB: `SELECT`, schema, view / function / SP definitions, extended properties, default constraints, value distributions - **only with a connection the user provided** | Any DB write, DDL, executing SPs, migrations |
| Inline onboarding summary (always); a guide file where the user asks; writing `<skill>/workspace/memory/` | Writing anything inside the repository unless the user explicitly asks |

Never copy connection-string values, hosts, accounts, passwords or API keys into the
guide or memory. Key **names** are fine.

**A repository's own data/fixture files may hold live-looking secrets** (a
cookie jar, a bearer token, a seeded account) committed as "test data". Note
the file's location and whether anything protects it (`.gitignore`, no git repo
at all) in the guide's unknowns/cautions - never the value itself, and never
copy it into memory.

"The application writes table X" is recorded as **App Behavior = WRITE**; it never
implies developers may write to the DB.

---

## Phases (breadth first, stop when sufficient)

```
1. Version snapshot      git branch / HEAD / last commit; runtime, framework, key
                         packages only; note whether there IS a git repo at all
1.5 README vs code       spot-check the README's concrete claims - default
    consistency          numbers, file lists, endpoint paths, "TODO"/"stub"
                         claims - against the actual code. A stale claim is
                         reported as OUTDATED, current code always wins
                         (memory-system.md §3); never silently trust the README
2. Reconnaissance        solution / projects / entry point / folders - "what
                         areas exist?" - decides Repository Kind above
3. Architecture pattern  actual layering with evidence; do not force DDD / Clean
                         / CQRS; for a caller/tooling repo this is its request-
                         construction and execution pattern, not a service layer
4. Domain discovery      Service: controller / route / service / repository / DTO
                         / table names. Caller/tooling: target domains from the
                         scripts/scenarios it drives, and the target base URLs
                         per environment
5. Endpoint inventory    Service: this repo's own routes, CORE/SECONDARY/UTILITY.
                         Caller/tooling: the TARGET system's endpoints this repo
                         exercises, plus how a request against each is built
6. Core flows            Service: scoped deep dive per CORE endpoint. Caller/
                         tooling: scoped deep dive per CORE scenario - request
                         shape, test-data source, stats/output contract
7. Output                guide + memory seed
8. STOP
```

For each CORE endpoint (Service) or CORE scenario (caller/tooling) keep three
layers separate:

```
Business meaning   what it does for whom / what condition it is verifying (not
                    "Controller calls Service" / not "sends a POST request").
                    The reader is new here: explain each project term, abbreviation
                    and field on first use, and name the actor of every action
                    (`explanation-standard.md`)
Technical flow      Service: entry -> service -> repository -> DB / cache /
                    search / external. Caller/tooling: how the request body is
                    built (data source, randomisation, ratios) -> target
                    endpoint -> how the result is checked/aggregated
Navigation         where to change / debug
```

Every important statement is `CONFIRMED` / `INFERRED` / `UNKNOWN`. Do not guess
sync mechanisms, broker types, environment mappings or business meaning of status
codes - write `UNKNOWN` and move on. Know a dependency only to the layer the code
shows (e.g. "EventBus client package; broker UNKNOWN").

---

## Stop Condition

Stop scanning when a newcomer could answer:

1. What does the project do?
2. Runtime / framework version (or tool + minimum version, for caller/tooling)?
3. How is it layered / how is a request or scenario put together?
4. Main business domains, or main target scenarios?
5. Main endpoints (own, or the target system's) and their business meaning?
6. Where is business logic / DB access / routing / config - or, for
   caller/tooling, where is request construction / test data / environment
   switching / output-stats logic?
7. Where to start debugging, where to make a change - or add a new scenario?

---

## Output

### Guide

For Repository Onboarding requests, **always produce a user-visible onboarding
summary** in the reply. "先掃 <repo>" already means the user wants to see the
result - do not finish with only the memory seed and a one-line note.

The inline summary covers at least: version, what the project does, architecture
(+ Mermaid if it helps), domain map, core endpoints with business meaning, quick
locator (where logic / DB access / routing / config live), where to start
debugging and changing, important unknowns, and a short **README ↔ Code
Consistency** list (only if step 1.5 found any - omit the section when clean,
never pad it).

If the user explicitly asks for a file, **additionally** write
`PROJECT-QUICK-GUIDE.md` to the requested location (a location the user names). Typical
file sections: version, summary, architecture (+ Mermaid), domain map, quick
locator, source index, endpoint inventory, core domain guides, DB quick map (or
target-system quick map, for caller/tooling), dependencies, debug map, change
locator, business rules, README ↔ code consistency, reading order, evidence
status, important unknowns.

Do not create a repository-local document by default, and never write the guide
inside `<skill>/`.

### Memory seed

Create `<skill>/workspace/memory/repositories/<RepoName>/` from the template matching the
Repository Kind decided above, and fill it, applying the admission test in
`memory-admission.md` (only what narrows search, avoids traps, or locates
code / dependencies / the target system):

**Service** - from `_REPO_TEMPLATE/`:

| File | What goes in |
|---|---|
| `overview.md` | purpose, stack, layout, entry points, domain -> main files, legacy hazards. A map, not an architecture document |
| `patterns.md` | established coding conventions: API shape, auth, service / repository / cache / external-call patterns, error handling, config, naming, logging, tests, branch / commit convention, reference implementations |
| `routing.md` | connection factory, shard selection, connection-string **key names** |
| `database.md` | DBs / tables touched, read / write paths, table sharding, DB code dictionaries |
| `dependencies.md` | upstream callers, downstream services, shared libraries |
| `business-rules.md` | non-obvious rules future tickets would otherwise re-derive |

**Caller / Tooling** (e.g. a k6 load-testing project) - from `_LOAD_TEST_TEMPLATE/`:

| File | What goes in |
|---|---|
| `overview.md` | purpose, tool + version, layout, execution entry points (which script for which scenario), legacy hazards |
| `patterns.md` | the shared script template shape (setup / default / teardown / handleSummary or equivalent), request-building pattern, data-loading pattern, environment-switching pattern, executor/scenario patterns |
| `targets.md` | target base URL per environment, target endpoints exercised (method + path + business meaning), auth/session mechanism used against the target |
| `test-data.md` | data files, how each is generated or maintained (a checked-in generator script, or manual), ratio/distribution parameters that encode test intent, and a caution note (not the values) for any file holding live-looking secrets |
| `business-rules.md` | test-design rules future scenarios would otherwise re-derive (why a ratio, why an extreme scenario exists, what a stat output is supposed to mean) |

Global / shared memory: targeted edits only (glossary terms, domain entry,
repository-specific notes). Do not promote repository findings to shared / global
without the promotion criteria in `memory-operations.md` §8. Add open questions to
`<skill>/workspace/memory/unknowns.md` with `Blocking Now: NO`.

Order of the final reply: inline onboarding summary first, then a short list of
memory files seeded / updated (and the guide file path, if one was written).

Then **STOP**. Do not offer to implement anything.
