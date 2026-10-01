# Completion Verification, Test Preservation & Post-Completion Documents

Mode A only. Applies between the end of implementation and Approval Gate #2, and
then after the user has confirmed the feature works.

---

## 1. Build / compile verification - mandatory before any completion claim

After implementation, before Approval Gate #2, run the build or compile that is
appropriate for that repository. Choose the command by the convention order in
`development-convention.md`:

```
1. the repository's own rule file / task runner (Taskfile, npm script, build script)
2. workspace/memory/repositories/<Repo>/patterns.md -> Build / Verification Commands
3. the obvious toolchain default for that project type
```

Report exactly one of:

```
Build: PASS        <command>   <summary>
Build: FAILED      <command>   <the real error lines, not a paraphrase>
Build: NOT RUN     <command that would be used>   <why it cannot run here>
```

Rules:

- **Only `PASS` permits the words "完成" / "done" / "implemented".** A build that
  was not run, or did not pass, means the work is reported as *unverified*.
- `FAILED` -> fix it. If it genuinely cannot be fixed inside this ticket's scope,
  report `FAILED` with the errors, state what is blocked, and stop at Approval
  Gate #2 with the change explicitly marked unverified. Never summarise a failing
  build as "just warnings".
- `NOT RUN` (toolchain absent, restore needs network/credentials that are not
  available, build requires Docker or an IDE that is not installed, building
  would touch a shared artefact) -> name exactly what is missing and write:

  ```
  VERIFICATION INCOMPLETE - completion not claimed
  ```

  then ask the user to run it if they can, and report their result rather than
  assuming it.
- Reading the code, a linter, an IDE squiggle, or "this should compile" never
  substitutes for a build.
- **Never run a build target that deploys, pushes an image, or touches a shared
  environment** (`*-docker-build-push`, `*-deploy-qa`, `*-deploy-production`, or
  equivalents). Local compile only. This follows from HARD RULE 1.

---

## 2. Test Preservation

Before changing a method or flow, find the tests that already cover it - unit and
integration. Record what was found (and where you looked) in the analysis
document under `## Existing Test Coverage`.

### When existing tests cover the changed method / flow

- **Keep every requirement and every regression case those tests already
  express.** They encode decisions from earlier tickets that this ticket was not
  asked to revoke.
- Adjust or add cases for the ticket's new behaviour.
- **Never** delete a test, comment it out, rename it out of the run, relax an
  assertion, or rewrite it so that only the new behaviour passes. A test suite
  that only proves the newest ticket is not a regression suite.
- If an existing test now genuinely contradicts the ticket, do not quietly change
  it. Report it and wait:

  ```
  EXISTING TEST CONTRADICTS TICKET
  Test:        <project / file / test name>
  Asserts:     <the old requirement>
  Ticket says: <the new requirement + where it says so>
  Proposal:    update | keep + narrow the new behaviour | ask requirement owner
  AWAITING USER DECISION
  ```

### Which tests to run - related, not everything

Run the tests **related to this change**, and report their counts honestly. Not
just the test you added; not the whole suite either. A legacy repository usually
carries failures this ticket did not cause, and running everything turns those
into a permanent block on unrelated work.

The related set is already written down by earlier steps - it is not a new
judgement call:

```
1  the tests listed in ## Existing Test Coverage  (the changed method / flow)
2  the tests for anything in ## Impact Scope      (confirmed callers, shared code
                                                   this change touched - P3)
3  one case per non-`unchanged` row of Gate 5's table   (the regressions this
                                                   change could actually cause)
4  the test you added or adjusted
```

Select them with the runner's own filter (test class, namespace, category, name
pattern, file path) rather than by running the project and reading past the
noise. State the filter used, so the scope is reviewable.

Widen beyond that set only when the change is in shared code whose callers could
not be enumerated (`UNKNOWN CALLERS`, P3) - and then say why.

**A failure that also fails on the authoritative baseline is not this ticket's.**
Before treating any failure as caused by this change, check the same test at the
Gate 5 baseline (`regression-validator.md`). Report it as:

```
PRE-EXISTING FAILURE   <test>   fails at baseline <ref> too - not caused by this
                       change, not fixed here (that would be scope creep)
```

and carry on. Only a test that passes at the baseline and fails now blocks the
work. Never "fix" an unrelated broken test inside this ticket, and never delete,
skip or weaken one to make the run green (HARD RULE 11) - if an unrelated failure
makes the related set unrunnable, say so and let the user decide.

"改 A 壞 B" is caught by the related set above - specifically by items 2 and 3,
which is why they are derived from the impact analysis rather than guessed.

### When no existing tests cover it

Do not decide alone, and do not silently skip:

```
NO RELEVANT TESTS FOUND
Method / flow:    <what is being changed>
Searched:         <test projects, paths, naming patterns actually checked>
Repository rule:  <rule file requires tests for changed logic | none found>
Options:          (a) add tests now   (b) implement without new tests
AWAITING USER DECISION ON TEST COVERAGE
```

- If the repository's own rule file requires tests for changed logic, that rule
  still applies (convention order level 1). Say so - the question then is scope
  and depth, not whether.
- Do not build test infrastructure the repository does not have as a side effect
  of an unrelated ticket. Propose it, let the user decide.

### Tests that cannot run here

Integration tests needing containers, a database, or network are reported as
`NOT RUN` with the reason, exactly like a build. Unrun tests are never reported
as passing.

---

## 3. Reporting, and the regression re-check

`templates/implementation-result.md` carries `Build`, `Tests`, the test
preservation statement and **Gate 5 run 2**. Report what was actually executed,
with the command and its real output. An honest `FAILED` / `NOT RUN` is always
better than a confident claim the user later disproves.

Before the report is written, re-run the Contract Parity table against the actual
`authoritative baseline -> final working tree` diff, not against the plan and not
against the previous commit (`regression-validator.md`). A build that passes and
tests that pass do **not** clear a contract regression: a lost audit record, a
side effect moved onto a background task, an exception now swallowed while the
operation still reports success, or a dropped auth check all compile and pass the
existing suite. Calling the same method is not the same contract.
A HIGH security, server-side enforcement, data-integrity, transaction-atomicity
or audit-loss regression that is unresolved and not explicitly accepted by the
user blocks Approval Gate #2 (HARD RULE 13):

```
REGRESSION RISK - HIGH - UNRESOLVED
Dimension:  <which of the seven>
Baseline:   <what it did, path:line>      Now: <what it does>
Options:    (a) restore parity  (b) accept the change explicitly  (c) follow-up
AWAITING USER DECISION
```

---

## 3.5 The Fix Loop - what happens when verification fails

A failure at step 21 / 21.5 does **not** restart the ticket. Re-running the whole
analysis re-opens settled scope, re-reads source already confirmed, and burns the
context that the failure evidence needs. Instead, open a **Fix Task**: one failure,
one diagnosis, one smallest safe fix, one re-verification.

Triggers: build failure · test failure · lint failure · an acceptance criterion
not met · a Gate 5 regression.

```
Failure
  -> Fix Task  (carry only the context below)
  -> Diagnose      root cause of THIS failure, from the real output
  -> Smallest Safe Fix
  -> Build  ->  Test  ->  Verify
  -> pass?   yes -> back to the step that failed, continue forward
             no  -> next Fix Task
```

**Context a Fix Task carries** - and nothing else (`runtime-contract.md` §3):

```
original goal, one paragraph        the acceptance criteria this failure touches
current diff                        the failure evidence, verbatim
the source the failure points at    previous decisions, as a summary
```

Dropped: the full analysis document, source outside the failing path, superseded
tool output, failures already resolved. The ticket's scope decisions, gate outputs
and acceptance criteria stay authoritative - a Fix Task may not quietly widen
scope, and a fix that genuinely requires work outside the approved plan goes back
to the user, not into the diff (HARD RULE 12).

**Rules inside the loop:**

- The fix is the smallest change that addresses the diagnosed cause -
  `Understand -> Verify -> Modify`, existing-pattern-first
  (`development-convention.md` §3b). Not a redesign, not a drive-by cleanup.
- Diagnose from the actual error lines. Attempting a fix before the cause is named
  is guessing; two guesses in a row on the same failure means stop and report.
- **Never** make the signal green by weakening it: no deleted / skipped / disabled
  test, no relaxed assertion, no suppressed warning-as-error, no commented-out
  lint rule (HARD RULE 11).
- A `PRE-EXISTING FAILURE` (§2) is not a Fix Task - it is reported and left alone.
- Each iteration re-runs the build and the related test set, and if the diff
  changed, Gate 5 run 2 as well (`regression-validator.md`). Earlier iterations'
  output is superseded and dropped.
- The loop is bounded by evidence, not by attempts: when an iteration produces no
  new information about the cause, stop and report rather than cycling.

```
FIX LOOP EXHAUSTED
Failure:     <command + the real error lines>
Attempts:    <what was tried, and what each one ruled out>
Diagnosis:   CONFIRMED <cause> | CANDIDATE <hypothesis> | UNKNOWN
Blocked by:  <missing decision / missing access / out-of-scope cause>
AWAITING USER DECISION
```

The loop ends in exactly one of: verification passes and the ticket continues to
Approval Gate #2; `VERIFICATION INCOMPLETE` with the reason (HARD RULE 10); or
`FIX LOOP EXHAUSTED` above. It never ends in a completion claim.

---

## 4. Post-completion documents

Both are skill-generated documents: **LOCAL ONLY**, outside the target
repository, never staged, never committed (HARD RULE 3).

### `<Ticket>驗收標準.md` - acceptance test cases

Created only when **all three** hold:

1. implementation is finished;
2. build passed, and the tests that could run were run;
3. **the user has explicitly confirmed the feature works.**

A green build is not user confirmation. Without (3), do not create the file -
offer it instead.

- Location: the same directory as the analysis document -
  `<workspace>/issue/<RepoName>/<Ticket>驗收標準.md`.
- Template: `templates/acceptance-criteria.md`.
- Built from three sources, in this order:
  1. the ticket's own acceptance criteria,
  2. what was actually implemented (the final diff, not the original plan),
  3. regression requirements - the behaviour the preserved existing tests
     protect, plus the flows named in the impact analysis.
- Every row must be executable by someone who did not do the implementation:
  preconditions / data, the action, the expected result, pass-fail.
- Do not copy the analysis document into it, and do not invent criteria the
  ticket never asked for. An item the ticket did not require is listed, if at
  all, under `參考 / 非本次驗收範圍`.

### `<Ticket>skill待優化項目.md` - skill retrospective

- Produced **only when the user explicitly asks for it.** Never offered as a
  routine end-of-ticket deliverable.
- Same directory, unless the user names another location.
- It reviews this skill's workflow (using the ticket only as a case study), not
  the repository's code.
- Every finding is first classified against P1-P5 and the existing gates
  (`engineering-principles.md` -> "Adding a rule"). A finding that already
  belongs to an existing concept sharpens that text; it does not become a new
  rule, and it is never written as the ticket's method, endpoint or table name.
- It changes nothing by itself. Any resulting skill edit is a separate task with
  its own approval.
