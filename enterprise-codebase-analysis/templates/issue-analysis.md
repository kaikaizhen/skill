# [Issue Number] - Issue Analysis & Change Proposal

> Save as `<workspace>/issue/<RepoName>/<issue-number>.md`. LOCAL ONLY.
> Decision-oriented, not a repository dump: cite `file:line`, never paste source.
> Proportional - delete every section that does not apply.
> First half of ONE report; the decision layer continues in
> `templates/change-proposal.md` and is appended to the same file.
> Rules: `change-proposal.md` · `requirement-evidence-gates.md` ·
> `capability-reuse.md` · `regression-validator.md` · `development-convention.md`.

## Manager Summary

<!-- Plain language, no implementation detail, under a minute. `change-proposal.md` §8 -->

1. **Problem**:
2. **Proposed change**:
3. **Files / systems affected**:
4. **Production risk**: Low / Medium / High - <why>
5. **Recommendation**: APPROVE / APPROVE WITH CONDITIONS / NEEDS HUMAN DECISION / NOT RECOMMENDED

## Executive Summary

<!-- One paragraph for an engineer: what is missing today, what is reused, what is
     deliberately NOT touched, where the risk sits. -->

## Repository Scope

<!-- e.g. ServiceA  |  Frontend -> ServiceB -> ServiceA -> ShardedDb -->

## Issue Goal

Type: Bug / Feature / Optimization / Refactor / Migration
Current Problem:
Business Goal:
Expected Behavior:
Non-goals:

<!-- Vague -> "Unknown / Need Confirmation". Never invent a business rule. -->

## Acceptance Criteria

## Requirement Resolution

<!-- GATE 1 - always; 3 lines if no designated baseline/reference doc. Rows come from
     the TICKET's own behaviours; level 1 alone decides scope. -->

Designated baseline: <"比照 X", or NONE>
Reference docs (background / navigation only): <or NONE>
| Item | Ticket evidence | Designated baseline - actual behaviour | Classification |
|---|---|---|---|
| | explicit (AC #n) / absent | exists / differs / unknown / n/a | SCOPE / CLARIFICATION / OUT OF SCOPE / FOLLOW-UP |

## Memory References

- `workspace/memory/repositories/<Repo>/<file>.md` - <what it suggested>
  (`CONFIRMED` / `INFERRED`). Advisory only; current evidence wins.

## Confirmed Facts / Assumptions / Unknown

- Fact - Evidence: `path/to/file.cs:42`

## Technical Blocker

<!-- Only "safe implementation is impossible without it"; a requirement question is
     NOT one. Otherwise: STATUS: BLOCKED / Blocking: / Need Confirmation: -->
None

## Requirement Decision / Follow-up (non-blocking)

<!-- Undecided product scope; a CONFIRMED MISSING capability never required; an item
     only in a doc/memory; NEEDS DECISION rows; a declined shared-code extension.
     Never in the gap table or the plan. -->
None

## Related Projects / Components / DB

<!-- Servers / DBs / tables / shards touched. Read-only unless approved. -->

## Current Production Behavior

<!-- What runs TODAY, before any proposal: inputs, conditions, outputs, side effects,
     error behaviour. This issue's flow only. Gate 2 triggered -> keep carriers
     APART; a shared Service/DAO/table is a dependency, not the same flow. -->

```
Request -> Controller -> Service/Domain -> DAO/Repository -> DB/External -> Response
```

Behaviour that is **production contract** (preserved unless the ticket says
otherwise; digested under Production Behavior Preservation):

-

### Carrier Separation

<!-- Delete if Gate 2 was not triggered. -->

| | Carrier | Entry & trigger | Active frontend artifact | Endpoint contract | State mutation owner | Status |
|---|---|---|---|---|---|---|
| Ticket target | | | | | | ACTIVE / UNKNOWN |
| Designated baseline | | | | | | ACTIVE / UNKNOWN |
| Legacy / alternate | | | | | | LEGACY - REFERENCE ONLY |

Shared dependencies: -

## Magic Numbers / Encoded Values

<!-- ONLY if the affected path contains a literal carrying meaning the number does
     not show (status code, bit flag/mask, threshold, limit, legacy/protocol code).
     Nothing found -> DELETE this section; never an empty table. Meaning needs
     evidence; UNKNOWN is never guessed or renamed. `encoded-values.md` -->

| Value | Location / Expression | Meaning | Encoding / Behavior | Evidence | Confidence | Recommendation |
|---|---|---|---|---|---|---|
| `3` | `status == 3` | | bit 0+1 mask / `0011`, or n/a | enum / comment / SP / mapping | CONFIRMED / INFERRED / UNKNOWN | REUSE EXISTING / KEEP AS IS / EXTRACT NAMED VALUE / DO NOT RENAME YET |

### Quick Behavior Comparison

<!-- Semantic line only for CONFIRMED meanings; unconfirmed stays mechanical
     ("legacy code 7"). Add Before / Proposed only if the proposal changes how the
     value is expressed - the numeric value itself stays (Gate 5 rows 3 and 7). -->

```
Current:
Semantic view:
```

## Capability Ownership

<!-- GATE 3 - reuse, a MISSING claim, or any new method/parameter/abstraction or
     shared-code change. Delete otherwise. "Ticket requires?" BEFORE tracing the
     owner. `capability-reuse.md` -->

| Capability | Ticket requires? | Active owner (layer + file) | Authoritative state | Mutation point | Evidence | Result | Reuse |
|---|---|---|---|---|---|---|---|
| | YES / NO | | | | `path:line` | CONFIRMED EXISTS / CONFIRMED MISSING / NOT OBSERVED IN TRACED PATH / UNKNOWN | SUFFICIENT AS IS / CALLER-SIDE / EXTENSION NEEDED |

<!-- Any EXTENSION NEEDED row: shared code stays untouched until this is answered.
SHARED CAPABILITY EXTENSION APPROVAL REQUIRED
Shared code: <file:line>   Callers: <CONFIRMED SOLE / ENUMERATED (n) / UNKNOWN>
Limitation:  <why the existing seam cannot carry this need, with evidence>
Option A:    solve at the caller - cost, what it duplicates
Option B:    extend shared code - exact change + impact on EACH other caller
Recommendation: <A or B>.   AWAITING USER DECISION -->

## Root Cause

<!-- Bug only; delete for Feature. Not confirmed -> say so; do not over-diagnose. -->
Status: CONFIRMED / CANDIDATE / UNKNOWN
Evidence: -

## Problem / Gap

<!-- EVERY row traces to a SCOPE row above. `Expected` is OBSERVABLE BEHAVIOUR, never
     a code change - that pre-picks the mechanism and skips Gate 3's Reuse verdict. -->

| Item | Current | Expected | Gap | Evidence (`path:line`) | Traces to |
|---|---|---|---|---|---|

## Impact Scope / Blast Radius

<!-- Callers, shared services, other repos, DB, cache, search, queue, frontend
     contract, schema, CI/CD. Shared code: CONFIRMED SOLE CALLER / CALLERS
     ENUMERATED (n) / UNKNOWN CALLERS + what was searched. The diff may be small -
     say whether the blast radius is. -->

| Component | Direct / Indirect / Unaffected / Unknown | Note |
|---|---|---|

## Contract Parity (Gate 5, run 1 - planned change)

<!-- Any change to an EXISTING flow. Baseline = main / the authoritative branch as of
     the ticket's start, NEVER the feature branch's previous commit. "unchanged" is a
     complete answer. Rows 3-4 carry data/state safety: transaction, concurrency,
     idempotency, partial failure, rollback, migration, back-compat. -->

Baseline: `<ref>` (<how chosen>)   Compared: <what was diffed / read>
State mutation: NONE (read-only) | <what is written>

| # | Dimension | Baseline behaviour (`path:line`) | Planned behaviour | Delta | Intended? | Risk |
|---|---|---|---|---|---|---|
| 1 | Security / auth / CSRF | | | | AC #n / NO | |
| 2 | Server-side validation & enforcement | | | | | |
| 3 | Data integrity | | | | | |
| 4 | Transaction / ACID boundary | | | | | |
| 5 | Side effects (success + failure) | | | | | |
| 6 | Logging / audit / trace | | | | | |
| 7 | Caller compatibility / blast radius | | | | | |

Duplicate submission guard: <guard, `path:line`>  |  NONE - <window>
Concurrency guard:          <guard>               |  NONE - <race>
Transaction boundary:       <what is inside>      |  NONE - <n independent writes>

### Side-effect Parity

<!-- Expand row 5 from BOTH success and failure paths. Same method call is NOT the
     same contract - all six attributes. Delete if no side effect is touched. -->

| Side effect | Trigger (success / failure branches) | Count | Order | Sync / async | Failure semantics | Reliability | Intended? | Risk |
|---|---|---|---|---|---|---|---|---|
| <effect> | baseline -> final | | | | | | REQUIRED BEHAVIOUR / TICKET CHANGE (AC #n) / NEEDS DECISION | |

## Production Behavior Preservation

<!-- Digest of the Gate 5 table, not a second analysis. A behaviour the proposal DOES
     change is `INTENTIONAL CHANGE` + its requirement, never "a refactor". -->

| Existing behaviour | Preserved? | Evidence / how |
|---|---|---|
| <API contract / response fields / query conditions / cache semantics / transaction boundary / authorization / logging-audit / other callers> | YES / INTENTIONAL CHANGE (AC #n) | |

## Convention Baseline

<!-- Cite the file, or UNKNOWN - never inferred from the framework. -->

| | Convention | Evidence (file / section) | Source level |
|---|---|---|---|
| Coding / style | | | |
| Error handling | | | |
| Logging | | | |
| Testing | | | |

## Existing Test Coverage

<!-- This + Impact Scope + non-`unchanged` Gate 5 rows ARE the set to run later.
     NONE FOUND -> AWAITING USER DECISION ON TEST COVERAGE -->
Covered by: <test project / file / test names>  |  NONE FOUND
Searched:   <paths and naming patterns actually checked>
