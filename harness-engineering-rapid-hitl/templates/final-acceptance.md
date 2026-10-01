# RAPID_DELIVERY_GATE — Final Acceptance

> Evaluate every check with evidence. `PASS` only when every critical check
> passes. Fail-closed rules: `references/correctness-contract.md`.

| ID | Check | Critical | Evidence | Result |
|---|---|---|---|---|
| FINAL-001 | All known MUST behaviors implemented | yes | <MB list + where> | |
| FINAL-002 | No unresolved Blocking Question | yes | <open BQ list, or none> | |
| FINAL-003 | Critical Business Rules verified | yes | <CT results> | |
| FINAL-004 | Project builds | yes | <build command + output> | |
| FINAL-005 | Core application flow actually executed | yes | <what was run, what was seen> | |
| FINAL-006 | Critical Tests actually executed | yes | <test command + counts> | |
| FINAL-007 | Known Safe Assumptions documented | yes | <ASM list> | |
| FINAL-008 | Known limitations documented | yes | <limitations section> | |
| FINAL-009 | No Critical Test currently failing | yes | <latest run> | |
| FINAL-010 | No Human Clarification silently contradicted | yes | <HC vs implementation review> | |

Result values: `PASS` / `FAIL` / `NOT_VERIFIED` / `ENVIRONMENT_BLOCKED`.

```text
RAPID_DELIVERY_GATE: PASS | INCOMPLETE | NEEDS_ATTENTION
```

`PASS` requires every critical check to be `PASS` **with executed evidence**.
`NOT_VERIFIED` is not a pass.

---

## Fail closed

Any of the following forces `INCOMPLETE` or `NEEDS_ATTENTION` — never `DONE`,
`SUCCESS`, `COMPLETE`, or `RAPID_DELIVERY_GATE = PASS`:

- [ ] a blocking question is unresolved
- [ ] the build fails
- [ ] the core flow was never executed
- [ ] a MUST requirement is missing
- [ ] a critical test fails
- [ ] an unresolved source contradiction exists
- [ ] a human clarification is contradicted
- [ ] a required runtime is unavailable and no valid verification exists

```text
Reasons (if not PASS):
- <reason, with evidence>
```

---

## Delivery summary

**Delivered:** <what works, with the evidence that shows it>

**Not delivered / cut for time:** <named explicitly>

**Safe assumptions a reviewer should sanity-check:** <ASM list>

**Deferred questions still open:** <DQ list>

**Known limitations:** <what a user or reviewer should know>

Do not describe an assumption as a requirement in this summary, and do not
describe an intended behaviour as an observed one.
