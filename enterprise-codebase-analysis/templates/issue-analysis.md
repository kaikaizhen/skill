# [Issue Number]

> Save as `<workspace>/issue/<RepoName>/<issue-number>.md`.
> LOCAL ONLY - never inside the repository, never inside the skill folder.
> Keep this proportional to the issue. Delete every section that does not apply.

## Repository Scope

<!-- e.g. ServiceA   |   Frontend -> ServiceB -> ServiceA -> ShardedDb -->

## Requirement

Type: Bug / Feature / Optimization / Refactor / Migration
Current Behavior:
Expected Behavior:

## Acceptance Criteria

## Requirement Resolution

<!-- GATE 1 - always, but three lines with no designated baseline/reference doc.
     Rows come from the TICKET's explicit behaviours, never a HackMD/old spec/
     memory. Source order: 1 ticket AC > 2 designated baseline ("比照 X") > 3 its
     CURRENT ACTIVE behaviour > 4 reference docs > 5 memory; level 1 decides scope. -->

Designated baseline: <"比照 X", or NONE>
Reference docs (background / navigation only): <or NONE>
| Item | Ticket evidence | Designated baseline - actual behaviour | Classification |
|---|---|---|---|
| | explicit (AC #n) / absent | exists / differs / unknown / n/a | SCOPE / CLARIFICATION / OUT OF SCOPE / FOLLOW-UP |
## Memory References

- `workspace/memory/repositories/<Repo>/<file>.md` - <what it suggested> (`CONFIRMED` /
  `INFERRED`). Memory is advisory only; current evidence wins.
## Scope

In Scope:      -
Out of Scope:  -

## Confirmed Facts / Assumptions / Unknown

<!-- Each fact with evidence: file:line, config, schema, log, runtime behaviour.
     Unknowns carry Blocking Now: NO unless they genuinely block. -->

- Fact - Evidence: `path/to/file.cs:42`
## Technical Blocker

<!-- Only "without this, safe implementation is impossible"; a requirement question is NOT one. Otherwise: STATUS: BLOCKED / Blocking: / Need Confirmation: -->
None

## Requirement Decision / Follow-up (non-blocking)

<!-- Product hasn't decided beyond the baseline; a CONFIRMED MISSING capability never
     required; an item only in a reference doc/memory; a gap needing a separate decision; every NEEDS DECISION row from Side-effect Parity; a declined shared-code extension. Never in the gap table/plan, never BLOCKED. -->
None
## Related Projects / Components / DB

<!-- Servers / DBs / tables / shards touched. Read-only unless approved. -->

## Existing Flow

<!-- Only this issue's flow. Mermaid only if it earns its place. When GATE 2 was
     triggered keep the carriers APART - never merged into one flow. A shared
     dependency (Service / DAO / table used by more than one carrier) proves a
     dependency, NOT the same frontend flow/endpoint contract/initial-value
     behaviour. Delete the table below if Gate 2 was not triggered. -->

### Carrier Separation

| | Carrier | Entry & trigger | Active frontend artifact (checked-in / deployed / runtime) | Endpoint contract | State mutation owner | Status |
|---|---|---|---|---|---|---|
| Ticket target | | | | | | ACTIVE / UNKNOWN |
| Designated baseline | | | | | | ACTIVE / UNKNOWN |
| Legacy / alternate | | | | | | LEGACY - REFERENCE ONLY |

Shared dependencies:
-

## Capability Ownership

<!-- GATE 3 - when the ticket reuses/depends on an existing verification, limit,
     quota, counter, state machine or shared backend mutation; when about to call
     something MISSING; or when the change adds a method, parameter, overload or
     abstraction, or modifies shared code. Delete otherwise. Decide "Ticket
     requires?" BEFORE tracing the owner. Result: CONFIRMED EXISTS / CONFIRMED
     MISSING (active carrier + owner + authoritative mutation path ALL confirmed)
     / NOT OBSERVED IN TRACED PATH / UNKNOWN - nothing new designed on the last
     two. Reuse (P5): SUFFICIENT AS IS (existing seam reaches it, add nothing) /
     CALLER-SIDE (solve at the caller) / EXTENSION NEEDED (concrete limitation at
     path:line after a WRITTEN seam inventory, then STOP - `capability-reuse.md`). -->

| Capability | Ticket requires? | Active owner (layer + file) | Authoritative state | Mutation point | Evidence | Result | Reuse |
|---|---|---|---|---|---|---|---|
| | YES / NO | | | | `path:line` | | |

<!-- Any EXTENSION NEEDED row: no shared code is touched until this is answered.
SHARED CAPABILITY EXTENSION APPROVAL REQUIRED
Shared code: <file:line>   Callers: <CONFIRMED SOLE / ENUMERATED (n) / UNKNOWN>
Limitation:  <why the existing seam cannot carry this need, with evidence>
Option A:    solve at the caller - cost, what it duplicates
Option B:    extend shared code - exact change + impact on EACH other caller
Recommendation: <A or B>.   AWAITING USER DECISION -->

## Root Cause

<!-- Bug only. Delete for Feature. -->
Status: CONFIRMED / CANDIDATE / UNKNOWN
Evidence:
-

## Gap

<!-- Requirement minus what the target surface does today. EVERY row traces back to
     a SCOPE row in ## Requirement Resolution. A capability the ticket never required
     is NOT a gap - it belongs in Requirement Decision / Follow-up. `Required
     outcome` is OBSERVABLE BEHAVIOUR - what the response, log line, screen or data
     must show afterwards, never a code change ("add an overload"): a gap written
     as its own solution has already picked the mechanism and skipped Gate 3's
     Reuse verdict (e.g. right: "this caller's connection failure must log at
     Warning"; wrong: "log level is hardcoded, callers cannot override it"). -->

| Gap | Evidence (`path:line`) | Required outcome | Traces to Requirement row |
|---|---|---|---|
## Impact Scope

<!-- Actual callers, shared services, other repos, DB writes, cached values,
     indexed fields, jobs. Shared code: state blast radius as CONFIRMED SOLE
     CALLER / CALLERS ENUMERATED (n) / UNKNOWN CALLERS + what was searched -
     no caller found in this repo is not confirmed absence of callers. -->

## Contract Parity (Gate 5, run 1 - planned change)

<!-- Required whenever an EXISTING flow is modified, replaced, re-routed or
     refactored. Baseline = main / the authoritative branch as of the ticket's
     start - NEVER the feature branch's previous commit. "unchanged" is a complete
     answer. "Intended?" is decided by the ticket. Risk HIGH / MEDIUM / LOW per
     references/regression-validator.md. -->

Baseline: `<ref>` (<how chosen>)   Compared: <what was diffed / read>
| # | Dimension | Baseline behaviour (`path:line`) | Planned behaviour | Delta | Intended? | Risk |
|---|---|---|---|---|---|---|
| 1 | Security / auth / CSRF | | | | AC #n / NO | |
| 2 | Server-side validation & enforcement | | | | | |
| 3 | Data integrity | | | | | |
| 4 | Transaction / ACID boundary | | | | | |
| 5 | Side effects (success + failure) | | | | | |
| 6 | Logging / audit / trace | | | | | |
| 7 | Caller compatibility / blast radius | | | | | |

Duplicate submission guard: <guard, `path:line`>   |   NONE - <window>
Concurrency guard:          <guard>                |   NONE - <race>
Transaction boundary:       <what is inside it>    |   NONE - <n independent writes>

### Side-effect Parity

<!-- Expand row 5 when Side-effect Discovery found anything: notifications,
     audit/history/domain-hook records, downstream calls, cache, queue, counters
     - from BOTH success and failure paths, direct and indirect. Same method
     call is NOT the same contract: compare all six attributes. Intended?:
     REQUIRED BEHAVIOUR (incl. a confirmed invariant) / TICKET CHANGE (AC #n) /
     NEEDS DECISION. Delete only when the change touches no side effect. -->

| Side effect | Trigger (which success / failure branches) | Count | Order | Sync / async | Failure semantics | Reliability | Intended? | Risk |
|---|---|---|---|---|---|---|---|---|
| <effect> | baseline -> final | | | | | | | |
Five checks (`regression-validator.md`): sync -> background; exception swallowed
but success still returned; effect lost/duplicated; logging/audit downgraded;
other callers affected - including sites the diff left inline, now differing.

## Convention Baseline

<!-- How THIS repo already writes this kind of code. Cite the file each line came
     from or write UNKNOWN, never inferred from the framework. Order: repo rule
     files > surrounding code > repo memory > team standards > best practice. -->

| | Convention | Evidence (file / section) | Source level |
|---|---|---|---|
| Coding / style | | | |
| Error handling | | | |
| Logging | | | |
| Testing | | | |

## Existing Test Coverage

<!-- This section + Impact Scope + the non-`unchanged` Gate 5 rows ARE the set of
     tests to run later - related to this change, not the whole suite. NONE FOUND -> don't decide alone: NO RELEVANT TESTS FOUND ... AWAITING USER DECISION ON TEST COVERAGE -->
Covered by: <test project / file / test names>   |   NONE FOUND
Searched:   <paths and naming patterns actually checked>
Repository rule on tests: <requires tests for changed logic | none found>
## Proposed Solution

<!-- Small, safe, existing-pattern-first (Bug/Feature/Migration), or the
     Design & Implementation Strategy below (Optimization/Refactor). -->

## Design & Implementation Strategy

<!-- Optimization / Refactor ONLY (`development-convention.md` §3a); delete
     for Bug/Feature/Migration - use Pattern Choice instead. Problem
     (`path:line`, what actually hurts) -> candidate approach(es) vs
     readability / maintainability / testability / low coupling /
     reuse-extensibility, and vs this repo's own convention above -> chosen
     approach + why a pattern earns its place against a concrete PRESENT
     need, never "later" -> what stays untouched (the refactor's boundary). -->

## Pattern Choice

<!-- Bug/Feature/Migration ONLY (`development-convention.md` §3b); a SOLID
     alternative volunteered inside a non-refactor ticket, only when ALL FOUR
     preconditions there pass. Otherwise delete this section, keep a one-line
     follow-up note. Silence = Option A.
     Option A - Existing pattern (default): what / files touched / risk
     Option B - Improvement (SRP/OCP/LSP/ISP/DIP): what / extra files /
       maintenance gain / impact on existing behaviour: NONE (evidence: ) /
       extra risk. Then: Recommendation, and AWAITING USER PATTERN CHOICE. -->

## Pseudocode / Files Expected To Change

```
```
## Test Plan

- Happy path:
- Original bug reproduction:
- Regression (one case per non-`unchanged` Contract Parity / Side-effect row,
  including the side effect firing exactly once on success and NOT on failure):
- Boundary:
- DB writes required: NO / YES -> requires Database Mutation Approval
## Implementation Plan

1.

## Memory Delta Candidate

<!-- file + section, never a whole-file rewrite -->
NONE / ADD / UPDATE / CORRECT / PROMOTE / DEMOTE

## Consistency Pass

<!-- GATE 4 - immediately before the approval gate, and again after any evidence
     round that overturned an earlier conclusion. A recompute, not a rewrite:
     every plan item traces to a level-1 requirement; every blocker really
     blocks; every MISSING meets Gate 3's threshold; every carrier claim matches
     its identity card; superseded conclusions DELETED not annotated; test plan
     matches the final scope; facts/root cause cite evidence that survived. -->

No superseded content.

## Approval

AWAITING USER APPROVAL TO IMPLEMENT
