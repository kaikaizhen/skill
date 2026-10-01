# Learning Update

> Run after every verification. Records **evidence learned**, not new
> requirements. Observed implementation context is context.

```text
LEARNING UPDATE — LU-001

Trigger:
<slice completed | test run | build | runtime observation>

Observed:
<what was actually seen>

Interpretation:
<what this means for the implementation>

Type:
IMPLEMENTATION CONTEXT EVIDENCE | REQUIREMENT EVIDENCE | CONTRADICTION

Contract change:
<which section of the Current Execution Contract is updated, or "none">

New unknown?
none | <unknown> -> BLOCKING / SAFE_ASSUMPTION / DEFER
```

## Example

```text
LEARNING UPDATE — LU-003

Trigger:
Inspected the persistence layer while implementing slice VS-002.

Observed:
The project already uses an ORM with an existing configured context and
migration history.

Interpretation:
Persistence for this feature should follow the existing convention rather than
introduce a second mechanism.

Type:
IMPLEMENTATION CONTEXT EVIDENCE

Contract change:
Current Understanding — added the persistence convention.
(No change to MUST Behaviors: this is not a new requirement.)

New unknown?
none
```

## Rules

- **Evidence only.** "We observed X" is recordable; "therefore the user probably
  wants Y" is not.
- **Context is not requirement.** Discovering how the project persists data does
  not create a requirement to persist anything.
- **A contradiction is not an edit.** If the observation contradicts a MUST
  behaviour or a human clarification, do not quietly update the contract — mark
  `CONTRADICTION` and go to the human.
- **Keep it short.** A few lines per update; this is a loop step, not a report.
