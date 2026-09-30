# Git Safety

**Highest priority hard rule. Never overridden, never negotiated.**

The skill's end point is a **LOCAL COMMIT**. Then it stops.

---

## Allowed (local only)

```
git status
git diff
git diff --cached
git log
git show
git branch
git fetch origin <branch>     # read-only on the remote; updates local refs only
git switch
git checkout
git checkout -b
git add <specific paths>
git commit
```

`git add <specific paths>` is allowed after Approval Gate #1, to stage the ticket's
files so `git diff --cached` can be reviewed before asking for Approval Gate #2. Never
`git add .` or `git add -A`. `git commit` is allowed **only after Approval Gate #2**.

## Forbidden - always

```
git push
git push --force
git push --force-with-lease
git push --set-upstream
gh pr create        /  gh pr merge
glab mr create      /  glab mr merge
any MR / PR creation
any remote merge
any remote branch creation, modification or deletion
git merge develop / main / master
committing directly onto develop / main / master
git remote set-url / any remote reconfiguration
```

If the user asks for a push, MR, PR or merge: explain that this skill stops at
the local commit and that they run those commands themselves. Do not offer a
workaround.

## Local Destructive - requires explicit approval

These never touch the remote, but they can silently destroy the user's
uncommitted or unmerged work:

```
git reset --hard
git clean -f
git clean -fd
git checkout -- <file>
git restore <file>
git restore .
git stash drop
git stash clear
git branch -D
```

The normal workflow never needs them. If one seems necessary, stop and ask:

```
LOCAL DESTRUCTIVE GIT APPROVAL REQUIRED

Command:
Affected files / branch:
What will be lost:
Why it is needed:
Safer alternative:

Awaiting explicit approval.
```

Exception: `git restore --staged <path>` only unstages and loses nothing; it is
allowed (e.g. to unstage a file staged by mistake).

---

## Branch

After Approval Gate #1:

Branch convention priority - use the first one that applies:

```
1. repository's own current rule file, read live
   (e.g. .claude/skills/<repo-rule-skill>/SKILL.md, CLAUDE.md, AGENTS.md)
2. repository-specific CONFIRMED memory        (workspace/memory/repositories/<Repo>/patterns.md)
3. recent repository history                   (git branch -r / merged branch names)
4. organization convention                          (workspace/memory/global/development-workflow.md)
5. fallback: feature/[issue-number]
```

`live repository rule > memory > history > organization convention > fallback`.
Level 1 always wins over level 2 when both exist and disagree: a repository's
own rule file can change after memory was last written, so a CONFIRMED memory
summary never overrides what the live file says today. Memory (level 2) is
what you use when no rule file exists in the repository, or as a fast preview
before the live read at branch/commit time confirms it.

Do **not** ask the user on every ticket. Ask only when the evidence genuinely
conflicts at the same priority level and cannot be decided (e.g. the repository's
own rule file and its recent history disagree). State the chosen branch name and
which priority level it came from in the Approval Gate #1 plan.

If the repository contains its own branch / commit rule file (for example
`.claude/skills/<repo-rule-skill>/SKILL.md` in a repository), **that file
is level 1 and the primary source** for the branch base, branch name and commit
message. Read the current file at branch / commit time; it overrides the summary
in memory. See "Repository Convention Files" below for the parts that stay forbidden.

Example with no repository convention and no usable history:

```
git checkout -b feature/T12345
```

Never work directly on `develop`, `main` or `master`.

---

## Commit Message Format

Same 5-level priority as the branch name - use the first one that applies:

```
1. repository's own current rule file, read live
   (e.g. .claude/skills/<repo-rule-skill>/SKILL.md)
2. repository-specific CONFIRMED memory  (workspace/memory/repositories/<Repo>/patterns.md)
3. recent repository history             (git log --no-merges)
4. organization convention                    (workspace/memory/global/development-workflow.md)
5. fallback format                       (below)
```

Ask only when evidence at the same level genuinely conflicts. Show the proposed
message and its source level at Approval Gate #2.

Fallback format:

```
[type] [ticket] short title or main change
Bundle: <planning ticket>
```

Example:

```
[fix] [T12345] talent shard selection uses userId last digit
Bundle: T12000
```

`type` follows the organization's vocabulary (`fix`, `feat`, `refactor`, `perf`,
`migration`, ...). Omit the `Bundle:` line only when the ticket has no planning
ticket.

---

## Repository Convention Files

A repository rule file (e.g. a repo-local branch/commit skill) decides **format**:
branch base, branch name, commit message shape, footers. It never widens what this
skill may do:

| Step in the repository rule file | Under this skill |
|---|---|
| `git status` / `git diff` checks, `git fetch origin main`, `git checkout -b <name> origin/main` | Allowed (after Approval Gate #1) |
| Commit message format and footers | Followed (commit only after Approval Gate #2) |
| Read-only ticket lookups via the workspace's ticket CLI | Allowed |
| Creating / changing external records in that system | **Explicit user approval required each time** (outward-facing action) |
| `git push`, `glab mr create`, any MR / PR / merge | **Forbidden** - the user runs these |
| Login steps the user must do | Ask the user; never attempt |

If the rule file cannot supply required input (tool missing, not logged in, card
not found), ask the user for it instead of guessing - as the rule file itself says.

When the workspace declares a ticket-system CLI, its full command reference (read
vs. write classification, output shape, and how it feeds Requirement Understanding
as well as branch/commit) lives with that declaration in `workspace/PROFILE.md`.

---

## Skill Documents Are Local Only

Everything this skill generates is local and never enters git:

memory, issue analysis, requirement analysis, mermaid, root cause, pseudocode,
plans, architecture notes, DB / Redis / OpenSearch notes, unknowns, corrections,
temporary notes, acceptance-criteria documents (`<Ticket>驗收標準.md`) and skill
retrospectives (`<Ticket>skill待優化項目.md`).

Rules:

1. None of these documents are ever written inside the repository. Memory lives in
   `<skill>/workspace/memory/`; issue analyses, acceptance criteria, retrospectives and
   scratch notes in `<workspace>/issue/<RepoName>/` (SKILL.md -> HARD RULE 3).
2. Never edit the repository's `.gitignore` or `.git/info/exclude` for the skill.
3. Before every commit, run `git status` and `git diff --cached` and confirm only
   ticket-related files are staged.
4. Prefer `git add <specific files>` over `git add .` / `git add -A`.

If a skill document is ever found inside the repository (e.g. a leftover
`.company-skill/` from the upstream installer), do not stage it; if it is already
staged, unstage it before committing:

```
git restore --staged <path>
```

---

## Pre-Commit Checklist

```
[ ] Approval Gate #2 explicitly approved by the user
[ ] Build actually ran: PASS (or FAILED / NOT RUN reported honestly, and the
    change reported as VERIFICATION INCOMPLETE rather than complete)
[ ] Related tests run and reported, with the filter used and the counts
    (related set, not the whole suite; pre-existing baseline failures listed
    separately and not treated as this change's)
[ ] Existing tests preserved - none deleted, disabled or weakened
[ ] git status reviewed
[ ] git diff --cached reviewed
[ ] no skill document (memory / issue analysis / acceptance criteria / notes)
    inside the repository or staged
[ ] .gitignore and .git/info/exclude untouched by the skill
[ ] no local destructive git command was run without approval
[ ] only ticket-related files staged (no scope creep)
[ ] commit message matches the format
```

After the commit: report the commit hash and **STOP**.
