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

<!-- Most severe first. One row per finding, complete on its own - never "same as
     above" or "see #2". THREE AXES, never merged (explanation-standard.md §4):
     嚴重度 🔴 建議修正 / 🟡 建議改善 / 🟢 小問題或備註   (how bad if real)
     驗證   ✅ 已驗證 / ❓ 待確認                        (how sure we are)
     新舊   本次新增 / 既有 / 既有但本次擴大            (where it came from)
     Judged by real impact - most diffs yield zero or one 🔴. ❓ rows belong in the
     待確認事項 block below, not here, and carry a conditional severity. If the
     repository's own review chapter words these levels differently, ITS wording
     wins for that repository (code-review.md preamble). -->

| 嚴重度 | 驗證 | 新舊 | 程式來源 | 原因／風險 | 建議修改方式 |
|---|---|---|---|---|---|
| 🔴 建議修正 | ✅ 已驗證 | 本次新增 | `<path:line>` evidence `<path:line>` | Trigger: <input / state / population> -> Impact: <what the user or data experiences> | <smallest fix, naming the API / method> |
| 🟡 建議改善 | ✅ 已驗證 | 既有但本次擴大 | `<path:line>` | <trigger -> impact> | <fix> |

Counts: 🔴 <n> · 🟡 <n> · 🟢 <n> ｜ 待確認 ❓ <n> ｜ 本次新增 <n> · 既有 <n>
<!-- The three axes are counted separately; a ❓ is in no severity total. -->

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

## 已追蹤的呼叫路徑與受影響元件 (Traced Path)

<!-- Required in every review (code-review.md §2.5). Read the implementations -
     a method name is not evidence. Every line answered, `NONE` / `UNCHANGED` /
     `UNKNOWN CALLERS` included. -->

```
<entry point path:line> -> <service path:line> -> <data access path:line>
  -> <query / stored procedure / external call>     <data store or service>
Shared with:      <other callers of each shared member, path:line> | SOLE CALLER
Transaction:      <scope, isolation, timeout, what runs inside it> | NONE
External I/O:     <cache / mail / HTTP / queue + its timeout> | NONE
Registration:     <new or changed DI registration + lifetime> | UNCHANGED
Contract surface: <DTO fields / status codes / messages changed> | UNCHANGED
                  consumers: <web / app / partner / internal> | UNKNOWN CALLERS
Not traced:       <what stayed closed, and why>
```

## 既有高風險問題與 Hotfix 建議 (Pre-existing, not blocking)

<!-- Found along the traced path, outside this diff. Being outside the diff is NOT
     a reason to omit a SQL-injection sink, a missing authorization / ownership
     check, a leaked secret or a data-loss path. Listed with evidence and a
     separate-hotfix recommendation; it does NOT block this change, and the two
     decisions are stated as separate (code-review.md §3, HARD RULE 12). -->

| 風險 | 程式來源 | 為何危險 | 建議 |
|---|---|---|---|
| 🔴 | `<path:line>` · PRE-EXISTING · evidence `<path:line>` | <trigger -> impact> | 另開 hotfix：<what to change> |

- NONE

## 待確認事項（未驗證）To Confirm

<!-- NEVER mixed into the findings table. One block per open item, all four lines
     filled (code-review.md §5.5). Its verdict is completed only after the user
     answers; without an answer the review is still delivered, partial, with the
     item left explicitly unverified. A ❓ counts toward no severity total. -->

```
❓ <the open item in one line>
Established:   <what WAS verified, with path:line>
Missing:       <the specific information you could not reach, and why>
Scenarios:     if <A> -> <conclusion A>; if <B> -> <conclusion B>
Question:      <one concrete question>  ->  <who can answer it>
```

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
Verification this review could NOT complete:
<!-- runtime-only behaviour, an external service, production data, a stored
     procedure or configuration that could not be read. Never implied as clear. -->
-

## Thinking Candidate

<!-- One line, every review, default NONE. Did this diff teach a *reusable*
     principle - true at another company, another stack? Reviewing someone else's
     fix is where one most often turns up. Write it as the engineering concept, not
     as this diff's method / endpoint / table. Proposes only: it reaches
     references/thinking/ solely through that folder's six admission criteria
     (thinking/README.md). Most reviews are honestly NONE - do not invent one.
     NOT NONE -> it must also appear in the chat reply with an explicit ask; the
     review file alone is not enough, since it may never be opened.
     NONE -> say nothing about it in the reply at all. -->
```
Thinking Candidate: NONE | <the reusable principle, one sentence>
```

## Next Step

<!-- The fixes are NOT applied here. If the user wants them, that is a new Mode A
     ticket with its own Approval Gate #1 (code-review.md §7). -->
```
Memory Delta: NONE | <targeted ADD / UPDATE via memory-admission.md>
```
