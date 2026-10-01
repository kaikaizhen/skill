# Critical Test Plan — Template

Written before or during verification; results filled in as checks execute.
Rules: `references/risk-based-verification.md`.

Path: `docs/critical-test-plan.md`, or a section of the final acceptance record.

---

```markdown
# Critical Test Plan

Contract: docs/execution-contract.md
Started at: T+<n>

---

## Selection

*Every test answers: what requirement or risk does this protect? A test that
cannot answer it is not a priority test.*

| ID | Check | Protects | Risk category | Type |
|---|---|---|---|---|
| T-001 | <observable outcome> | MUST-001 / RULE-001 | state correctness | unit |
| T-002 | | | isolation | API |
| T-003 | | | persistence | manual |

*Risk ordering: state correctness, persistence, isolation, ownership,
authorization, destructive behavior, failure handling, sorting/filtering,
reload, navigation, API semantics — and only where the requirements involve the
concern.*

---

## Results

*A PASS requires executed evidence. Reading the code is not running the code.*

```
T-001 — <check>
Protects: MUST-001
Method: <command run / request made / steps taken>
Evidence:
  <command output, response body, or observed behavior>
Result: PASS | FAIL | NOT_VERIFIED
```

```
T-002 — <check>
Protects: RULE-001
Method: create item as user A; authenticate as user B; GET /items
Evidence:
  HTTP 200, body: []
Result: PASS
```

```
T-00n — <check>
Result: NOT_VERIFIED
Reason: <what could not be executed and why — no runtime, no credentials, ...>
```

---

## Manual Checks

*Legitimate evidence when recorded with steps and observed output. Unrecorded
manual checks are not evidence.*

| ID | Steps | Observed | Result |
|---|---|---|---|
| MC-001 | | | |

---

## Build / Run Evidence

*Not optional. The fail-closed rule depends on this being real.*

```
Build command: <cmd>
Result: <output summary>

Start command: <cmd>
Result: <started on port X / failed with ...>

Core flow executed: <yes — what was done and observed | no>
```

---

## Failures and Fixes

| ID | Failure | Fix | Re-run result |
|---|---|---|---|
| T-004 | | | |

*A fix without a re-run is not a fix. After fixing, re-run anything the fix could
plausibly have broken — at minimum the core flow.*

---

## Summary

| Result | Count | IDs |
|---|---|---|
| PASS | | |
| FAIL | | |
| NOT_VERIFIED | | |
```
