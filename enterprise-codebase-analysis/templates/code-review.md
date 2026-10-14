# [Branch / MR] - Code Review

> Mode R output. Read-only: this review changes no file. Local only, never written
> inside the repository (HARD RULE 3). Rules: `references/code-review.md`.

## Verdict

```
REVIEW RESULT: BLOCKING ISSUES FOUND (<n>) | NON-BLOCKING FINDINGS ONLY (<n>)
             | NO FINDINGS - LOOKS CORRECT FOR THE STATED SCOPE
             | CANNOT COMPLETE REVIEW - <what is missing>
```

<!-- Then 1-3 lines: what this change does, whether it does it, the one thing that
     matters most. Plain language (explanation-standard.md). -->

The verdict recommends. Merging, approving, pushing and commenting on the MR are
the user's (HARD RULE 1).

## Findings

<!-- Most severe first. One row per finding, each row complete on its own - never
     "same as above" or "see #2". Severity is real impact (code-quality-gates.md
     §8): 🔴 BLOCKER · 🟠 MAJOR · 🟡 MINOR · 🔵 MINOR (optimisation)
     · ❓ RISK / TO CONFIRM · ✅ checked, no change. Most diffs yield zero or one 🔴.
     ❓ rows put the exact question to ask, and who answers it, in the fix column. -->

| 分類 | 程式來源 | 原因／風險 | 建議修改方式 |
|---|---|---|---|
| 🔴 必須修正 | `<path:line>` · INTRODUCED · evidence `<path:line>` | Trigger: <input / state / population> -> Impact: <what the user or data experiences> | <smallest fix, naming the API / method> |
| ❓ 待確認 | `<path:line>` · UNVERIFIED - <what is missing> | <why it may fail; why it cannot be verified here> | Ask <who>: <exact question> |

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

## Pre-existing issues noticed (informational, not blocking)

<!-- Listed once, never escalated into a reason to reject this change, never
     folded into the recommendation. A separate ticket (HARD RULE 12). -->
- NONE

## Dimension Pass

<!-- One line each, so the reader knows which checks actually ran. N/A is a
     legitimate answer when the diff does not touch that dimension. A ❌ line
     names the problem itself - never "see finding #n". -->

```
1 Call chain / reachability : OK | N/A | ❌ <the problem in a few words, path:line>
2 Backward compatibility    : OK | N/A | ❌ <...>
3 Boundaries / runtime      : OK | N/A | ❌ <...>
4 Cross-layer consistency   : OK | N/A | ❌ <...>
5 Validation order / errors : OK | N/A | ❌ <...>
6 Maintainability           : OK | N/A | ❌ <...>
7 Tests                     : OK | N/A | ❌ <...>
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
