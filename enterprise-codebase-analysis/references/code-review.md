# Mode R - Requested Code Review (read-only)

Loaded when the user asks for a **review of code that already exists** - a merge
request, a branch, a diff, a commit range, "幫我 review 這個 MR", "這段改動有沒有
問題". It produces findings, never a fix: Mode R changes no file (HARD RULE 16).
If the user then asks for the fixes, that is a new Mode A ticket with its own
Approval Gate #1.

**The full review is the default.** Every trigger - a local `git diff`, a branch
comparison, a GitLab / GitHub merge request, a named commit range, a pasted diff -
runs the call-path trace (§2.5) and all six check categories
(`thinking/code-review-checks.md`) without being asked, and without waiting for the user to
name a category. Reviewing only the correctness of the diff's own lines is not a
review: **the question is what this change does to the real execution path and to
the existing callers.**

Mode R reuses, rather than re-inventing: the seven quality dimensions and the
severity ladder come from `thinking/code-quality-gates.md`, the six mandatory check
categories from `thinking/code-review-checks.md`, contract loss from
`thinking/regression-validator.md`, reuse and negative evidence from `thinking/capability-reuse.md`,
and reply shape, table format and prose rules from `thinking/explanation-standard.md`. No
gate paperwork (Gates 1-5) and no branch, commit, build-to-complete or memory
write are required.

**Division of authority - there is no single company-wide review document.**

| Owns | What |
|---|---|
| this skill | the **mandatory** checks every review runs (`thinking/code-review-checks.md`), the procedure, the evidence and uncertainty rules, the report shape |
| the target repository | its **project-specific** technical and business requirements - its own review chapter in `CLAUDE.md` / `AGENTS.md`, and its business rules under `.agents/rules/` (plus any synced `.claude/rules/` copy) |

A repository's own rules win on anything they define, and may only make a check
stricter, never remove one (SKILL.md -> Repository-local rules win). **Never carry
a technical conclusion from one repository to another** - runtime, framework
version, auth mechanism and data-access stack differ, so the same code can be safe
in one and a defect in the other. Where two documents **genuinely conflict**, do
not pick one: raise it as a 待確認事項 (§5.5) naming both sources. Entry point for
the repositories here, and what differs between them:
`workspace/PROFILE.md` -> Organization-Specific Procedures.

## 1. Resolve the two ends of the diff - ask, never assume

A review of the wrong range is worse than no review. **Never default to a branch
name** - not `origin/qa`, not `main`, not `develop`, not the last commit.

```
git status -sb ; git branch --show-current ; git log --oneline -5 ; git remote -v
git log --oneline <base>..<head> | head -40      # merge-base: git merge-base A B
REVIEW SCOPE  head: <branch/commit>  base: <branch/commit>  files: <n> (+i/-d)
```

- Both ends named -> use them. One end or none -> infer from the repository's own
  evidence (the MR the branch belongs to, its stated integration branch, the
  merge-base), **say which evidence you used**, and proceed only if it is
  unambiguous. Two plausible targets -> ask, and stop.
- A pasted diff is its own scope; say so, do not guess which branch it came from.
- `git fetch` only if the user asks: review what is local and say the base may be
  stale, rather than mutating the repository's remote state (`git-safety.md`).

**No GitLab / GitHub API access.** This skill has no MR / PR API credential, so a
merge request is reviewed through one of three local substitutes: the local branch
comparison, a commit range, or the diff the user pastes. That is allowed - but
**never describe it as having reviewed the merge request itself**. State which
substitute was used and what it therefore cannot see: commits pushed after your
local copy, the MR's description and discussion, its approval state and CI result,
and any file outside the diff you were given. The call-path trace (§2.5) and the
six default checks still run in full - a missing API is a scope caveat, never a
reason to shrink the review to the diff's own lines.

## 2. Diff first, then only the context the diff demands

The MR diff is the review scope. Reading beyond it is allowed only to answer a
question the diff raised, and the report says why it was read.

Widen for exactly these reasons:

| Trigger in the diff | What to open |
|---|---|
| a new or changed method | its callers (dimension 1) |
| a changed shared method, DTO, base class, filter, middleware, extension | every caller, then each caller's class of behaviour (P3) |
| a changed or added validation / business rule | the other layers computing the same rule (dimension 4) + what existing data looks like (dimension 2) |
| a changed query, entity, migration or stored procedure | the schema, nullability, and who else writes that column (read-only, `database-safety.md`) |
| a removed line | what used to depend on it - a deleted check, log, audit write or side effect is the highest-yield finding in any diff |

Not reasons to widen: completeness, curiosity, "while I am here", or auditing the repository's pre-existing quality.

## 2.5 The call-path trace (required output, every review)

Not an optional deep dive: before grading anything, follow what the change **newly calls or now routes through**, down to the code that really performs I/O - entry point, service, data-access member, the actual query or stored procedure, plus any helper that sends mail, calls a service, touches a cache or enqueues work. **Read the implementation; a method name is never evidence of what it does.**

The report carries this as its own block (`templates/code-review.md`):

```
TRACED PATH
<entry point path:line> -> <service path:line> -> <repository path:line>
  -> <query / stored procedure / external call>   <data store or service>
Shared with:      <other callers of each shared member, path:line> | SOLE CALLER
Transaction:      <scope, isolation, timeout, what is inside it> | NONE
External I/O:     <cache / mail / HTTP / queue, with its timeout> | NONE
Registration:     <new or changed DI registration + lifetime> | UNCHANGED
Contract surface: <DTO fields / status codes / messages that changed> | UNCHANGED
                  consumers: <web / app / partner / internal> | UNKNOWN CALLERS
Not traced:       <what was left closed, and why>
```

A shared member reached by several entry points is assessed **for every caller**, not only the one in the diff (P3). A changed response contract - a field renamed or removed, a status code or message whose meaning moved - is assessed against the consumers that depend on it; if they cannot be enumerated here, that is `UNKNOWN CALLERS`, a ❓ row, not silence.

## 3. Separate introduced from pre-existing

Every finding is labelled, and the labels are not interchangeable:

```
INTRODUCED    this diff creates it, or this diff makes a latent defect reachable
PRE-EXISTING  true before the diff; listed once, informational, never a blocker
AGGRAVATED    existed before, and this diff widens its exposure or blast radius
```

A pre-existing defect is never escalated into a reason to reject the change, and fixing it is never folded into the review's recommendation - it is a separate ticket (HARD RULE 12).

**But a high-risk pre-existing defect is still reported.** Being outside the diff
is not a reason to stay silent: a SQL-injection sink, a missing authorization or
ownership check, a leaked secret or a lost-data path found **along the traced path**
goes into its own report block with its evidence and the recommendation to raise a
separate hotfix ticket. It is listed as `PRE-EXISTING`, it does not block this
change, and the review says plainly that the two decisions are separate.

## 4. What to look for, in priority order

All six categories of `thinking/code-review-checks.md` run by default - correctness,
security, performance / I/O, asynchrony and transactions, exception handling and
partial success, project convention. They are *reported* in impact order:

| # | What | Typical shape |
|---|---|---|
| 1 | **Functional defect** | wrong logic, inverted condition, wrong operator or boundary, a result computed and discarded, an unreachable or no-op change |
| 2 | **Business-rule mismatch** | the code does not do what the requirement or the repository's recorded business rules (`.agents/rules/` and the like) say, or two layers now disagree |
| 3 | **Security** | injection, missing or bypassable authorization, IDOR, unencoded output, brute-forceable one-time code, hard-coded secret. Server-side enforcement is not a separate pass: a missing server-side check on a mutation, authorization or ownership decision is priority 1 (P1, HARD RULE 14) |
| 4 | **Compatibility break** | existing data, old records, existing callers, partial updates, a response contract its consumers still depend on; contract loss on Gate 5's dimensions - especially a deleted side effect, audit record or auth check (`thinking/regression-validator.md`) |
| 5 | **Runtime failure** | `null`, parse, cast, index, overflow, date range, culture, unhandled failure branch, blocked async chain, lock held across external I/O |
| 6 | **Partial success** | data committed but the caller told it failed, or a required follow-up step silently skipped |
| 7 | Then error-handling detail, convention conformance, maintainability, duplication, magic values (`thinking/encoded-values.md`), test gaps |

Stop pushing deeper once the remaining effort would only buy style points.

## 5. One finding, five facts

Every finding carries all five facts, or it is not a finding. They map onto the
review table of `thinking/explanation-standard.md` §4 - one row per finding, each row
complete on its own (no "same as #2", no "see above"):

| 嚴重度 | 驗證 | 新舊 | 程式來源 | 原因／風險 | 建議修改方式 |
|---|---|---|---|---|---|
| 🔴 建議修正 | ✅ 已驗證 | 本次新增 | `path:line` | **Trigger**: the input / state / population that reaches it -> **Impact**: what the user or data experiences | the smallest fix in this repo's idiom, naming the API / method |

- **Three axes, never merged** (defined in `thinking/explanation-standard.md` §4):
  嚴重度 🔴 建議修正 / 🟡 建議改善 / 🟢 小問題或備註 · 驗證 ✅ 已驗證 / ❓ 待確認 ·
  新舊 本次新增 / 既有 / 既有但本次擴大. 程式來源 carries `path:line` plus the
  evidence; unreachable proof -> ❓ with `UNVERIFIED - <what>`.
- **Severity is judged by real impact.** Do not file improvements as 🔴: a review
  whose every line is 🔴 tells the reader nothing. Expect most diffs to produce
  zero or one 🔴.
- **An unverifiable suspicion is a risk, not a bug**: file it as ❓ per §5.5 and
  never present an unconfirmed hypothesis as a defect (SKILL.md, negative
  evidence).
- Taste is marked as taste and kept out of 🔴; full fix code only on request.

## 5.5 When you are not sure - ask, never guess (mandatory)

This is a stop rule, not advice. Whenever the review cannot establish something
from the evidence in front of it - the requirement's real intent, whether a
behaviour is deliberate or a defect, what a stored procedure / trigger / external
service actually does, a configuration you cannot read, whether an existing caller
is still live, or whether a change alters an existing business flow - you may
**not** assume, and you may **not** list the unverified inference among the
confirmed findings.

Do this instead:

1. finish every check that *can* be settled independently, and report those;
2. put the open item in the report's **待確認事項 / To Confirm** block - never
   mixed into the confirmed list - as a ❓ row carrying all four of:

```
Established:   <what you did verify, with path:line>
Missing:       <the specific information you could not reach, and why>
Scenarios:     if <A> -> <conclusion A>; if <B> -> <conclusion B>
Question:      <the one concrete question>  ->  <who can answer it>
```

3. that item's verdict is **completed only after the user answers**. Without an
   answer the review is still delivered - partial is fine - with the item left
   explicitly unverified, and the overall verdict says so.

A ❓ row never counts toward the 🔴 / 🟡 totals, and "probably a bug" is not a
severity - it is ❓ with a conditional severity ("if A -> 🔴"). Equally, a ❓ is not
a shrug: it names what *would* settle it.

## 6. Output and verdict

Two outputs, per `thinking/explanation-standard.md` §6:

**The reply** (what the user reads):

```
REVIEW RESULT: <verdict>                       <- line one
Scope: <base>..<head>, <n> files               <- one line
<findings table, most severe first - the 3-5 that matter most; "+<n> more
 🟡/🟢 in the review file" when there are more>
Not reviewed / To confirm: <one line each, omitted when empty>
Next: <one line>        File: <path to the review file>
```

**The review file** - `templates/code-review.md`, the full record, in this order:
verdict · review scope and change summary · the traced path and affected
components (§2.5) · findings 🔴 then 🟡 then 🟢 · high-risk pre-existing issues
with the hotfix recommendation · 待確認事項 (§5.5) · tests and what remains
unverified · the dimension pass · what was not reviewed · the one-line
`Thinking Candidate` (default `NONE`; rule and admission criteria in
`thinking/README.md`) - reviewing someone else's fix is where a reusable principle
most often turns up. Every block appears even when its answer is `NONE` - an absent
block reads as "not checked".

Report only concrete, evidenced problems. **Do not manufacture a finding to fill a
severity bucket**; when nothing was found, say which categories and paths were
actually checked and which verification limits remain - that is the useful
answer, not an empty table.

The verdict recommends - it never merges, approves or pushes anything:

```
REVIEW RESULT: BLOCKING ISSUES FOUND (<n>) | NON-BLOCKING FINDINGS ONLY (<n>)
             | NO FINDINGS - LOOKS CORRECT FOR THE STATED SCOPE
             | CANNOT COMPLETE REVIEW - <what is missing>
```

Say explicitly what was **not** reviewed: files skipped, a layer not opened, a runtime behaviour not reproducible here. A review that hides its own blind spots is worse than a short one that names them.

## 7. Mode R hard boundaries

- **No file is modified** - no fix, no formatting, no "while I was in there" (HARD RULE 16). Offer the fix as a follow-up Mode A ticket.
- No push, MR / PR creation, merge, approve, comment-posting or remote branch
  change; no `git fetch` / `checkout` / `stash` unless the user asks
  (`git-safety.md`, HARD RULE 1, HARD RULE 9).
- Database read-only, and only when the diff makes a schema question material
  (`database-safety.md`, HARD RULE 2).
- Memory: a review is task output, not reusable knowledge. Usually `Memory Delta: NONE`; anything admitted goes through `memory-admission.md`.
- The review document is local-only, never written inside the repository, and a repository that has no review chapter or rules file does not get one authored for it (HARD RULE 3). It goes in that ticket's folder, `<workspace>/issue/<RepoName>/<Ticket>/` - created before the file (`usage.md` -> Output Locations).
