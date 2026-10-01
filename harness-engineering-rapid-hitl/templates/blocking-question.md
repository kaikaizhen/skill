# Blocking Question

> One question, answerable in seconds. Budget: ≤3 in the initial burst, ≤1 per
> implementation interruption (≤3 only if tightly coupled).
> Policy: `references/human-question-policy.md`.

```text
BLOCKING QUESTION — BQ-001

Question:
<one sentence; the human should not need to read code to answer>

Why it matters:
<what breaks, and how expensively, if this is guessed wrong>

Evidence:
<what the source says, what it does not say, what the code currently does>

Possible interpretations:

A. <interpretation>
B. <interpretation>
C. <interpretation, or omit>

Implementation impact:

A:
<what gets built, and what it costs to change later>

B:
<...>

C:
<...>

AI Recommendation:
<one option>

Recommendation Reason:
<one or two sentences>

Human Decision Required:
A / B / C / Custom
```

Then **wait**. The recommendation is never self-adopted as the answer.

---

## After the answer

1. Record:

```text
HC-00n
Question: <the question>
Human Answer: <the option chosen, in the human's terms>
Impact: <what changes in the contract and the code>
```

2. Update the Current Execution Contract.
3. Check whether the blocking unknown is resolved.
4. Continue implementation — do **not** rerun the full requirement analysis.

---

## Checklist before sending

- [ ] Is this genuinely BLOCKING (wrong guess changes core behaviour)?
- [ ] Could this be a recorded SAFE_ASSUMPTION instead?
- [ ] Could this be DEFERred until a later slice needs it?
- [ ] Is it answerable with a single letter?
- [ ] Am I within the question budget?
- [ ] Have I stated what I will do with each answer?
