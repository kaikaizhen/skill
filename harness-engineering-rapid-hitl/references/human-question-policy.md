# Human Question Policy

The human is a **fast decision maker**, not a requirement author. Their time is
the scarcest resource in the loop; protect it while refusing to guess.

## Threshold

Ask only when:

```text
cost(wrong assumption)  >  cost(human interruption)
```

`cost(wrong assumption)` is high when the mistake reaches user-visible
behaviour, data, permissions, or acceptance criteria — and when discovering it
late means rework rather than a rename.

`cost(human interruption)` is real: it stops their work, and it stops yours.
It is not infinite: one 20-second multiple-choice question is far cheaper than
50 minutes of building the wrong semantics.

## Budget

| Moment | Maximum |
|---|---|
| Initial question burst | **3** blocking questions |
| Each implementation interruption | **1** new blocking question |
| Coupled interruption exception | up to **3**, only if they must be answered together |

Prohibited: dumping 10-20 requirement questions on the human, asking for a
requirements document, or asking open-ended design essays.

If more than 3 genuinely blocking unknowns exist at the start, that is a signal
in itself: ask the 3 that unblock the first slices, defer the rest, and consider
whether the task is beyond Rapid HITL (`SKILL.md` § Escalation).

## Question form

Prefer **fast multiple choice**. Template:
`../templates/blocking-question.md`.

```text
BLOCKING QUESTION — BQ-001

Question:
<one sentence, answerable without reading code>

Why it matters:
<what breaks if this is guessed wrong>

Evidence:
<what the source/code does and does not say>

Possible interpretations:
A. ...
B. ...
C. ...

Implementation impact:
A: ...
B: ...
C: ...

AI Recommendation:
<one option>

Recommendation Reason:
<one or two sentences>

Human Decision Required: A / B / C / Custom
```

Then **wait** for the human.

## Recommendation rule

`AI Recommendation != Human Decision`.

For a BLOCKING question, the recommendation may never be self-adopted as the
answer — not after a pause, not under time pressure, not because the human is
slow to reply. If the human is unreachable, the correct output is
`NEEDS_ATTENTION` with the open question, not a quiet choice.

The recommendation still has value: it makes the answer one keystroke.

## After the answer

Do **not** rerun requirement analysis. Do exactly:

1. Record it as `HC-nnn` (question, answer, impact).
2. Update the Current Execution Contract.
3. Check whether the blocking unknown is now resolved.
4. Continue implementation.

The clarification is now **current execution authority** until a newer human
clarification or source evidence supersedes it. Implementing something other
than what the human chose is silent contract drift — see
`failure-classification.md` and `correctness-contract.md`.

## Good vs bad questions

| Bad | Good |
|---|---|
| "Please describe your ideal system architecture." | "Should deleting a record remove it, or mark it inactive? A / B" |
| "What are all the requirements for this feature?" | "Can a user open another user's item: yes, read-only, or no?" |
| "Do you have any preferences about the UI?" | (don't ask — safe assumption, record it) |
| Ten numbered questions at once | The one question that blocks the next slice |
