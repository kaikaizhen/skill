# Risk-based Verification

Budget: **T+65 - T+82** at a 90-minute total, plus the final acceptance window.

Fast Mode does not pursue maximum test coverage. It pursues **highest-risk
requirement coverage**: the smallest set of executed checks that would catch the
failures which actually reject the delivery.

---

## Test Selection Rule

Every critical test must answer, in one line:

> **What requirement or risk does this test protect?**

If it cannot be answered, the test is not a priority. Delete it and spend the
minutes on one that can.

This single rule does most of the work. It removes tests written because a file
existed, because a function looked testable, or because coverage felt low, and it
keeps tests tied to the contract.

---

## Risk Ordering

Verify in this order, and only where the requirements involve the concern:

1. **State correctness** — the data ends up in the state the rules require
2. **Persistence** — state survives whatever the source says it must survive
3. **Actor / user isolation** — one actor cannot see another's data
4. **Ownership** — the right actor is recorded as owner, and it does not drift
5. **Authorization boundary** — permitted actions permitted, others refused
6. **Destructive / reversal behavior** — delete, cancel, undo behave as specified
7. **Failure handling** — the specified failure paths behave as specified
8. **Sorting / filtering / pagination** — only if required
9. **Reload behavior** — the app recovers its state after reload/restart
10. **Critical navigation** — the core paths are reachable
11. **Core API semantics** — status codes, shapes, idempotency as specified

Items 3, 4, 5, and 6 are the classic silent failures: the UI looks perfect and the
delivery is wrong. They come before anything cosmetic.

**Only test what the requirements involve.** A single-user tool has no isolation
risk; testing it burns budget and proves nothing.

---

## Verification Types

Choose the cheapest credible instrument per check:

| Type | Good for | Cost |
|---|---|---|
| Unit test | Pure business rules, calculations, validators | Low |
| Integration test | Persistence, repository behavior, cross-layer state | Medium |
| API test (curl / HTTP client) | Endpoint semantics, status codes, auth boundary | Low |
| UI / E2E smoke test | One core flow end to end | High |
| Build check | Compiles / typechecks / lints | Very low |
| Manual acceptance check | Anything above, when automating costs more than it returns | Low, but must be recorded |

**Do not build heavy test infrastructure.** Standing up an E2E framework, fixture
factories, seeded databases, or CI configuration inside a 90-minute budget usually
consumes the entire verification reserve and verifies nothing. If the framework is
already configured in the repository, use it. If it is not, prefer API tests and
recorded manual checks.

**Manual checks are legitimate evidence** when recorded properly:

```
MC-002 — User B cannot see User A's items.
Steps: create item as A; log in as B; open list.
Observed: list empty; API returned 200 with [].
Result: PASS
```

An unrecorded manual check is not evidence. Steps + observed output + result, or
it did not happen.

---

## No Fake Verification

Prohibited:

> "The code looks correct, so this test passes."

A `PASS` requires real evidence of one of these:

- a command that was executed, with its output
- a test run, with its result
- an API response that was received
- application behavior that was observed
- an equivalent verifiable output

Where the environment cannot execute the check — no runtime, no network, no
credentials, no browser — mark it:

```
NOT_VERIFIED — <what could not be executed and why>
```

`NOT_VERIFIED` is an honest result. A fabricated `PASS` is not, and it is worse
than no test at all: it removes the reader's ability to distinguish what was
checked from what was assumed. (Full harness L-002: an overstated verification
claim is more damaging than an acknowledged limitation.)

**Reading the code is not running the code.** Static reasoning may inform where to
look; it never produces a PASS.

---

## Failure Rules

| What failed | Response |
|---|---|
| Critical Acceptance Check | Fix first, before anything else |
| MUST requirement | The delivery is not complete — say so at the gate |
| Build | Not complete. No exceptions. |
| Application will not start | Not complete. No exceptions. |
| Optional feature | Fix if time allows; otherwise record a Known Limitation |
| Polish / cosmetic | Record as Known Limitation |

**A Known Limitation is not a place to hide a MUST.** A failed MUST is reported as
a failed MUST, at the top of the delivery report, in plain words.

---

## Fixing Under Time Pressure

When a critical check fails at T+75:

1. Fix the smallest thing that makes the check pass.
2. **Re-run the check.** A fix without a re-run is not a fix.
3. Re-run any check the fix could plausibly have broken — at minimum, the core
   flow.
4. If the fix is not converging within a few minutes, stop, revert to the last
   working state, and record the failure honestly. A working delivery with one
   documented failure beats a broken delivery with an attempted fix in flight.

Step 4 is the one people skip. Watch the clock while debugging.

---

## Recording

Use `templates/critical-test-plan.md` before execution (it can be written during
implementation gaps) and record the results in it as they run. Roll the results up
into `templates/final-acceptance.md`.

Each check carries: ID, the requirement or risk it protects, the method, the
evidence, and the result (`PASS` / `FAIL` / `NOT_VERIFIED`).
