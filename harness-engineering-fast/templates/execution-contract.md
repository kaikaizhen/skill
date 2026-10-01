# Execution Contract — Template

Output path: `docs/execution-contract.md` (unless the repository already has an
established structure).

This is the **only** requirement-phase artifact in Fast Mode. Do not create
source-extraction, requirements, context, or decision-inventory documents.

Sections below are required. Delete the instructional italics; keep the headings.

---

```markdown
# Execution Contract

Task: <name>
Source: <path / file / conversation reference>
Time budget: <90 minutes>  |  T+0 = <wall clock>
Status: DRAFT | FROZEN
REQUIREMENT_FAST_GATE: <not yet run | PASS | FAIL>

---

## Goal

<1-3 sentences describing what will be delivered.>

*Only what the source asks for. No added product goals, no inferred purpose,
no "so that users can ..." unless the source says so.*

---

## MUST Requirements

*Only genuinely required behavior. Each traces to a source location or a recorded
human clarification. No general engineering common sense.*

| ID | Requirement | Source |
|---|---|---|
| MUST-001 | <observable behavior> | <section / page / quote fragment> |
| MUST-002 | | |

*A requirement with no traceable source is not a MUST. Move it to Safe
Assumptions or delete it.*

---

## Critical Business Rules

*Rules that constitute a requirement failure if wrong, even when the screen looks
correct. Include only what the source supports.*

*Candidate concerns — check each against the source, record silence as an unknown:
ownership, isolation, persistence, ordering, destructive behavior, state
transitions, authorization boundaries.*

| ID | Rule | Source | Why critical |
|---|---|---|---|
| RULE-001 | | | |

---

## Blocking Ambiguities

*Only unknowns that could make the core implementation wrong. See
`references/ambiguity-classification.md`.*

```
BLOCKING B-001 — <question in one line>
Why it blocks: <which implementation decision cannot be made without the answer>
Interpretations:
  A <interpretation and its implementation consequence>
  B <interpretation and its implementation consequence>
Status: PENDING | RESOLVED (human: <what they said>, <when>) | UNANSWERED (proceeding under <A|B>)
```

*If any entry is PENDING, implementation has not started.
If any entry is UNANSWERED, the final gate cannot be PASS.*

---

## Safe Assumptions

*Not stated by the source; does not change core product behavior; cheap to change;
does not affect any Critical Acceptance Check. All three, or it is not safe.*

```
ASSUMPTION A-001 — <the assumption, stated as a decision you made>
Source: silent | partially states <x>
Why safe: <does not change core behavior> / <cheap to change> / <no acceptance check depends on it>
```

*Never phrase an assumption as a requirement. "The system must ..." is reserved
for MUSTs.*

---

## Out of Scope

*Explicitly not built in the available time. Validated against the SOURCE, not
against convenience.*

```
OUT-001 — <what is not being built>
Source support: required | optional | absent
Reason: <why it is out of scope>
```

*A MUST never appears here. If a MUST cannot be delivered, that is a delivery
shortfall reported at the final gate.*

---

## Critical Acceptance Checks

*What must be verified before claiming completion. Every entry maps to a MUST or a
Critical Business Rule.*

| ID | Check | Protects | How it will be verified |
|---|---|---|---|
| CHECK-001 | <observable outcome> | MUST-001 | unit / integration / API / manual |

*Coverage: every MUST and every RULE appears in the Protects column at least once.
Verify this — it is REQ-CHECK-006.*

---

## Source Contradictions

*Only if found. Otherwise: "None found."*

```
SOURCE CONTRADICTION SC-001
Statement A: <quote + location>
Statement B: <quote + location>
Affected: <requirement>
Status: ESCALATED (pending human) | RESOLVED (human: ...)
```

---

## Change Log

*After Requirement Freeze, every change records why it was permitted.*

| Time | Change | Freeze exception |
|---|---|---|
| T+34 | MUST-005 clarified | human clarification |
```

---

## Notes for the author

- Write it once, in the first 8 minutes. It is a working instrument, not a
  document deliverable.
- IDs matter. Verification, the acceptance record, and the README all cite them.
- Sections with nothing in them say "None" — an empty section and a missing
  section read the same to a fresh reader, and they are not the same thing.
