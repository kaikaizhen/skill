# Deployment Report

**Status:** DONE | INCOMPLETE | BLOCKED (gate) | FAILED
<!-- DONE only when every applicable generation-time check is PASS. -->

**Mode / scope:** <Generate (full) | Extend (QA) | ...>
**Git:** changes left in the working tree - nothing committed, pushed or deployed.

## Changed files

| File | Change |
|---|---|

## Validation - generation time (run)

| Check | Command | Result | Evidence / reason |
|---|---|---|---|
| | | PASS / FAIL / NOT RUN | |

## Validation - deployment time (in pipeline / runbook, not run)

| Where | Check |
|---|---|

## Manual setup

<!-- Everything the user must do before the pipeline works. Names only, never values. -->

| What | Where | Environments | Purpose |
|---|---|---|---|

## Pipeline flow

```text
<trigger> -> <build/test> -> <package: artifact:<sha>> -> <env> (auto) -> <env> (manual) ...
```

## To decommission after cutover

<!-- Migration only (decision-rules.md §1.1): existing delivery files kept in place.
     Removing them is a separate explicit request. Otherwise "none". -->

## Rollback runbook

1. **See what runs now:** `<command>`
2. **Return to the previous version:** `<command>` (or re-run deploy job of commit `<sha>`)
3. **Verify:** `<command>`
4. **Not undone by rollback:** <schema migrations / side effects / none>

## Open items

<!-- Remaining Unknowns, held-back parts, Findings not fixed, suggestions (e.g. dependency audit). -->
