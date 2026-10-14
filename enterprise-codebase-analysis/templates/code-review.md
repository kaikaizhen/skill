# [Branch / MR] - Code Review

> Mode R output. Read-only: this review changes no file. Local only, never written
> inside the repository (HARD RULE 3). Rules: `references/code-review.md`.

## Review Scope

```
Source (head): <branch / commit>        Target (base): <branch / commit>
Range:         <base>..<head>           Merge-base:    <sha>
Resolved by:   the user said so | <the repository evidence used>
Files:         <n>  (+<ins> / -<del>)
Diff command:  <exactly what was run>
```

Reviewed beyond the diff, and why:
<!-- one line each: path - the question in the diff that required opening it.
     "completeness" is not a reason (code-review.md §2). -->
- NONE

Not reviewed:
<!-- files skipped, a layer not opened, behaviour only reproducible at runtime.
     Naming the blind spots is mandatory. -->
-

## Summary

<!-- 3-5 lines for a reader who has not opened the diff: what this change does,
     whether it does it, and the one thing that matters most. Plain language,
     every term explained on first use (explanation-standard.md). -->

## Verdict

```
REVIEW RESULT: BLOCKING ISSUES FOUND (<n>) | NON-BLOCKING FINDINGS ONLY (<n>)
             | NO FINDINGS - LOOKS CORRECT FOR THE STATED SCOPE
             | CANNOT COMPLETE REVIEW - <what is missing>
```

| | Count |
|---|---|
| `BLOCKER` | |
| `MAJOR` | |
| `MINOR` | |
| `RISK / TO CONFIRM` | |
| `PRE-EXISTING` (informational) | |

The verdict recommends. Merging, approving, pushing and commenting on the MR are
the user's (HARD RULE 1).

## Findings

<!-- Most severe first. Every finding carries all five facts or it is not a
     finding. Severity is real impact, not aspiration - most diffs yield zero or
     one BLOCKER. An unverifiable suspicion is RISK / TO CONFIRM, never a bug. -->

### [BLOCKER] <one-line claim>

```
Where:     <path:line>   (INTRODUCED | PRE-EXISTING | AGGRAVATED)
Trigger:   <the concrete input / state / data population that reaches it>
Impact:    <what the user or the data actually experiences>
Fix:       <smallest change that resolves it, in this repository's idiom>
Evidence:  <path:line that proves it> | UNVERIFIED - <what is missing>
Dimension: <1-7 from code-quality-gates.md>
```

### [MAJOR] <...>

### [MINOR] <...>

### [RISK / TO CONFIRM] <...>

```
Question to ask: <the exact question, and who can answer it>
Why unverifiable here: <runtime only / external service / production data / config>
```

## Pre-existing issues noticed (informational, not blocking)

<!-- Listed once, never escalated into a reason to reject this change, never
     folded into the recommendation. A separate ticket (HARD RULE 12). -->
- NONE

## Dimension Pass

<!-- One line each, so the reader knows which checks actually ran. N/A is a
     legitimate answer when the diff does not touch that dimension. -->

```
1 Call chain / reachability : OK | N/A | see finding #<n>
2 Backward compatibility    : OK | N/A | see finding #<n>
3 Boundaries / runtime      : OK | N/A | see finding #<n>
4 Cross-layer consistency   : OK | N/A | see finding #<n>
5 Validation order / errors : OK | N/A | see finding #<n>
6 Maintainability           : OK | N/A | see finding #<n>
7 Tests                     : OK | N/A | see finding #<n>
Contract loss (Gate 5 dims) : unchanged | <delta> - <intended? evidence>
```

## Tests

```
Status: EXECUTED AND PASSING | STATIC REVIEW ONLY | NOT VERIFIED
```
<!-- STATIC REVIEW ONLY is the normal answer for a review: nothing was run.
     Never describe a test that was not executed as passing (HARD RULE 10). -->

Command (if any):
Coverage the diff should have but does not:
-

## Next Step

<!-- The fixes are NOT applied here. If the user wants them, that is a new Mode A
     ticket with its own Approval Gate #1 (code-review.md §7). -->
```
Memory Delta: NONE | <targeted ADD / UPDATE via memory-admission.md>
```
