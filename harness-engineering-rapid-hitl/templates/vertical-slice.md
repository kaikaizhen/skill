# Vertical Slice

> One user-meaningful end-to-end path. Feedback within 5-20 minutes.
> Rules: `references/vertical-slice-loop.md`.

```text
SLICE — VS-001

Objective:
<what this slice proves, in one sentence>

Path:
<user action> -> <UI/API> -> <application behaviour> -> <persistence> -> <result>

Requirements protected:
MB-00n, BR-00n, HC-00n

Out of scope for this slice:
<what is deliberately not built yet, and why that is safe>

Expected feedback time:
<5-20> minutes
```

## Execution log

| Step | Action | Observed | Result |
|---|---|---|---|
| Implement | <smallest useful change> | | |
| Build | `<command>` | <output summary> | PASS / FAIL |
| Test | `<command>` | <counts, failing names> | PASS / FAIL / NOT_VERIFIED |
| Run / Observe | <flow executed> | <what actually happened> | PASS / FAIL / NOT_VERIFIED |

## On failure

Classify before fixing (`references/failure-classification.md`):

```text
Classification: IMPLEMENTATION_BUG | REQUIREMENT_AMBIGUITY |
                ARCHITECTURE_CONFLICT | ENVIRONMENT_PROBLEM | TEST_PROBLEM
Reasoning: <why this class>
Action: <fix code | stop and ask | options to human | record blocked | fix test>
```

## Slice close-out

- [ ] Builds
- [ ] Runs
- [ ] Protected requirements still hold, with observed evidence
- [ ] Working Model updated with what was learned
- [ ] Any new unknown classified (BLOCKING / SAFE_ASSUMPTION / DEFER)
- [ ] Next slice named, or the round moves to critical verification

```text
Next: <next slice name> | CRITICAL VERIFICATION | BLOCKED — BQ-00n open
```
