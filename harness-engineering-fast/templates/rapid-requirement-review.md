# Rapid Requirement Review — Template

Run once, against `docs/execution-contract.md`, before coding. Budget: 3-5 min.
Checks are defined in `references/requirement-fast-loop.md`.

May be appended to the execution contract or kept as
`docs/rapid-requirement-review.md`. One or the other — not both.

---

```markdown
# Rapid Requirement Review

Target artifact: docs/execution-contract.md
Ground truth: <source path>
Reviewed at: T+<n>
Independence: SELF_REVIEW | INDEPENDENT (<who / fresh agent>)

*A self-review is not an independent evaluation. Record which one this was.*

---

## Checks

| ID | Check | Result | Notes |
|---|---|---|---|
| REQ-CHECK-001 | Every MUST traces to source or human clarification | PASS/FAIL | |
| REQ-CHECK-002 | No requirement unsupported by source | PASS/FAIL | |
| REQ-CHECK-003 | Blocking ambiguity answered or explicitly stopped | PASS/FAIL | |
| REQ-CHECK-004 | No assumption written as a requirement | PASS/FAIL | |
| REQ-CHECK-005 | Out of Scope contains no MUST | PASS/FAIL | |
| REQ-CHECK-006 | Acceptance checks cover every MUST and RULE | PASS/FAIL | |
| REQ-CHECK-007 | No missing core business rule | PASS/FAIL | non-blocking |

*Every FAIL names the offending item by ID.*

---

## Coverage Map

*REQ-CHECK-006 evidence. Fill it in rather than asserting it.*

| Requirement | Covered by |
|---|---|
| MUST-001 | CHECK-001 |
| RULE-001 | CHECK-003 |

---

## Findings

```
F-01  <check id>  <what is wrong>  <which contract item>
      Action: <what was changed in the contract>
```

*The contract is revised. This review record is not revised to match the
contract.*

---

## Gate

All critical checks (001-006) PASS -> PASS.
Any critical check FAIL -> FAIL, and coding does not start.

REQUIREMENT_FAST_GATE = PASS | FAIL
```

---

## Notes for the author

- On FAIL: fix the contract, then re-run the failed checks and record a second
  result below the first. Do not overwrite the first — the record of what was
  wrong is what shows it was corrected.
- REQ-CHECK-007 FAIL does not block the gate, but the missing rule must reach the
  contract (as a requirement or a classified unknown) before coding starts.
- This review checks the contract *against the source*. It does not re-derive the
  source, and it does not evaluate architecture or implementation.
