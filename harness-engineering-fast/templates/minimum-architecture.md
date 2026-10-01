# Minimum Architecture — Template

Decide only what blocks coding. Budget: ~7 minutes at a 90-minute total.
Rules: `references/minimum-architecture.md`.

May be a section inside the execution contract or `docs/minimum-architecture.md`.

---

```markdown
# Minimum Architecture

Decided at: T+<n>
ARCHITECTURE_FAST_GATE: <not yet run | PASS>

---

## Decisions

*Only the concerns the requirements actually demand. A concern nothing requires is
recorded as N/A — that is a decision, and it is one line.*

| Concern | Decision | Driven by | Why this option |
|---|---|---|---|
| Presentation | <choice / N/A> | MUST-00x | <one line> |
| Backend | | | |
| Persistence | | | |
| Identity | | | |
| Testing strategy | | | |

*Selection order: Requirement Fit > Implementation Speed > Testability >
Simplicity > Reversibility > Extensibility. Requirement Fit is absolute.*

---

## Deliberately Not Introduced

*Only worth listing where the option was genuinely on the table.*

| Not used | Would have needed | Not required by |
|---|---|---|
| <e.g. message queue> | <requirement that would justify it> | any MUST |

---

## Time-constrained Engineering Assumptions

*Where the architecture budget expired before the decision settled.*

```
TCA-001 — <concern>: <chosen option>
Alternatives considered: <list>
Why chosen: <lowest implementation cost satisfying MUST-00x>
Cost accepted: <what this option gives up>
Revisit trigger: <what would make this wrong>
```

*A TCA is a record of a decision made under time pressure. It is not a
recommendation, and it never enters the MUST list.*

---

## Pre-coding Sanity Check

| # | Question | Answer |
|---|---|---|
| 1 | Can every MUST be implemented on this architecture? | |
| 2 | Can the critical acceptance checks be executed against it? | |
| 3 | Is there a runnable path to a working vertical slice? | |
| 4 | Does the environment have what this needs (runtime, package manager, ports, network)? | |

*Question 4 is checked, not assumed. A missing toolchain found at T+40 costs more
than every other risk in this phase.*

---

## Vertical Slice

First slice to build: <the flow>
Path: <UI> -> <application> -> <persistence> -> <result>
Carries: MUST-00x, RULE-00x

---

## Gate

ARCHITECTURE_FAST_GATE = PASS

Coding starts at T+<n>.

*Reopen only for: (1) cannot satisfy a MUST, (2) environment does not support it,
(3) verification proves it wrong, (4) human requirements changed. Not for
elegance.*
```
