# Correctness Contract

## What this skill does not claim

Fast Mode does **not** guarantee that delivered software is correct. No process
does. Correctness in the strong sense — behavior proven right across all inputs
and all conditions — is not achievable in 90 minutes, and claiming it would be the
most damaging thing this skill could do, because the claim itself would stop
anyone from checking.

## What this skill does claim

> **High-confidence correctness under time constraint.**

Concretely, a delivery satisfies Fast Mode Correctness when all seven hold:

1. **Delivered behavior matches known MUST requirements.**
2. **No unresolved blocking ambiguity was silently guessed.**
3. **Critical business rules have verification evidence.**
4. **Known assumptions are explicit** — labelled `ASSUMPTION`, never phrased as
   requirements.
5. **Known failures are not hidden** — failures appear in the delivery report,
   not only in a file nobody opens.
6. **The project builds and runs in the expected environment** — observed, not
   inferred.
7. **Critical acceptance checks pass** — with real evidence.

Each is checkable by a reader who did not do the work. That is the point: the
claim is not "this is correct", it is "here is exactly what was verified, what was
assumed, and what was not checked."

---

## The Six Risk Mechanisms

| Mechanism | Failure it prevents |
|---|---|
| Source Fidelity | A requirement that came from the implementer, not the source |
| Explicit Assumptions | An assumption that hardened into a requirement unnoticed |
| Blocking Question Handling | A core semantic guessed to save eight minutes |
| Critical Acceptance Checks | "Done" declared without a definition of done |
| Risk-based Verification | The test budget spent on low-risk surfaces |
| Independent / fresh check | "I wrote it" mistaken for "it works" |

None eliminates risk. Together they remove the failure modes that most often turn
a plausible-looking 90-minute delivery into a rejected one.

---

## Fail-Closed Rule

Never output `DONE`, `SUCCESS`, or `PASS` when any of these is true:

- the build was not verified
- a MUST requirement is knowingly incomplete
- a blocking ambiguity is unanswered
- a critical test fails
- a source contradiction is unresolved
- the core flow was never actually executed
- the application fails to start

Output instead:

```
FAST_DELIVERY_GATE = NEEDS_ATTENTION
```
or
```
FAST_DELIVERY_GATE = INCOMPLETE
```

with the reasons named.

**Which one:**

- `NEEDS_ATTENTION` — the delivery works and is usable, but carries a known
  defect, an unanswered blocking question, a `NOT_VERIFIED` critical check, or an
  unresolved source contradiction.
- `INCOMPLETE` — the delivery does not stand on its own: it does not build, does
  not start, the core flow does not work, or a MUST is missing.

When in doubt between the two, choose the more severe. Understating a delivery's
state costs a correction; overstating it costs the reader's ability to trust
anything else in the report.

---

## The Honest Report

Whatever the gate result, the delivery report says, briefly and near the top:

```
What works        (verified, with what evidence)
What is assumed   (ASSUMPTION IDs)
What is not done  (OUT_OF_SCOPE IDs, cut features)
What is not verified (NOT_VERIFIED checks and why)
What is broken    (failures, with what is known about them)
```

A reviewer reading only that block should be able to predict what they will find
when they run the software. If running it would surprise them, the report is
wrong.

**Do not bury a failure in a Known Limitations list at the bottom.** A failed MUST
belongs in the first paragraph.

---

## Why fail-closed matters more in Fast Mode

In a long project, an overstated status gets corrected by the next person to touch
the code. In a 90-minute delivery there is no next person and no next pass: the
report is the last word, and it is usually read by someone deciding whether to
trust the work.

An honest `NEEDS_ATTENTION` with three verified MUSTs and one documented gap is a
better delivery than a `DONE` that is wrong about one of them — because the first
can be acted on and the second cannot.
