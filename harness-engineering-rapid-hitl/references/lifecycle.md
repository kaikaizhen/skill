# Lifecycle

The full cycle this skill runs. The short form in `SKILL.md` is
`UNDERSTAND → QUESTION → COMMIT → BUILD → VERIFY → LEARN`; this is that loop
expanded with the branch that decides whether the human is interrupted.

```text
PROJECT / REQUIREMENT
        |
RAPID UNDERSTANDING            (1-5 min, references/rapid-understanding.md)
        |
WORKING MODEL                  (thin contract, references/working-model.md)
        |
UNCERTAINTY DETECTION
        |
CLASSIFY UNKNOWN               (references/uncertainty-classification.md)
        |
ASK ONLY BLOCKING QUESTIONS    (budget: references/human-question-policy.md)
        |
HUMAN ANSWER
        |
CURRENT EXECUTION CONTRACT     (provisional freeze)
        |
MINIMUM IMPLEMENTATION DECISION
        |
SMALL VERTICAL SLICE           (references/vertical-slice-loop.md)
        |
BUILD / RUN / TEST
        |
OBSERVE
        |
LEARN
        |
UPDATE WORKING MODEL
        |
NEW UNKNOWN?
   +-----------+-----------+
   |                       |
  NO                      YES
   |                       |
Continue          Classify Unknown
                           |
               +-----------+-----------+
               v           v           v
            BLOCKING      SAFE        DEFER
               |           |           |
             Human       Record      Ignore now
               |
               +----------> Continue
```

## Stage contracts

### RAPID UNDERSTANDING
Input: the requirement/source plus the repository as it actually is.
Output: enough model to name a goal, a first slice, and the unknowns.
Hard limit: minutes, not tens of minutes. Stop when you can state the next
slice — not when you feel complete.

### WORKING MODEL
One artifact. Only evidence-backed content. Unknowns live in their own sections,
never inside MUST behaviours.

### UNCERTAINTY DETECTION
Actively look for unknowns rather than waiting to trip over them. The cheapest
moment to notice "ownership is unspecified" is before the first slice.

### CLASSIFY UNKNOWN
Every unknown gets exactly one of `BLOCKING` / `SAFE_ASSUMPTION` / `DEFER`.
An unclassified unknown is a process failure, not a shortcut.

### ASK ONLY BLOCKING QUESTIONS
Batch the initial burst (≤3). During implementation, ≤1 per interruption unless
tightly coupled (≤3). Everything else is recorded, not asked.

### CURRENT EXECUTION CONTRACT
Represents commitment, not truth. Signature: "no blocking unknown is open, so
implementation may proceed under this reading."

### MINIMUM IMPLEMENTATION DECISION
Smallest technical direction that satisfies the contract. Existing project
conventions win by default (`SKILL.md` § Operating Rules 8).

### SMALL VERTICAL SLICE → BUILD/RUN/TEST → OBSERVE
Feedback within 5-20 minutes. Real execution, not reasoning about execution.

### LEARN → UPDATE WORKING MODEL
Add evidence. Observed implementation context is context, not requirement.

### NEW UNKNOWN?
The loop's only exit toward the human. Re-entering `CLASSIFY UNKNOWN` mid-build
is normal and expected — that is the point of the skill.

## Loop exits

| Exit | Condition | Output |
|---|---|---|
| Continue | No blocking unknown; slices remain | Next slice |
| Human loop | Blocking unknown | One question, then resume |
| Final gate | No slices remain, verification reserve reached | `RAPID_DELIVERY_GATE` evaluation |
| Escalation | Task exceeds Rapid HITL scope | Mode warning to human |
| Fail closed | Any fail-closed condition | `INCOMPLETE` / `NEEDS_ATTENTION` |

## Existing-project entry

When entering an existing project mid-flight, the entry question is:

> What is the earliest **blocking delivery gap**?

not

> Which document is missing first?

Inspect → understand current state → find the current delivery goal → detect
existing evidence → detect blocking unknowns → determine the smallest next
slice. Do not regenerate requirements that the project already answers.
