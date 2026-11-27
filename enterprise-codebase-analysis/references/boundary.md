# Engine / Workspace Boundary - classify before you write

**Why this exists.** Company content leaked into the reusable engine (repository
names, ticket ids, team names, domain vocabulary, a real case written into a
principle) because the boundary was a sentence in `SKILL.md`, applied only when
someone remembered it. A fact learned from a real ticket arrives in the company's
words; writing it down verbatim is the path of least effort. This file makes the
classification a step with an output and a check.

Load when you **create or edit anything in `SKILL.md`, `references/`, `templates/`
or `scripts/`**, move content between engine and workspace, or add a principle or
example. Memory-layer questions (global / shared / repository) stay in
`memory-admission.md`; this file decides engine **vs** workspace first.

## 1. The classification test (run on every sentence you are about to add)

```
A  Would this still be TRUE and USEFUL at another company with another stack?
     No  -> it is an organization fact        -> workspace
     Yes -> go to B
B  Does the wording carry organization nouns - a repository, system, host, table,
   column, class, team, ticket id, product, domain term, tool only we run?
     Yes -> rewrite with neutral words (section 3), keep the origin in workspace
     No  -> it may enter the engine
C  Is it a lesson from one real case?
     Yes -> write the PRINCIPLE (the engineering concept) in the engine; the case,
            its names and its numbers go to the workspace and the engine points
            there only if a reader needs the case (one line, no names)
```

| Content | Destination |
|---|---|
| Reasoning principle, diagnostic order, gate, output shape, safety rule | engine (`references/`, `references/thinking/`) |
| Output template whose fixed labels are a language choice (繁中 columns) | engine `templates/` - language is not an organization fact |
| Repository, system, domain, endpoint, table, host, network, business rule | `workspace/memory/**` |
| Organization tool, ticket system, planner format, commit footer, review checklist | `workspace/references/**` (routed from `workspace/PROFILE.md`) |
| A worked example in the organization's own vocabulary | `workspace/references/` (the engine keeps a neutral version) |
| Generic tool names (git, glab, gopass, Postman), generic tech (Redis, SQL Server, `rowguid` as a SQL Server concept) | engine - they are not organization facts |
| Credentials, tokens, hosts, connection strings | nowhere (HARD RULE 17); never in either tree |
| An operator's own endpoint or personal service | `.secrets/` or workspace; recorded exception otherwise (`boundary-terms.txt` `allow:`) |

## 2. Signs a sentence is not neutral

- A name you could grep for in one repository only; a ticket id; a date tied to a scan
  of "this company's" systems; "our", "the company", a team or person.
- A column, table or class from a real schema, even renamed halfway.
- A domain noun from one business (profile types, order types of the company's site).
- A value (host, port, key name) - HARD RULE 15 already forbids these.
- A rule whose reason is "because the ticket did X".

## 3. Neutralising - replace the noun, keep the reasoning

| Instead of | Write |
|---|---|
| a repository / service name | `ServiceA`, `the legacy site`, `the API` |
| a business entity | `customer`, `order`, `document` |
| a real table or flag | an invented one that shows the same shape |
| a ticket id | `T1001`... (obviously fake), or none |
| a team or role | PM / backend / architecture / DBA / client team |
| the task-card system's name | `ticket` or `task card` |
| a proper-noun tool the company runs | the capability ("the log store", "the decision service") |

The lesson must survive the swap. If it does not, it was about the case, not about
engineering: workspace.

## 4. The check - run it before you report an engine edit as done

```bash
bash scripts/boundary-scan.sh      # 0 clean, 1 hits, 2 no term file
```

- Terms are organization facts, so they live in
  `workspace/references/boundary-terms.txt` (not here). A hit is classified by section
  1: neutralise, move, or add an `allow:` line with the reason as a comment.
- A fact that leaked **and the scan missed** -> add its term to that file in the same
  change, so the next leak of the same kind is caught.
- No term file (a new organization): build one from `workspace/PROFILE.md` (repository
  names, domains, hosts pattern, ticket-id shape, team names) before editing the
  engine.
- The scan is a net, not the test: section 1 is the test. Absence of a hit never proves
  a sentence is neutral.

## 5. Moving content out (the pattern)

1. Copy the original to `workspace/references/<same name>` (or the owning memory
   file); route it from `workspace/PROFILE.md`.
2. Rewrite the engine file neutrally and keep one pointer line if a reader needs the
   case; never leave the same fact in both trees.
3. Re-run the scan; keep both trees within the 250-line budget.
