# Code Quality Gates (write-time rules + Gate 6 self-review)

**Compiling is not working, and an implemented method is not a working business
flow.** A change can build, pass its own unit test, and still never run in
production, break a member whose data predates the new rule, or contradict the
same rule as another layer computes it.

This file owns the seven quality dimensions, **when** each is checked, and
**Gate 6 (Self-Review)**. It is a design input, not an after-the-fact checklist:
every dimension below is answered while the diff is being written, then confirmed
once at Gate 6. A user-requested review of an existing diff applies the same seven
dimensions through `code-review.md`.

## 0. Two moments, one checklist

| Moment | What happens | Where |
|---|---|---|
| During analysis (steps 13-17) | dimensions 1, 2 and 4 are **inputs to the solution** - the call chain is traced, the compatibility question is asked, the cross-layer rule is compared, before a line is written | `workflow.md` §13.6 |
| While implementing (step 20) | dimensions 3, 5, 6, 7 shape the diff as it is typed - boundaries, validation order, naming, tests | `development-convention.md` §2.5 |
| After implementing (step 21.6) | **Gate 6** - one pass over the real diff confirming each dimension, before Approval Gate #2 | §8 below |

**Modes.** This file governs **Mode A** (write-time + Gate 6) and **Mode R** (a
requested review). **Mode B** stays read-only reconnaissance - onboarding never
sweeps a repository for quality defects - and **Mode C** stays a business
explanation; neither runs Gate 6 or produces findings unless the user asks for a
review, which is Mode R.

Gate 5 (`regression-validator.md`) and Gate 6 are not the same pass. Gate 5 compares
the **contract** against the authoritative baseline on its seven dimensions. Gate 6
asks whether the code **does the right thing at all** - reachability, data-level
compatibility, boundaries, layer agreement, test honesty. Where they touch (caller
compatibility), **Gate 5 owns the contract table** and Gate 6 does not restate it.

## 0.1 Depth is proportional - this is not a repository scan

Checking depth follows the change's blast radius, never "be thorough". A dimension
is never skipped as a *question*; what scales is how far you trace to answer it.

| Change shape | Trace |
|---|---|
| One method, one caller, no shared code, no rule touched | that caller, the boundary values, the tests of that method |
| A new or changed validation / business rule | every layer that computes the same rule (dimension 4) + existing data that must still pass (dimension 2) |
| Shared code - helper, base class, filter, middleware, extension, DTO, defaulted parameter | every caller (P3 / Gate 3), then dimensions 1-5 per caller class |
| A new endpoint / parameter / field | its own chain end to end, plus whoever serialises or persists the new value |

Forbidden: "I have not reviewed the whole repository, so I cannot say." The question
is always **this change's** reachability, compatibility and boundaries.

## 1. Business logic and call-chain reality  (highest priority)

An implemented method proves nothing until its caller is named.

- For every method added or changed, name the **actual** caller(s) at `path:line`.
  No caller found -> `NOT OBSERVED IN TRACED PATH` or `UNREACHABLE` - never
  "done". A registration path counts as a caller (DI, filter, middleware,
  startup wiring, attribute, job scheduler) - see SKILL.md's invariants.
- Walk the chain the repository actually has - typically entry point -> service ->
  helper -> repository -> database - and say which layer now carries the change.
- State the **business condition** under which the new code runs, and confirm from
  code that the condition is reachable: which flag, role, status, locale, feature
  switch or branch puts execution there. A new branch behind a condition that is
  never true in production is a silent no-op.
- Check what the change leaves behind: dead code, an unreachable branch, a
  condition that can no longer be false, an error path that now returns the wrong
  failure, and **a return value nobody reads** (a validation result assigned and
  discarded is the classic one - it compiles, and validates nothing).
- Finally compare behaviour to the requirement, not implementation to the plan:
  "the method exists and is correct" is not "the ticket's behaviour happens".

```
Call Chain:  POST /x (Controller:88) -> OrderService.Submit (:142)
             -> LimitHelper.Check (:33, NEW)  -> returns Result, USED at :145
Runs when:   order.Type == 2 && member.Status == Active   (reachable: :139)
Dead/unused: none | <what, path:line>
```

## 2. Backward compatibility and regression  (highest priority)

The rule that bites is rarely "the API changed" - it is **existing data that was
legal yesterday and is illegal today**.

- Before changing a rule, record the rule as it stands and the data shapes it
  currently accepts, with evidence (`path:line`, a column's nullability, the
  format of a real stored value).
- Compare Before / After as **behaviour**, per population: a brand-new record, an
  old member's record, historical or imported data, an existing API caller, an
  in-flight session.
- A new or tightened validation is guilty until proven innocent: does it reject
  data the system itself produced earlier? Nullable columns, blank legacy values,
  a looser legacy format, a code value retired years ago, a default-zero date.
- **Partial update is the trap.** When an update path validates the whole entity
  but the user edits one field, a historical value in an untouched field can fail
  the new rule and block an edit that has nothing to do with it. Say explicitly
  whether validation applies to the submitted fields or to the whole record.
- **Never tighten an existing rule without a requirement that asks for it**
  (HARD RULE 12). Discovering that a rule is loose is a finding to report, not a
  licence to fix it inside this ticket.
- If the requirement genuinely needs a breaking change, it is not implemented
  silently: propose a migration, a grace rule or a compatibility path and carry
  it to Approval Gate #1 as an explicit decision (`change-proposal.md` §5).

Contract-level deltas (the seven dimensions, risk grade, what blocks Gate #2) stay
in `regression-validator.md`. This dimension adds the **data population** view.

## 3. Boundary values and runtime safety

- `null`, empty string, whitespace-only, empty collection, `0`, negative, maximum,
  off-by-one at both ends, duplicate, oversized input, unexpected format.
- Numbers: overflow, division by zero, precision, rounding direction,
  currency / percentage scaling, implicit conversion.
- **Dates: validate against the range the actual type allows**, not a guessed one -
  the minimum and maximum of the runtime type, and separately of the database
  column (they differ, and the narrower one decides). Also local era vs calendar
  year, month end, leap day, string-to-date parsing, time zone, and
  culture-dependent parsing or formatting; prefer the repository's existing
  culture-invariant idiom.
- Parsing: a `TryParse` whose `false` branch is unhandled, an exception-throwing
  parse on user input, a cast that can fail at runtime.
- Unhandled exceptions, an uninitialised or conditionally-assigned variable, a
  nullable dereference the compiler cannot see, an index out of range.
- **The backend never relies on frontend validation** (P1, HARD RULE 14). A rule
  the UI enforces must also hold server-side for any mutation, authorization or
  eligibility decision - the route behind the UI is still open.

## 4. Cross-layer rule consistency

The same business rule implemented twice drifts; the bug then appears where the two
copies disagree, not inside either one.

- For each rule this change touches, list where it is computed: frontend, backend
  service, database constraint / default / trigger, a preview or draft path, a
  status or eligibility calculation, a scheduled job, a report.
- Compare the **condition**, not the wording: age and date-of-birth cut-offs,
  gender or category code sets, required-field sets, status transitions,
  visibility and expiry rules, rounding.
- A deliberate difference between layers needs a requirement behind it; record it.
  An accidental one is a finding.
- Prefer one owner of the rule over a second copy (P5 / Gate 3). If a second copy
  cannot be avoided here, name the pair in the report so the next change sees both.

## 5. Validation flow and error handling

- **Order matters**: required -> format -> business condition -> system error.
  Report the first, most specific, actionable failure; a format error raised
  before the missing-field error misleads the caller.
- Keep those four kinds apart in the response, using the repository's native
  failure channel and error codes (`development-convention.md` §4) - never a
  second error-handling scheme beside it.
- Confirm every validation's **return value is read** and short-circuits the flow
  (dimension 1), and that a later assignment cannot overwrite an earlier error
  message or status.
- One clear, actionable message per failure; do not concatenate an unbounded list
  of messages, and do not leak internal detail or identifiers.
- A caught exception that returns success is a Gate 5 check-3 failure, not a
  style issue.

## 6. Maintainability

- No duplicated validation logic - reuse or extend the existing rule (P5).
- No magic number or encoded literal introduced without a name or a documented
  reason (`encoded-values.md`); reuse the existing constant before defining one.
- Each method does one thing, and its **name matches what it actually does** after
  the change - a method whose name still describes the old behaviour is a trap for
  the next reader.
- A large addition is a prompt to ask whether a split is warranted, decided by the
  repository's existing structure, not by a pattern catalogue
  (`development-convention.md` §3, over-engineering guard).
- Follow the existing architecture and idiom first.
- **Refactoring never changes business behaviour.** Tidying inside a bug or
  feature ticket is out of scope unless §3b's four preconditions hold.

## 7. Test completeness and verification honesty

When the change adds or alters a core business rule, cover - proportional to risk:
normal case · failure case · boundary case · `null` / empty / malformed ·
each business-condition branch · **old-data compatibility** · the API error
response · regression of the previously working path.

Which tests to run, test preservation and the no-relevant-tests path stay in
`verification.md`. What this dimension adds is a reporting rule:

```
EXECUTED AND PASSING   - the command was run here; give it and the counts
STATIC REVIEW ONLY     - reasoned from code, not executed
NOT VERIFIED           - could not run here (DB / container / network / env) + why
```

Every test claim carries one of these three labels. **Never describe a test that
was not executed as passing**, and never let a green related-test run imply that
the untested dimensions above are clear (HARD RULE 10, HARD RULE 11).

## 8. GATE 6 - Self-Review (Mode A, after the diff, before Approval Gate #2)

Trigger: any Mode A implementation, every time. It runs **after** Gate 5 run 2 and
reviews the real diff, not the plan. Length is proportional - a one-line fix is
seven short lines; it is never skipped, and never becomes a repository scan.

```
SELF-REVIEW (Gate 6)
1 Call chain / reachability : OK | <finding>      (caller at path:line)
2 Backward compatibility    : OK | <finding>      (populations checked)
3 Boundaries / runtime      : OK | <finding>
4 Cross-layer consistency   : OK | N/A - no shared rule touched | <finding>
5 Validation order / errors : OK | <finding>
6 Maintainability           : OK | <finding>
7 Tests                     : EXECUTED AND PASSING | STATIC REVIEW ONLY
                              | NOT VERIFIED   + gaps
```

Severity (shared with `code-review.md`):

| | Meaning |
|---|---|
| `BLOCKER` | wrong behaviour, a broken business rule, a compatibility break, or a runtime exception on a reachable path |
| `MAJOR` | a real defect on a narrow or unproven path, or a missing test for a rule this change introduced |
| `MINOR` | maintainability, naming, duplication - worth doing, does not hold the change |
| `RISK / TO CONFIRM` | cannot be verified from here; stated as a risk, never asserted as a defect |

A `BLOCKER` is **fixed before the report**, inside the approved scope, through the
Fix Loop (`verification.md` §3.5) - not reported as a known defect. If fixing it
needs scope the user has not approved, stop and ask; it blocks Approval Gate #2.
`MAJOR` and below are listed in the Gate #2 report for the user to decide.
Gate 6 never widens the approved scope on its own, and never fixes a pre-existing
defect it merely happened to notice - that is reported (HARD RULE 12).
