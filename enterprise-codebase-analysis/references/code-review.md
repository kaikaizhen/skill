# Mode R - Requested Code Review (read-only)

Loaded when the user asks for a **review of code that already exists** - a merge
request, a branch, a diff, a commit range, "幫我 review 這個 MR", "這段改動有沒有
問題". It produces findings, never a fix: Mode R changes no file (HARD RULE 16).
If the user then asks for the fixes, that is a new Mode A ticket with its own
Approval Gate #1.

Mode R reuses, rather than re-inventing: the seven quality dimensions and the
severity ladder come from `code-quality-gates.md`, contract loss from
`regression-validator.md`, reuse and negative evidence from `capability-reuse.md`,
and reply shape, table format and prose rules from `explanation-standard.md`. No gate paperwork (Gates 1-5) and
no branch, commit, build-to-complete or memory write are required.

## 1. Resolve the two ends of the diff - ask, never assume

A review of the wrong range is worse than no review. **Never default to a branch
name** - not `origin/qa`, not `main`, not `develop`, not the last commit.

```
git status -sb ; git branch --show-current ; git log --oneline -5
git remote -v ; git branch -r --list '*/<guess>' ; git log --oneline <base>..<head> | head -40
```

State the resolved range back before reviewing:

```
REVIEW SCOPE
Source (head): <branch / commit>          Target (base): <branch / commit>
Range:         <base>..<head>   (merge-base: <sha>)
Files:         <n>   (+<ins> / -<del>)
```

- The user named both ends -> use them.
- The user named one end, or none -> infer from the repository's own evidence (the
  MR / PR the branch belongs to, the repository's stated default integration
  branch, the branch's merge-base), **say which evidence you used**, and proceed
  only if it is unambiguous. Two plausible targets -> ask, and stop.
- A detached diff the user pasted is its own scope; say so and do not guess the
  branch it came from.
- `git fetch` only if the user asks. Review what is local, and say the base may be
  stale rather than mutating the repository's remote state (`git-safety.md`).

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

Not reasons to widen: completeness, curiosity, "while I am here", or auditing the
repository's pre-existing quality.

## 3. Separate introduced from pre-existing

Every finding is labelled, and the labels are not interchangeable:

```
INTRODUCED    this diff creates it, or this diff makes a latent defect reachable
PRE-EXISTING  true before the diff; listed once, informational, never a blocker
AGGRAVATED    existed before, and this diff widens its exposure or blast radius
```

A pre-existing defect is never escalated into a reason to reject the change, and
fixing it is never folded into the review's recommendation - it is a separate
ticket (HARD RULE 12).

## 4. What to look for, in priority order

Run the seven dimensions of `code-quality-gates.md` against the diff, in this
order - stop pushing deeper once the remaining budget would only buy style points.

1. **Functional defects** - wrong logic, inverted condition, wrong operator or
   boundary, wrong branch, a result computed and discarded, an unreachable or
   no-op change (dimension 1).
2. **Business-rule mismatch** - the code does not do what the requirement or the
   surrounding rules say, or two layers now disagree (dimension 4).
3. **Compatibility break** - existing data, old records, existing callers, partial
   updates, a tightened rule with no requirement behind it (dimension 2); contract
   loss on the seven dimensions, especially a deleted side effect, audit record or
   auth check (`regression-validator.md`).
4. **Runtime exceptions** - `null`, parse, cast, index, overflow, date range,
   culture, unhandled failure branch (dimension 3).
5. Then error handling and validation order (dimension 5).
6. Then maintainability, duplication, naming, magic values (dimension 6,
   `encoded-values.md`).
7. Then test gaps for the rules this diff introduces (dimension 7).

Security and server-side enforcement are not a separate pass: a missing
server-side check on a mutation, authorization or ownership decision is a
functional defect at priority 1 (P1, HARD RULE 14).

## 5. One finding, five facts

Every finding carries all five facts, or it is not a finding. They map onto the
review table of `explanation-standard.md` §4 - one row per finding, each row
complete on its own (no "same as #2", no "see above"):

| 分類 | 程式來源 | 原因／風險 | 建議修改方式 |
|---|---|---|---|
| 🔴 必須修正 | `path:line` · INTRODUCED | **Trigger**: the concrete input / state / population that reaches it -> **Impact**: what the user or data experiences | the smallest fix in this repo's idiom, naming the API / method (`int.TryParse()`, an `isSubmitting` guard) |

- 程式來源 carries the location, the INTRODUCED / PRE-EXISTING / AGGRAVATED label
  and the evidence `path:line`; an unreachable proof is written
  `UNVERIFIED - <what is missing>`.
- **Severity is judged by real impact**, using the ladder in
  `code-quality-gates.md` §8: 🔴 `BLOCKER` · 🟠 `MAJOR` · 🟡 / 🔵 `MINOR` (🔵 =
  performance / structure / UX optimisation) · ❓ `RISK / TO CONFIRM` · ✅ checked,
  no change. Do not file improvements as blockers: a review whose every line is
  🔴 tells the reader nothing. Expect most diffs to produce zero or one 🔴.
- **An unverifiable suspicion is a risk, not a bug.** If you cannot reach the
  evidence - runtime-only behaviour, external service, production data, a config
  you cannot see - file it as ❓ `RISK / TO CONFIRM`, and put the exact question to
  ask (and who can answer it) in the fix column. Never present an unconfirmed
  hypothesis as a defect (SKILL.md, negative evidence).
- A judgement about taste is marked as such and kept out of 🔴 / 🟠.
- Full code for a fix only when the user asks.

## 6. Output and verdict

Two outputs, per `explanation-standard.md` §6:

**The reply** (what the user reads):

```
REVIEW RESULT: <verdict>            <- line one
Scope: <base>..<head>, <n> files     <- one line
<findings table, most severe first - the 3-5 that matter most;
 "+<n> more 🟡/🔵 in the review file" when there are more>
Not reviewed: <one line, or omitted when nothing was skipped>
Next: <one line - e.g. "fix the 🔴 row as a new ticket", or "ready from a code standpoint">
File: <path to the review file>
```

**The review file** - `templates/code-review.md`, the full record: every finding,
the dimension pass, what was opened beyond the diff and why.

The verdict recommends - it never merges, approves or pushes anything:

```
REVIEW RESULT: BLOCKING ISSUES FOUND (<n>) | NON-BLOCKING FINDINGS ONLY (<n>)
             | NO FINDINGS - LOOKS CORRECT FOR THE STATED SCOPE
             | CANNOT COMPLETE REVIEW - <what is missing>
```

Say explicitly what was **not** reviewed: files skipped, a layer not opened, a
runtime behaviour not reproducible here. A review that hides its own blind spots
is worse than a short one that names them.

## 7. Mode R hard boundaries

- **No file is modified** - no fix, no formatting, no "while I was in there"
  (HARD RULE 16). Offer the fix as a follow-up Mode A ticket.
- No push, MR / PR creation, merge, approve, comment-posting or remote branch
  change; no `git fetch` / `checkout` / `stash` unless the user asks
  (`git-safety.md`, HARD RULE 1, HARD RULE 9).
- Database read-only, and only when the diff makes a schema question material
  (`database-safety.md`, HARD RULE 2).
- Memory: a review is task output, not reusable knowledge. Usually
  `Memory Delta: NONE`; anything admitted goes through `memory-admission.md`.
- The review document is local-only, never written inside the repository
  (HARD RULE 3).
