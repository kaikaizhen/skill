# Problem Map - fast localisation of a known symptom

A **shortcut**, nothing more. Each row says: here is a symptom met before, here is
what to suspect first, here is the one file that owns the reasoning.

**Absence from this table means nothing.** It is not a catalogue of what this skill
can handle. For a symptom that is not listed - which is the normal case - use the
diagnostic order in `thinking/README.md`; that order is what makes the skill work on
problems nobody has written down yet. Never force a new problem into the nearest row.

No rule is defined here. Every row points at its owner, and the owner is where the
reasoning lives.

## Data is wrong, duplicated or missing

| Symptom | Suspect first | Owner |
|---|---|---|
| the same row written twice; duplicates appearing with no error reported | which of the three guards is missing - lock / idempotent write / transaction | `thinking/duplicate-write-defence.md` |
| data committed but the caller was told it failed, or a follow-up step silently skipped | post-write side actions and the transaction boundary | `thinking/code-review-checks.md` §5 |
| "delete the whole set, then insert it again" loses or overwrites data | the eight preconditions - especially transaction (#5) and concurrent overwrite (#6) | `thinking/data-strategy.md` §2 |
| a screen shows success while the stored data is wrong | the write path diverged from the read path | `e2e-investigation.md` Phase 1 |
| an edit to one field fails because of an untouched historical field | whole-entity validation on partial update | `thinking/code-quality-gates.md` §2 |
| "the latest row" is not deterministic | ordering on a non-unique column; time precision collision | `thinking/table-design.md` §3, §4 |

## An identifier or a field's meaning is changing

| Symptom | Suspect first | Owner |
|---|---|---|
| an identifier column must be removed - what replaces it? | what each live project already does; batch replacement before any new identifier | `thinking/data-strategy.md` §1 |
| a hash / GUID / index is proposed as the replacement | identity lifecycle: scope, re-ordering, identical content, concurrent edit | `thinking/consistency-gate.md` §4 |
| a field keeps its name but now carries a different concept | semantic overloading - forbidden | `thinking/consistency-gate.md` §3 |
| an API field would start returning empty / default to stay compatible | the consumer has not been confirmed | `thinking/consistency-gate.md` §5 |
| the same business rule disagrees between frontend, backend and DB | one rule, one condition | `thinking/code-quality-gates.md` §4 |

## Scope, evidence and depth

| Symptom | Suspect first | Owner |
|---|---|---|
| a search found no caller / no consumer | negative evidence - not proof it is unused | `thinking/scoped-scan.md`, `thinking/consistency-gate.md` §5 |
| an attribute / filter / middleware looks unused | every registration path, not just usage | `thinking/scoped-scan.md` |
| two same-named handlers; unsure which one runs | the active carrier is decided by the ticket's own surface | `requirement-evidence-gates.md` (Gate 2) |
| the analysis keeps widening and will not finish | tier, early exit, cost control | `thinking/risk-tiers.md` |
| a one-line change in a repository with many consumers | blast radius before the diff | `thinking/engineering-principles.md` P3 |

## Changing existing behaviour

| Symptom | Suspect first | Owner |
|---|---|---|
| a new validation may reject data the system itself produced | data populations, not just the new record | `thinking/code-quality-gates.md` §2 |
| a refactor that "preserves behaviour" | the seven contract dimensions - this is where loss hides | `thinking/regression-validator.md` |
| a new method / parameter / abstraction is about to be added | does an existing seam already reach the need | `thinking/capability-reuse.md` (Gate 3) |
| a shared method is about to change | every caller, per class of behaviour | `thinking/engineering-principles.md` P3 |
| a magic number / bit mask / status code is in the affected code | its real meaning and whether it may change at all | `thinking/encoded-values.md` |

## Runtime and concurrency

| Symptom | Suspect first | Owner |
|---|---|---|
| `.Result` / `.Wait()` in the diff | read the calling context - never assert deadlock from the call alone | `thinking/code-review-checks.md` §4 |
| a date / parse / culture failure | the range the actual type and column allow | `thinking/code-quality-gates.md` §3 |
| intermittent failure only under load or repeat submission | concurrency guard and idempotency | `thinking/engineering-principles.md` P4, `thinking/duplicate-write-defence.md` |
| a timing-dependent defect nobody can reproduce | reconstruct it with two concrete cases and real values | `e2e-investigation.md` Phase 4 |

## Adding a row

Only after the reasoning already has an owner in `thinking/`. A row is one line of
symptom plus a pointer - if you find yourself explaining the rule here, it belongs in
its owner file instead.
