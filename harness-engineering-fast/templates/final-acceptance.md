# Final Acceptance — Template

Run in the last window (T+82 - T+90 at a 90-minute total). Produces the terminal
gate line and the honest report. Rules: `references/correctness-contract.md`.

Path: `docs/final-acceptance.md`, and the report block is repeated to the user.

---

```markdown
# Final Acceptance

Contract: docs/execution-contract.md
Completed at: T+<n>

---

## Gate Checks

| ID | Check | Result | Evidence |
|---|---|---|---|
| FINAL-001 | Project builds and runs | PASS/FAIL | <command + output> |
| FINAL-002 | Core happy path works | PASS/FAIL | <what was executed and observed> |
| FINAL-003 | Critical business rules verified | PASS/FAIL | <test IDs> |
| FINAL-004 | No known MUST requirement intentionally omitted | PASS/FAIL | <MUST coverage> |
| FINAL-005 | Blocking ambiguities resolved | PASS/FAIL | <B-00x status> |
| FINAL-006 | Safe assumptions documented | PASS/FAIL | <A-00x> |
| FINAL-007 | Known limitations explicit | PASS/FAIL | <list> |
| FINAL-008 | Critical verification evidence exists | PASS/FAIL | <plan path> |

*FINAL-001 and FINAL-002 require executed evidence. An inferred build is a FAIL.*

---

## MUST Coverage

| Requirement | Implemented | Verified by | Result |
|---|---|---|---|
| MUST-001 | yes/no | T-001 | PASS/FAIL/NOT_VERIFIED |

*Every MUST from the contract appears. A missing row is a gap, not an omission.*

---

## Gate

All critical checks PASS -> PASS.
Any of: build unverified, MUST knowingly incomplete, blocking ambiguity
unanswered, critical test FAIL, source contradiction unresolved, core flow never
executed, application does not start -> NEEDS_ATTENTION or INCOMPLETE.

FAST_DELIVERY_GATE = PASS | NEEDS_ATTENTION | INCOMPLETE

Reasons (if not PASS):
- <named reason>

*NEEDS_ATTENTION: works and is usable, carries a known defect or unanswered
question. INCOMPLETE: does not build, does not start, core flow broken, or a MUST
is missing. When in doubt, choose the more severe.*

---

## Delivery Report

*Repeat this block to the user. A reviewer reading only this should be able to
predict what they will find when they run the software.*

```
FAST_DELIVERY_GATE = <result>

What works
  <verified behavior, with what evidence>

What is broken
  <failures — a failed MUST goes here, not in Known Limitations>

What is assumed
  A-001 <...>

What is not done
  OUT-001 <...>
  Cut under time pressure: <...>

What is not verified
  T-00n <what and why>
```

---

## Known Limitations

*Optional-feature failures and accepted cuts. Never a failed MUST.*

| ID | Limitation | Impact |
|---|---|---|

---

## README Checklist

| Item | Done |
|---|---|
| How to install / run | |
| What was built (against the contract) | |
| Assumptions (A-00x) | |
| Known limitations | |
| What was not verified | |
| Unanswered blocking questions, if any | |
```
